# frozen_string_literal: true

module Admin
  module EngagementTimeline
    class Component < ViewComponent::Base
      VARIANTS = %i[full compact].freeze
      TYPES = %i[email meeting call note].freeze

      TYPE_COLORS = {
        email: "#2E75B6",
        meeting: "#8B5CF6",
        call: "#16A34A",
        note: "#E8913A"
      }.freeze

      # @param engagements [Array<Hash>] Each: { type: Symbol, date: String, time: String,
      #   timezone: String, subject: String, excerpt: String, creator_name: String, date_group: String }
      # @param variant [Symbol] :full (default), :compact
      # @param new_engagement_path [String] URL for "+ New Engagement" button
      def initialize(engagements: [], variant: :full, new_engagement_path: nil)
        @engagements = engagements || []
        @variant = VARIANTS.include?(variant) ? variant : :full
        @new_engagement_path = new_engagement_path
      end

      private

      def panel_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 20px"
        ].join("; ")
      end

      def title_styles
        size = compact? ? "14px" : "16px"
        [
          "font-weight: 600",
          "color: #1B2A4A",
          "font-size: #{size}"
        ].join("; ")
      end

      def button_styles
        [
          "background: #1B2A4A",
          "color: #fff",
          "font-size: 13px",
          "border: none",
          "border-radius: 6px",
          "padding: 6px 12px",
          "text-decoration: none",
          "display: inline-block"
        ].join("; ")
      end

      def entry_styles
        padding = compact? ? "10px 0" : "14px 0"
        "padding: #{padding}; border-bottom: 1px solid #F0F0F0;"
      end

      def last_entry_styles
        padding = compact? ? "10px 0" : "14px 0"
        "padding: #{padding};"
      end

      def type_badge_styles(type)
        type_sym = TYPES.include?(type) ? type : :email
        color = TYPE_COLORS[type_sym]
        [
          "font-size: 10px",
          "font-weight: 700",
          "text-transform: uppercase",
          "letter-spacing: 0.04em",
          "border-radius: 4px",
          "border: 1.5px solid #{color}",
          "color: #{color}",
          "background: transparent",
          "padding: 2px 6px",
          "display: inline-block"
        ].join("; ")
      end

      def date_styles
        "font-size: 12px; color: #6C757D; margin-left: 8px;"
      end

      def subject_styles
        "font-weight: 600; color: #1B2A4A; font-size: 14px; margin-top: 4px;"
      end

      def excerpt_styles
        "font-size: 13px; color: #6C757D; margin-top: 4px; line-height: 1.4;"
      end

      def creator_styles
        "font-size: 12px; color: #6C757D;"
      end

      def date_group_header_styles
        [
          "font-size: 11px",
          "font-weight: 700",
          "text-transform: uppercase",
          "letter-spacing: 0.06em",
          "color: #6C757D",
          "padding: 12px 0 4px",
          "border-bottom: 1px solid #DEE2E6",
          "margin-bottom: 0"
        ].join("; ")
      end

      def title_text
        compact? ? "Recent Engagements" : "Engagements"
      end

      def compact?
        @variant == :compact
      end

      def full?
        @variant == :full
      end

      def grouped_engagements
        @engagements.group_by { |e| e[:date_group] || e[:date] }
      end

      def format_date(engagement)
        parts = [ engagement[:date] ]
        parts << ". #{engagement[:time]}" if engagement[:time].present?
        parts << " #{engagement[:timezone]}" if engagement[:timezone].present?
        parts.join
      end

      def type_label(type)
        type.to_s.upcase
      end
    end
  end
end
