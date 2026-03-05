# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::Dashboard::Component, type: :component do
  let(:default_params) do
    {
      user_name: "Badie",
      greeting_time: :morning,
      current_date: "Tuesday, Feb 25"
    }
  end

  it "renders morning greeting with user name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("h5", text: "Good morning, Badie")
  end

  it "renders afternoon greeting" do
    render_inline(described_class.new(**default_params.merge(greeting_time: :afternoon)))

    expect(page).to have_css("h5", text: "Good afternoon, Badie")
  end

  it "renders evening greeting" do
    render_inline(described_class.new(**default_params.merge(greeting_time: :evening)))

    expect(page).to have_css("h5", text: "Good evening, Badie")
  end

  it "renders subtitle with current date" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Here's your CRM snapshot for Tuesday, Feb 25")
  end

  it "does not render subtitle when current_date is nil" do
    render_inline(described_class.new(**default_params.merge(current_date: nil)))

    expect(page).not_to have_text("Here's your CRM snapshot")
  end

  it "renders stat cards via slot" do
    card1_html = render_inline(Admin::StatCard::Component.new(label: "Total Contacts", value: "2,307")).to_html
    card2_html = render_inline(Admin::StatCard::Component.new(label: "Engagements This Week", value: "47")).to_html

    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_stat_card { card1_html.html_safe }
      dash.with_stat_card { card2_html.html_safe }
    end

    expect(page).to have_text("Total Contacts")
    expect(page).to have_text("2,307")
    expect(page).to have_text("Engagements This Week")
    expect(page).to have_text("47")
  end

  it "renders stat cards in a 4-column grid" do
    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_stat_card { "<div>Card</div>".html_safe }
    end

    expect(page).to have_css("div.row.g-3 div.col-md-6.col-lg-3")
  end

  it "renders activity feed via data props" do
    params = default_params.merge(
      activities: [
        { type: :email, description: "Email logged to Sarah", timestamp: "2 hours ago" },
        { type: :meeting, description: "Meeting with Sony", timestamp: "4 hours ago" }
      ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("Recent Activity")
    expect(page).to have_text("Email logged to Sarah")
    expect(page).to have_text("Meeting with Sony")
  end

  it "renders activity icons with correct type colors" do
    params = default_params.merge(
      activities: [ { type: :email, description: "Email", timestamp: "now" } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("div[style*='background: #EBF3FB']")
    expect(page).to have_css("i.bi.bi-envelope-fill")
  end

  it "renders meeting activity icon" do
    params = default_params.merge(
      activities: [ { type: :meeting, description: "Meeting", timestamp: "now" } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("div[style*='background: #F3EFFE']")
    expect(page).to have_css("i.bi.bi-camera-video-fill")
  end

  it "renders activity timestamps" do
    params = default_params.merge(
      activities: [ { type: :email, description: "Test", timestamp: "3 hours ago" } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("3 hours ago")
  end

  it "renders quick actions with correct labels" do
    params = default_params.merge(
      quick_action_buttons: [
        { label: "Add new Contact", path: "/contacts/new", icon: "bi-plus-lg" },
        { label: "Add new Account", path: "/accounts/new", icon: "bi-plus-lg" },
        { label: "Add new Engagement", path: "/engagements/new", icon: "bi-plus-lg" }
      ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("Quick Actions")
    expect(page).to have_link("Add new Contact", href: "/contacts/new")
    expect(page).to have_link("Add new Account", href: "/accounts/new")
    expect(page).to have_link("Add new Engagement", href: "/engagements/new")
  end

  it "renders quick action buttons as outlined style" do
    params = default_params.merge(
      quick_action_buttons: [ { label: "Add new Contact", path: "/contacts/new" } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("a[style*='border: 1px solid #DEE2E6'][style*='background: #fff']")
  end

  it "renders follow-up queue with statuses" do
    params = default_params.merge(
      followups: [
        { name: "Sarah Connor", description: "Follow-up with Sarah", status: :overdue, status_label: "7d overdue", avatar_name: "Sarah Connor" },
        { name: "John Smith", description: "Check in with John", status: :due_today, status_label: "Due today", avatar_name: "John Smith" }
      ],
      followup_count: 12,
      followup_path: "/followups"
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("Follow-up Queue")
    expect(page).to have_text("Follow-up with Sarah")
    expect(page).to have_css("div[style*='color: #DC3545']", text: "7d overdue")
    expect(page).to have_css("div[style*='color: #DC3545']", text: "Due today")
  end

  it "renders follow-up queue with warning color for due tomorrow" do
    params = default_params.merge(
      followups: [
        { name: "Test", description: "Test", status: :due_tomorrow, status_label: "Due tomorrow", avatar_name: "Test User" }
      ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("div[style*='color: #D4772C']", text: "Due tomorrow")
  end

  it "renders follow-up queue with muted color for future" do
    params = default_params.merge(
      followups: [
        { name: "Test", description: "Test", status: :future, status_label: "In 3 days", avatar_name: "Test User" }
      ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("div[style*='color: #6C757D']", text: "In 3 days")
  end

  it "renders 'View all' link for follow-up queue" do
    params = default_params.merge(
      followups: [ { name: "Test", description: "Test", status: :overdue, status_label: "Overdue", avatar_name: "Test" } ],
      followup_count: 12,
      followup_path: "/followups"
    )
    render_inline(described_class.new(**params))

    expect(page).to have_link(href: "/followups")
    expect(page).to have_text("View all 12")
  end

  it "renders follow-up avatars" do
    params = default_params.merge(
      followups: [ { name: "Sarah Connor", description: "Follow-up", status: :overdue, status_label: "Overdue", avatar_name: "Sarah Connor" } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("span.rounded-circle", text: "SC")
  end

  it "renders contacts by group chart" do
    params = default_params.merge(
      group_data: [
        { label: "Buyers", count: 120, color: "#C05621", percentage: 35.0 },
        { label: "Press", count: 85, color: "#2E75B6", percentage: 25.0 },
        { label: "Festivals", count: 137, color: "#8B5CF6", percentage: 40.0 }
      ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("Contacts by Group")
    expect(page).to have_css("div[role='img'][aria-label='Contacts by group distribution']")
  end

  it "renders group chart bar segments with colors" do
    params = default_params.merge(
      group_data: [ { label: "Buyers", count: 120, color: "#C05621", percentage: 35.0 } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("div[style*='background: #C05621']")
  end

  it "renders group chart legend with dots and counts" do
    params = default_params.merge(
      group_data: [ { label: "Buyers", count: 120, color: "#C05621", percentage: 35.0 } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("div[style*='background: #C05621'][style*='border-radius: 50%']")
    expect(page).to have_text("Buyers")
    expect(page).to have_text("120")
  end

  it "renders two-column body layout" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div.row.g-4 div.col-lg-8")
    expect(page).to have_css("div.row.g-4 div.col-lg-4")
  end

  it "falls back to morning for invalid greeting_time" do
    render_inline(described_class.new(**default_params.merge(greeting_time: :midnight)))

    expect(page).to have_text("Good morning, Badie")
  end

  it "renders activity feed slot when provided" do
    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_activity_feed { "<div id='custom-feed'>Custom Feed</div>".html_safe }
    end

    expect(page).to have_css("#custom-feed", text: "Custom Feed")
  end

  it "renders quick actions slot when provided" do
    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_quick_actions { "<div id='custom-actions'>Custom Actions</div>".html_safe }
    end

    expect(page).to have_css("#custom-actions", text: "Custom Actions")
  end

  it "renders activity with contact name and link" do
    params = default_params.merge(
      activities: [ {
        type: :email,
        description: "Email logged with",
        contact_name: "Sarah Chen",
        contact_path: "/contacts/1",
        timestamp: "2 hours ago"
      } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_link("Sarah Chen", href: "/contacts/1")
  end

  it "renders activity with account name and link" do
    params = default_params.merge(
      activities: [ {
        type: :email,
        description: "Email logged",
        account_name: "Sony Pictures",
        account_path: "/accounts/1",
        timestamp: "now"
      } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_link("Sony Pictures", href: "/accounts/1")
  end

  it "renders followup with contact name" do
    params = default_params.merge(
      followups: [ {
        name: "Sarah Chen",
        description: "Follow-up task",
        status: :overdue,
        status_label: "7d overdue",
        avatar_name: "Sarah Chen"
      } ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_css("div[style*='font-weight: 600']", text: "Sarah Chen")
  end
end
