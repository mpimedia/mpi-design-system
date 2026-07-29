# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module TagChip
      class Component < ViewComponent::Base
        # DEPRECATED FOR RENDERING (#168). No component paints from this map any more —
        # `GROUP_VARIANTS` below is the live mapping. It is retained for two reasons:
        # it remains the canonical **key set** for the CRM tag vocabulary (this
        # component validates `group:` against it, and Badge's Lookbook preview
        # enumerates it), and it documents the original brand hex for designers.
        #
        # These pairs are also the palette ISS#142 measured at 2.77:1-4.34:1 — every
        # one below the WCAG AA floor. That is *why* nothing renders from them now.
        # Do not reintroduce them as a colour source.
        GROUPS = {
          production: { color: "#6366F1", bg: "#EEEFFE" },
          distribution: { color: "#E8733A", bg: "#FEF3EC" },
          finance: { color: "#D97706", bg: "#FEF9EC" },
          press_festival: { color: "#2E75B6", bg: "#EBF3FB" },
          internal: { color: "#64748B", bg: "#F1F5F9" },
          vendors: { color: "#8B5CF6", bg: "#F3EFFE" },
          outreach: { color: "#2DA67E", bg: "#ECF8F4" }
        }.freeze

        # Maps each CRM tag group onto a Bootstrap semantic colour, so a category
        # resolves from `--bs-*` and tracks `data-bs-theme`. This is the single source
        # of truth for that mapping — every key in GROUPS has an entry (asserted in
        # the spec) — and since #168 **every** engine renderer of tag-group colour
        # reads it: this component, Badge's `:tag_group` variant, the contact/
        # engagement cards, both list rows, both detail panels, TagInput (server and
        # its Stimulus controller), FilterChipBar and DataTable.
        #
        # MPI maps `$info` -> `$primary` (`_tokens_values.scss`), so `info` would
        # render the same blue as `primary`; the palette therefore offers five
        # distinct adaptive hues, and the three cool categories collapse onto
        # `primary` (blue). This is an accepted trade of Option A (#151) — the tag's
        # always-present text label carries the identity, not the hue alone.
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

        def variant
          GROUP_VARIANTS[@group] || :secondary
        end

        # The chip's surface and foreground come from the semantic `-subtle`/
        # `-emphasis` pair, which Bootstrap derives to clear AA in both colour modes
        # (measured 9.34:1-9.43:1 in light) and which re-resolves under
        # `data-bs-theme`. Replaces the frozen brand-hex pair that ISS#142 measured
        # below the AA floor. (#168)
        def chip_classes
          "rounded-pill bg-#{variant}-subtle text-#{variant}-emphasis"
        end

        # Geometry only. `border-radius: 999px` moved to `rounded-pill`; colour moved
        # to `chip_classes`. The em padding, per-size font-size and line-height have
        # no Bootstrap equivalent and stay inline deliberately. (#168)
        def chip_styles
          [
            "font-size: #{@size == :sm ? '12px' : '13px'}",
            "padding: 0.25em 0.75em",
            "line-height: 1.4"
          ].join("; ")
        end

        # `currentColor` — NOT a solid `bg-#{variant}` like DataTable's dots. This dot
        # sits INSIDE the `-subtle` chip, and a solid semantic fill on its own subtle
        # surface measures 2.67:1 (success) / 2.62:1 (warning) — below the 3:1 floor
        # `.claude/rules/frontend.md` requires for a decorative semantic dot. Painting
        # `currentColor` inherits the chip's `-emphasis` foreground instead (9.43:1 /
        # 9.34:1), is adaptive by construction, and needs no second token. Dots on a
        # plain card/row backdrop keep the solid `bg-#{variant}` treatment, where the
        # DataTable browser spec already proves >=3:1. (#168)
        def dot_styles
          [
            "width: 8px",
            "height: 8px",
            "border-radius: 50%",
            "background-color: currentColor",
            "flex-shrink: 0"
          ].join("; ")
        end

        # Geometry only. Colour, background and border come from
        # `text-reset bg-transparent border-0` in the template, so the button inherits
        # the chip's `-emphasis` foreground and pins nothing of its own. The retired
        # `opacity: 0.6` faded an already-sub-AA foreground further — the same defect
        # #130 removed from FilterChipBar at 0.8. (#130, #168)
        def remove_button_styles
          [
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
