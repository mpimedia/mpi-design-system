# frozen_string_literal: true

module Admin
  module BreadcrumbNav
    class Component < ViewComponent::Base
      # @param back_path [String] URL for the back arrow link
      # @param back_label [String] Text for the back link (e.g., "Engagements")
      # @param current_title [String] Current page title displayed after the separator
      def initialize(back_path:, back_label:, current_title:)
        @back_path = back_path
        @back_label = back_label
        @current_title = current_title
      end

      private

      def container_styles
        [
          "display: flex",
          "align-items: center",
          "gap: 8px",
          "padding: 12px 0",
          "font-size: 14px"
        ].join("; ")
      end

      def back_link_styles
        [
          "color: #2E75B6",
          "text-decoration: none",
          "display: inline-flex",
          "align-items: center",
          "gap: 4px",
          "font-weight: 500"
        ].join("; ")
      end

      def separator_styles
        "color: #6C757D; font-size: 12px;"
      end

      def title_styles
        "color: #1B2A4A; font-weight: 600;"
      end
    end
  end
end
