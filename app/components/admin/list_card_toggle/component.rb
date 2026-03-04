# frozen_string_literal: true

module Admin
  module ListCardToggle
    class Component < ViewComponent::Base
      VIEWS = %i[list card].freeze

      # @param result_count [Integer] Total number of results
      # @param result_label [String] Contextual label (e.g., "contacts", "accounts")
      # @param active_view [Symbol] :list (default), :card
      # @param sort_options [Array<Array>] Options for sort dropdown [[label, value], ...]
      # @param sort_by [String] Current sort value
      # @param search_query [String] Optional search term for keyword highlighting
      # @param list_url [String] URL/Turbo action for list view
      # @param card_url [String] URL/Turbo action for card view
      def initialize(result_count:, result_label: "results", active_view: :list,
                     sort_options: [], sort_by: nil, search_query: nil,
                     list_url: "#", card_url: "#")
        @result_count = result_count
        @result_label = result_label
        @active_view = VIEWS.include?(active_view) ? active_view : :list
        @sort_options = sort_options
        @sort_by = sort_by
        @search_query = search_query
        @list_url = list_url
        @card_url = card_url
      end

      private

      def result_count_styles
        "font-size: 14px; color: #1B2A4A;"
      end

      def highlight_styles
        "background: #FFF3CD; border-radius: 2px; padding: 0 2px;"
      end

      def toggle_group_styles
        [
          "display: inline-flex",
          "border: 1px solid #DEE2E6",
          "border-radius: 6px",
          "overflow: hidden"
        ].join("; ")
      end

      def toggle_button_styles(view)
        active = @active_view == view
        bg = active ? "#2E75B6" : "#fff"
        color = active ? "#fff" : "#6C757D"
        [
          "width: 36px",
          "height: 32px",
          "background: #{bg}",
          "color: #{color}",
          "border: none",
          "display: inline-flex",
          "align-items: center",
          "justify-content: center",
          "cursor: pointer",
          "text-decoration: none"
        ].join("; ")
      end

      def list_button_styles
        base = toggle_button_styles(:list)
        "#{base}; border-right: 1px solid #DEE2E6"
      end

      def sort_select_styles
        [
          "font-size: 13px",
          "color: #6C757D",
          "border: 1px solid #DEE2E6",
          "border-radius: 6px",
          "padding: 4px 8px",
          "background: #fff"
        ].join("; ")
      end

      def highlighted_result_text
        escaped_count = ERB::Util.html_escape(@result_count.to_s)
        escaped_label = ERB::Util.html_escape(@result_label)
        base = "#{escaped_count} #{escaped_label}"
        return base.html_safe if @search_query.blank?

        escaped_query = ERB::Util.html_escape(@search_query)
        "#{base} for <span style=\"#{highlight_styles}\">#{escaped_query}</span>".html_safe
      end

      def list_active?
        @active_view == :list
      end

      def card_active?
        @active_view == :card
      end
    end
  end
end
