# frozen_string_literal: true

class Admin::ContactListRow::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::ContactListRow::Component.new(
      name: "Jane Cooper",
      title: "VP of Acquisitions",
      tags: [ { group: :distribution, role: "Acquisitions" } ],
      last_engagement: "2 days ago",
      account_name: "Acme Films",
      account_path: "#"
    )
  end

  # @label Multiple Tags
  def multiple_tags
    render Admin::ContactListRow::Component.new(
      name: "Robert Fox",
      title: "Festival Director",
      tags: [
        { group: :press_festival, role: "Festival" },
        { group: :distribution, role: "Streaming" }
      ],
      last_engagement: "1 week ago",
      account_name: "Berlin Film Fest",
      account_path: "#"
    )
  end

  # @label Search Result Variant
  def search_result
    render Admin::ContactListRow::Component.new(
      name: "Emily Chen",
      title: "Press Manager",
      variant: :search_result,
      match_text: "Email: emily.chen@filmweekly.com",
      tags: [ { group: :outreach, role: "Journalist" } ]
    )
  end

  # @label Inactive Status
  def inactive
    render Admin::ContactListRow::Component.new(
      name: "Marcus Johnson",
      title: "Former Sales Rep",
      status: :inactive,
      tags: [ { group: :vendors, role: "Intl Sales" } ],
      last_engagement: "6 months ago"
    )
  end
end
