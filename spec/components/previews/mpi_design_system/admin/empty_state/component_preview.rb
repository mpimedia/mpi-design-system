# frozen_string_literal: true

class MpiDesignSystem::Admin::EmptyState::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::EmptyState::Component.new(
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
    render MpiDesignSystem::Admin::EmptyState::Component.new(
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
    render MpiDesignSystem::Admin::EmptyState::Component.new(
      heading: "No activity yet",
      description: "Engagements will appear here once recorded."
    )
  end

  # @label Nested heading (:h5)
  # Empty state composed under an existing section heading — a consumer passes the level
  # that keeps the document outline monotonic (e.g. :h5 beneath a show-page <h4>).
  def nested_heading
    render MpiDesignSystem::Admin::EmptyState::Component.new(
      icon: "bi-people",
      heading: "No associated users found",
      heading_level: :h5
    )
  end
end
