# frozen_string_literal: true

class MpiDesignSystem::Admin::FilterChipBar::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::FilterChipBar::Component.new(
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
    render MpiDesignSystem::Admin::FilterChipBar::Component.new(
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
    render MpiDesignSystem::Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 342 },
        { label: "Distribution", count: 120, group: :distribution, href: "#" },
        { label: "Outreach", count: 85, group: :outreach, href: "#" }
      ]
    )
  end

  # @label With Reset All
  def with_reset_all
    render MpiDesignSystem::Admin::FilterChipBar::Component.new(
      groups: [
        { label: "All", count: 2307 },
        { label: "Distribution", count: 342, group: :distribution, selected: true, href: "#" },
        { label: "Outreach", count: 128, group: :outreach, href: "#" },
        { label: "Press/Festival", count: 95, group: :press_festival, href: "#" }
      ],
      reset_all_url: "#"
    )
  end

  # The point of the #151 conversion: the same component, no variant flag, following
  # Bootstrap's colour mode. Side-by-side so a designer can compare the selected chips'
  # semantic subtle/emphasis surfaces on the light and dark backdrop in one view.
  #
  # @label Dark Mode
  def dark_mode
    render_with_template
  end
end
