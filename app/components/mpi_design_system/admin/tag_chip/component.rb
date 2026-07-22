# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module TagChip
      class Component < ViewComponent::Base
        GROUPS = {
          production: { color: "#6366F1", bg: "#EEEFFE" },
          distribution: { color: "#E8733A", bg: "#FEF3EC" },
          finance: { color: "#D97706", bg: "#FEF9EC" },
          press_festival: { color: "#2E75B6", bg: "#EBF3FB" },
          internal: { color: "#64748B", bg: "#F1F5F9" },
          vendors: { color: "#8B5CF6", bg: "#F3EFFE" },
          outreach: { color: "#2DA67E", bg: "#ECF8F4" }
        }.freeze

        # Maps each CRM tag group onto a Bootstrap semantic colour so consumers that
        # want a theme-adaptive chip (FilterChipBar's selected chip, DataTable's tag
        # dots) resolve their colour from `--bs-*` rather than the frozen hex above.
        # This is the single source of truth for that mapping — every key in GROUPS
        # has an entry (asserted in the spec).
        #
        # MPI maps `$info` -> `$primary` (`_tokens_values.scss`), so `info` would
        # render the same blue as `primary`; the palette therefore offers five
        # distinct adaptive hues, and the three cool categories collapse onto
        # `primary` (blue). This is an accepted trade of Option A (#151) — the tag's
        # always-present text label carries the identity, not the hue alone. The
        # remaining `GROUPS` consumers (TagChip's own rendering, contact/engagement
        # cards, list rows, detail panels) still render the frozen hex this phase;
        # unifying them is the tracked #151 follow-up.
        GROUP_VARIANTS = {
          press_festival: :primary,
          production: :primary,
          vendors: :primary,
          outreach: :success,
          finance: :warning,
          distribution: :danger,
          internal: :secondary
        }.freeze

        # @param label [String] Tag display text
        # @param group [Symbol] :production, :distribution, :finance, :press_festival, :internal, :vendors, :outreach
        # @param removable [Boolean] Show x remove button (default: false)
        # @param size [Symbol] :sm (12px), :md (13px, default)
        # @param remove_url [String] URL for Turbo Stream removal
        def initialize(label:, group:, removable: false, size: :md, remove_url: nil)
          @label = label
          @group = GROUPS.key?(group) ? group : :internal
          @removable = removable
          @size = %i[sm md].include?(size) ? size : :md
          @remove_url = remove_url
        end

        private

        def colors
          GROUPS[@group]
        end

        def chip_styles
          [
            "color: #{colors[:color]}",
            "background-color: #{colors[:bg]}",
            "font-size: #{@size == :sm ? '12px' : '13px'}",
            "padding: 0.25em 0.75em",
            "border-radius: 999px",
            "line-height: 1.4"
          ].join("; ")
        end

        def dot_styles
          [
            "width: 8px",
            "height: 8px",
            "border-radius: 50%",
            "background-color: #{colors[:color]}",
            "flex-shrink: 0"
          ].join("; ")
        end

        def remove_button_styles
          [
            "color: #{colors[:color]}",
            "opacity: 0.6",
            "background: none",
            "border: none",
            "padding: 0",
            "font-size: inherit",
            "line-height: 1",
            "cursor: pointer"
          ].join("; ")
        end
      end
    end
  end
end
