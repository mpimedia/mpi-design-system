# frozen_string_literal: true

class Admin::FilterChipBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 156, group: nil, selected: true },
        { label: "Buyers", count: 42, group: :buyers, selected: false },
        { label: "Press", count: 28, group: :press, selected: false },
        { label: "Festivals", count: 35, group: :festivals, selected: false },
        { label: "Sellers", count: 22, group: :sellers, selected: false }
      ]
    )
  end

  # @label With Active Filters
  def with_active_filters
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 156, group: nil, selected: false },
        { label: "Buyers", count: 42, group: :buyers, selected: true }
      ],
      active_filters: [
        { category: "Status", value: "Active", remove_url: "#" },
        { category: "Location", value: "New York", remove_url: "#" }
      ],
      clear_all_url: "#"
    )
  end

  # @label Groups Only
  def groups_only
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "Buyers", count: 42, group: :buyers, selected: false },
        { label: "Press", count: 28, group: :press, selected: false },
        { label: "Festivals", count: 35, group: :festivals, selected: false }
      ]
    )
  end
end
