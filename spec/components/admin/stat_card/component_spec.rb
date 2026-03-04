# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::StatCard::Component, type: :component do
  it "renders label and value" do
    render_inline(described_class.new(label: "Total Contacts", value: "2,307"))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Total Contacts")
    expect(page).to have_css("div[style*='font-size: 32px']", text: "2,307")
  end

  it "renders value in navy by default" do
    render_inline(described_class.new(label: "Accounts", value: "418"))

    expect(page).to have_css("div[style*='color: #1B2A4A']", text: "418")
  end

  it "renders value in danger red when alert is true" do
    render_inline(described_class.new(label: "Overdue Follow-Ups", value: "12", alert: true))

    expect(page).to have_css("div[style*='color: #DC3545']", text: "12")
  end

  it "adds role=alert when alert is true" do
    render_inline(described_class.new(label: "Overdue", value: "5", alert: true))

    expect(page).to have_css("div[role='alert']")
  end

  it "renders an up arrow with positive trend" do
    render_inline(described_class.new(
      label: "Total", value: "100",
      trend_text: "34 this month", trend_direction: :up, trend_sentiment: :positive
    ))

    expect(page).to have_css("i.bi.bi-arrow-up")
    expect(page).to have_css("div[style*='color: #22A06B']", text: "34 this month")
  end

  it "renders a down arrow with negative trend" do
    render_inline(described_class.new(
      label: "Active", value: "50",
      trend_text: "5 this week", trend_direction: :down, trend_sentiment: :negative
    ))

    expect(page).to have_css("i.bi.bi-arrow-down")
    expect(page).to have_css("div[style*='color: #DC3545']", text: "5 this week")
  end

  it "renders neutral trend without arrow" do
    render_inline(described_class.new(
      label: "Accounts", value: "418",
      trend_text: "8 added this month", trend_direction: :neutral, trend_sentiment: :neutral
    ))

    expect(page).not_to have_css("i.bi")
    expect(page).to have_css("div[style*='color: #6C757D']", text: "8 added this month")
  end

  it "hides trend section when no trend_text is provided" do
    render_inline(described_class.new(label: "Total", value: "100"))

    expect(page).not_to have_css("div[style*='font-size: 12px']")
  end
end
