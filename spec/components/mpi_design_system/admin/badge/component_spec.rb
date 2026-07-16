# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::Badge::Component, type: :component do
  it "renders a filled badge with default color" do
    render_inline(described_class.new(label: "Active"))

    expect(page).to have_css("span.badge.rounded-pill.text-bg-primary", text: "Active")
  end

  it "renders a filled danger badge" do
    render_inline(described_class.new(label: "Overdue", color: :danger))

    expect(page).to have_css("span.badge.text-bg-danger", text: "Overdue")
  end

  it "renders a filled secondary badge" do
    render_inline(described_class.new(label: "Draft", color: :secondary))

    expect(page).to have_css("span.badge.text-bg-secondary", text: "Draft")
  end

  it "renders a filled success badge with Bootstrap-computed contrast" do
    render_inline(described_class.new(label: "Paid", color: :success))

    # text-bg-success lets Bootstrap derive the foreground (#000 / 6.31:1 against
    # $mpi-success #22A06B) instead of the retired hardcoded text-white (3.33:1).
    expect(page).to have_css("span.badge.text-bg-success", text: "Paid")
    expect(page).to have_no_css("span.badge.bg-success")
    expect(page).to have_no_css("span.badge.text-white")
  end

  it "uses Bootstrap-computed dark text on warning background for accessibility" do
    render_inline(described_class.new(label: "Pending", color: :warning))

    expect(page).to have_css("span.badge.text-bg-warning", text: "Pending")
    expect(page).to have_no_css("span.badge.bg-warning")
    expect(page).to have_no_css("span.badge.text-dark")
  end

  it "defaults invalid color to primary" do
    render_inline(described_class.new(label: "Test", color: :invalid))

    expect(page).to have_css("span.badge.text-bg-primary")
  end

  it "renders an outline variant" do
    render_inline(described_class.new(label: "Draft", variant: :outline, color: :secondary))

    expect(page).to have_css("span.badge.border.border-secondary.text-secondary")
  end

  it "renders a tag group variant with inline styles" do
    render_inline(described_class.new(label: "Distribution", variant: :tag_group, tag_group: :distribution))

    expect(page).to have_css("span.badge[style*='#E8733A']", text: "Distribution")
  end

  it "renders with a count" do
    render_inline(described_class.new(label: "Contacts", count: 24))

    expect(page).to have_css("span.badge", text: "Contacts 24")
    expect(page).to have_css("span[aria-label='Contacts: 24']")
  end
end
