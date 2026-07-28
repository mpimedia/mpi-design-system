# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module ContactCard
      class Component < ViewComponent::Base
        GROUP_VARIANTS = MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS

        # @param name [String] Contact full name
        # @param company [String] Company/organization name
        # @param tags [Array<Hash>] Each: { label: String, group: Symbol } or { label: String, color: String, bg_color: String }
        # @param last_engaged [String] Relative time (e.g., "2 days ago")
        # @param engagement_count [Integer] Number of engagements
        # @param owner_name [String] Internal owner display name
        # @param path [String] URL to contact detail page
        def initialize(name:, company: nil, tags: [], last_engaged: nil, engagement_count: nil,
                       owner_name: nil, path: "#")
          @name = name
          @company = company
          @tags = tags || []
          @last_engaged = last_engaged
          @engagement_count = engagement_count
          @owner_name = owner_name
          @path = path
        end

        private

        def card_styles
          [
            "background: #fff",
            "border: 1px solid #DEE2E6",
            "border-radius: 8px",
            "padding: 16px",
            "text-decoration: none",
            "color: inherit",
            "display: block",
            "transition: border-color 0.15s ease"
          ].join("; ")
        end

        def name_styles
          "font-weight: 600; color: #1B2A4A; font-size: 14px;"
        end

        def company_styles
          "font-size: 13px; color: #6C757D;"
        end

        # A tag carrying caller-supplied colour is a deliberate consumer-owned
        # passthrough (the ISS#172 principle: the design system does not own
        # app-supplied values), so it keeps its exact inline hex. A known group, and
        # the no-group/no-custom default, both render the adaptive semantic pair.
        # A known group wins over custom colours, preserving today's precedence.
        def tag_variant(tag)
          GROUP_VARIANTS[tag[:group]]
        end

        def custom_tag?(tag)
          tag_variant(tag).nil? && (tag[:color].present? || tag[:bg_color].present?)
        end

        # `border-radius: 999px` -> `rounded-pill`; `display: inline-flex` /
        # `align-items: center` / `gap: 4px` -> `d-inline-flex align-items-center
        # gap-1` (matching TagChip's markup); colour -> the semantic pair.
        #
        # The no-group/no-custom fallback is now `secondary`, NOT the frozen
        # #64748B on #F1F5F9 it used to paint — ISS#142 measured that pair at
        # 4.34:1, below the AA floor. Only genuinely caller-supplied colour stays
        # inline. (#168)
        def tag_pill_classes(tag)
          base = "rounded-pill d-inline-flex align-items-center gap-1"
          return base if custom_tag?(tag)

          variant = tag_variant(tag) || :secondary
          "#{base} bg-#{variant}-subtle text-#{variant}-emphasis"
        end

        def tag_pill_styles(tag)
          geometry = [ "padding: 2px 8px", "font-size: 11px", "font-weight: 500" ]
          return geometry.join("; ") unless custom_tag?(tag)

          # Each half falls back independently, exactly as `resolve_color`/
          # `resolve_bg` did, so a caller supplying only one keeps the other's
          # historical default.
          geometry.push(
            "color: #{tag[:color] || '#64748B'}",
            "background-color: #{tag[:bg_color] || '#F1F5F9'}"
          ).join("; ")
        end

        # Geometry only. `currentColor` inherits whatever the pill paints — the
        # `-emphasis` foreground for a semantic tag, the caller's own colour for a
        # custom one — so the dot needs no branch and can never contradict its pill.
        # It also cannot repeat the solid-on-subtle contrast failure a `bg-#{variant}`
        # fill would produce inside a `-subtle` pill (2.62:1-2.67:1). (#168)
        def tag_dot_styles(_tag)
          [
            "width: 6px",
            "height: 6px",
            "border-radius: 50%",
            "background-color: currentColor",
            "flex-shrink: 0"
          ].join("; ")
        end

        def meta_styles
          "font-size: 11px; color: #ADB5BD;"
        end
      end
    end
  end
end
