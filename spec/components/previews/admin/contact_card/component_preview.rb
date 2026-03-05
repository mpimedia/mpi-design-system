# frozen_string_literal: true

class Admin::ContactCard::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::ContactCard::Component.new(
      name: "Jane Cooper",
      company: "Acme Films",
      tags: [
        { label: "Acquisitions", group: :distribution },
        { label: "Festival", group: :press_festival }
      ],
      last_engaged: "2 days ago",
      engagement_count: 14,
      owner_name: "Sarah Williams",
      path: "#"
    )
  end

  # @label Minimal
  def minimal
    render Admin::ContactCard::Component.new(
      name: "Robert Fox",
      path: "#"
    )
  end

  # @label Grid of Cards
  def grid
    render_with_template(
      locals: {
        contacts: [
          { name: "Jane Cooper", company: "Acme Films", tags: [ { label: "Acquisitions", group: :distribution } ], last_engaged: "2 days ago", engagement_count: 14, owner_name: "Sarah", path: "#" },
          { name: "Robert Fox", company: "Berlin Film Fest", tags: [ { label: "Festival", group: :press_festival } ], last_engaged: "1 week ago", engagement_count: 8, path: "#" },
          { name: "Emily Chen", company: "Film Weekly", tags: [ { label: "Journalist", group: :outreach } ], last_engaged: "3 days ago", engagement_count: 22, owner_name: "David", path: "#" },
          { name: "Marcus Johnson", company: "Global Distribution", tags: [ { label: "Intl Sales", group: :vendors } ], last_engaged: "Yesterday", engagement_count: 5, path: "#" }
        ]
      }
    )
  end
end
