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
        env["omniauth.strategy"].options[:issuer] = provider_config[:issuer]
        env["omniauth.strategy"].options[:assertion_consumer_service_url] = provider_config[:assertion_consumer_service_url]
        env["omniauth.strategy"].options[:sp_entity_id] = provider_config[:sp_entity_id]
        env["omniauth.strategy"].options[:idp_sso_service_url] = provider_config[:idp_sso_service_url]
        env["omniauth.strategy"].options[:idp_slo_service_url] = provider_config[:idp_slo_service_url]
        env["omniauth.strategy"].options[:idp_cert] = provider_config[:idp_cert]
        env["omniauth.strategy"].options[:name_identifier_format] = provider_config[:name_identifier_format]
        env["omniauth.strategy"].options[:attribute_service_name] = provider_config[:attribute_service_name]
      }
      # ,
      # request_attributes: [
      #   { :name => 'email', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Email address' },
      #   { :name => 'name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Full name' },
      #   { :name => 'first_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Given name' },
      #   { :name => 'last_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Family name' }
      # ],
      # attribute_statements: {
      #   name: ["name"],
      #   email: ["email", "mail"],
      #   first_name: ["first_name", "firstname", "firstName"],
      #   last_name: ["last_name", "lastname", "lastName"]
      # }
    )
  end
end
