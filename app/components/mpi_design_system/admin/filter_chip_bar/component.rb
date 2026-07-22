# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module FilterChipBar
      class Component < ViewComponent::Base
        GROUPS = MpiDesignSystem::Admin::TagChip::Component::GROUPS
        GROUP_VARIANTS = MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS

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

        # Geometry only. Every colour (border, background, foreground) now comes from
        # the Bootstrap semantic utilities in `group_chip_classes`, so the chip tracks
        # `data-bs-theme` instead of pinning a light palette. `border-radius: 999px`,
        # `text-decoration: none` and `display: inline-block` moved to their utility
        # equivalents (`rounded-pill`/`text-decoration-none`/`d-inline-block`); the
        # 5px/12px padding, 13px size and 500 weight have no Bootstrap equivalent and
        # stay inline deliberately. (#151)
        def group_chip_styles
          [
            "padding: 5px 12px",
            "font-size: 13px",
            "font-weight: 500"
          ].join("; ")
        end

        # A selected chip with a known group renders that group's semantic `-subtle`
        # surface + `-emphasis` foreground (AA-clean, theme-adaptive). An unselected
        # chip — or a selected one whose group is unknown/absent — falls back to the
        # neutral `bg-body text-body` treatment. The fallback is a state the selected
        # branch cannot produce (no `-subtle`/`-emphasis` utilities), so the spec can
        # tell the two apart. (#151)
        def group_chip_classes(chip)
          base = "rounded-pill d-inline-block text-decoration-none"
          variant = chip[:selected] ? GROUP_VARIANTS[chip[:group]] : nil

          if variant
            "#{base} border border-#{variant}-subtle bg-#{variant}-subtle text-#{variant}-emphasis"
          else
            "#{base} border bg-body text-body"
          end
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

        # Geometry only. Colour, background and border now come from
        # `text-reset bg-transparent border-0` in the template, so the button inherits
        # the pill's derived foreground (as the retired inline `color: inherit` did)
        # and pins nothing of its own — leaving no colour declaration for the
        # theme-adaptivity guard to catch. The retired `opacity: 0.8` faded white to
        # an effective #D5E3F0 (3.71:1, an AA failure) and stays gone. (#130, #151)
        def remove_btn_styles
          [
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
