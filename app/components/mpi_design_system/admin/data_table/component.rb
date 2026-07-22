# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module DataTable
      class Component < ViewComponent::Base
        VARIANTS = %i[contacts search_results].freeze

        # Tag dots derive their colour from the shared tag-group -> semantic mapping,
        # so a category renders the same theme-adaptive hue everywhere it is converted.
        GROUP_VARIANTS = MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS

        # Record status -> Bootstrap semantic. Replaces the retired STATUS_COLORS hex
        # map. The status dot fill (`bg-#{sem}`) is a FIXED decorative identity hue —
        # constant across colour modes, NOT `data-bs-theme`-adaptive (see
        # `status_dot_class`); the adjacent status label carries the meaning.
        STATUS_VARIANTS = {
          active: :success,
          follow_up: :warning,
          inactive: :secondary
        }.freeze

        # @param columns [Array<Hash>] Column definitions:
        #   [{ key: :name, label: "Name", sortable: true }]
        # @param rows [Array<Hash>] Row data
        # @param sort_by [Symbol] Current sort column
        # @param sort_dir [Symbol] :asc or :desc
        # @param variant [Symbol] :contacts (default), :search_results
        def initialize(columns:, rows: [], sort_by: nil, sort_dir: :asc, variant: :contacts)
          @columns = columns
          @rows = rows || []
          @sort_by = sort_by
          @sort_dir = sort_dir
          @variant = VARIANTS.include?(variant) ? variant : :contacts
        end

        private

        # Geometry only. The muted foreground now comes from `text-body-secondary`
        # and the 2px separator from the `border-bottom` utility (colour via the
        # adaptive `--bs-border-color`), both applied in the template. The `<th>` keeps
        # `--bs-border-width: 2px` inline so the utility renders 2px on the BOTTOM edge
        # only — `border-2` would widen all four sides of a `.table th`. (#151)
        def header_styles
          [
            "font-size: 11px",
            "font-weight: 600",
            "text-transform: uppercase",
            "letter-spacing: 0.06em",
            "--bs-border-width: 2px"
          ].join("; ")
        end

        def sort_indicator(column)
          return "" unless column[:sortable] && @sort_by == column[:key]

          @sort_dir == :asc ? " \u2191" : " \u2193"
        end

        def aria_sort(column)
          return unless column[:sortable] && @sort_by == column[:key]

          @sort_dir == :asc ? "ascending" : "descending"
        end

        # Geometry only; the navy foreground now comes from `text-body` in the
        # template (adaptive via `--bs-body-color`).
        def name_styles
          "font-weight: 600; font-size: 14px;"
        end

        # Geometry only; muted foreground now comes from `text-body-secondary`.
        def title_styles
          "font-size: 12px;"
        end

        # Dots are geometry only — their fill comes from `tag_dot_class` /
        # `status_dot_class` (`bg-#{variant}`). See the dark-mode note on those.
        def dot_styles
          "width: 6px; height: 6px; border-radius: 50%;"
        end

        # Decorative identity dots. `bg-#{variant}` reads `--bs-#{variant}-rgb`, a
        # FIXED hue across colour modes rather than a `data-bs-theme`-adaptive one —
        # an intentional exception, mirroring the nav env-bar's fixed status hues: a
        # category/status IDENTITY colour should stay constant, and the browser spec
        # proves every variant >=3:1 on both the light and dark RESTING row backdrops.
        # The colour meaning is carried by the adjacent text label, so the dot is
        # purely decorative (WCAG 2.1 SC 1.4.11) — which is why the transient dip below
        # 3:1 on a HOVERED row (`table-hover` paints an inset shadow over the backdrop)
        # is acceptable and deliberately not asserted. An unknown group falls back to
        # `secondary`. (#151)
        def tag_dot_class(group)
          "d-inline-block bg-#{GROUP_VARIANTS[group] || :secondary}"
        end

        # Geometry only; navy foreground now comes from `text-body`.
        def tag_text_styles
          "font-size: 13px;"
        end

        # Geometry only; muted foreground now comes from `text-body-secondary`.
        def meta_text_styles
          "font-size: 13px;"
        end

        # Geometry only. The account anchor now uses Bootstrap's DEFAULT adaptive link
        # colour (`--bs-link-color` — AA on white ~4.6:1, `#82ACD3` in dark) and keeps
        # its natural underline as the navigation affordance, so no colour or
        # text-decoration is declared here. (#151)
        def account_link_styles
          "font-size: 13px;"
        end

        # See tag_dot_class — same decorative fixed-hue exception. Unknown status
        # falls back to `secondary`.
        def status_dot_class(status)
          "d-inline-block bg-#{STATUS_VARIANTS[status] || :secondary}"
        end
      end
    end
  end
end
