# frozen_string_literal: true

module MarkdownToProposalsExtends
  def paragraph(text)
    return if text.blank?

    create_proposal(
      "#{I18n.t("decidim.proposals.markdown_to_proposals.paragraph")} #{@last_position + 1 - @num_sections}",
      text,
      Decidim::Proposals::ParticipatoryTextSection::LEVELS[:article]
    )

    text
  end
end

Decidim::Proposals::MarkdownToProposals.class_eval do
  prepend(MarkdownToProposalsExtends)
end
