# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module AccountListRow
      class Component < ViewComponent::Base
        HEALTH_STATUSES = {
          active: { color: "#22A06B", label: "Active" },
          warm: { color: "#D4772C", label: "Warm" },
          cold: { color: "#DC3545", label: "Cold" }
        }.freeze

        # Replaces the local TAG_DOT_COLORS hex map (derived from the frozen GROUPS
        # palette) with the shared group -> semantic mapping. (#168)
        GROUP_VARIANTS = MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS

        # @param name [String] Account/company name
        # @param type_label [String] Account type badge text (e.g., "Distributor", "Studio")
        # @param location [String] Location text (e.g., "Los Angeles, CA")
        # @param contact_names [Array<String>] Names for stacked contact avatars
        # @param tags [Array<Hash>] Each: { group: Symbol, role: String }
        # @param health [Symbol] :active, :warm, :cold
        # @param account_path [String] URL to account detail page
        def initialize(name:, type_label: nil, location: nil, contact_names: [],
                       tags: [], health: nil, account_path: nil)
          @name = name
          @type_label = type_label
          @location = location
          @contact_names = contact_names || []
          @tags = tags || []
          @health = HEALTH_STATUSES.key?(health) ? health : nil
          @account_path = account_path
        end

        private

        def name_styles
          "font-weight: 600; color: #1B2A4A; font-size: 14px; text-decoration: none;"
        end

        def type_badge_styles
          [
            "font-size: 10px",
            "font-weight: 600",
            "text-transform: uppercase",
            "letter-spacing: 0.04em",
            "border: 1px solid #DEE2E6",
            "border-radius: 4px",
            "padding: 2px 6px",
            "color: #6C757D",
            "background: #F8F9FA"
          ].join("; ")
        end

        def location_styles
          "font-size: 13px; color: #6C757D;"
        end

        # Decorative identity dot on the row surface (not inside a `-subtle` chip),
        # so it keeps the solid `bg-#{variant}` treatment DataTable's browser spec
        # already proves >=3:1 on both resting backdrops — a fixed hue across colour
        # modes by design, with the adjacent label carrying the meaning (WCAG 2.1
        # SC 1.4.11). An unknown group falls back to `secondary`. (#151, #168)
        def tag_dot_class(group)
          "d-inline-block bg-#{GROUP_VARIANTS[group] || :secondary}"
        end

        # Geometry only. (#168)
        def tag_dot_style
          "width: 6px; height: 6px; border-radius: 50%;"
        end

        # The label beside the decorative dot IS the category's accessible carrier,
        # so it must stay readable in both colour modes — the frozen #1B2A4A navy it
        # used to paint measures 1.09:1 on Bootstrap's dark surface. `text-body` in
        # the template. (#168)
        def tag_text_styles
          "font-size: 13px; font-weight: 500;"
        end

        def health_dot_style
          return "" unless @health

          color = HEALTH_STATUSES[@health][:color]
          "width: 8px; height: 8px; border-radius: 50%; background: #{color}; display: inline-block;"
        end

        def health_text_styles
          return "" unless @health

          color = HEALTH_STATUSES[@health][:color]
          "font-size: 13px; font-weight: 500; color: #{color};"
        end

        def health_label
          HEALTH_STATUSES.dig(@health, :label)
        end

        def cell_styles
          "vertical-align: middle;"
        end
      end
    end
  end
end
