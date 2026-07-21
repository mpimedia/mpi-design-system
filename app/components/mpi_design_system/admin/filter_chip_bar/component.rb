# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module FilterChipBar
      class Component < ViewComponent::Base
        GROUPS = MpiDesignSystem::Admin::TagChip::Component::GROUPS

        # @param groups [Array<Hash>] Group chip data:
        #   [{ label: "All", count: 2307 },
        #    { label: "Distribution", count: 342, group: :distribution, selected: true }]
        # @param active_filters [Array<Hash>] Active filter pill data:
        #   [{ category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" }]
        # @param clear_all_url [String] URL to clear all active filters
        # @param reset_all_url [String] URL to reset all filters (shown in header)
        def initialize(groups: [], active_filters: [], clear_all_url: nil, reset_all_url: nil)
          @groups = groups || []
          @active_filters = active_filters || []
          @clear_all_url = clear_all_url
          @reset_all_url = reset_all_url
        end

        private

        # This component sets no background of its own, so a pinned foreground is
        # only ever verified against an assumed one: `#6C757D` scored 4.69:1 on
        # white but 4.37:1 on the app background (`$mpi-background`). Bootstrap's
        # `.text-body-secondary` derives from `--bs-body-color` and clears AA on
        # both (6.40:1 / 6.14:1). (#130)
        def label_styles
          [
            "font-size: 11px",
            "font-weight: 600",
            "text-transform: uppercase",
            "letter-spacing: 0.06em"
          ].join("; ")
        end

        def group_chip_styles(chip)
          selected = chip[:selected]
          group_key = chip[:group]

          styles = [
            "padding: 5px 12px",
            "border-radius: 999px",
            "font-size: 13px",
            "font-weight: 500",
            "text-decoration: none",
            "display: inline-block"
          ]

          if selected && group_key && GROUPS[group_key]
            colors = GROUPS[group_key]
            styles.concat([
              "border: 1px solid #{colors[:color]}",
              "background: #{colors[:bg]}",
              "color: #{colors[:color]}"
            ])
          else
            styles.concat([
              "border: 1px solid #DEE2E6",
              "background: #fff",
              "color: #1B2A4A"
            ])
          end

          styles.join("; ")
        end

        # Geometry only — background and foreground come from `.text-bg-primary`.
        # Mirrors `ActiveFilterBar#pill_styles`, which renders the identical pill. (#130)
        def active_pill_styles
          [
            "padding: 4px 10px",
            "font-size: 12px",
            "font-weight: 500",
            "display: inline-flex",
            "align-items: center",
            "gap: 6px",
            "text-decoration: none"
          ].join("; ")
        end

        # Inherits the pill's derived foreground. The retired `opacity: 0.8` faded
        # white to an effective #D5E3F0 — 3.71:1, an AA failure. (#130)
        def remove_btn_styles
          [
            "color: inherit",
            "background: none",
            "border: none",
            "padding: 0",
            "font-size: inherit",
            "line-height: 1",
            "cursor: pointer"
          ].join("; ")
        end

        def clear_all_styles
          "font-size: 13px; text-decoration: none;"
        end

        def reset_all_styles
          "font-size: 12px; text-decoration: none;"
        end

        def chip_label(chip)
          chip[:count] ? "#{chip[:label]} #{chip[:count]}" : chip[:label]
        end

        def pill_label(filter)
          "#{filter[:category]}: #{filter[:value]}"
        end

        def show_groups?
          @groups.any?
        end

        def show_active_filters?
          @active_filters.any?
        end
      end
    end
  end
end
