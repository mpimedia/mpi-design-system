# frozen_string_literal: true

class Admin::NavBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#"
    )
  end

  # @label CRM Section (with Sub-Nav)
  def crm_section
    render Admin::NavBar::Component.new(
      current_section: :crm,
      current_subsection: :contacts,
      user_name: "Jane Cooper",
      search_url: "#"
    )
  end

  # @label Content Section
  def content_section
    render Admin::NavBar::Component.new(
      current_section: :content,
      user_name: "Robert Fox",
      search_url: "#"
    )
  end

  # @label No User
  def no_user
    render Admin::NavBar::Component.new(
      current_section: :dashboard,
      search_url: "#"
    )
  end

  # @label Custom Sections (CRM App)
  def custom_sections
    render Admin::NavBar::Component.new(
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
    render Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#",
      environment: :development,
      sign_out_url: "/sign_out"
    )
  end

  # @label Staging Environment
  def staging_environment
    render Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#",
      environment: :staging,
      sign_out_url: "/sign_out"
    )
  end

  # @label With User Menu
  def with_user_menu
    render Admin::NavBar::Component.new(
      current_section: :dashboard,
      user_name: "Jane Cooper",
      search_url: "#",
      sign_out_url: "/sign_out",
      profile_url: "/profile"
    )
  end
end
