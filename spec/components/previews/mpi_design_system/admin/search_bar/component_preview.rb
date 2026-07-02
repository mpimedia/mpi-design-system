# frozen_string_literal: true

class MpiDesignSystem::Admin::SearchBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::SearchBar::Component.new(placeholder: "Search contacts...")
  end

  # @label With Value
  def with_value
    render MpiDesignSystem::Admin::SearchBar::Component.new(
      placeholder: "Search contacts...",
      value: "Jane Cooper"
    )
  end

  # @label Large Size
  def large
    render MpiDesignSystem::Admin::SearchBar::Component.new(
      placeholder: "Search across all records...",
      size: :lg
    )
  end

  # @label With Button
  def with_button
    render MpiDesignSystem::Admin::SearchBar::Component.new(
      placeholder: "Search...",
      show_button: true,
      url: "#"
    )
  end

  # @label With Search and Export Buttons
  def with_search_and_export
    render MpiDesignSystem::Admin::SearchBar::Component.new(
      placeholder: "Search by name, company, email, or keyword...",
      show_button: true,
      show_export: true,
      export_url: "#",
      url: "#",
      size: :lg
    )
  end
end
