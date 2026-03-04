# frozen_string_literal: true

module Admin
  module DataTable
    class Component < ViewComponent::Base
      VARIANTS = %i[contacts search_results].freeze

      TAG_DOT_COLORS = {
        buyers: "#E8733A",
        press: "#2DA67E",
        festivals: "#2E75B6",
        sellers: "#8B5CF6",
        institutional: "#D97706",
        organizations: "#6366F1",
        internal: "#64748B"
      }.freeze

      STATUS_COLORS = {
        active: "#22A06B",
        follow_up: "#D97706",
        inactive: "#6C757D"
      }.freeze

      # @param columns [Array<Hash>] Column definitions:
      #   [{ key: :name, label: "Name", sortable: true }]
      # @param rows [Array<Hash>] Row data
      # @param sort_by [Symbol] Current sort column
      # @param sort_dir [Symbol] :asc or :desc
      # @param variant [Symbol] :contacts (default), :search_results
      def initialize(columns:, rows: [], sort_by: nil, sort_dir: :asc, variant: :contacts)
        @columns = columns
        @rows = rows || []
        @sort_by = sort_by
        @sort_dir = sort_dir
        @variant = VARIANTS.include?(variant) ? variant : :contacts
      end

      private

      def header_styles
        [
          "font-size: 11px",
          "font-weight: 600",
          "text-transform: uppercase",
          "letter-spacing: 0.06em",
          "color: #6C757D",
          "border-bottom: 2px solid #DEE2E6"
        ].join("; ")
      end

      def sort_indicator(column)
        return "" unless column[:sortable] && @sort_by == column[:key]

        @sort_dir == :asc ? " \u2191" : " \u2193"
      end

      def aria_sort(column)
        return unless column[:sortable] && @sort_by == column[:key]

        @sort_dir == :asc ? "ascending" : "descending"
      end

      def name_styles
        "font-weight: 600; color: #1B2A4A; font-size: 14px;"
      end

      def title_styles
        "font-size: 12px; color: #6C757D;"
      end

      def tag_dot_style(group)
        color = TAG_DOT_COLORS[group] || "#64748B"
        "width: 6px; height: 6px; border-radius: 50%; background: #{color}; display: inline-block;"
      end

      def tag_text_styles
        "font-size: 13px; color: #1B2A4A;"
      end

      def meta_text_styles
        "font-size: 13px; color: #6C757D;"
      end

      def account_link_styles
        "color: #2E75B6; font-size: 13px; text-decoration: none;"
      end

      def status_dot_style(status)
        color = STATUS_COLORS[status] || "#6C757D"
        "width: 6px; height: 6px; border-radius: 50%; background: #{color}; display: inline-block;"
      end

      def cell_styles
        "vertical-align: middle;"
      end
    end
  end
end
