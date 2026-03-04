# frozen_string_literal: true

class Admin::EngagementCard::ComponentPreview < ApplicationComponentPreview
  # @label Email
  def email
    render Admin::EngagementCard::Component.new(
      engagement_type: :email,
      time: "10:42 AM",
      subject: "Follow-up on Berlin screening",
      excerpt: "Hi Jane, I wanted to follow up on our discussion about the Berlin screening schedule...",
      contacts: [ { name: "Jane Cooper", path: "#" } ],
      account_name: "Acme Films",
      account_path: "#",
      tags: [ { group: :buyers, role: "Buyer — Theatrical" } ],
      creator_name: "Sarah Williams"
    )
  end

  # @label Meeting
  def meeting
    render Admin::EngagementCard::Component.new(
      engagement_type: :meeting,
      time: "2:00 PM",
      subject: "Quarterly review with Berlin Film Fest",
      contacts: [
        { name: "Robert Fox", path: "#" },
        { name: "Emily Chen", path: "#" }
      ],
      account_name: "Berlin Film Fest",
      account_path: "#",
      tags: [ { group: :festivals, role: "Fest — Acquisitions" } ],
      creator_name: "David Kim"
    )
  end

  # @label Call
  def call
    render Admin::EngagementCard::Component.new(
      engagement_type: :call,
      time: "9:15 AM",
      subject: "Sales pitch — Global Distribution",
      excerpt: "Discussed pricing tiers and delivery timelines for Q2...",
      contacts: [ { name: "Marcus Johnson", path: "#" } ],
      tags: [ { group: :sellers, role: "Seller — Worldwide" } ],
      creator_name: "Tom Wilson"
    )
  end

  # @label Note
  def note
    render Admin::EngagementCard::Component.new(
      engagement_type: :note,
      time: "4:30 PM",
      subject: "Internal note",
      excerpt: "Contact expressed interest in exclusive screening rights for Asia-Pacific region.",
      contacts: [ { name: "Lisa Park", path: "#" } ],
      tags: [ { group: :press, role: "Press — Film Critic" } ],
      creator_name: "Jane Cooper"
    )
  end

  # @label All Types
  def all_types
    render_with_template(
      locals: {
        engagements: [
          { engagement_type: :email, time: "10:42 AM", subject: "Follow-up email", creator_name: "Sarah" },
          { engagement_type: :meeting, time: "2:00 PM", subject: "Quarterly review", creator_name: "David" },
          { engagement_type: :call, time: "9:15 AM", subject: "Sales call", creator_name: "Tom" },
          { engagement_type: :note, time: "4:30 PM", subject: "Internal note", creator_name: "Jane" }
        ]
      }
    )
  end
end
