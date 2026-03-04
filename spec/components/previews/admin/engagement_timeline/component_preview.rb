# frozen_string_literal: true

class Admin::EngagementTimeline::ComponentPreview < ApplicationComponentPreview
  # @label Default (Full)
  def default
    render Admin::EngagementTimeline::Component.new(
      engagements: sample_engagements,
      new_engagement_path: "#"
    )
  end

  # @label Compact
  def compact
    render Admin::EngagementTimeline::Component.new(
      variant: :compact,
      engagements: sample_engagements
    )
  end

  # @label Empty
  def empty
    render Admin::EngagementTimeline::Component.new(
      engagements: [],
      new_engagement_path: "#"
    )
  end

  private

  def sample_engagements
    [
      { type: :email, date: "2025-01-15", time: "10:42 AM", timezone: "EST", subject: "Follow-up on Berlin screening", excerpt: "Hi Jane, I wanted to follow up...", creator_name: "Sarah Williams" },
      { type: :meeting, date: "2025-01-14", time: "2:00 PM", timezone: "EST", subject: "Quarterly review with Berlin Film Fest", creator_name: "David Kim" },
      { type: :call, date: "2025-01-13", time: "9:15 AM", timezone: "EST", subject: "Sales pitch — Global Distribution", excerpt: "Discussed pricing tiers...", creator_name: "Tom Wilson" },
      { type: :note, date: "2025-01-12", time: "4:30 PM", timezone: "EST", subject: "Internal note on screening rights", creator_name: "Jane Cooper" }
    ]
  end
end
