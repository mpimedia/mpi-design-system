# frozen_string_literal: true

class MpiDesignSystem::Admin::ActiveFilterBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::ActiveFilterBar::Component.new(
      filters: [
        { category: "Keyword", value: "investors", remove_url: "#" },
        { category: "Group", value: "Distribution", remove_url: "#" }
      ],
      clear_all_url: "#"
    )
  end

  # @label Single Filter
  def single_filter
    render MpiDesignSystem::Admin::ActiveFilterBar::Component.new(
      filters: [
        { category: "Tag", value: "Acquisitions", remove_url: "#" }
      ]
    )
  end

  # @label Many Filters
  def many_filters
    render MpiDesignSystem::Admin::ActiveFilterBar::Component.new(
      filters: [
        { category: "Keyword", value: "distribution", remove_url: "#" },
        { category: "Group", value: "Distribution", remove_url: "#" },
        { category: "Sub-group", value: "Theatrical", remove_url: "#" },
        { category: "Last Engaged", value: "30 days", remove_url: "#" }
      ],
      clear_all_url: "#"
    )
  end
end
