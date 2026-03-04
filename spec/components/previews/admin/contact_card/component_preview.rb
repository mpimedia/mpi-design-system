# frozen_string_literal: true

class Admin::ContactCard::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::ContactCard::Component.new(
      name: "Jane Cooper",
      company: "Acme Films",
      tags: [
        { label: "Buyers", color: "#E8733A", bg_color: "#FEF3EC" },
        { label: "Festivals", color: "#2E75B6", bg_color: "#EBF3FB" }
      ],
      last_engaged: "2 days ago",
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
          { name: "Jane Cooper", company: "Acme Films", tags: [ { label: "Buyers", color: "#E8733A", bg_color: "#FEF3EC" } ], last_engaged: "2 days ago", owner_name: "Sarah", path: "#" },
          { name: "Robert Fox", company: "Berlin Film Fest", tags: [ { label: "Festivals", color: "#2E75B6", bg_color: "#EBF3FB" } ], last_engaged: "1 week ago", path: "#" },
          { name: "Emily Chen", company: "Film Weekly", tags: [ { label: "Press", color: "#2DA67E", bg_color: "#ECF8F4" } ], last_engaged: "3 days ago", owner_name: "David", path: "#" },
          { name: "Marcus Johnson", company: "Global Distribution", tags: [ { label: "Sellers", color: "#8B5CF6", bg_color: "#F3EFFE" } ], last_engaged: "Yesterday", path: "#" }
        ]
      }
    )
  end
end
