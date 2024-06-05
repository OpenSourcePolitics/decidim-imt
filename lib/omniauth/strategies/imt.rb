# frozen_string_literal: true

require "omniauth-saml"

module OmniAuth
  module Strategies
    class IMT < OmniAuth::Strategies::SAML
      option :name, :imt

      option :sp_entity_id, "decidim-imt"

      option :idp_entity_selector_url

      option :request_attribute_email, "email"
      option :request_attribute_name, "name"
      option :request_attribute_first_name, "first_name"
      option :request_attribute_last_name, "last_name"
      option :request_attribute_nickname, "username"

      info do
        found_attributes = options.attribute_statements.map do |key, values|
          attribute = find_attribute_by(values)
          [key, attribute]
        end

        hash_attributes = found_attributes.to_h

        hash_attributes["uid"] = uid

        hash_attributes["name"] = "#{hash_attributes["first_name"]} #{hash_attributes["last_name"]}"
        ## Don't fallback on uid to force the sign up form
        # hash_attributes["name"] = uid.split("@").first if hash_attributes["name"].blank?

        hash_attributes
      end

      def on_setup_path?
        on_path?(setup_path)
      end

      def skip_setup
        @skip_setup = true
      end

      def redirect_to_entity_selector
        Rails.logger.debug "Redirecting to entity selector URL : #{entity_selector_url}"
        redirect(entity_selector_url)
      end

      def entity_selector_url
        if options[:idp_entity_selector_url].present?
          uri = URI.parse(options[:idp_entity_selector_url])
          uri_query_params = CGI.parse(uri.query || "")
          uri_query_params.merge!({
            entityID: options[:sp_entity_id],
            return: entity_selector_callback_url
          })
          uri.query = uri_query_params.to_query
          uri.to_s
        end
      end

      def entity_selector_callback_url
        uri = URI.parse(full_host + setup_path)
        uri.query = {
          setup_action: "idp_entity_selector_url",
          state: new_state
        }.to_query
        uri.to_s
      end

      def idp_entity_setup
        invalid_state = request.params["state"].to_s.empty? || request.params["state"] != stored_state
        raise CallbackError, error: :csrf_detected, reason: "Invalid \"state\" parameter" if invalid_state

        if request.params["entityID"].present? && request.params["entityID"].start_with?("http")
          options[:idp_metadata_url] = request.params["entityID"]
          @skip_idp_entity_setup = true
          Rails.logger.debug "(#{name}) IDP entity setup with new metadata URL #{options["idp_metadata_url"]}"
        end
      end

      def new_state
        session["omniauth.state"] = SecureRandom.hex(16)
      end

      def stored_state
        session.delete("omniauth.state")
      end

      def setup_phase
        super unless @skip_setup
      end

      def request_phase
        if options[:idp_entity_selector_url].present? && !@skip_idp_entity_setup
          redirect_to_entity_selector
        else
          authn_request = OneLogin::RubySaml::Authrequest.new

          with_settings do |settings|
            return  authn_request.create(settings, additional_params_for_authn_request)
          end
        end
      end

      def callback_call
        Rails.logger.debug "(#{name}) custom callback_call"
        Rails.logger.debug session.keys
        Rails.logger.debug session["omniauth.idp_metadata_url"]
        options[:idp_metadata_url] = session.delete("omniauth.idp_metadata_url")
        super
      end



      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri

        def initialize(data)
          super
          self.error = data[:error]
          self.error_reason = data[:reason]
          self.error_uri = data[:uri]
        end

        def message
          [error, error_reason, error_uri].compact.join(" | ")
        end
      end

    end
  end
end

OmniAuth.config.add_camelization "imt", "IMT"
