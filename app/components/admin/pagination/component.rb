# frozen_string_literal: true

module Admin
  module Pagination
    class Component < ViewComponent::Base
      # @param current_page [Integer] Current active page (1-based)
      # @param total_pages [Integer] Total number of pages
      # @param total_count [Integer] Total number of records
      # @param per_page [Integer] Records per page (default: 25)
      # @param url_builder [Proc] Lambda that builds page URLs: ->(page) { "?page=#{page}" }
      # @param turbo_frame [String] Turbo Frame target for page loads
      def initialize(current_page:, total_pages:, total_count:, per_page: 25, url_builder: nil, turbo_frame: nil)
        @current_page = current_page
        @total_pages = [total_pages, 1].max
        @total_count = total_count
        @per_page = per_page
        @url_builder = url_builder || ->(page) { "?page=#{page}" }
        @turbo_frame = turbo_frame
      end

      private

      def results_text
        start_record = ((@current_page - 1) * @per_page) + 1
        end_record = [@current_page * @per_page, @total_count].min
        "Showing #{start_record}\u2013#{end_record} of #{@total_count} results"
      end

      def results_text_styles
        "font-size: 13px; color: #2E75B6;"
      end

      def page_btn_styles(active: false)
        styles = [
          "width: 32px",
          "height: 32px",
          "border-radius: 6px",
          "font-size: 13px",
          "font-weight: 500",
          "display: inline-flex",
          "align-items: center",
          "justify-content: center",
          "text-decoration: none"
        ]
        if active
          styles.concat(["background: #2E75B6", "color: #fff", "border: 1px solid #2E75B6"])
        else
          styles.concat(["background: #fff", "color: #1B2A4A", "border: 1px solid #DEE2E6"])
        end
        styles.join("; ")
      end

      def page_url(page)
        @url_builder.call(page)
      end

      def show_prev?
        @current_page > 1
      end

      def show_next?
        @current_page < @total_pages
      end

      def turbo_data
        @turbo_frame ? { turbo_frame: @turbo_frame } : {}
      end

      def pages
        (1..@total_pages).to_a
      end
    end
  end
end
