# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module EmptyState
      class Component < ViewComponent::Base
        HEADING_LEVELS = %i[h1 h2 h3 h4 h5 h6].freeze

        # @param icon [String] Bootstrap Icon class (e.g., "bi-search", "bi-inbox")
        # @param heading [String] Heading text
        # @param heading_level [Symbol] Semantic heading level for the heading text —
        #   one of :h1..:h6 (default :h3). Lets a consumer compose the empty state under an
        #   existing section heading without a backward jump (e.g. :h5 beneath a show-page
        #   <h4>). The visual size is held constant (`fs-5`) regardless of level. Invalid
        #   values fall back to :h3.
        # @param description [String] Description text
        # @param action_label [String] Optional CTA button text
        # @param action_url [String] Optional CTA button URL
        # @param action_icon [String] Optional icon for CTA button (e.g., "bi-plus-lg")
        # @param shortcuts [Array<Hash>] Optional shortcut cards:
        #   [{ title: "Buyers — no engagement", description: "Follow-up candidates", href: "#" }]
        def initialize(icon: nil, heading:, heading_level: :h3, description: nil, action_label: nil,
                       action_url: nil, action_icon: nil, shortcuts: [])
          @icon = icon
          @heading = heading
          @heading_level = HEADING_LEVELS.include?(heading_level) ? heading_level : :h3
          @description = description
          @action_label = action_label
          @action_url = action_url
          @action_icon = action_icon
          @shortcuts = shortcuts || []
        end

        private

        def show_action?
          @action_label.present? && @action_url.present?
        end

        def show_shortcuts?
          @shortcuts.any?
        end
      end
    end
  end
end
