# frozen_string_literal: true

module Decidim
  module Devise
    class CustomOmniauthRegistrationsController < ::Decidim::Devise::OmniauthRegistrationsController
      # rubocop:disable Rails/LexicallyScopedActionFilter
      skip_before_action :verify_authenticity_token, only: [:imt]
      skip_after_action :verify_same_origin_request, only: [:imt]
      # rubocop:enable Rails/LexicallyScopedActionFilter
    end
  end
end