# frozen_string_literal: true

module Admin
  module EngagementDetailView
    class Component < ViewComponent::Base
      renders_one :breadcrumb
      renders_one :header_bar
      renders_one :tabs
      renders_one :main_content
      renders_one :sidebar

      TYPE_COLORS = {
        email: "#2E75B6",
        meeting: "#8B5CF6",
        call: "#16A34A",
        note: "#E8913A"
      }.freeze

      # @param engagement_type [Symbol] :email, :meeting, :call, :note (used for styling context)
      # @param title [String] Engagement title/subject
      # @param date [String] Date string
      # @param status [String] Status label (e.g., "Sent", "Received")
      def initialize(engagement_type: :email, title: nil, date: nil, status: nil)
        @engagement_type = %i[email meeting call note].include?(engagement_type) ? engagement_type : :email
        @title = title
        @date = date
        @status = status
      end

      private

      def container_styles
        "background: #F5F7FA; min-height: 100%;"
      end

      def breadcrumb_bar_styles
        [
          "background: #fff",
          "border-bottom: 1px solid #DEE2E6",
          "padding: 0 24px"
        ].join("; ")
      end

      def header_bar_container_styles
        [
          "background: #fff",
          "border-bottom: 1px solid #DEE2E6",
          "padding: 16px 24px"
        ].join("; ")
      end

      def type_color
        TYPE_COLORS[@engagement_type]
      end

      def type_badge_styles
        [
          "font-size: 10px",
          "font-weight: 700",
          "text-transform: uppercase",
          "letter-spacing: 0.04em",
          "border-radius: 4px",
          "border: 1.5px solid #{type_color}",
          "color: #{type_color}",
          "background: transparent",
          "padding: 2px 6px",
          "display: inline-block"
        ].join("; ")
      end

      def header_title_styles
        "font-weight: 600; color: #1B2A4A; font-size: 16px; margin: 0;"
      end

      def header_meta_styles
        "font-size: 12px; color: #6C757D;"
      end

      def tabs_container_styles
        [
          "background: #fff",
          "border-bottom: 1px solid #DEE2E6",
          "padding: 0 24px"
        ].join("; ")
      end

      def body_styles
        "padding: 24px;"
      end

      def main_panel_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 24px"
        ].join("; ")
      end

      def sidebar_panel_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 20px",
          "min-width: 280px"
        ].join("; ")
      end

      def type_label
        @engagement_type.to_s.upcase
      end

      def show_default_header?
        !header_bar? && (@title.present? || @date.present?)
      end
    end
  end
end
