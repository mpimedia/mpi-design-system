# frozen_string_literal: true

module Admin
  module ContactCard
    class Component < ViewComponent::Base
      # @param name [String] Contact full name
      # @param initials [String] Two-letter initials for avatar
      # @param avatar_color [String] Hex color for avatar background
      # @param company [String] Company/organization name
      # @param tags [Array<Hash>] Each: { label: String, color: String, bg_color: String }
      # @param last_engaged [String] Relative time (e.g., "2 days ago")
      # @param owner_name [String] Internal owner display name
      # @param path [String] URL to contact detail page
      def initialize(name:, company: nil, tags: [], last_engaged: nil, owner_name: nil, path: "#")
        @name = name
        @company = company
        @tags = tags || []
        @last_engaged = last_engaged
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

      def tag_pill_styles(tag)
        [
          "display: inline-block",
          "padding: 2px 8px",
          "border-radius: 999px",
          "font-size: 11px",
          "font-weight: 500",
          "color: #{tag[:color]}",
          "background-color: #{tag[:bg_color]}"
        ].join("; ")
      end

      def meta_styles
        "font-size: 11px; color: #ADB5BD;"
      end
    end
  end
end
