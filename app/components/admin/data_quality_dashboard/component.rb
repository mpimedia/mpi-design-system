# frozen_string_literal: true

module Admin
  module DataQualityDashboard
    class Component < ViewComponent::Base
      TIERS = %i[poor fair good excellent].freeze

      TIER_COLORS = {
        excellent: { color: "#22A06B", bg: "#ECF8F4", label: "Excellent" },
        good: { color: "#2E75B6", bg: "#EBF3FB", label: "Good" },
        fair: { color: "#D4772C", bg: "#FEF3EC", label: "Fair" },
        poor: { color: "#DC3545", bg: "#FEE2E2", label: "Poor" }
      }.freeze

      # @param overall_score [Integer] 0-100 percentage
      # @param overall_tier [Symbol] :poor, :fair, :good, :excellent
      # @param grade_distribution [Hash] { excellent: Integer, good: Integer, fair: Integer, poor: Integer }
      # @param total_contacts [Integer] Total contact count
      # @param gaps [Array<Hash>] Each: { label: String, count: Integer, percentage: Float }
      # @param priority_fixes [Array<Hash>] Each: { name: String, organization: String,
      #   missing_fields: Array<String>, score: Integer, last_active: String }
      def initialize(overall_score:, overall_tier:, grade_distribution: {}, total_contacts: 0,
                     gaps: [], priority_fixes: [])
        @overall_score = overall_score.clamp(0, 100)
        @overall_tier = TIERS.include?(overall_tier) ? overall_tier : :poor
        @grade_distribution = grade_distribution || {}
        @total_contacts = total_contacts
        @gaps = gaps || []
        @priority_fixes = priority_fixes || []
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

      def heading_styles
        "font-weight: 600; color: #1B2A4A; font-size: 16px; margin-bottom: 16px;"
      end

      def score_text_styles
        "font-size: 28px; font-weight: 700; color: #1B2A4A;"
      end

      def tier_config
        TIER_COLORS[@overall_tier]
      end

      def ring_color
        tier_config[:color]
      end

      def ring_circumference
        2 * Math::PI * 52
      end

      def ring_offset
        ring_circumference * (1 - @overall_score / 100.0)
      end

      def grade_badge_styles(tier)
        config = TIER_COLORS[tier]
        return "" unless config

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

      def bar_styles(tier, count)
        config = TIER_COLORS[tier]
        pct = @total_contacts > 0 ? (count.to_f / @total_contacts * 100).round(1) : 0
        "background: #{config[:color]}; width: #{pct}%; height: 8px; border-radius: 4px; min-width: #{count > 0 ? '4px' : '0'};"
      end

      def bar_label(tier)
        TIER_COLORS[tier][:label]
      end

      def bar_count(tier)
        @grade_distribution[tier] || 0
      end

      def bar_percentage(tier)
        count = bar_count(tier)
        return "0%" if @total_contacts == 0

        "#{(count.to_f / @total_contacts * 100).round(1)}%"
      end

      def gap_card_styles
        [
          "background: #F5F7FA",
          "border-radius: 8px",
          "padding: 16px",
          "text-align: center"
        ].join("; ")
      end

      def gap_count_styles
        "font-size: 24px; font-weight: 700; color: #1B2A4A;"
      end

      def gap_label_styles
        "font-size: 12px; color: #6C757D; margin-top: 4px;"
      end

      def gap_percentage_styles
        "font-size: 11px; color: #6C757D;"
      end

      def fix_row_styles
        "padding: 10px 0; border-bottom: 1px solid #F0F0F0;"
      end

      def fix_name_styles
        "font-weight: 600; color: #1B2A4A; font-size: 13px;"
      end

      def fix_org_styles
        "font-size: 12px; color: #6C757D;"
      end

      def fix_missing_styles
        "font-size: 11px; color: #DC3545;"
      end

      def fix_recency_styles
        "font-size: 11px; color: #6C757D;"
      end

      def mini_ring_color(score)
        case score
        when 85..100 then "#22A06B"
        when 50..84 then "#2E75B6"
        when 30..49 then "#D4772C"
        else "#DC3545"
        end
      end

      def mini_ring_circumference
        2 * Math::PI * 12
      end

      def mini_ring_offset(score)
        clamped = score.clamp(0, 100)
        mini_ring_circumference * (1 - clamped / 100.0)
      end
    end
  end
end
