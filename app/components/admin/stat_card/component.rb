# frozen_string_literal: true

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

      def card_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 20px"
        ].join("; ")
      end

      def label_styles
        [
          "font-size: 11px",
          "font-weight: 600",
          "text-transform: uppercase",
          "letter-spacing: 0.06em",
          "color: #6C757D",
          "margin-bottom: 8px"
        ].join("; ")
      end

      def value_styles
        color = @alert ? "#DC3545" : "#1B2A4A"
        [
          "font-size: 32px",
          "font-weight: 700",
          "color: #{color}",
          "line-height: 1.1"
        ].join("; ")
      end

      def trend_styles
        color = case @trend_sentiment
                when :positive then "#22A06B"
                when :negative then "#DC3545"
                else "#6C757D"
                end
        [
          "font-size: 12px",
          "font-weight: 500",
          "color: #{color}",
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

      def trend_class
        case @trend_sentiment
        when :positive then "text-success"
        when :negative then "text-danger"
        else "text-muted"
        end
      end
    end
  end
end
