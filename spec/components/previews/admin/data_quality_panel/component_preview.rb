# frozen_string_literal: true

class Admin::DataQualityPanel::ComponentPreview < ApplicationComponentPreview
  # @label Excellent
  def excellent
    render Admin::DataQualityPanel::Component.new(
      score: 92,
      tier: :excellent,
      fields_complete: 11,
      fields_total: 12,
      fields: [
        { name: "Name", complete: true, priority: :high, value: "Jane Cooper" },
        { name: "Email", complete: true, priority: :high, value: "jane@acmefilms.com" },
        { name: "Phone", complete: true, priority: :high, value: "+1 (555) 012-3456" },
        { name: "Company", complete: true, priority: :high, value: "Acme Films" },
        { name: "Title", complete: true, priority: :med, value: "VP of Acquisitions" },
        { name: "Tags", complete: true, priority: :med, value: "Buyer — Theatrical, Buyer — Digital" },
        { name: "Account", complete: true, priority: :med, value: "Acme Films" },
        { name: "Location", complete: true, priority: :low, value: "Los Angeles, CA" },
        { name: "LinkedIn", complete: true, priority: :low, value: "linkedin.com/in/janecooper" },
        { name: "Owner", complete: true, priority: :low, value: "Badie Ali" },
        { name: "Engagement History", complete: true, priority: :low, value: "34 engagements" },
        { name: "Notes", complete: false, priority: :low, add_url: "#" }
      ]
    )
  end

  # @label Poor
  def poor
    render Admin::DataQualityPanel::Component.new(
      score: 25,
      tier: :poor,
      fields_complete: 3,
      fields_total: 12,
      fields: [
        { name: "Name", complete: true, priority: :high, value: "Robert Fox" },
        { name: "Email", complete: false, priority: :high, add_url: "#" },
        { name: "Phone", complete: false, priority: :high, add_url: "#" },
        { name: "Company", complete: true, priority: :high, value: "Unknown" },
        { name: "Title", complete: false, priority: :med, add_url: "#" },
        { name: "Tags", complete: false, priority: :med, add_url: "#" },
        { name: "Account", complete: false, priority: :med, add_url: "#" },
        { name: "Location", complete: false, priority: :low, add_url: "#" },
        { name: "LinkedIn", complete: false, priority: :low, add_url: "#" },
        { name: "Owner", complete: true, priority: :low, value: "Unassigned" },
        { name: "Engagement History", complete: false, priority: :low },
        { name: "Notes", complete: false, priority: :low }
      ]
    )
  end

  # @label Fair
  def fair
    render Admin::DataQualityPanel::Component.new(
      score: 58,
      tier: :fair,
      fields_complete: 7,
      fields_total: 12,
      fields: [
        { name: "Name", complete: true, priority: :high, value: "Emily Chen" },
        { name: "Email", complete: true, priority: :high, value: "emily@filmweekly.com" },
        { name: "Phone", complete: false, priority: :high, add_url: "#" },
        { name: "Company", complete: true, priority: :high, value: "Film Weekly" },
        { name: "Title", complete: true, priority: :med, value: "Film Critic" },
        { name: "Tags", complete: true, priority: :med, value: "Press — Film Critic" },
        { name: "Account", complete: false, priority: :med, add_url: "#" },
        { name: "Location", complete: true, priority: :low, value: "New York, NY" },
        { name: "LinkedIn", complete: false, priority: :low, add_url: "#" },
        { name: "Owner", complete: true, priority: :low, value: "Badie Ali" },
        { name: "Engagement History", complete: false, priority: :low },
        { name: "Notes", complete: false, priority: :low }
      ]
    )
  end
end
