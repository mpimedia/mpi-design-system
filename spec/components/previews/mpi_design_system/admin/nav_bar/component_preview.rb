# frozen_string_literal: true

class MpiDesignSystem::Admin::NavBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#"
    )
  end

  # @label CRM Section (with Sub-Nav)
  def crm_section
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :crm,
      current_subsection: :contacts,
      user_name: "Jane Cooper",
      search_url: "#"
    )
  end

  # @label Content Section
  def content_section
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :content,
      user_name: "Robert Fox",
      search_url: "#"
    )
  end

  # @label No User
  def no_user
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :dashboard,
      search_url: "#"
    )
  end

  # @label Custom Sections (CRM App)
  def custom_sections
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :crm,
      current_subsection: :contacts,
      user_name: "Jane Cooper",
      search_url: "#",
      logo_text: "MARKAZ",
      sections: [
        { key: :dashboard, label: "Dashboard", href: "/admin" },
        { key: :sites, label: "Sites", href: "/admin/sites" },
        { key: :crm, label: "CRM", href: "/admin/crm" }
      ],
      subsections: {
        crm: [
          { key: :contacts, label: "Contacts", href: "/admin/contacts" },
          { key: :accounts, label: "Accounts", href: "/admin/organizations" },
          { key: :engagements, label: "Engagements", href: "/admin/engagements" }
        ]
      },
      system_url: "/admin/system",
      sign_out_url: "/sign_out",
      profile_url: "/admin/profile"
    )
  end

  # @label Development Environment
  def development_environment
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#",
      environment: :development,
      sign_out_url: "/sign_out"
    )
  end

  # @label Staging Environment
  def staging_environment
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#",
      environment: :staging,
      sign_out_url: "/sign_out"
    )
  end

  # @label With User Menu
  def with_user_menu
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#",
      sign_out_url: "/sign_out",
      profile_url: "/profile"
    )
  end

  # @label Custom Logo Mark
  def custom_logo_mark
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :dashboard,
      logo_text: "HARVEST",
      logo_mark: '<svg width="20" height="24" viewBox="0 0 24 24" fill="#4EA8DE" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><rect x="2" y="2" width="20" height="20" rx="4"/></svg>'.html_safe
    )
  end

  # @label Subsection Visibility
  def subsection_visibility
    render MpiDesignSystem::Admin::NavBar::Component.new(
      current_section: :crm,
      current_subsection: :contacts,
      sections: [ { key: :crm, label: "CRM", href: "/crm" } ],
      subsections: { crm: [
        { key: :contacts, label: "Contacts", href: "/crm/contacts" },
        { key: :accounts, label: "Accounts", href: "/crm/accounts" },
        { key: :secret, label: "Hidden (visible: false)", href: "/crm/secret", visible: false }
      ] }
    )
  end

  # The point of the #154 conversion: the same NavBar, no variant flag, following
  # Bootstrap's colour mode. Light and dark side by side so a designer can compare
  # the two surfaces — including the logo, subnav, gear, and search prepend — in one
  # view. (#154)
  #
  # @label Theme Adaptive
  def theme_adaptive
    render_with_template
  end
end
