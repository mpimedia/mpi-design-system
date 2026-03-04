# frozen_string_literal: true

module Admin
  module NavBar
    class Component < ViewComponent::Base
      SECTIONS = [
        { key: :dashboard, label: "Dashboard", href: "/dashboard" },
        { key: :content, label: "Content", href: "/content" },
        { key: :crm, label: "CRM", href: "/crm" },
        { key: :rights_avails, label: "Rights & Avails", href: "/rights-avails" },
        { key: :releases, label: "Releases", href: "/releases" },
        { key: :screenings, label: "Screenings", href: "/screenings" }
      ].freeze

      SUBSECTIONS = {
        crm: [
          { key: :dashboard, label: "Dashboard", href: "/crm/dashboard" },
          { key: :contacts, label: "Contacts", href: "/crm/contacts" },
          { key: :accounts, label: "Accounts", href: "/crm/accounts" },
          { key: :engagements, label: "Engagements", href: "/crm/engagements" }
        ]
      }.freeze

      # @param current_section [Symbol] :dashboard, :content, :crm, :rights_avails, :releases, :screenings
      # @param current_subsection [Symbol] Section-specific (e.g., :contacts, :accounts for CRM)
      # @param user_name [String] Current user name (for avatar)
      # @param search_url [String] Global search action URL
      def initialize(current_section: nil, current_subsection: nil, user_name: nil, search_url: nil)
        @current_section = current_section
        @current_subsection = current_subsection
        @user_name = user_name
        @search_url = search_url
      end

      private

      def topbar_styles
        [
          "background: #fff",
          "border-bottom: 1px solid #DEE2E6",
          "height: 52px"
        ].join("; ")
      end

      def subnav_styles
        [
          "background: #fff",
          "border-bottom: 1px solid #DEE2E6",
          "height: 42px"
        ].join("; ")
      end

      def nav_item_styles(active)
        styles = [
          "font-size: 14px",
          "padding: 14px 12px",
          "text-decoration: none",
          "border-bottom: 2px solid #{active ? '#2E75B6' : 'transparent'}"
        ]
        if active
          styles.concat([ "color: #2E75B6", "font-weight: 600" ])
        else
          styles.concat([ "color: #6C757D", "font-weight: 500" ])
        end
        styles.join("; ")
      end

      def subnav_item_styles(active)
        styles = [
          "font-size: 13px",
          "padding: 10px 12px",
          "text-decoration: none",
          "border-bottom: 2px solid #{active ? '#2E75B6' : 'transparent'}"
        ]
        if active
          styles.concat([ "color: #2E75B6", "font-weight: 600" ])
        else
          styles.concat([ "color: #6C757D", "font-weight: 500" ])
        end
        styles.join("; ")
      end

      def logo_text_styles
        "font-weight: 300; letter-spacing: 0.12em; color: #1B2A4A; font-size: 14px; text-decoration: none;"
      end

      def show_subnav?
        @current_section && SUBSECTIONS.key?(@current_section)
      end

      def subsections
        SUBSECTIONS[@current_section] || []
      end

      def nexus_svg
        <<~SVG.html_safe
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <path d="M12 2L2 12L12 22L22 12L12 2Z" fill="#2E75B6"/>
            <path d="M12 2L2 12H12V2Z" fill="#1B2A4A" opacity="0.6"/>
            <path d="M12 22L22 12H12V22Z" fill="#1B2A4A" opacity="0.6"/>
          </svg>
        SVG
      end
    end
  end
end
