# frozen_string_literal: true

module Admin
  module FilterPanel
    class Component < ViewComponent::Base
      # @param sections [Array<Hash>] Each section hash:
      #   - title [String] Section heading (e.g., "Tag Group", "Date Range")
      #   - options [Array<Hash>] Each: { label: String, value: String, count: Integer, checked: Boolean }
      #   - collapsed [Boolean] Whether the section starts collapsed (default: false)
      #   - field_name [String] Form field name for the section (e.g., "tag_group[]")
      # @param form_action [String] URL the filter form submits to
      # @param form_method [String] HTTP method (default: "get")
      def initialize(sections:, form_action: "#", form_method: "get")
        @sections = sections || []
        @form_action = form_action
        @form_method = form_method
      end

      private

      def panel_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 0",
          "min-width: 220px"
        ].join("; ")
      end

      def header_styles
        [
          "font-size: 13px",
          "font-weight: 700",
          "text-transform: uppercase",
          "letter-spacing: 0.06em",
          "color: #1B2A4A",
          "padding: 14px 16px 10px"
        ].join("; ")
      end

      def section_header_styles
        [
          "display: flex",
          "align-items: center",
          "justify-content: space-between",
          "padding: 10px 16px",
          "cursor: pointer",
          "border: none",
          "background: transparent",
          "width: 100%",
          "font-size: 13px",
          "font-weight: 600",
          "color: #1B2A4A",
          "text-align: left"
        ].join("; ")
      end

      def option_styles
        [
          "display: flex",
          "align-items: center",
          "justify-content: space-between",
          "padding: 4px 16px 4px 20px",
          "font-size: 13px",
          "color: #1B2A4A"
        ].join("; ")
      end

      def option_label_styles
        [
          "display: flex",
          "align-items: center",
          "gap: 6px",
          "cursor: pointer"
        ].join("; ")
      end

      def count_styles
        "font-size: 11px; color: #6C757D;"
      end

      def divider_styles
        "border: none; border-top: 1px solid #DEE2E6; margin: 0;"
      end

      def section_id(index)
        "filter-section-#{index}"
      end

      def section_collapsed?(section)
        section.fetch(:collapsed, false)
      end
    end
  end
end
