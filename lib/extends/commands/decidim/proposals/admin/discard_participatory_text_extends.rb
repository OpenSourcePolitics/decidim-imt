# frozen_string_literal: true

module DiscardParticipatoryTextExtends
  def initialize(component, proposal_id = nil, locale = "")
    @component = component
    @proposal_id = proposal_id
    @locale = locale
  end

  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid.
  # - :invalid if the form wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    transaction do
      if @proposal_id
        proposal = Decidim::Proposals::Proposal.find(@proposal_id)
        value = proposal.title[@locale].split.last.to_i
        is_article = proposal.article?
        Decidim::Proposals::Proposal.destroy(@proposal_id)
        update_later_proposals_title(@component, value, is_article, @locale)
      else
        discard_drafts
      end
    end

    broadcast(:ok)
  end

  private

  def update_later_proposals_title(component, value, is_article, locale)
    proposals = Decidim::Proposals::Proposal.where(decidim_component_id: component.id)
                                            .where(participatory_text_level: "article")
                                            .select { |proposal| proposal.title[locale].split.last.to_i > value }
    if proposals.any? && is_article
      proposals.sort_by(&:id).each_with_index do |proposal, index|
        proposal.update(title: { "#{locale}": "#{I18n.t("decidim.proposals.admin.participatory_texts.discard.paragraph")} #{value + index}" })
      end
    end
  end
end

Decidim::Proposals::Admin::DiscardParticipatoryText.class_eval do
  prepend DiscardParticipatoryTextExtends
end
