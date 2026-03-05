# frozen_string_literal: true

module Admin
  module AccountListRow
    class Component < ViewComponent::Base
      HEALTH_STATUSES = {
        active: { color: "#22A06B", label: "Active" },
        warm: { color: "#D4772C", label: "Warm" },
        cold: { color: "#DC3545", label: "Cold" }
      }.freeze

      TAG_DOT_COLORS = Admin::TagChip::Component::GROUPS.transform_values { |v| v[:color] }.freeze

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

      def tag_dot_style(group)
        color = TAG_DOT_COLORS[group] || "#64748B"
        "width: 6px; height: 6px; border-radius: 50%; background: #{color}; display: inline-block;"
      end

      def tag_text_styles
        "font-size: 13px; font-weight: 500; color: #1B2A4A;"
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
