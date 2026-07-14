# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::EmptyState::Component, type: :component do
  it "renders heading and description" do
    render_inline(described_class.new(heading: "No contacts found", description: "Try adjusting your filters"))

    expect(page).to have_css("h3.fs-5.fw-semibold", text: "No contacts found")
    # Description is held to a centered, width-capped measure via the responsive grid
    # (replacing the old inline `max-width: 420px; margin: 0 auto`).
    expect(page).to have_css(".row.justify-content-center > p.small.text-muted.col-xl-6", text: "Try adjusting your filters")
  end

  it "renders a class-based container with no inline styles or literal hex" do
    render_inline(described_class.new(heading: "Empty"))

    # Class/token-based container (was an inline `style='background: #F5F7FA'` seam).
    expect(page).to have_css("div.bg-body-tertiary.rounded-3.p-5.text-center")
    # The whole point of #121: no inline styling survives anywhere in the markup.
    expect(page).to have_no_css("[style]")
  end

  it "renders the heading at :h3 by default" do
    render_inline(described_class.new(heading: "Empty"))

    expect(page).to have_css("h3.fs-5.fw-semibold", text: "Empty")
    expect(page).to have_no_css("h4, h5")
  end

  it "renders the heading at a caller-supplied level so it composes under a section heading" do
    render_inline(described_class.new(heading: "No associated users found", heading_level: :h5))

    # Same visual size (`fs-5`), correct semantic level — no backward h4 -> h3 jump.
    expect(page).to have_css("h5.fs-5.fw-semibold", text: "No associated users found")
    expect(page).to have_no_css("h3")
  end

  it "falls back to :h3 when given an unsupported heading level" do
    render_inline(described_class.new(heading: "Empty", heading_level: :h7))

    expect(page).to have_css("h3.fs-5.fw-semibold", text: "Empty")
  end

  it "renders an icon when provided" do
    render_inline(described_class.new(heading: "Search", icon: "bi-search"))

    expect(page).to have_css("i.bi.bi-search.fs-1.text-primary[aria-hidden='true']")
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
      { title: "Distribution", description: "Follow-up candidates", href: "/search?q=distribution" },
      { title: "Outreach", description: "All critics", href: "/search?q=outreach" }
    ]
    render_inline(described_class.new(heading: "Start searching", shortcuts: shortcuts))

    expect(page).to have_css(".col-6", count: 2)
    expect(page).to have_css("a[href='/search?q=distribution']")
    expect(page).to have_css("div.small.fw-semibold.text-primary-emphasis", text: "Distribution")
    expect(page).to have_css("div.small.text-muted", text: "Follow-up candidates")
    # The 2-card cluster is width-capped and centered via the grid (replacing the old
    # inline `max-width: 600px; margin: 0 auto` on the row).
    expect(page).to have_css(".row.justify-content-center > .col-lg-8 > .row.g-3[aria-label='Quick access shortcuts']")
  end

  it "shortcut cards are color-mode-aware links with no underline" do
    shortcuts = [ { title: "Recent", description: "Last 7 days", href: "/recent" } ]
    render_inline(described_class.new(heading: "Search", shortcuts: shortcuts))

    # `bg-body` (not fixed `bg-white`) so the card and its `text-muted` copy stay
    # legible when a consumer enables Bootstrap's dark color mode.
    expect(page).to have_css("a.text-decoration-none.border.bg-body[href='/recent']")
  end

  it "does not render the shortcut section when shortcuts are empty" do
    render_inline(described_class.new(heading: "Empty", description: "Nothing here yet"))

    expect(page).to have_no_css("[aria-label='Quick access shortcuts']")
    expect(page).to have_no_css(".shortcut-card")
  end
end
