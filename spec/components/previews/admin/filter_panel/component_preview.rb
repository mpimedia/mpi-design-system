# frozen_string_literal: true

class Admin::FilterPanel::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::FilterPanel::Component.new(
      form_action: "/crm/contacts/search",
      sections: [
        {
          title: "Tag Group",
          field_name: "tag_group[]",
          options: [
            { label: "Distribution", value: "distribution", count: 42, checked: false },
            { label: "Outreach", value: "outreach", count: 28, checked: true },
            { label: "Press/Festival", value: "press_festival", count: 15, checked: false },
            { label: "Vendors", value: "vendors", count: 8, checked: false },
            { label: "Finance", value: "finance", count: 4, checked: false }
          ]
        },
        {
          title: "Engagement Type",
          field_name: "engagement_type[]",
          options: [
            { label: "Email", value: "email", count: 120 },
            { label: "Meeting", value: "meeting", count: 35 },
            { label: "Call", value: "call", count: 18 },
            { label: "Note", value: "note", count: 12 }
          ]
        },
        {
          title: "Date Range",
          field_name: "date_range[]",
          collapsed: true,
          options: [
            { label: "Last 7 days", value: "7d" },
            { label: "Last 30 days", value: "30d" },
            { label: "Last 90 days", value: "90d" },
            { label: "This year", value: "year" }
          ]
        }
      ]
    )
  end

  # @label With Collapsed Sections
  def collapsed
    render Admin::FilterPanel::Component.new(
      sections: [
        {
          title: "Status",
          field_name: "status[]",
          collapsed: true,
          options: [
            { label: "Active", value: "active", count: 180 },
            { label: "Inactive", value: "inactive", count: 24 }
          ]
        },
        {
          title: "Health",
          field_name: "health[]",
          collapsed: true,
          options: [
            { label: "Active", value: "active", count: 45 },
            { label: "Warm", value: "warm", count: 32 },
            { label: "Cold", value: "cold", count: 11 }
          ]
        }
      ]
    )
  end
end
