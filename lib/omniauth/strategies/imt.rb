# frozen_string_literal: true

require "omniauth-saml"

module OmniAuth
  module Strategies
    class IMT < OmniAuth::Strategies::SAML
      option :name, :imt
      option :protocol_binding, "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"

      option :idp_cert_fingerprint_algorithm, XMLSecurity::Document::SHA256
      option :security,
             digest_method: XMLSecurity::Document::SHA256,
             signature_method: XMLSecurity::Document::RSA_SHA256
    end
  end
end

OmniAuth.config.add_camelization "imt", "IMT"