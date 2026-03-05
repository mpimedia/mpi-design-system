# frozen_string_literal: true

module Admin
  module ListView
    class Component < ViewComponent::Base
      renders_one :table_content
      renders_one :card_content

      ENTITY_TYPES = %i[contacts accounts engagements].freeze
      SORT_OPTIONS = {
        contacts: [
          [ "Last Engaged", "last_engaged" ],
          [ "Name A\u2013Z", "name_asc" ],
          [ "Name Z\u2013A", "name_desc" ],
          [ "Date Added", "date_added" ],
          [ "Account", "account" ],
          [ "Engagement Count", "engagement_count" ]
        ],
        accounts: [
          [ "Last Engaged", "last_engaged" ],
          [ "Name A\u2013Z", "name_asc" ],
          [ "Name Z\u2013A", "name_desc" ],
          [ "Contacts", "contacts_count" ],
          [ "Health", "health" ]
        ],
        engagements: [
          [ "Most Recent", "most_recent" ],
          [ "Type", "type" ],
          [ "Contact", "contact" ]
        ]
      }.freeze

      # @param entity_type [Symbol] :contacts, :accounts, :engagements
      # @param groups [Array<Hash>] Each: { label: String, count: Integer, group: Symbol, selected: Boolean }
      # @param sub_groups [Array<Hash>] Each: { name: String, selected: Boolean } (shown when a group is selected)
      # @param selected_group_color [String] Hex color of the selected group (for sub-group pills)
      # @param selected_group_bg [String] Hex bg color of the selected group
      # @param total_count [Integer] Total results
      # @param current_page [Integer]
      # @param per_page [Integer] Default 25
      # @param sort_by [String] Current sort field
      # @param view_mode [Symbol] :list (default) or :card
      # @param search_query [String] Optional search keyword
      # @param search_summary [String] Result summary text (e.g., "23 contacts match investors in Buyers")
      # @param list_url [String] URL for list view toggle
      # @param card_url [String] URL for card view toggle
      # @param active_filters [Array<Hash>] Active filter pills
      # @param clear_all_url [String] URL to clear all filters
      def initialize(entity_type: :contacts, groups: [], sub_groups: [],
                     selected_group_color: nil, selected_group_bg: nil,
                     total_count: 0, current_page: 1, per_page: 25,
                     sort_by: nil, view_mode: :list, search_query: nil,
                     search_summary: nil,
                     list_url: "#", card_url: "#",
                     active_filters: [], clear_all_url: nil)
        @entity_type = ENTITY_TYPES.include?(entity_type) ? entity_type : :contacts
        @groups = groups || []
        @sub_groups = sub_groups || []
        @selected_group_color = selected_group_color
        @selected_group_bg = selected_group_bg
        @total_count = total_count
        @current_page = current_page
        @per_page = [ per_page.to_i, 1 ].max
        @sort_by = sort_by || sort_options.first&.last
        @view_mode = view_mode == :card ? :card : :list
        @search_query = search_query
        @search_summary = search_summary
        @list_url = list_url
        @card_url = card_url
        @active_filters = active_filters || []
        @clear_all_url = clear_all_url
      end

      private

      def sort_options
        SORT_OPTIONS[@entity_type] || []
      end

      def total_pages
        return 1 if @total_count == 0

        (@total_count.to_f / @per_page).ceil
      end

      def result_label
        @entity_type.to_s
      end

      def show_sub_groups?
        @sub_groups.any?
      end

      def list_view?
        @view_mode == :list
      end

      def card_view?
        @view_mode == :card
      end

      def show_search_summary?
        @search_summary.present?
      end

      def subgroup_bar_styles
        [
          "display: flex",
          "align-items: center",
          "gap: 6px",
          "padding: 8px 12px",
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 6px"
        ].join("; ")
      end

      def subgroup_label_styles
        [
          "font-size: 10px",
          "font-weight: 600",
          "text-transform: uppercase",
          "letter-spacing: 0.06em",
          "color: #6C757D"
        ].join("; ")
      end

      def subgroup_pill_styles(selected)
        styles = [
          "padding: 3px 10px",
          "border-radius: 999px",
          "font-size: 11px",
          "font-weight: 500",
          "text-decoration: none",
          "display: inline-block"
        ]

        if selected && @selected_group_color
          styles.concat([
            "border: 1px solid #{@selected_group_color}",
            "background: #{@selected_group_bg || '#fff'}",
            "color: #{@selected_group_color}"
          ])
        else
          styles.concat([
            "border: 1px solid #DEE2E6",
            "background: #fff",
            "color: #6C757D"
          ])
        end

        styles.join("; ")
      end

      def search_summary_styles
        "font-size: 13px; color: #6C757D; margin-bottom: 12px;"
      end

      def section_spacing_styles
        "margin-bottom: 16px;"
      end
    end
  end
end
