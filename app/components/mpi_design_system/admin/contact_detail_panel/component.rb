# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module ContactDetailPanel
      class Component < ViewComponent::Base
        GROUP_VARIANTS = MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS

        # @param name [String] Contact full name
        # @param title [String] Contact job title
        # @param company [String] Company/organization name
        # @param tags [Array<Hash>] Each: { label: String, group: Symbol, remove_url: String (optional) }
        # @param add_tag_path [String] URL for "+ Add tag" link
        # @param email [String] Contact email address
        # @param phone [String] Contact phone number
        # @param account [Hash] { name: String, path: String }
        # @param location [String] Location text
        # @param added_date [String] Date added (e.g., "Jan 15, 2026")
        # @param owner [Hash] { name: String, path: String }
        # @param auto_groups [Array<Hash>] Each: { label: String, group: Symbol }
        def initialize(name:, title: nil, company: nil, tags: [], add_tag_path: nil,
                       email: nil, phone: nil, account: nil, location: nil,
                       added_date: nil, owner: nil, auto_groups: [])
          @name = name
          @title = title
          @company = company
          @tags = tags || []
          @add_tag_path = add_tag_path
          @email = email
          @phone = phone
          @account = account
          @location = location
          @added_date = added_date
          @owner = owner
          @auto_groups = auto_groups || []
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

        def title_styles
          "font-size: 13px; color: #6C757D; margin-top: 2px;"
        end

        def company_styles
          "font-size: 13px; color: #6C757D;"
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

        def add_tag_styles
          "font-size: 13px; color: #2E75B6; text-decoration: none;"
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

        # Covers the auto-groups pills only — this panel's `@tags` render through a
        # nested `TagChip::Component`, which carries its own conversion. An unknown
        # group falls back to `secondary`, the semantic equivalent of the `:internal`
        # pair this previously fell back to. (#168)
        def group_pill_classes(group_sym)
          variant = GROUP_VARIANTS[group_sym] || :secondary
          "rounded-pill d-inline-block bg-#{variant}-subtle text-#{variant}-emphasis"
        end

        # Geometry only. (#168)
        def group_pill_styles
          [
            "padding: 2px 8px",
            "font-size: 11px",
            "font-weight: 500"
          ].join("; ")
        end

        def has_contact_info?
          @email.present? || @phone.present? || @account.present? || @location.present? || @added_date.present? || @owner.present?
        end
      end
    end
  end
end
