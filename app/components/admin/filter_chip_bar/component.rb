# frozen_string_literal: true

module Admin
  module FilterChipBar
    class Component < ViewComponent::Base
      GROUPS = Admin::TagChip::Component::GROUPS

      # @param groups [Array<Hash>] Group chip data:
      #   [{ label: "All", count: 2307 },
      #    { label: "Buyers", count: 342, group: :buyers, selected: true }]
      # @param active_filters [Array<Hash>] Active filter pill data:
      #   [{ category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" }]
      # @param clear_all_url [String] URL to clear all active filters
      # @param reset_all_url [String] URL to reset all filters (shown in header)
      def initialize(groups: [], active_filters: [], clear_all_url: nil, reset_all_url: nil)
        @groups = groups || []
        @active_filters = active_filters || []
        @clear_all_url = clear_all_url
        @reset_all_url = reset_all_url
      end

      private

      def label_styles
        [
          "font-size: 11px",
          "font-weight: 600",
          "text-transform: uppercase",
          "letter-spacing: 0.06em",
          "color: #6C757D"
        ].join("; ")
      end

      def group_chip_styles(chip)
        selected = chip[:selected]
        group_key = chip[:group]

        styles = [
          "padding: 5px 12px",
          "border-radius: 999px",
          "font-size: 13px",
          "font-weight: 500",
          "text-decoration: none",
          "display: inline-block"
        ]

        if selected && group_key && GROUPS[group_key]
          colors = GROUPS[group_key]
          styles.concat([
            "border: 1px solid #{colors[:color]}",
            "background: #{colors[:bg]}",
            "color: #{colors[:color]}"
          ])
        else
          styles.concat([
            "border: 1px solid #DEE2E6",
            "background: #fff",
            "color: #1B2A4A"
          ])
        end

        styles.join("; ")
      end

      def active_pill_styles
        [
          "padding: 4px 10px",
          "border-radius: 999px",
          "background: #2E75B6",
          "color: #fff",
          "font-size: 12px",
          "font-weight: 500",
          "display: inline-flex",
          "align-items: center",
          "gap: 6px",
          "text-decoration: none"
        ].join("; ")
      end

      def remove_btn_styles
        [
          "color: #fff",
          "opacity: 0.8",
          "background: none",
          "border: none",
          "padding: 0",
          "font-size: inherit",
          "line-height: 1",
          "cursor: pointer"
        ].join("; ")
      end

      def clear_all_styles
        "font-size: 13px; color: #6C757D; text-decoration: none;"
      end

      def reset_all_styles
        "font-size: 12px; color: #6C757D; text-decoration: none;"
      end

      def chip_label(chip)
        chip[:count] ? "#{chip[:label]} #{chip[:count]}" : chip[:label]
      end

      def pill_label(filter)
        "#{filter[:category]}: #{filter[:value]}"
      end

      def show_groups?
        @groups.any?
      end

      def show_active_filters?
        @active_filters.any?
      end
    end
  end
end
