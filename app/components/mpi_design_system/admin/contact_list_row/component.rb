# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module ContactListRow
      class Component < ViewComponent::Base
        VARIANTS = %i[default search_result].freeze

        # Replaces the local TAG_DOT_COLORS hex map (derived from the frozen GROUPS
        # palette) with the shared group -> semantic mapping. (#168)
        GROUP_VARIANTS = MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS

        STATUSES = %i[active inactive].freeze

        # @param name [String] Contact full name
        # @param title [String] Job title
        # @param tags [Array<Hash>] Each: { group: Symbol, role: String }
        # @param last_engagement [String] Relative time string (e.g., "2 days ago")
        # @param account_name [String] Linked account name
        # @param account_path [String] URL to account detail
        # @param variant [Symbol] :default, :search_result
        # @param match_text [String] Search match context (search_result variant)
        # @param status [Symbol] :active, :inactive (search_result variant)
        def initialize(name:, title: nil, tags: [], last_engagement: nil, account_name: nil,
                       account_path: nil, variant: :default, match_text: nil, status: nil)
          @name = name
          @title = title
          @tags = tags || []
          @last_engagement = last_engagement
          @account_name = account_name
          @account_path = account_path
          @variant = VARIANTS.include?(variant) ? variant : :default
          @match_text = match_text
          @status = STATUSES.include?(status) ? status : nil
        end

        private

        def name_styles
          "font-weight: 600; color: #1B2A4A; font-size: 14px;"
        end

        def title_styles
          "font-size: 12px; color: #6C757D;"
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

        def meta_text_styles
          "font-size: 13px; color: #6C757D;"
        end

        def account_link_styles
          "color: #2E75B6; font-size: 13px; text-decoration: none;"
        end

        def cell_styles
          "vertical-align: middle;"
        end

        def status_dot_style
          color = @status == :active ? "#22A06B" : "#6C757D"
          "width: 6px; height: 6px; border-radius: 50%; background: #{color}; display: inline-block;"
        end

        def status_text_styles
          color = @status == :active ? "#22A06B" : "#6C757D"
          "font-size: 13px; color: #{color};"
        end

        def search_result?
          @variant == :search_result
        end
      end
    end
  end
end
