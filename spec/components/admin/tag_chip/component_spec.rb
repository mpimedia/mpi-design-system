# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::TagChip::Component, type: :component do
  it "renders a tag chip with group color" do
    render_inline(described_class.new(label: "Buyers", group: :buyers))

    expect(page).to have_css("span[style*='#E8733A']", text: "Buyers")
    expect(page).to have_css("span[style*='#FEF3EC']")
  end

  it "renders different colors for different groups" do
    render_inline(described_class.new(label: "Press", group: :press))

    expect(page).to have_css("span[style*='#2DA67E']", text: "Press")
  end

  it "renders a colored dot indicator before the label" do
    render_inline(described_class.new(label: "Buyers", group: :buyers))

    expect(page).to have_css("span[style*='background-color: #E8733A'][style*='border-radius: 50%']")
  end

  it "renders dot with correct color for each group" do
    render_inline(described_class.new(label: "Festivals", group: :festivals))

    expect(page).to have_css("span[style*='background-color: #2E75B6'][style*='border-radius: 50%']")
  end

  it "renders a removable chip with close button (no URL)" do
    render_inline(described_class.new(label: "MIPCOM 2025", group: :buyers, removable: true))

    expect(page).to have_css("button[aria-label='Remove MIPCOM 2025']")
    expect(page).to have_css("i.bi.bi-x-lg")
  end

  it "renders a removable chip as turbo link when remove_url provided" do
    render_inline(described_class.new(label: "MIPCOM 2025", group: :buyers, removable: true, remove_url: "/tags/1"))

    expect(page).to have_css("a[href='/tags/1'][aria-label='Remove MIPCOM 2025']")
    expect(page).to have_css("a[data-turbo-method='delete']")
  end

  it "does not show remove button by default" do
    render_inline(described_class.new(label: "Festivals", group: :festivals))

    expect(page).not_to have_css("button")
  end

  it "renders at small size" do
    render_inline(described_class.new(label: "Test", group: :internal, size: :sm))

    expect(page).to have_css("span[style*='font-size: 12px']")
  end

  it "renders at default size" do
    render_inline(described_class.new(label: "Test", group: :internal))

    expect(page).to have_css("span[style*='font-size: 13px']")
  end

  it "has pill shape" do
    render_inline(described_class.new(label: "Test", group: :sellers))

    expect(page).to have_css("span[style*='border-radius: 999px']")
  end
end
