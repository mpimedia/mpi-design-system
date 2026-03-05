# frozen_string_literal: true

module Admin
  module ActiveFilterBar
    class Component < ViewComponent::Base
      # @param filters [Array<Hash>] Each: { category: String, value: String, remove_url: String }
      # @param clear_all_url [String] URL to clear all active filters
      def initialize(filters: [], clear_all_url: nil)
        @filters = filters || []
        @clear_all_url = clear_all_url
      end

      private

      def bar_styles
        [
          "display: flex",
          "align-items: center",
          "flex-wrap: wrap",
          "gap: 8px",
          "padding: 10px 16px",
          "background: #F5F7FA",
          "border-radius: 6px"
        ].join("; ")
      end

      def label_styles
        [
          "font-size: 11px",
          "font-weight: 700",
          "text-transform: uppercase",
          "letter-spacing: 0.06em",
          "color: #6C757D"
        ].join("; ")
      end

      def pill_styles
        [
          "display: inline-flex",
          "align-items: center",
          "gap: 6px",
          "padding: 4px 10px",
          "border-radius: 999px",
          "background: #2E75B6",
          "color: #fff",
          "font-size: 12px",
          "font-weight: 500"
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
          "cursor: pointer",
          "text-decoration: none"
        ].join("; ")
      end

      def clear_all_styles
        "font-size: 13px; color: #6C757D; text-decoration: none;"
      end

      def pill_label(filter)
        "#{filter[:category]}: #{filter[:value]}"
      end

      def show?
        @filters.any?
      end
    end
  end
end
