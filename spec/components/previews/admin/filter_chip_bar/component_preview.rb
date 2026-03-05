# frozen_string_literal: true

class Admin::FilterChipBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 2307 },
        { label: "Buyers", count: 342, group: :buyers, href: "#" },
        { label: "Press", count: 128, group: :press, href: "#" },
        { label: "Festivals", count: 95, group: :festivals, href: "#" },
        { label: "Sellers", count: 67, group: :sellers, href: "#" }
      ]
    )
  end

  # @label With Active Filters
  def with_active_filters
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 2307 },
        { label: "Buyers", count: 342, group: :buyers, selected: true, href: "#" },
        { label: "Press", count: 128, group: :press, href: "#" }
      ],
      active_filters: [
        { category: "Keyword", value: "investors", remove_url: "#" },
        { category: "Group", value: "Buyers", remove_url: "#" },
        { category: "Activity", value: "Engaged last 90 days", remove_url: "#" }
      ],
      clear_all_url: "#"
    )
  end

  # @label Groups Only
  def groups_only
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 342 },
        { label: "Buyers", count: 120, group: :buyers, href: "#" },
        { label: "Press", count: 85, group: :press, href: "#" }
      ]
    )
  end

  # @label With Reset All
  def with_reset_all
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 2307 },
        { label: "Buyers", count: 342, group: :buyers, selected: true, href: "#" },
        { label: "Press", count: 128, group: :press, href: "#" },
        { label: "Festivals", count: 95, group: :festivals, href: "#" }
      ],
      reset_all_url: "#"
    )
  end
end
