# frozen_string_literal: true

module Admin
  module ContactCard
    class Component < ViewComponent::Base
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

      def tag_pill_styles(tag)
        color = resolve_color(tag)
        bg = resolve_bg(tag)
        [
          "display: inline-flex",
          "align-items: center",
          "gap: 4px",
          "padding: 2px 8px",
          "border-radius: 999px",
          "font-size: 11px",
          "font-weight: 500",
          "color: #{color}",
          "background-color: #{bg}"
        ].join("; ")
      end

      def tag_dot_styles(tag)
        color = resolve_color(tag)
        [
          "width: 6px",
          "height: 6px",
          "border-radius: 50%",
          "background-color: #{color}",
          "flex-shrink: 0"
        ].join("; ")
      end

      def meta_styles
        "font-size: 11px; color: #ADB5BD;"
      end

      def resolve_color(tag)
        if tag[:group] && Admin::TagChip::Component::GROUPS[tag[:group]]
          Admin::TagChip::Component::GROUPS[tag[:group]][:color]
        else
          tag[:color] || "#64748B"
        end
      end

      def resolve_bg(tag)
        if tag[:group] && Admin::TagChip::Component::GROUPS[tag[:group]]
          Admin::TagChip::Component::GROUPS[tag[:group]][:bg]
        else
          tag[:bg_color] || "#F1F5F9"
        end
      end
    end
  end
end
