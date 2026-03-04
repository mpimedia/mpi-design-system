# frozen_string_literal: true

class Admin::StatCard::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::StatCard::Component.new(
      label: "Total Contacts",
      value: "2,307"
    )
  end

  # @label With Trend (Up / Positive)
  def trend_up
    render Admin::StatCard::Component.new(
      label: "Total Contacts",
      value: "2,307",
      trend_text: "34 this month",
      trend_direction: :up,
      trend_sentiment: :positive
    )
  end

  # @label With Trend (Down / Negative)
  def trend_down
    render Admin::StatCard::Component.new(
      label: "Active Deals",
      value: "18",
      trend_text: "3 lost this week",
      trend_direction: :down,
      trend_sentiment: :negative
    )
  end

  # @label With Alert
  def with_alert
    render Admin::StatCard::Component.new(
      label: "Data Quality",
      value: "67%",
      trend_text: "Below target",
      trend_direction: :down,
      trend_sentiment: :negative,
      alert: true
    )
  end

  # @label Grid of Cards
  def grid
    render_with_template(
      locals: {
        cards: [
          { label: "Total Contacts", value: "2,307", trend_text: "34 this month", trend_direction: :up, trend_sentiment: :positive },
          { label: "Active Accounts", value: "156", trend_text: "12 new", trend_direction: :up, trend_sentiment: :positive },
          { label: "Engagements", value: "89", trend_text: "This week", trend_direction: :neutral, trend_sentiment: :neutral },
          { label: "Data Quality", value: "82%", trend_text: "3% improvement", trend_direction: :up, trend_sentiment: :positive }
        ]
      }
    )
  end
end
