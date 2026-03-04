# frozen_string_literal: true

class Admin::EmptyState::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::EmptyState::Component.new(
      icon: "bi-people",
      heading: "No contacts found",
      description: "Get started by adding your first contact to the CRM.",
      action_label: "Add Contact",
      action_url: "#",
      action_icon: "bi-plus-lg"
    )
  end

  # @label With Shortcuts
  def with_shortcuts
    render Admin::EmptyState::Component.new(
      icon: "bi-search",
      heading: "No results for your search",
      description: "Try adjusting your search or filter criteria.",
      shortcuts: [
        { title: "View all contacts", description: "Browse the full contact list", href: "#" },
        { title: "Import contacts", description: "Upload a CSV file", href: "#" },
        { title: "Add manually", description: "Create a new contact record", href: "#" }
      ]
    )
  end

  # @label Minimal
  def minimal
    render Admin::EmptyState::Component.new(
      heading: "No activity yet",
      description: "Engagements will appear here once recorded."
    )
  end
end
