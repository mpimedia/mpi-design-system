# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module ActiveFilterBar
      class Component < ViewComponent::Base
        # @param filters [Array<Hash>] Each: { category: String, value: String, remove_url: String }
        # @param clear_all_url [String] URL to clear all active filters
        def initialize(filters: [], clear_all_url: nil)
          @filters = filters || []
          @clear_all_url = clear_all_url
        end

        private

        # Geometry only. The surface and radius come from `.bg-body-secondary.rounded`
        # in the template, so the bar tracks `data-bs-theme` instead of pinning a light
        # `#F5F7FA`. That adaptive surface is why the template no longer pins
        # `data-bs-theme="light"` — the pin existed only to freeze the light hex. (#150)
        def bar_styles
          [
            "display: flex",
            "align-items: center",
            "flex-wrap: wrap",
            "gap: 8px",
            "padding: 10px 16px"
          ].join("; ")
        end

        # Colour comes from Bootstrap's `.text-body-secondary`, not a pinned hex.
        # The retired `#6C757D` scored 4.37:1 on this bar — below the AA floor. (#130)
        def label_styles
          [
            "font-size: 11px",
            "font-weight: 700",
            "text-transform: uppercase",
            "letter-spacing: 0.06em"
          ].join("; ")
        end

        # Geometry only. Background and foreground come from `.text-bg-primary`,
        # which derives an accessible foreground from the consuming app's actual
        # `$primary` — so the pill tracks a token override instead of pinning
        # `#2E75B6` and silently desynchronising from it. (#130)
        def pill_styles
          [
            "display: inline-flex",
            "align-items: center",
            "gap: 6px",
            "padding: 4px 10px",
            "font-size: 12px",
            "font-weight: 500"
          ].join("; ")
        end

        # `color: inherit` picks up whatever foreground `.text-bg-primary` derived
        # for the pill. The retired `opacity: 0.8` faded white to an effective
        # #D5E3F0 — 3.71:1, an AA failure that no `color:` audit would have caught,
        # so there is deliberately no opacity-based hover treatment here. (#130)
        def remove_btn_styles
          [
            "color: inherit",
            "background: none",
            "border: none",
            "padding: 0",
            "font-size: inherit",
            "line-height: 1",
            "cursor: pointer",
            "text-decoration: none"
          ].join("; ")
        end

        def clear_all_styles
          "font-size: 13px; text-decoration: none;"
        end

        def pill_label(filter)
          "#{filter[:category]}: #{filter[:value]}"
        end

        def show?
          @filters.any?
        end
      end
    end
  end
end
