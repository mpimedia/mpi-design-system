# frozen_string_literal: true

module Admin
  module Dashboard
    class Component < ViewComponent::Base
      renders_many :stat_cards
      renders_one :activity_feed
      renders_one :quick_actions
      renders_one :followup_queue
      renders_one :group_chart

      GREETING_TIMES = %i[morning afternoon evening].freeze

      ACTIVITY_ICONS = {
        email: { icon: "bi-envelope-fill", bg: "#EBF3FB", color: "#2E75B6" },
        meeting: { icon: "bi-camera-video-fill", bg: "#F3EFFE", color: "#8B5CF6" },
        new_contact: { icon: "bi-plus-circle-fill", bg: "#ECF8F4", color: "#22A06B" },
        call: { icon: "bi-telephone-fill", bg: "#ECF8F4", color: "#16A34A" },
        note: { icon: "bi-journal-text", bg: "#FEF3EC", color: "#E8913A" }
      }.freeze

      FOLLOWUP_COLORS = {
        overdue: "#DC3545",
        due_today: "#DC3545",
        due_tomorrow: "#D4772C",
        future: "#6C757D"
      }.freeze

      # @param user_name [String] Current user's first name
      # @param greeting_time [Symbol] :morning, :afternoon, :evening
      # @param current_date [String] Formatted date string (e.g., "Tuesday, Feb 25")
      # @param activities [Array<Hash>] Each: { type: Symbol, description: String, timestamp: String,
      #   contact_name: String, contact_path: String, account_name: String, account_path: String }
      # @param followups [Array<Hash>] Each: { name: String, description: String, status: Symbol,
      #   status_label: String, avatar_name: String }
      # @param followup_count [Integer] Total follow-ups for "View all" link
      # @param followup_path [String] URL for "View all" link
      # @param quick_action_buttons [Array<Hash>] Each: { label: String, path: String, icon: String }
      # @param group_data [Array<Hash>] Each: { label: String, count: Integer, color: String, percentage: Float }
      def initialize(user_name:, greeting_time: :morning, current_date: nil,
                     activities: [], followups: [], followup_count: 0, followup_path: nil,
                     quick_action_buttons: [], group_data: [])
        @user_name = user_name
        @greeting_time = GREETING_TIMES.include?(greeting_time) ? greeting_time : :morning
        @current_date = current_date
        @activities = activities || []
        @followups = followups || []
        @followup_count = followup_count
        @followup_path = followup_path
        @quick_action_buttons = quick_action_buttons || []
        @group_data = group_data || []
      end

      private

      def greeting_text
        prefix = case @greeting_time
                 when :morning then "Good morning"
                 when :afternoon then "Good afternoon"
                 when :evening then "Good evening"
                 end
        "#{prefix}, #{@user_name}"
      end

      def subtitle_text
        return nil unless @current_date

        "Here's your CRM snapshot for #{@current_date}"
      end

      def greeting_styles
        "font-size: 20px; font-weight: 600; color: #1B2A4A;"
      end

      def subtitle_styles
        "font-size: 14px; color: #6C757D; margin-top: 4px;"
      end

      def widget_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 20px"
        ].join("; ")
      end

      def widget_title_styles
        "font-weight: 600; color: #1B2A4A; font-size: 16px;"
      end

      def activity_icon_styles(type)
        config = ACTIVITY_ICONS[type] || ACTIVITY_ICONS[:email]
        [
          "width: 28px",
          "height: 28px",
          "border-radius: 50%",
          "background: #{config[:bg]}",
          "color: #{config[:color]}",
          "display: inline-flex",
          "align-items: center",
          "justify-content: center",
          "font-size: 13px",
          "flex-shrink: 0"
        ].join("; ")
      end

      def activity_icon_class(type)
        config = ACTIVITY_ICONS[type] || ACTIVITY_ICONS[:email]
        config[:icon]
      end

      def activity_text_styles
        "font-size: 13px; color: #1B2A4A;"
      end

      def activity_link_styles
        "color: #2E75B6; text-decoration: none; font-weight: 500;"
      end

      def activity_time_styles
        "font-size: 12px; color: #6C757D;"
      end

      def followup_status_styles(status)
        color = FOLLOWUP_COLORS[status] || FOLLOWUP_COLORS[:future]
        "font-size: 12px; font-weight: 600; color: #{color};"
      end

      def followup_desc_styles
        "font-size: 13px; color: #1B2A4A;"
      end

      def quick_action_styles
        [
          "padding: 10px 14px",
          "border: 1px solid #DEE2E6",
          "border-radius: 6px",
          "background: #fff",
          "color: #1B2A4A",
          "text-decoration: none",
          "display: block",
          "font-size: 14px",
          "font-weight: 500",
          "text-align: left"
        ].join("; ")
      end

      def view_all_styles
        "font-size: 13px; color: #2E75B6; text-decoration: none; font-weight: 500;"
      end

      def bar_container_styles
        "height: 16px; border-radius: 8px; overflow: hidden; display: flex; width: 100%;"
      end

      def bar_segment_styles(group)
        "background: #{group[:color]}; width: #{group[:percentage]}%; height: 100%;"
      end

      def legend_dot_styles(color)
        "width: 10px; height: 10px; border-radius: 50%; background: #{color}; flex-shrink: 0;"
      end

      def legend_label_styles
        "font-size: 12px; color: #6C757D;"
      end

      def legend_count_styles
        "font-size: 12px; font-weight: 600; color: #1B2A4A;"
      end

      def show_activities?
        @activities.any?
      end

      def show_followups?
        @followups.any?
      end

      def show_quick_actions?
        @quick_action_buttons.any?
      end

      def show_group_chart?
        @group_data.any?
      end
    end
  end
end
