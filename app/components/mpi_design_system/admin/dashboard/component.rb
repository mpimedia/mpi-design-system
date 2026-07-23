# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module Dashboard
      class Component < ViewComponent::Base
        renders_many :stat_cards
        renders_one :activity_feed
        renders_one :quick_actions
        renders_one :followup_queue
        renders_one :group_chart

        GREETING_TIMES = %i[morning afternoon evening].freeze

        # Engagement type -> icon glyph + Bootstrap semantic. Replaces the retired
        # ACTIVITY_ICONS hex map (pastel `bg:` / hex `color:`). The icon chip renders
        # `bg-#{variant}-subtle text-#{variant}-emphasis` (see `activity_icon_classes`),
        # a theme-adaptive pairing that is AA in both colour modes. Five types map onto
        # four hues: `meeting -> secondary` because purple has no MPI semantic and `info`
        # aliases to `primary` (= email's blue); `call` and `new_contact` both map to
        # `success` — they already shared a pastel and the glyphs differ. The icon is
        # `aria-hidden` decoration beside the activity text, so the collapse costs no
        # information. Unknown type falls back to `:email`.
        ACTIVITY_TYPES = {
          email:       { icon: "bi-envelope-fill",     variant: :primary },
          meeting:     { icon: "bi-camera-video-fill", variant: :secondary },
          new_contact: { icon: "bi-plus-circle-fill",  variant: :success },
          call:        { icon: "bi-telephone-fill",    variant: :success },
          note:        { icon: "bi-journal-text",      variant: :warning }
        }.freeze

        # Follow-up status -> Bootstrap semantic text utility. Replaces the retired
        # FOLLOWUP_COLORS hex map. `-emphasis` (not base `text-danger`/`text-warning`)
        # because the status label is 12px small text (AA 4.5:1), which base danger/warning
        # fail; the emphasis tokens clear it and follow `data-bs-theme`. Unknown status
        # falls back to `:future`.
        FOLLOWUP_CLASSES = {
          overdue:      "text-danger-emphasis",
          due_today:    "text-danger-emphasis",
          due_tomorrow: "text-warning-emphasis",
          future:       "text-body-secondary"
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
        # @param group_data [Array<Hash>] Each: { label: String, count: Integer, color: String, percentage: Float }.
        #   `color` is a deliberate consumer-owned data-viz passthrough (decided #172); the component does
        #   not own it. The caller supplies a trusted, consumer-validated CSS colour — see `bar_segment_styles`.
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

        # Geometry/typography only; the navy foreground now comes from `text-body` in the
        # template (adaptive via `--bs-body-color`).
        def greeting_styles
          "font-size: 20px; font-weight: 600;"
        end

        # Geometry/typography only; the muted foreground now comes from `text-body-secondary`.
        def subtitle_styles
          "font-size: 14px; margin-top: 4px;"
        end

        # Geometry only. The surface, border, and radius now come from Bootstrap
        # utilities in the template (`bg-body border rounded-3`) so each widget tracks
        # `data-bs-theme` instead of pinning a light `#fff` / `#DEE2E6`. `rounded-3`
        # resolves to `--bs-border-radius-lg` = 8px under this engine's configuration,
        # preserving the retired literal (the StatCard precedent, #150). 20px has no
        # Bootstrap equivalent, stays inline.
        def widget_styles
          "padding: 20px"
        end

        # Geometry/typography only; the navy foreground now comes from `text-body`.
        def widget_title_styles
          "font-weight: 600; font-size: 16px;"
        end

        # Geometry only. The pastel background + hex glyph now come from
        # `activity_icon_classes` (`bg-#{variant}-subtle text-#{variant}-emphasis`),
        # both theme-adaptive.
        def activity_icon_styles
          [
            "width: 28px",
            "height: 28px",
            "border-radius: 50%",
            "display: inline-flex",
            "align-items: center",
            "justify-content: center",
            "font-size: 13px",
            "flex-shrink: 0"
          ].join("; ")
        end

        # Theme-adaptive icon chip colours: `-subtle` background + `-emphasis` glyph,
        # AA in both colour modes. Unknown type falls back to the `:email` (primary) pair.
        def activity_icon_classes(type)
          variant = (ACTIVITY_TYPES[type] || ACTIVITY_TYPES[:email])[:variant]
          "bg-#{variant}-subtle text-#{variant}-emphasis"
        end

        # The Bootstrap Icons glyph for the type. Unknown type falls back to `:email`.
        def activity_icon_class(type)
          (ACTIVITY_TYPES[type] || ACTIVITY_TYPES[:email])[:icon]
        end

        # Geometry only; the navy foreground now comes from `text-body`.
        def activity_text_styles
          "font-size: 13px;"
        end

        # Geometry only. The link now uses Bootstrap's DEFAULT adaptive link colour
        # (`--bs-link-color` — #2E75B6 light, #82ACD3 dark) and keeps its natural
        # underline as the navigation affordance, so no colour class and no
        # `text-decoration: none` are declared here (the DataTable precedent, #151).
        def activity_link_styles
          "font-weight: 500;"
        end

        # Geometry only; the muted foreground now comes from `text-body-secondary`.
        def activity_time_styles
          "font-size: 12px;"
        end

        # Geometry/typography only; the status colour now comes from
        # `followup_status_class` (a `-emphasis` / `text-body-secondary` utility).
        def followup_status_styles
          "font-size: 12px; font-weight: 600;"
        end

        # Theme-adaptive status colour. Unknown status falls back to the `:future`
        # (`text-body-secondary`) class.
        def followup_status_class(status)
          FOLLOWUP_CLASSES[status] || FOLLOWUP_CLASSES[:future]
        end

        # Geometry only; the navy foreground now comes from `text-body`.
        def followup_name_styles
          "font-size: 13px; font-weight: 600;"
        end

        # Geometry only; the navy foreground now comes from `text-body`.
        def followup_desc_styles
          "font-size: 13px;"
        end

        # Geometry/layout only. The surface, border, and navy foreground now come from
        # `border bg-body text-body` in the template. `text-decoration: none` stays
        # inline: the quick action is a button-like control, not body-text navigation,
        # so it keeps no underline (unlike the activity/"View all" links).
        def quick_action_styles
          [
            "padding: 10px 14px",
            "border-radius: 6px",
            "text-decoration: none",
            "display: block",
            "font-size: 14px",
            "font-weight: 500",
            "text-align: left"
          ].join("; ")
        end

        # Geometry only. Like the activity links, "View all" now uses Bootstrap's default
        # adaptive `--bs-link-color` with its natural underline — no colour class, no
        # `text-decoration: none`. (#151 precedent.)
        def view_all_styles
          "font-size: 13px; font-weight: 500;"
        end

        def bar_container_styles
          "height: 16px; border-radius: 8px; overflow: hidden; display: flex; width: 100%;"
        end

        # Deliberate consumer-owned data-viz passthrough (decided #172); the component does not
        # own `group_data[:color]`. The consuming app supplies a trusted, consumer-validated CSS
        # colour (preferably a hex value), so it is deliberately outside the #153 theme-adaptive
        # mandate — that mandate governs the component's OWN chrome, not app-supplied chart data.
        # Geometry survives here.
        def bar_segment_styles(group)
          "background: #{group[:color]}; width: #{group[:percentage]}%; height: 100%;"
        end

        # Deliberate consumer-owned data-viz passthrough (decided #172) — see `bar_segment_styles`.
        # The dot mirrors its segment's caller-supplied fill; geometry survives here.
        def legend_dot_styles(color)
          "width: 10px; height: 10px; border-radius: 50%; background: #{color}; flex-shrink: 0;"
        end

        # Geometry only; the muted foreground now comes from `text-body-secondary`.
        def legend_label_styles
          "font-size: 12px;"
        end

        # Geometry only; the navy foreground now comes from `text-body`.
        def legend_count_styles
          "font-size: 12px; font-weight: 600;"
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
end
