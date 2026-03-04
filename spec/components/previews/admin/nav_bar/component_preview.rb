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
end
