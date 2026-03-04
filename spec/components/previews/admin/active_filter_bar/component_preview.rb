# frozen_string_literal: true

class Admin::ActiveFilterBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::ActiveFilterBar::Component.new(
      filters: [
        { category: "Keyword", value: "investors", remove_url: "#" },
        { category: "Group", value: "Buyers", remove_url: "#" }
      ],
      clear_all_url: "#"
    )
  end

  # @label Single Filter
  def single_filter
    render Admin::ActiveFilterBar::Component.new(
      filters: [
        { category: "Tag", value: "Buyer — Theatrical", remove_url: "#" }
      ]
    )
  end

  # @label Many Filters
  def many_filters
    render Admin::ActiveFilterBar::Component.new(
      filters: [
        { category: "Keyword", value: "distribution", remove_url: "#" },
        { category: "Group", value: "Buyers", remove_url: "#" },
        { category: "Sub-group", value: "Theatrical", remove_url: "#" },
        { category: "Last Engaged", value: "30 days", remove_url: "#" }
      ],
      clear_all_url: "#"
    )
  end
end
