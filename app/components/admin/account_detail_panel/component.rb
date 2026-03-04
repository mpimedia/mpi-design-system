# frozen_string_literal: true

module Admin
  module AccountDetailPanel
    class Component < ViewComponent::Base
      # @param name [String] Account name
      # @param account_type [String] Account type label (e.g., "Distributor", "Studio")
      # @param account_type_color [Symbol] Badge color :primary, :success, :danger, :warning, :secondary (default: :primary)
      # @param contacts [Array<Hash>] Each: { name: String, title: String, path: String }
      # @param email [String] Account email
      # @param phone [String] Account phone
      # @param location [String] Account location
      # @param created_date [String] Date created (e.g., "Jan 10, 2025")
      # @param owner [Hash] { name: String, path: String }
      def initialize(name:, account_type: nil, account_type_color: :primary,
                     contacts: [], email: nil, phone: nil, location: nil,
                     created_date: nil, owner: nil)
        @name = name
        @account_type = account_type
        @account_type_color = %i[primary success danger warning secondary].include?(account_type_color) ? account_type_color : :primary
        @contacts = contacts || []
        @email = email
        @phone = phone
        @location = location
        @created_date = created_date
        @owner = owner
      end

      private

      def card_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 8px",
          "padding: 20px"
        ].join("; ")
      end

      def name_styles
        "font-weight: 600; color: #1B2A4A; font-size: 18px; margin: 0;"
      end

      def section_heading_styles
        [
          "font-size: 10px",
          "font-weight: 600",
          "text-transform: uppercase",
          "letter-spacing: 0.04em",
          "color: #6C757D",
          "margin-bottom: 8px"
        ].join("; ")
      end

      def contact_name_styles
        "font-size: 13px; color: #2E75B6; text-decoration: none; font-weight: 600;"
      end

      def contact_title_styles
        "font-size: 12px; color: #6C757D;"
      end

      def contact_row_styles
        "padding: 8px 0; border-bottom: 1px solid #F0F0F0;"
      end

      def contact_last_row_styles
        "padding: 8px 0;"
      end

      def info_label_styles
        [
          "font-size: 10px",
          "font-weight: 600",
          "text-transform: uppercase",
          "letter-spacing: 0.04em",
          "color: #6C757D"
        ].join("; ")
      end

      def info_value_styles
        "font-size: 13px; color: #1B2A4A;"
      end

      def info_link_styles
        "font-size: 13px; color: #2E75B6; text-decoration: none;"
      end

      def info_row_styles
        "margin-bottom: 10px;"
      end

      def divider_styles
        "border: none; border-top: 1px solid #DEE2E6; margin: 16px 0;"
      end

      def has_contact_info?
        @email.present? || @phone.present? || @location.present? || @created_date.present? || @owner.present?
      end
    end
  end
end
