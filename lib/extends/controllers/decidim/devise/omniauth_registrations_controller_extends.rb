# frozen_string_literal: true

module OmniauthRegistrationsControllerExtends
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token, only: [:imt, :failure]
    skip_after_action :verify_same_origin_request, only: [:imt, :failure]

    def verified_email
      @verified_email ||= (oauth_data.dig(:info, :email) || params.dig(:user, :verified_email))
      @form.verified_email ||= @verified_email
    end
  end
end

Decidim::Devise::OmniauthRegistrationsController.class_eval do
  include(OmniauthRegistrationsControllerExtends)
end
