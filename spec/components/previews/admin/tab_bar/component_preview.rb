# frozen_string_literal: true

class Admin::TabBar::ComponentPreview < ApplicationComponentPreview
  # @label Default (Underline)
  def default
    render Admin::TabBar::Component.new(
      tabs: [
        { label: "Overview", href: "#", active: true },
        { label: "Activity", href: "#", count: 12 },
        { label: "Notes", href: "#", count: 3 },
        { label: "Files", href: "#" }
      ]
    )
  end

  # @label Pill Variant
  def pill
    render Admin::TabBar::Component.new(
      variant: :pill,
      tabs: [
        { label: "All", href: "#", active: true, count: 156 },
        { label: "Active", href: "#", count: 89 },
        { label: "Inactive", href: "#", count: 67 }
      ]
    )
  end

  # @label Small Size
  def small
    render Admin::TabBar::Component.new(
      size: :sm,
      tabs: [
        { label: "Details", href: "#", active: true },
        { label: "History", href: "#" },
        { label: "Settings", href: "#" }
      ]
    )
  end

  # @label With Disabled Tab
  def with_disabled
    render Admin::TabBar::Component.new(
      tabs: [
        { label: "Overview", href: "#", active: true },
        { label: "Analytics", href: "#" },
        { label: "Reports", href: "#", disabled: true }
      ]
    )
  end
end
