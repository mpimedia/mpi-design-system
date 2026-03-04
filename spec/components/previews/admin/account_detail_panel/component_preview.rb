# frozen_string_literal: true

class Admin::AccountDetailPanel::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::AccountDetailPanel::Component.new(
      name: "Sony Pictures",
      account_type: "Distributor",
      account_type_color: :primary,
      metrics: { contacts: 7, engagements: 34, titles: 12 },
      contacts: [
        { name: "Jane Doe", title: "VP of Acquisitions", path: "#" },
        { name: "John Smith", title: "Director of Sales", path: "#" }
      ],
      email: "info@sonypictures.com",
      phone: "+1 (555) 987-6543",
      location: "Los Angeles, CA",
      website: "https://sonypictures.com",
      territory: "North America",
      health: "Good",
      created_date: "Jan 10, 2025",
      owner: { name: "A. Garcia", path: "#" },
      tag_groups: [
        { label: "Buyers", count: 5, group: :buyers },
        { label: "Festivals", count: 2, group: :festivals },
        { label: "Press", count: 1, group: :press }
      ],
      linked_titles: [
        { name: "The Great Film", status: "In Distribution", path: "#" },
        { name: "Another Movie", status: "Pre-Release", path: "#" },
        { name: "Documentary Series", status: "Completed", path: "#" }
      ]
    )
  end

  # @label Minimal
  def minimal
    render Admin::AccountDetailPanel::Component.new(
      name: "Independent Films Ltd",
      account_type: "Studio",
      account_type_color: :success
    )
  end

  # @label With Metrics Only
  def with_metrics
    render Admin::AccountDetailPanel::Component.new(
      name: "Berlin Film Festival",
      account_type: "Festival",
      account_type_color: :warning,
      metrics: { contacts: 12, engagements: 56, titles: 8 },
      location: "Berlin, Germany",
      website: "https://berlinale.de"
    )
  end
end
