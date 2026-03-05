# frozen_string_literal: true

module Admin
  module DataQualityPanel
    class Component < ViewComponent::Base
      TIERS = %i[poor fair good excellent].freeze

      TIER_COLORS = {
        excellent: { color: "#22A06B", bg: "#ECF8F4", label: "EXCELLENT" },
        good: { color: "#2E75B6", bg: "#EBF3FB", label: "GOOD" },
        fair: { color: "#D4772C", bg: "#FEF3EC", label: "FAIR" },
        poor: { color: "#DC3545", bg: "#FEE2E2", label: "POOR" }
      }.freeze

      PRIORITY_STYLES = {
        high: { color: "#DC3545", bg: "#FEE2E2", label: "HIGH" },
        med: { color: "#D4772C", bg: "#FEF3EC", label: "MED" },
        low: { color: "#64748B", bg: "#F1F5F9", label: "LOW" }
      }.freeze

      # @param score [Integer] 0-100 percentage
      # @param tier [Symbol] :poor, :fair, :good, :excellent
      # @param fields_complete [Integer] Number of complete fields
      # @param fields_total [Integer] Total tracked fields
      # @param fields [Array<Hash>] Each: { name: String, complete: Boolean, priority: Symbol, value: String }
      def initialize(score:, tier:, fields_complete:, fields_total:, fields: [])
        @score = score.clamp(0, 100)
        @tier = TIERS.include?(tier) ? tier : :poor
        @fields_complete = fields_complete
        @fields_total = fields_total
        @fields = fields || []
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
        "font-weight: 600; color: #1B2A4A; font-size: 16px;"
      end

      def subtitle_styles
        "font-size: 12px; color: #6C757D; margin-top: 2px;"
      end

      def tier_config
        TIER_COLORS[@tier]
      end

      def ring_color
        tier_config[:color]
      end

      def ring_circumference
        2 * Math::PI * 20
      end

      def ring_offset
        ring_circumference * (1 - @score / 100.0)
      end

      def grade_badge_styles
        config = tier_config
        [
          "display: inline-block",
          "padding: 2px 8px",
          "border-radius: 4px",
          "font-size: 10px",
          "font-weight: 700",
          "text-transform: uppercase",
          "letter-spacing: 0.04em",
          "color: #{config[:color]}",
          "background: #{config[:bg]}"
        ].join("; ")
      end

      def field_row_styles(complete)
        bg = complete ? "transparent" : "#FFFBEB"
        "padding: 8px 0; border-bottom: 1px solid #F0F0F0; background: #{bg};"
      end

      def field_name_styles(complete)
        color = complete ? "#1B2A4A" : "#DC3545"
        "font-size: 13px; font-weight: 500; color: #{color};"
      end

      def field_value_styles
        "font-size: 12px; color: #6C757D;"
      end

      def priority_badge_styles(priority)
        config = PRIORITY_STYLES[priority]
        return "" unless config

        [
          "display: inline-block",
          "padding: 1px 6px",
          "border-radius: 3px",
          "font-size: 9px",
          "font-weight: 700",
          "text-transform: uppercase",
          "color: #{config[:color]}",
          "background: #{config[:bg]}"
        ].join("; ")
      end

      def priority_label(priority)
        PRIORITY_STYLES.dig(priority, :label) || ""
      end

      def check_icon_styles
        "color: #22A06B; font-size: 14px;"
      end

      def x_icon_styles
        "color: #DC3545; font-size: 14px;"
      end

      def add_action_styles
        "font-size: 12px; color: #2E75B6; text-decoration: none; font-weight: 500;"
      end

      def progress_percentage
        return 0 if @fields_total == 0

        (@fields_complete.to_f / @fields_total * 100).round(1)
      end

      def progress_color
        tier_config[:color]
      end
    end
  end
end
