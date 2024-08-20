# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ParticipatoryTextsController, type: :controller do
        routes { Decidim::Proposals::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create :proposal_component, :with_participatory_texts_enabled }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "discarding" do
          let!(:proposals) do
            create_list(:proposal, 3, :draft, component: component)
          end

          context "when there is no proposal_id in params" do
            it "suppresses document" do
              post :discard, params: {
                component_id: component.id,
                participatory_process_slug: component.participatory_space.slug
              }
              expect(response).to redirect_to EngineRouter.admin_proxy(component).participatory_texts_path
              expect(flash[:notice]).to eq("All participatory text drafts have been discarded.")
            end
          end

          context "when there is a proposal_id in params" do
            it "supresses one article" do
              post :discard, params: {
                component_id: component.id,
                participatory_process_slug: component.participatory_space.slug,
                proposal_id: Decidim::Proposals::Proposal.last.id,
                level: "article"
              }
              expect(response).to redirect_to EngineRouter.admin_proxy(component).participatory_texts_path
              expect(flash[:notice]).to eq("article deleted")
            end
          end
        end
      end
    end
  end
end
