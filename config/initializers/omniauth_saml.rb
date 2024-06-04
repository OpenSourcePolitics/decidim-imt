# frozen_string_literal: true

require "omniauth/strategies/imt"

if Rails.application.secrets.dig(:omniauth, :imt).present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    OmniAuth.config.logger = Rails.logger
    provider(
      OmniAuth::Strategies::IMT,
      setup: lambda { |env|
        request = Rack::Request.new(env)
        organization = Decidim::Organization.find_by(host: request.host)
        provider_config = organization.enabled_omniauth_providers[:imt]

        if provider_config[:idp_metadata_url].present?
          idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
          idp_metadata = idp_metadata_parser.parse_remote_to_hash("")

          Rails.logger.debug "++++++++++ idp_metadata  ++++++++++"
          idp_metadata.each do |k,v|
            Rails.logger.debug "------------------------------------"
            Rails.logger.debug k
            Rails.logger.debug v
          end
          Rails.logger.debug "+++++++++++++++++++++++++++++++++++"

          env["omniauth.strategy"].options.merge!(idp_metadata)
        end

        %w(
          idp_metadata_url
          issuer
          assertion_consumer_service_url
          sp_entity_id
          idp_sso_service_url
          idp_slo_service_url
          idp_cert
          name_identifier_format
          attribute_service_name
          uid_attribute
          protocol_binding
          idp_security_digest_method
          idp_security_signature_method
          request_attribute_email
          request_attribute_name
          request_attribute_first_name
          request_attribute_last_name
          request_attribute_nickname
        ).map(&:to_sym).each do |key|
          env["omniauth.strategy"].options[key] = provider_config[key] if provider_config[key].present?
        end

        env["omniauth.strategy"].options[:request_attributes] = [
          { name: env["omniauth.strategy"].options[:request_attribute_email], name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Email address" },
          { name: env["omniauth.strategy"].options[:request_attribute_name], name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Full name" },
          { name: env["omniauth.strategy"].options[:request_attribute_first_name], name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "First name" },
          { name: env["omniauth.strategy"].options[:request_attribute_last_name], name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Given name" },
          { name: env["omniauth.strategy"].options[:request_attribute_nickname], name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendly_name: "Nickname" }
        ]

        env["omniauth.strategy"].options[:attribute_statements] = {
          name: ["name", env["omniauth.strategy"].options[:request_attribute_name]].uniq,
          email: ["email", "mail", env["omniauth.strategy"].options[:request_attribute_email]].uniq,
          first_name: ["first_name", "firstname", "firstName", env["omniauth.strategy"].options[:request_attribute_first_name]].uniq,
          last_name: ["last_name", "lastname", "lastName", env["omniauth.strategy"].options[:request_attribute_last_name]].uniq,
          nickname: ["username", "nickname", "handle", env["omniauth.strategy"].options[:request_attribute_nickname]].uniq
        }

        # env["omniauth.strategy"].options[:certificate] = provider_config[:idp_cert] if provider_config[:idp_cert].present?

        Rails.logger.debug "++++++++++ env[\"omniauth.strategy\"].options  ++++++++++"
        env["omniauth.strategy"].options.each do |k,v|
          Rails.logger.debug "------------------------------------"
          Rails.logger.debug k
          Rails.logger.debug v
        end
        Rails.logger.debug "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      }
    )
  end
end

ActiveSupport::Notifications.subscribe "decidim.user.omniauth_registration" do |_name, data|
  if %(imt).include?(data[:provider])
    user = Decidim::User.find(data[:user_id])

    # Array with only one element are converted to singleton
    raw_info = data[:raw_data][:extra]["raw_info"].to_h.transform_values do |v|
      if v.is_a?(Array) && v.size == 1
        v.first
      else
        v
      end
    end.compact

    user.extended_data.merge!({ data[:provider] => raw_info })
    user.save!(validate: false, touch: false)
  end
end
