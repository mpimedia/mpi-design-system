# frozen_string_literal: true

module Admin
  module EngagementDetailView
    class Component < ViewComponent::Base
      renders_one :breadcrumb
      renders_one :main_content
      renders_one :sidebar

      # @param engagement_type [Symbol] :email, :meeting, :call, :note (used for styling context)
      def initialize(engagement_type: :email)
        @engagement_type = %i[email meeting call note].include?(engagement_type) ? engagement_type : :email
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
    end
  end
end
