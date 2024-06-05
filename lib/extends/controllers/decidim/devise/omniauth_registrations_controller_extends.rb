# frozen_string_literal: true

module OmniauthRegistrationsControllerExtends
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token, only: [:imt, :failure]
    skip_after_action :verify_same_origin_request, only: [:imt, :failure]
  end

  def setup
    Rails.logger.debug "Decidim::Devise::OmniauthRegistrationsController#setup"
    if request.env["omniauth.strategy"].on_setup_path? && request.params["setup_action"] == "idp_entity_selector_url"
      Rails.logger.debug "(#{request.env["omniauth.strategy"].name}) Setup phase redirected to Request call"
      request.env["omniauth.strategy"].skip_setup
      redirect_to request.env["omniauth.strategy"].request_call
    end
  end
end

Decidim::Devise::OmniauthRegistrationsController.class_eval do
  include(OmniauthRegistrationsControllerExtends)
end
