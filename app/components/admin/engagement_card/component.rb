# frozen_string_literal: true

module Admin
  module EngagementCard
    class Component < ViewComponent::Base
      TYPES = %i[email meeting call note].freeze

      TYPE_COLORS = {
        email: "#2E75B6",
        meeting: "#8B5CF6",
        call: "#16A34A",
        note: "#E8913A"
      }.freeze

      TYPE_BG_COLORS = {
        email: "#EBF3FB",
        meeting: "#F3EFFE",
        call: "#ECF8F4",
        note: "#FEF3EC"
      }.freeze

      # @param engagement_type [Symbol] :email, :meeting, :call, :note
      # @param time [String] Display time (e.g., "10:42 AM")
      # @param subject [String] Engagement subject line
      # @param excerpt [String] Note/body excerpt text
      # @param contacts [Array<Hash>] Each: { name: String, path: String }
      # @param account_name [String] Linked account name
      # @param account_path [String] URL to account detail
      # @param tags [Array<Hash>] Each: { group: Symbol, role: String }
      # @param linked_titles [Array<Hash>] Each: { name: String, path: String }
      # @param creator_name [String] Internal user who logged the engagement
      def initialize(engagement_type:, time: nil, subject: nil, excerpt: nil, contacts: [],
                     account_name: nil, account_path: nil, tags: [], linked_titles: [],
                     creator_name: nil)
        @engagement_type = TYPES.include?(engagement_type) ? engagement_type : :email
        @time = time
        @subject = subject
        @excerpt = excerpt
        @contacts = contacts || []
        @account_name = account_name
        @account_path = account_path
        @tags = tags || []
        @linked_titles = linked_titles || []
        @creator_name = creator_name
      end

      private

      def card_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 16px 20px"
        ].join("; ")
      end

      def type_color
        TYPE_COLORS[@engagement_type]
      end

      def type_bg_color
        TYPE_BG_COLORS[@engagement_type]
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
          "background: #{type_bg_color}",
          "padding: 2px 6px",
          "display: inline-block"
        ].join("; ")
      end

      def time_styles
        "font-size: 12px; color: #6C757D; margin-left: 8px;"
      end

      def subject_styles
        "font-weight: 600; color: #1B2A4A; font-size: 14px; margin-top: 4px;"
      end

      def excerpt_styles
        "font-size: 13px; color: #6C757D; margin-top: 4px; line-height: 1.4;"
      end

      def contact_chip_styles
        [
          "display: inline-flex",
          "align-items: center",
          "gap: 4px",
          "background: #F5F7FA",
          "border-radius: 999px",
          "padding: 2px 8px 2px 2px",
          "font-size: 12px",
          "color: #1B2A4A",
          "text-decoration: none"
        ].join("; ")
      end

      def right_meta_styles
        [
          "font-size: 12px",
          "color: #6C757D",
          "min-width: 160px",
          "text-align: right"
        ].join("; ")
      end

      def account_link_styles
        "color: #2E75B6; text-decoration: none; font-size: 12px;"
      end

      def creator_styles
        "font-size: 12px; color: #6C757D;"
      end

      def tag_dot_style(tag)
        color = Admin::TagChip::Component::GROUPS.dig(tag[:group], :color) || "#64748B"
        "width: 6px; height: 6px; border-radius: 50%; background: #{color}; display: inline-block;"
      end

      def tag_text_styles
        "font-size: 12px; color: #1B2A4A;"
      end

      def title_link_styles
        "color: #2E75B6; text-decoration: none; font-size: 12px;"
      end

      def type_label
        @engagement_type.to_s.upcase
      end

      def show_right_meta?
        @account_name.present? || @tags.any? || @linked_titles.any?
      end
    end
  end
end
