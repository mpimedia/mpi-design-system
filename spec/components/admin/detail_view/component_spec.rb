# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::DetailView::Component, type: :component do
  it "renders two-column layout with col-4 and col-8" do
    render_inline(described_class.new(variant: :contact))

    expect(page).to have_css("div.row.g-4")
    expect(page).to have_css("div.col-md-4")
    expect(page).to have_css("div.col-md-8")
  end

  it "renders profile panel slot in left column" do
    render_inline(described_class.new(variant: :contact)) do |dv|
      dv.with_profile_panel { "<div class='card'><div class='card-body'>Profile</div></div>".html_safe }
    end

    expect(page).to have_css("div.col-md-4 div.card", text: "Profile")
  end

  it "renders activity panel slot in right column" do
    render_inline(described_class.new(variant: :contact)) do |dv|
      dv.with_activity_panel { "<div class='timeline'>Timeline content</div>".html_safe }
    end

    expect(page).to have_css("div.col-md-8 div.timeline", text: "Timeline content")
  end

  it "renders both panels simultaneously" do
    render_inline(described_class.new(variant: :contact)) do |dv|
      dv.with_profile_panel { "<div id='profile'>Left</div>".html_safe }
      dv.with_activity_panel { "<div id='activity'>Right</div>".html_safe }
    end

    expect(page).to have_css("div.col-md-4 #profile", text: "Left")
    expect(page).to have_css("div.col-md-8 #activity", text: "Right")
  end

  it "defaults to contact variant" do
    component = described_class.new
    expect(component.instance_variable_get(:@variant)).to eq(:contact)
  end

  it "accepts account variant" do
    component = described_class.new(variant: :account)
    expect(component.instance_variable_get(:@variant)).to eq(:account)
  end

  it "falls back to contact for invalid variant" do
    component = described_class.new(variant: :invalid)
    expect(component.instance_variable_get(:@variant)).to eq(:contact)
  end

  it "renders empty columns when no slots are provided" do
    render_inline(described_class.new(variant: :contact))

    expect(page).to have_css("div.col-md-4")
    expect(page).to have_css("div.col-md-8")
  end

  it "composes with AvatarCircle in profile panel" do
    avatar_html = render_inline(Admin::AvatarCircle::Component.new(name: "Sarah Connor", size: :lg)).to_html

    render_inline(described_class.new(variant: :contact)) do |dv|
      dv.with_profile_panel { avatar_html.html_safe }
    end

    expect(page).to have_css("div.col-md-4 span.rounded-circle", text: "SC")
  end

  it "composes with EngagementTimeline in activity panel" do
    engagements = [
      { type: :email, date: "Feb 21", subject: "Follow-up", creator_name: "John" }
    ]
    timeline_html = render_inline(Admin::EngagementTimeline::Component.new(
      engagements: engagements,
      variant: :full,
      new_engagement_path: "/engagements/new"
    )).to_html

    render_inline(described_class.new(variant: :contact)) do |dv|
      dv.with_activity_panel { timeline_html.html_safe }
    end

    expect(page).to have_css("div.col-md-8")
    expect(page).to have_text("Follow-up")
    expect(page).to have_text("+ New Engagement")
  end
end
