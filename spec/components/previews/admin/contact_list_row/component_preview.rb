# frozen_string_literal: true

class Admin::ContactListRow::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::ContactListRow::Component.new(
      name: "Jane Cooper",
      title: "VP of Acquisitions",
      tags: [ { group: :buyers, role: "Lead" } ],
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
        { group: :festivals, role: "Director" },
        { group: :buyers, role: "Reviewer" }
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
      tags: [ { group: :press, role: "Contact" } ]
    )
  end

  # @label Inactive Status
  def inactive
    render Admin::ContactListRow::Component.new(
      name: "Marcus Johnson",
      title: "Former Sales Rep",
      status: :inactive,
      tags: [ { group: :sellers, role: "Rep" } ],
      last_engagement: "6 months ago"
    )
  end
end
