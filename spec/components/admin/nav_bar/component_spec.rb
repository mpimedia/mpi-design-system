# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::NavBar::Component, type: :component do
  it "renders the Nexus logo SVG and MARKAZ text" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("svg")
    expect(page).to have_text("MARKAZ")
  end

  it "renders all 6 navigation sections" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_link("Dashboard")
    expect(page).to have_link("Content")
    expect(page).to have_link("CRM")
    expect(page).to have_link("Rights & Avails")
    expect(page).to have_link("Releases")
    expect(page).to have_link("Screenings")
  end

  it "highlights the active section with blue underline" do
    render_inline(described_class.new(current_section: :crm))

    expect(page).to have_css("a[aria-current='page'][style*='color: #2E75B6'][style*='font-weight: 600']", text: "CRM")
  end

  it "renders inactive sections in gray" do
    render_inline(described_class.new(current_section: :crm))

    expect(page).to have_css("a[style*='color: #6C757D']", text: "Dashboard")
  end

  it "renders Level 1 only when section has no sub-nav" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("nav[aria-label='Main navigation']")
    expect(page).not_to have_css("nav[aria-label='Section navigation']")
  end

  it "renders Level 1 + Level 2 for CRM section" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :contacts))

    expect(page).to have_css("nav[aria-label='Main navigation']")
    expect(page).to have_css("nav[aria-label='Section navigation']")
    expect(page).to have_link("Contacts")
    expect(page).to have_link("Accounts")
    expect(page).to have_link("Engagements")
  end

  it "highlights the active subsection" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :contacts))

    expect(page).to have_css("nav[aria-label='Section navigation'] a[aria-current='page']", text: "Contacts")
  end

  it "renders the user avatar" do
    render_inline(described_class.new(current_section: :dashboard, user_name: "Jane Doe"))

    expect(page).to have_css("span.rounded-circle", text: "JD")
  end

  it "renders the search bar when search_url is provided" do
    render_inline(described_class.new(current_section: :dashboard, search_url: "/search"))

    expect(page).to have_css("form[action='/search']")
    expect(page).to have_css("input[type='search']")
  end

  it "does not render search bar when search_url is nil" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).not_to have_css("form[action]")
  end

  it "renders the top bar at 52px height" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("div[style*='height: 52px']")
  end

  it "renders the sub-nav at 42px height" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :dashboard))

    expect(page).to have_css("div[style*='height: 42px']")
  end

  it "logo links to dashboard" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("a[href='/dashboard'] span", text: "MARKAZ")
  end
end
