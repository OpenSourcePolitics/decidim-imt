# frozen_string_literal: true

require "active_support/concern"

module OmniauthRegistrationFormExtends
  extend ActiveSupport::Concern

  included do
    attribute :verified_email, String
  end
end

Decidim::OmniauthRegistrationForm.include(OmniauthRegistrationFormExtends)
