# frozen_string_literal: true

class Admin::ContactDetailPanel::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::ContactDetailPanel::Component.new(
      name: "Jane Cooper",
      title: "VP of Acquisitions",
      company: "Acme Films",
      tags: [
        { label: "Buyer — Theatrical", group: :buyers },
        { label: "Fest — Acquisitions", group: :festivals }
      ],
      email: "jane.cooper@acmefilms.com",
      phone: "+1 (555) 010-0100",
      account: { name: "Acme Films", path: "#" },
      location: "New York, NY",
      added_date: "Jan 10, 2025",
      owner: { name: "Sarah Williams", path: "#" },
      auto_groups: [
        { label: "VIP", group: :buyers },
        { label: "Market Attendee", group: :festivals }
      ]
    )
  end

  # @label Minimal
  def minimal
    render Admin::ContactDetailPanel::Component.new(
      name: "Robert Fox",
      title: "Festival Director"
    )
  end

  # @label With Tag Input
  def with_tag_input
    render Admin::ContactDetailPanel::Component.new(
      name: "Emily Chen",
      title: "Press Manager",
      company: "Film Weekly",
      tags: [
        { label: "Press — Film Critic", group: :press, remove_url: "#" }
      ],
      add_tag_path: "#",
      email: "emily@filmweekly.com",
      owner: { name: "David Kim", path: "#" }
    )
  end
end
