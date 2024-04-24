# frozen_string_literal: true

require "omniauth-saml"

module OmniAuth
  module Strategies
    class IMT < OmniAuth::Strategies::SAML
      option :name, :imt

      option :sp_entity_id, "decidim-imt"
      option :protocol_binding, "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"

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
        hash_attributes["name"] = uid.split("@").first if hash_attributes["name"].blank?

        hash_attributes
      end
    end
  end
end

OmniAuth.config.add_camelization "imt", "IMT"
