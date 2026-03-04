# frozen_string_literal: true

module Admin
  module EmptyState
    class Component < ViewComponent::Base
      # @param icon [String] Bootstrap Icon class (e.g., "bi-search", "bi-inbox")
      # @param heading [String] Heading text
      # @param description [String] Description text
      # @param action_label [String] Optional CTA button text
      # @param action_url [String] Optional CTA button URL
      # @param action_icon [String] Optional icon for CTA button (e.g., "bi-plus-lg")
      # @param shortcuts [Array<Hash>] Optional shortcut cards:
      #   [{ title: "Buyers — no engagement", description: "Follow-up candidates", href: "#" }]
      def initialize(icon: nil, heading:, description: nil, action_label: nil, action_url: nil,
                     action_icon: nil, shortcuts: [])
        @icon = icon
        @heading = heading
        @description = description
        @action_label = action_label
        @action_url = action_url
        @action_icon = action_icon
        @shortcuts = shortcuts || []
      end

      private

      def container_styles
        [
          "background: #F5F7FA",
          "border-radius: 8px",
          "padding: 60px 40px",
          "text-align: center"
        ].join("; ")
      end

      def icon_styles
        "font-size: 40px; color: #4EA8DE;"
      end

      def heading_styles
        "font-size: 18px; font-weight: 600; color: #1B2A4A;"
      end

      def description_styles
        [
          "font-size: 14px",
          "color: #6C757D",
          "max-width: 420px",
          "line-height: 1.5",
          "margin: 0 auto"
        ].join("; ")
      end

      def shortcut_card_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 16px",
          "text-decoration: none",
          "display: block",
          "text-align: left"
        ].join("; ")
      end

      def shortcut_title_styles
        "font-size: 14px; font-weight: 600; color: #2E75B6;"
      end

      def shortcut_desc_styles
        "font-size: 12px; color: #6C757D;"
      end

      def show_action?
        @action_label.present? && @action_url.present?
      end

      def show_shortcuts?
        @shortcuts.any?
      end
    end
  end
end
