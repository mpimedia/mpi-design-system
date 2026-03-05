# frozen_string_literal: true

class Admin::FilterChipBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 2307 },
        { label: "Distribution", count: 342, group: :distribution, href: "#" },
        { label: "Outreach", count: 128, group: :outreach, href: "#" },
        { label: "Press/Festival", count: 95, group: :press_festival, href: "#" },
        { label: "Vendors", count: 67, group: :vendors, href: "#" }
      ]
    )
  end

  # @label With Active Filters
  def with_active_filters
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 2307 },
        { label: "Distribution", count: 342, group: :distribution, selected: true, href: "#" },
        { label: "Outreach", count: 128, group: :outreach, href: "#" }
      ],
      active_filters: [
        { category: "Keyword", value: "investors", remove_url: "#" },
        { category: "Group", value: "Distribution", remove_url: "#" },
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
        { label: "Distribution", count: 120, group: :distribution, href: "#" },
        { label: "Outreach", count: 85, group: :outreach, href: "#" }
      ]
    )
  end

  # @label With Reset All
  def with_reset_all
    render Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 2307 },
        { label: "Distribution", count: 342, group: :distribution, selected: true, href: "#" },
        { label: "Outreach", count: 128, group: :outreach, href: "#" },
        { label: "Press/Festival", count: 95, group: :press_festival, href: "#" }
      ],
      reset_all_url: "#"
    )
  end
end
