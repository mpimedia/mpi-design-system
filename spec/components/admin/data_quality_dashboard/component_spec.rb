# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::DataQualityDashboard::Component, type: :component do
  let(:default_params) do
    {
      overall_score: 72,
      overall_tier: :good,
      grade_distribution: { excellent: 120, good: 200, fair: 80, poor: 50 },
      total_contacts: 450,
      gaps: [
        { label: "No Email", count: 89, percentage: 19.8 },
        { label: "No Tags", count: 134, percentage: 29.8 },
        { label: "No Account", count: 67, percentage: 14.9 }
      ],
      priority_fixes: [
        {
          name: "John Smith",
          organization: "Sony Pictures",
          missing_fields: ["Email", "Phone"],
          score: 25,
          last_active: "2 days ago"
        }
      ]
    }
  end

  it "renders overall score ring with percentage" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("svg[aria-label='Data quality score: 72%']")
    expect(page).to have_css("text", text: "72%")
  end

  it "renders tier label in score ring" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("text", text: "Good")
  end

  it "renders ring with correct tier color" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("circle[stroke='#2E75B6']")
  end

  it "renders grade distribution bars" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Excellent")
    expect(page).to have_text("Good")
    expect(page).to have_text("Fair")
    expect(page).to have_text("Poor")
  end

  it "renders grade distribution counts" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("120")
    expect(page).to have_text("200")
    expect(page).to have_text("80")
    expect(page).to have_text("50")
  end

  it "renders gap stat cards" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-size: 24px']", text: "89")
    expect(page).to have_text("No Email")
    expect(page).to have_text("19.8%")
  end

  it "renders all three gap cards" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("No Tags")
    expect(page).to have_text("No Account")
  end

  it "renders priority fixes with avatar" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.rounded-circle", text: "JS")
    expect(page).to have_css("div[style*='font-weight: 600']", text: "John Smith")
  end

  it "renders organization in priority fixes" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #6C757D']", text: "Sony Pictures")
  end

  it "renders missing fields in red" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #DC3545']", text: "Email, Phone")
  end

  it "renders mini score ring for priority fixes" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("svg[aria-label='Score: 25%']")
  end

  it "renders mini ring with danger color for low scores" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("svg circle[stroke='#DC3545']")
  end

  it "renders recency in priority fixes" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("2 days ago")
  end

  it "hides priority fixes section when empty" do
    render_inline(described_class.new(**default_params.merge(priority_fixes: [])))

    expect(page).not_to have_text("Priority Fixes")
  end

  it "clamps score to 0-100" do
    render_inline(described_class.new(**default_params.merge(overall_score: 150)))

    expect(page).to have_css("text", text: "100%")
  end

  it "defaults invalid tier to poor" do
    render_inline(described_class.new(**default_params.merge(overall_tier: :invalid)))

    expect(page).to have_css("circle[stroke='#DC3545']")
  end
end
