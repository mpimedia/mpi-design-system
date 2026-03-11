# frozen_string_literal: true

module Admin
  module WelcomeBar
    class Component < ViewComponent::Base
      renders_one :actions

      # @param title [String] Left-side heading text (e.g., "Good morning, Badie")
      # @param subtitle [String, nil] Left-side secondary text (e.g., "Here's your CRM snapshot for Tuesday, Feb 25")
      def initialize(title:, subtitle: nil)
        @title = title
        @subtitle = subtitle
      end

      private

      def container_styles
        [
          "padding: 8px 0",
          "margin-bottom: 8px"
        ].join("; ")
      end

      def title_styles
        "font-size: 20px; font-weight: 600; color: #1B2A4A;"
      end

      def subtitle_styles
        "font-size: 14px; color: #6C757D; margin-top: 4px;"
      end
    end
  end
end
