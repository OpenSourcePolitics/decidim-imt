# frozen_string_literal: true

module OmniauthRegistrationsControllerExtends
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token, only: [:imt]
    skip_after_action :verify_same_origin_request, only: [:imt]
  end
end

Decidim::Devise::OmniauthRegistrationsController.class_eval do
  include(OmniauthRegistrationsControllerExtends)
end
