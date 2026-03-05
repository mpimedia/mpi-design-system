# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::EmptyState::Component, type: :component do
  it "renders heading and description" do
    render_inline(described_class.new(heading: "No contacts found", description: "Try adjusting your filters"))

    expect(page).to have_css("h3", text: "No contacts found")
    expect(page).to have_css("p", text: "Try adjusting your filters")
  end

  it "renders on a light gray background" do
    render_inline(described_class.new(heading: "Empty"))

    expect(page).to have_css("div[style*='background: #F5F7FA']")
  end

  it "renders an icon when provided" do
    render_inline(described_class.new(heading: "Search", icon: "bi-search"))

    expect(page).to have_css("i.bi.bi-search[aria-hidden='true']")
    expect(page).to have_css("i[style*='color: #4EA8DE']")
  end

  it "renders a CTA button when action is provided" do
    render_inline(described_class.new(
      heading: "No contacts", action_label: "Add Contact", action_url: "/contacts/new", action_icon: "bi-plus-lg"
    ))

    expect(page).to have_css("a.btn.btn-primary", text: "Add Contact")
    expect(page).to have_css("i.bi.bi-plus-lg")
  end

  it "does not render CTA when action_label is missing" do
    render_inline(described_class.new(heading: "Empty", action_url: "/contacts/new"))

    expect(page).not_to have_css("a.btn")
  end

  it "renders shortcut cards in a 2-column grid" do
    shortcuts = [
      { title: "Distribution", description: "Follow-up candidates", href: "/search?q=buyers" },
      { title: "Press", description: "All critics", href: "/search?q=press" }
    ]
    render_inline(described_class.new(heading: "Start searching", shortcuts: shortcuts))

    expect(page).to have_css(".col-6", count: 2)
    expect(page).to have_css("a[href='/search?q=buyers']")
    expect(page).to have_css("div[style*='color: #2E75B6']", text: "Distribution")
    expect(page).to have_css("div[style*='color: #6C757D']", text: "Follow-up candidates")
  end

  it "shortcut cards are links with text-decoration none" do
    shortcuts = [ { title: "Recent", description: "Last 7 days", href: "/recent" } ]
    render_inline(described_class.new(heading: "Search", shortcuts: shortcuts))

    expect(page).to have_css("a[style*='text-decoration: none'][href='/recent']")
  end

  it "does not render shortcut section when shortcuts are empty" do
    render_inline(described_class.new(heading: "Empty"))

    expect(page).not_to have_css(".row")
  end
end
