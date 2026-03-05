# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::TabBar::Component, type: :component do
  let(:tabs) do
    [
      { label: "Metadata", href: "#metadata", active: true },
      { label: "Archive Files", href: "#files", count: 47 },
      { label: "Outreach", href: "#outreach" }
    ]
  end

  it "renders underline tabs by default" do
    render_inline(described_class.new(tabs: tabs))

    expect(page).to have_css("[role='tablist']")
    expect(page).to have_css("a[role='tab']", count: 3)
  end

  it "marks the active tab with aria-selected and blue underline" do
    render_inline(described_class.new(tabs: tabs))

    expect(page).to have_css("a[aria-selected='true'][style*='border-bottom: 2px solid #2E75B6']", text: "Metadata")
  end

  it "renders inactive tabs with transparent underline" do
    render_inline(described_class.new(tabs: tabs))

    expect(page).to have_css("a[aria-selected='false'][style*='border-bottom: 2px solid transparent']", text: "Outreach")
  end

  it "displays count in parentheses" do
    render_inline(described_class.new(tabs: tabs))

    expect(page).to have_text("Archive Files (47)")
  end

  it "renders pill variant with filled active state" do
    render_inline(described_class.new(tabs: tabs, variant: :pill))

    expect(page).to have_css("a[style*='border-radius: 999px'][style*='background: #2E75B6']", text: "Metadata")
  end

  it "renders pill inactive tabs with white background" do
    render_inline(described_class.new(tabs: tabs, variant: :pill))

    expect(page).to have_css("a[style*='border-radius: 999px'][style*='background: #fff']", text: "Outreach")
  end

  it "renders disabled tab as span with aria-disabled" do
    disabled_tabs = [
      { label: "Active", href: "#active", active: true },
      { label: "Disabled", href: "#disabled", disabled: true }
    ]
    render_inline(described_class.new(tabs: disabled_tabs))

    expect(page).to have_css("span[role='tab'][aria-disabled='true'][tabindex='-1']", text: "Disabled")
    expect(page).to have_css("span[style*='cursor: not-allowed']")
  end

  it "renders at small size with smaller font" do
    render_inline(described_class.new(tabs: tabs, size: :sm))

    expect(page).to have_css("a[style*='font-size: 13px']")
  end

  it "uses role=tablist on container" do
    render_inline(described_class.new(tabs: tabs))

    expect(page).to have_css("div[role='tablist']")
  end
end
