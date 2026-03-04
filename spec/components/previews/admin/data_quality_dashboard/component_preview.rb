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
        { label: "Missing email", count: 42, percentage: 2 },
        { label: "Missing phone", count: 156, percentage: 7 },
        { label: "Missing company", count: 89, percentage: 4 }
      ],
      priority_fixes: [
        { name: "John Doe", organization: "Acme Films", missing_fields: [ "email", "phone" ], score: 35, last_active: "2 days ago" },
        { name: "Jane Smith", organization: "Global Dist", missing_fields: [ "company" ], score: 55, last_active: "1 week ago" }
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
        { label: "Missing email", count: 250, percentage: 50 },
        { label: "Missing phone", count: 300, percentage: 60 },
        { label: "Missing company", count: 200, percentage: 40 }
      ]
    )
  end

  # @label Good
  def good
    render Admin::DataQualityDashboard::Component.new(
      overall_score: 75,
      overall_tier: :good,
      grade_distribution: { excellent: 25, good: 40, fair: 20, poor: 15 },
      total_contacts: 1500
    )
  end
end
