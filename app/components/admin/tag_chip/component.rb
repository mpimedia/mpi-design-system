# frozen_string_literal: true

module Admin
  module TagChip
    class Component < ViewComponent::Base
      GROUPS = {
        buyers: { color: "#E8733A", bg: "#FEF3EC" },
        press: { color: "#2DA67E", bg: "#ECF8F4" },
        festivals: { color: "#2E75B6", bg: "#EBF3FB" },
        sellers: { color: "#8B5CF6", bg: "#F3EFFE" },
        institutional: { color: "#D97706", bg: "#FEF9EC" },
        organizations: { color: "#6366F1", bg: "#EEEFFE" },
        internal: { color: "#64748B", bg: "#F1F5F9" }
      }.freeze

      # @param label [String] Tag display text
      # @param group [Symbol] :buyers, :press, :festivals, :sellers, :institutional, :organizations, :internal
      # @param removable [Boolean] Show x remove button (default: false)
      # @param size [Symbol] :sm (12px), :md (13px, default)
      # @param remove_url [String] URL for Turbo Stream removal
      def initialize(label:, group:, removable: false, size: :md, remove_url: nil)
        @label = label
        @group = GROUPS.key?(group) ? group : :internal
        @removable = removable
        @size = %i[sm md].include?(size) ? size : :md
        @remove_url = remove_url
      end

      private

      def colors
        GROUPS[@group]
      end

      def chip_styles
        [
          "color: #{colors[:color]}",
          "background-color: #{colors[:bg]}",
          "font-size: #{@size == :sm ? '12px' : '13px'}",
          "padding: 0.25em 0.75em",
          "border-radius: 999px",
          "line-height: 1.4"
        ].join("; ")
      end

      def remove_button_styles
        [
          "color: #{colors[:color]}",
          "opacity: 0.6",
          "background: none",
          "border: none",
          "padding: 0",
          "font-size: inherit",
          "line-height: 1",
          "cursor: pointer"
        ].join("; ")
      end
    end
  end
end
