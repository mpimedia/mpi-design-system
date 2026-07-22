# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module StatCard
      class Component < ViewComponent::Base
        TREND_DIRECTIONS = %i[up down neutral].freeze
        TREND_SENTIMENTS = %i[positive negative neutral].freeze

        # @param label [String] Metric label (displayed ALL-CAPS)
        # @param value [String] Formatted metric value (e.g., "2,307", "47")
        # @param trend_text [String] Trend description (e.g., "34 this month")
        # @param trend_direction [Symbol] :up, :down, :neutral
        # @param trend_sentiment [Symbol] :positive (green), :negative (red), :neutral (gray)
        # @param alert [Boolean] Display value in danger red (default: false)
        def initialize(label:, value:, trend_text: nil, trend_direction: :neutral, trend_sentiment: :neutral, alert: false)
          @label = label
          @value = value
          @trend_text = trend_text
          @trend_direction = TREND_DIRECTIONS.include?(trend_direction) ? trend_direction : :neutral
          @trend_sentiment = TREND_SENTIMENTS.include?(trend_sentiment) ? trend_sentiment : :neutral
          @alert = alert
        end

        private

        # Geometry only. The surface, border, and radius now come from Bootstrap
        # utilities in the template (`bg-body border rounded-3`) so the card tracks
        # `data-bs-theme` instead of pinning a light `#fff` / `#DEE2E6`. `rounded-3`
        # resolves to `--bs-border-radius-lg` = 8px under this engine's configuration,
        # preserving the retired literal. 20px has no Bootstrap equivalent, stays inline.
        def card_styles
          "padding: 20px"
        end

        # Colour comes from `.text-body-secondary` in the template, not a pinned
        # `#6C757D` — so the label follows the colour mode. Geometry only here.
        def label_styles
          [
            "font-size: 11px",
            "font-weight: 600",
            "text-transform: uppercase",
            "letter-spacing: 0.06em",
            "margin-bottom: 8px"
          ].join("; ")
        end

        # Geometry only. The value's colour comes from `value_class` — `.text-danger`
        # for alerts, `.text-body` otherwise — both theme-adaptive. At 32px the value is
        # "large text" (AA 3:1), which `.text-danger` clears in both modes (4.53 light /
        # 3.41 dark) while staying semantically red, so base danger is correct here.
        def value_styles
          [
            "font-size: 32px",
            "font-weight: 700",
            "line-height: 1.1"
          ].join("; ")
        end

        # Geometry only. The trend's colour comes from `trend_class`. Unlike the 32px
        # value, the 12px trend is "small text" (AA 4.5:1), so it uses the `-emphasis`
        # variants, which pass AA in both modes where base `text-success`/`text-danger`
        # do not.
        def trend_styles
          [
            "font-size: 12px",
            "font-weight: 500",
            "margin-top: 4px"
          ].join("; ")
        end

        def trend_icon
          case @trend_direction
          when :up then "bi-arrow-up"
          when :down then "bi-arrow-down"
          end
        end

        def show_trend?
          @trend_text.present?
        end

        def value_class
          @alert ? "text-danger" : "text-body"
        end

        # Small-text (12px) trend colour. The `-emphasis` variants are used deliberately:
        # base `.text-success` (#22A06B = 3.33:1 on light) and `.text-danger`
        # (#DC3545 = 3.41:1 on dark) both FAIL the 4.5:1 small-text floor and do not
        # follow the colour mode. The emphasis tokens pass (7.7–13.7:1) and are adaptive.
        def trend_class
          case @trend_sentiment
          when :positive then "text-success-emphasis"
          when :negative then "text-danger-emphasis"
          else "text-body-secondary"
          end
        end
      end
    end
  end
end
