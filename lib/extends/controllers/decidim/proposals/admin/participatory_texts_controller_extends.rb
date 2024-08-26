# frozen_string_literal: true

require "active_support/concern"

module ParticipatoryTextsControllerExtends
  extend ActiveSupport::Concern
  included do
    def discard
      enforce_permission_to :manage, :participatory_texts

      if params[:proposal_id]
        locale = params[:locale] || "en"
        Decidim::Proposals::Admin::DiscardParticipatoryText.call(current_component, params[:proposal_id].to_i, locale) do
          on(:ok) do
            flash[:notice] = "#{params[:level]} #{I18n.t("decidim.proposals.admin.participatory_texts.discard.delete")}"
            redirect_to Decidim::EngineRouter.admin_proxy(current_component).participatory_texts_path
          end
        end
      else
        Decidim::Proposals::Admin::DiscardParticipatoryText.call(current_component) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_texts.discard.success", scope: "decidim.proposals.admin")
            redirect_to Decidim::EngineRouter.admin_proxy(current_component).participatory_texts_path
          end
        end
      end
    end
  end
end

Decidim::Proposals::Admin::ParticipatoryTextsController.include(ParticipatoryTextsControllerExtends)
