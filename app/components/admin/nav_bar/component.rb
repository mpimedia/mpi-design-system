# frozen_string_literal: true

module Admin
  module NavBar
    class Component < ViewComponent::Base
      DEFAULT_SECTIONS = [
        { key: :dashboard, label: "Dashboard", href: "/dashboard" },
        { key: :content, label: "Content", href: "/content" },
        { key: :crm, label: "CRM", href: "/crm" },
        { key: :rights_avails, label: "Rights & Avails", href: "/rights-avails" },
        { key: :releases, label: "Releases", href: "/releases" },
        { key: :screenings, label: "Screenings", href: "/screenings" }
      ].freeze

      DEFAULT_SUBSECTIONS = {
        crm: [
          { key: :dashboard, label: "Dashboard", href: "/crm/dashboard" },
          { key: :contacts, label: "Contacts", href: "/crm/contacts" },
          { key: :accounts, label: "Accounts", href: "/crm/accounts" },
          { key: :engagements, label: "Engagements", href: "/crm/engagements" }
        ]
      }.freeze

      ENVIRONMENT_COLORS = {
        development: "#2E75B6",
        staging: "#DC3545",
        production: nil
      }.freeze

      # @param current_section [Symbol] Active top-level section key
      # @param current_subsection [Symbol] Active subsection key
      # @param user_name [String] Current user name (for avatar)
      # @param search_url [String] Global search action URL
      # @param sections [Array<Hash>] Custom top-level sections (overrides defaults)
      # @param subsections [Hash{Symbol => Array<Hash>}] Custom subsections (overrides defaults)
      # @param environment [Symbol] :development, :staging, :production (for color-coding)
      # @param system_url [String] URL for system admin gear icon (shown when present)
      # @param sign_out_url [String] URL for sign-out action
      # @param sign_out_method [Symbol] HTTP method for sign-out (default: :delete)
      # @param profile_url [String] Optional URL for user profile link
      # @param logo_text [String] Logo text (default: "MARKAZ")
      # @param logo_href [String] Logo link URL (default: first section's href or "/")
      def initialize(current_section: nil, current_subsection: nil, user_name: nil, search_url: nil,
                     sections: nil, subsections: nil, environment: nil, system_url: nil,
                     sign_out_url: nil, sign_out_method: :delete, profile_url: nil,
                     logo_text: "MARKAZ", logo_href: nil)
        @current_section = current_section
        @current_subsection = current_subsection
        @user_name = user_name
        @search_url = search_url
        @sections = sections || DEFAULT_SECTIONS
        @subsections = subsections || DEFAULT_SUBSECTIONS
        @environment = environment
        @system_url = system_url
        @sign_out_url = sign_out_url
        @sign_out_method = sign_out_method
        @profile_url = profile_url
        @logo_text = logo_text
        @logo_href = logo_href
      end

      def before_render
        @logo_href ||= visible_sections.first&.dig(:href) || "/"
      end

      private

      def visible_sections
        @sections.select { |s| s.fetch(:visible, true) }
      end

      def topbar_styles
        styles = [
          "border-bottom: 1px solid #DEE2E6",
          "height: 52px"
        ]
        bg = environment_color
        styles << "background: #{bg || '#fff'}"
        styles.join("; ")
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
          styles.concat([ "color: #{environment_color ? '#fff' : '#2E75B6'}", "font-weight: 600" ])
        else
          styles.concat([ "color: #{environment_color ? 'rgba(255,255,255,0.75)' : '#6C757D'}", "font-weight: 500" ])
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
        color = environment_color ? "#fff" : "#1B2A4A"
        "font-weight: 300; letter-spacing: 0.12em; color: #{color}; font-size: 14px; text-decoration: none;"
      end

      def show_subnav?
        @current_section && current_subsections.any?
      end

      def current_subsections
        @subsections[@current_section] || []
      end

      def environment_color
        @environment && ENVIRONMENT_COLORS[@environment]
      end

      def show_user_menu?
        @sign_out_url || @profile_url
      end

      def nexus_svg
        fill = environment_color ? "#fff" : "#2E75B6"
        accent = environment_color ? "rgba(255,255,255,0.6)" : "#1B2A4A"
        <<~SVG.html_safe
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <path d="M12 2L2 12L12 22L22 12L12 2Z" fill="#{fill}"/>
            <path d="M12 2L2 12H12V2Z" fill="#{accent}" opacity="0.6"/>
            <path d="M12 22L22 12H12V22Z" fill="#{accent}" opacity="0.6"/>
          </svg>
        SVG
      end

      def gear_svg
        color = environment_color ? "#fff" : "#6C757D"
        <<~SVG.html_safe
          <svg width="18" height="18" viewBox="0 0 16 16" fill="#{color}" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <path d="M8 4.754a3.246 3.246 0 1 0 0 6.492 3.246 3.246 0 0 0 0-6.492zM5.754 8a2.246 2.246 0 1 1 4.492 0 2.246 2.246 0 0 1-4.492 0z"/>
            <path d="M9.796 1.343c-.527-1.79-3.065-1.79-3.592 0l-.094.319a.873.873 0 0 1-1.255.52l-.292-.16c-1.64-.892-3.433.902-2.54 2.541l.159.292a.873.873 0 0 1-.52 1.255l-.319.094c-1.79.527-1.79 3.065 0 3.592l.319.094a.873.873 0 0 1 .52 1.255l-.16.292c-.892 1.64.901 3.434 2.541 2.54l.292-.159a.873.873 0 0 1 1.255.52l.094.319c.527 1.79 3.065 1.79 3.592 0l.094-.319a.873.873 0 0 1 1.255-.52l.292.16c1.64.893 3.434-.902 2.54-2.541l-.159-.292a.873.873 0 0 1 .52-1.255l.319-.094c1.79-.527 1.79-3.065 0-3.592l-.319-.094a.873.873 0 0 1-.52-1.255l.16-.292c.893-1.64-.902-3.433-2.541-2.54l-.292.159a.873.873 0 0 1-1.255-.52l-.094-.319zm-2.633.283c.246-.835 1.428-.835 1.674 0l.094.319a1.873 1.873 0 0 0 2.693 1.115l.291-.16c.764-.415 1.6.42 1.184 1.185l-.159.292a1.873 1.873 0 0 0 1.116 2.692l.318.094c.835.246.835 1.428 0 1.674l-.319.094a1.873 1.873 0 0 0-1.115 2.693l.16.291c.415.764-.42 1.6-1.185 1.184l-.291-.159a1.873 1.873 0 0 0-2.693 1.116l-.094.318c-.246.835-1.428.835-1.674 0l-.094-.319a1.873 1.873 0 0 0-2.692-1.115l-.292.16c-.764.415-1.6-.42-1.184-1.185l.159-.291A1.873 1.873 0 0 0 1.945 8.93l-.319-.094c-.835-.246-.835-1.428 0-1.674l.319-.094A1.873 1.873 0 0 0 3.06 4.377l-.16-.292c-.415-.764.42-1.6 1.185-1.184l.292.159a1.873 1.873 0 0 0 2.692-1.115l.094-.319z"/>
          </svg>
        SVG
      end
    end
  end
end
