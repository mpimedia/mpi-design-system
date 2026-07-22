# frozen_string_literal: true

class MpiDesignSystem::Admin::AppShell::ComponentPreview < ApplicationComponentPreview
  # @label Default (Dashboard)
  def default
    render_with_template(
      locals: {
        current_section: :dashboard,
        user_name: "Jane Cooper",
        search_url: "#",
        show_sidebar: false
      }
    )
  end

  # @label CRM with Sidebar
  def crm_with_sidebar
    render_with_template(
      locals: {
        current_section: :crm,
        current_subsection: :contacts,
        user_name: "Jane Cooper",
        search_url: "#",
        show_sidebar: true
      }
    )
  end

  # @label Custom CRM App
  def custom_crm_app
    render_with_template(
      locals: {
        current_section: :crm,
        current_subsection: :contacts,
        user_name: "Jane Cooper",
        search_url: "#",
        show_sidebar: false,
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
        logo_text: "MARKAZ",
        system_url: "/admin/system",
        sign_out_url: "/sign_out",
        profile_url: "/admin/profile",
        environment: :development
      }
    )
  end

  # @label With Breadcrumb
  def with_breadcrumb
    render_with_template(
      locals: {
        current_section: :crm,
        current_subsection: :contacts,
        user_name: "Jane Cooper",
        search_url: "#",
        show_sidebar: false,
        sign_out_url: "/sign_out"
      }
    )
  end

  # The #154 conversion reaches the shell surfaces too — sidebar, breadcrumb, and
  # main all resolve from Bootstrap runtime custom properties, so the whole frame
  # follows `data-bs-theme`. Light and dark side by side. (#154)
  #
  # @label Theme Adaptive
  def theme_adaptive
    render_with_template
  end
end
