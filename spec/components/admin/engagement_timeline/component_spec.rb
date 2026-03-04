# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::EngagementTimeline::Component, type: :component do
  let(:engagements) do
    [
      {
        type: :email,
        date: "Feb 21, 2026",
        time: "3:42 PM",
        timezone: "CT",
        subject: "Follow-up on distribution deal",
        excerpt: "Hi team, just wanted to circle back...",
        creator_name: "M. Johnson"
      },
      {
        type: :meeting,
        date: "Feb 20, 2026",
        time: "10:00 AM",
        timezone: "CT",
        subject: "Q1 Planning Session",
        excerpt: "Discussed theatrical release timeline.",
        creator_name: "A. Garcia"
      }
    ]
  end

  let(:grouped_engagements) do
    [
      {
        type: :email,
        date: "Feb 25, 2026",
        time: "3:42 PM",
        timezone: "CT",
        date_group: "TODAY — FEB 25",
        subject: "Follow-up",
        creator_name: "M. Johnson"
      },
      {
        type: :meeting,
        date: "Feb 24, 2026",
        time: "10:00 AM",
        timezone: "CT",
        date_group: "YESTERDAY — FEB 24",
        subject: "Q1 Planning",
        creator_name: "A. Garcia"
      }
    ]
  end

  it "renders panel with white background and rounded border" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_css("div[style*='background: #fff'][style*='border-radius: 8px']")
  end

  it "renders Engagements title for full variant" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_css("div[style*='font-size: 16px']", text: "Engagements")
  end

  it "renders + New Engagement button" do
    render_inline(described_class.new(engagements: engagements, new_engagement_path: "/engagements/new"))

    expect(page).to have_css("a[href='/engagements/new'][style*='background: #1B2A4A']", text: "+ New Engagement")
  end

  it "hides button when no path provided" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).not_to have_css("a", text: "+ New Engagement")
  end

  it "renders type badges with correct colors" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_css("span[style*='color: #2E75B6']", text: "EMAIL")
    expect(page).to have_css("span[style*='color: #8B5CF6']", text: "MEETING")
  end

  it "renders date with time and timezone" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_text("Feb 21, 2026. 3:42 PM CT")
  end

  it "renders subjects in bold navy" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_css("div[style*='font-weight: 600']", text: "Follow-up on distribution deal")
  end

  it "renders excerpts in muted text for full variant" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_css("div[style*='color: #6C757D'][style*='font-size: 13px']", text: /circle back/)
  end

  it "renders creator name for full variant" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_text("by M. Johnson")
  end

  it "separates entries with light borders" do
    render_inline(described_class.new(engagements: engagements))

    expect(page).to have_css("div[style*='border-bottom: 1px solid #F0F0F0']", minimum: 1)
  end

  it "renders date group headers when date_group is provided" do
    render_inline(described_class.new(engagements: grouped_engagements))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "TODAY — FEB 25")
    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "YESTERDAY — FEB 24")
  end

  it "renders date group headers with muted style" do
    render_inline(described_class.new(engagements: grouped_engagements))

    expect(page).to have_css("div[style*='color: #6C757D'][style*='font-weight: 700']", text: /TODAY/)
  end

  context "compact variant" do
    it "renders Recent Engagements title" do
      render_inline(described_class.new(engagements: engagements, variant: :compact))

      expect(page).to have_css("div[style*='font-size: 14px']", text: "Recent Engagements")
    end

    it "hides excerpts" do
      render_inline(described_class.new(engagements: engagements, variant: :compact))

      expect(page).not_to have_text("circle back")
    end

    it "hides creator name" do
      render_inline(described_class.new(engagements: engagements, variant: :compact))

      expect(page).not_to have_text("by M. Johnson")
    end

    it "uses tighter padding" do
      render_inline(described_class.new(engagements: engagements, variant: :compact))

      expect(page).to have_css("div[style*='padding: 10px 0']")
    end
  end

  context "empty state" do
    it "renders empty message when no engagements" do
      render_inline(described_class.new(engagements: []))

      expect(page).to have_text("No engagements yet.")
    end

    it "renders create link in empty state when path provided" do
      render_inline(described_class.new(engagements: [], new_engagement_path: "/engagements/new"))

      expect(page).to have_css("a[href='/engagements/new']", text: "Create the first engagement")
    end
  end

  it "defaults invalid variant to full" do
    render_inline(described_class.new(engagements: engagements, variant: :invalid))

    expect(page).to have_css("div[style*='font-size: 16px']", text: "Engagements")
  end
end
