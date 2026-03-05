# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::ActiveFilterBar::Component, type: :component do
  let(:filters) do
    [
      { category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" },
      { category: "Group", value: "Distribution", remove_url: "/contacts?remove=group" }
    ]
  end

  it "renders active filter pills" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("span[style*='background: #2E75B6']", text: "Keyword: investors")
    expect(page).to have_css("span[style*='background: #2E75B6']", text: "Group: Distribution")
  end

  it "renders ACTIVE label" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Active:")
  end

  it "renders remove buttons for each filter" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("a[aria-label='Remove filter: Keyword: investors']")
    expect(page).to have_css("a[data-turbo-method='delete']", count: 2)
  end

  it "renders clear all link" do
    render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

    expect(page).to have_css("a[href='/contacts?clear']", text: "Clear all")
  end

  it "does not render when filters are empty" do
    render_inline(described_class.new(filters: []))

    expect(page).not_to have_css("div[role='toolbar']")
  end

  it "renders on a light gray background" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("div[style*='background: #F5F7FA']")
  end

  it "renders as a toolbar with aria label" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("div[role='toolbar'][aria-label='Active filters']")
  end
end
