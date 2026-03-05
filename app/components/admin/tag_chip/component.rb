# frozen_string_literal: true

module Admin
  module TagChip
    class Component < ViewComponent::Base
      GROUPS = {
        production: { color: "#6366F1", bg: "#EEEFFE" },
        distribution: { color: "#E8733A", bg: "#FEF3EC" },
        finance: { color: "#D97706", bg: "#FEF9EC" },
        press_festival: { color: "#2E75B6", bg: "#EBF3FB" },
        internal: { color: "#64748B", bg: "#F1F5F9" },
        vendors: { color: "#8B5CF6", bg: "#F3EFFE" },
        outreach: { color: "#2DA67E", bg: "#ECF8F4" }
      }.freeze

      # @param label [String] Tag display text
      # @param group [Symbol] :production, :distribution, :finance, :press_festival, :internal, :vendors, :outreach
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

      def dot_styles
        [
          "width: 8px",
          "height: 8px",
          "border-radius: 50%",
          "background-color: #{colors[:color]}",
          "flex-shrink: 0"
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
