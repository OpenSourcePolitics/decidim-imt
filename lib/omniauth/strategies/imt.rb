# frozen_string_literal: true

require "omniauth-saml"

module OmniAuth
  module Strategies
    class IMT < OmniAuth::Strategies::SAML
      option :name, :imt

      option :sp_entity_id, "decidim-imt"

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

      def new_state
        session["omniauth.state"] = SecureRandom.hex(16)
      end

      def stored_state
        session.delete("omniauth.state")
      end
    end
  end
end

OmniAuth.config.add_camelization "imt", "IMT"
