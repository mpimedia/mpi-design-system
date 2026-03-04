# frozen_string_literal: true

class Admin::AppShell::ComponentPreview < ApplicationComponentPreview
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
end
