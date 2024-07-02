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

    def after_sign_in_path_for(user)
      if user.present? && user.blocked?
        check_user_block_status(user)
      elsif !skip_first_login_authorization? && (!pending_redirect?(user) && first_login_and_not_authorized?(user))
        decidim_verifications.authorizations_path
      else
        super
      end
    end
  end
end

Decidim::Devise::OmniauthRegistrationsController.class_eval do
  include(OmniauthRegistrationsControllerExtends)
end
