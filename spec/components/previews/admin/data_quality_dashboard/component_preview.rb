# frozen_string_literal: true

class Admin::DataQualityDashboard::ComponentPreview < ApplicationComponentPreview
  # @label Excellent
  def excellent
    render Admin::DataQualityDashboard::Component.new(
      overall_score: 92,
      overall_tier: :excellent,
      grade_distribution: { excellent: 45, good: 30, fair: 15, poor: 10 },
      total_contacts: 2307,
      gaps: [
        { label: "No Email Address", count: 186, percentage: 8.1 },
        { label: "No Tags Assigned", count: 247, percentage: 10.7 },
        { label: "No Linked Account", count: 312, percentage: 13.5 }
      ],
      priority_fixes: [
        { name: "John Doe", organization: "Acme Films", missing_fields: [ "Email", "Phone" ], score: 35, last_active: "2 days ago" },
        { name: "Jane Smith", organization: "Global Distribution", missing_fields: [ "Tags", "Account" ], score: 55, last_active: "1 week ago" },
        { name: "Robert Fox", organization: "Berlin Film Fest", missing_fields: [ "Email" ], score: 72, last_active: "3 days ago" }
      ]
    )
  end

  # @label Poor
  def poor
    render Admin::DataQualityDashboard::Component.new(
      overall_score: 32,
      overall_tier: :poor,
      grade_distribution: { excellent: 5, good: 10, fair: 25, poor: 60 },
      total_contacts: 500,
      gaps: [
        { label: "No Email Address", count: 250, percentage: 50.0 },
        { label: "No Tags Assigned", count: 300, percentage: 60.0 },
        { label: "No Linked Account", count: 200, percentage: 40.0 }
      ]
    )
  end

  # @label Good
  def good
    render Admin::DataQualityDashboard::Component.new(
      overall_score: 75,
      overall_tier: :good,
      grade_distribution: { excellent: 25, good: 40, fair: 20, poor: 15 },
      total_contacts: 1500,
      gaps: [
        { label: "No Email Address", count: 120, percentage: 8.0 },
        { label: "No Tags Assigned", count: 180, percentage: 12.0 },
        { label: "No Linked Account", count: 95, percentage: 6.3 }
      ]
    )
  end
end
