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
        { name: "First Name", complete: true, priority: :high, value: "Jane" },
        { name: "Last Name", complete: true, priority: :high, value: "Cooper" },
        { name: "Email", complete: true, priority: :high, value: "jane@example.com" },
        { name: "Phone", complete: true, priority: :med, value: "+1 555-0100" },
        { name: "Company", complete: true, priority: :med, value: "Acme Films" },
        { name: "Title", complete: true, priority: :low, value: "VP of Acquisitions" },
        { name: "Location", complete: true, priority: :low, value: "New York, NY" },
        { name: "Notes", complete: false, priority: :low }
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
        { name: "First Name", complete: true, priority: :high, value: "John" },
        { name: "Last Name", complete: true, priority: :high, value: "Doe" },
        { name: "Email", complete: false, priority: :high },
        { name: "Phone", complete: false, priority: :med },
        { name: "Company", complete: true, priority: :med, value: "Unknown Corp" },
        { name: "Title", complete: false, priority: :low }
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
        { name: "First Name", complete: true, priority: :high, value: "Emily" },
        { name: "Last Name", complete: true, priority: :high, value: "Chen" },
        { name: "Email", complete: true, priority: :high, value: "emily@filmweekly.com" },
        { name: "Phone", complete: false, priority: :med },
        { name: "Company", complete: true, priority: :med, value: "Film Weekly" },
        { name: "Title", complete: true, priority: :low, value: "Press Manager" },
        { name: "Location", complete: false, priority: :low }
      ]
    )
  end
end
