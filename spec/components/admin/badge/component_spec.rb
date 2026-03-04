# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::Badge::Component, type: :component do
  it "renders a filled badge with default color" do
    render_inline(described_class.new(label: "Active"))

    expect(page).to have_css("span.badge.rounded-pill.bg-primary", text: "Active")
  end

  it "renders with a specific color" do
    render_inline(described_class.new(label: "Overdue", color: :danger))

    expect(page).to have_css("span.badge.bg-danger", text: "Overdue")
  end

  it "renders an outline variant" do
    render_inline(described_class.new(label: "Draft", variant: :outline, color: :secondary))

    expect(page).to have_css("span.badge.border.border-secondary.text-secondary")
  end

  it "renders a tag group variant with inline styles" do
    render_inline(described_class.new(label: "Buyers", variant: :tag_group, tag_group: :buyers))

    expect(page).to have_css("span.badge[style*='#E8733A']", text: "Buyers")
  end

  it "renders with a count" do
    render_inline(described_class.new(label: "Contacts", count: 24))

    expect(page).to have_css("span.badge", text: "Contacts 24")
    expect(page).to have_css("span[aria-label='Contacts: 24']")
  end

  it "defaults invalid color to primary" do
    render_inline(described_class.new(label: "Test", color: :invalid))

    expect(page).to have_css("span.badge.bg-primary")
  end

  it "uses dark text on warning background for accessibility" do
    render_inline(described_class.new(label: "Pending", color: :warning))

    expect(page).to have_css("span.badge.bg-warning.text-dark", text: "Pending")
  end
end
