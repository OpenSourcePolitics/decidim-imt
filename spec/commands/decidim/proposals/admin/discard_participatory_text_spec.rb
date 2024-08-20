# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe DiscardParticipatoryText do
        describe "call" do
          let(:current_component) do
            create(
              :proposal_component,
              participatory_space: create(:participatory_process)
            )
          end
          let!(:proposals) do
            create_list(:proposal, 3, :draft, component: current_component)
          end

          describe "when discarding" do
            context "when there is no proposal_id in arguments" do
              let(:command) { described_class.new(current_component) }

              it "removes all drafts" do
                expect { command.call }.to broadcast(:ok)
                proposals = Decidim::Proposals::Proposal.drafts.where(component: current_component)
                expect(proposals).to be_empty
              end
            end

            context "when there is proposal_id in arguments" do
              it "removes one proposal" do
                id = Decidim::Proposals::Proposal.drafts.where(component: current_component).last.id
                command = described_class.new(current_component, id, "en")
                expect { command.call }.to change(Decidim::Proposals::Proposal, :count).by(-1)
              end
            end
          end
        end
      end
    end
  end
end
