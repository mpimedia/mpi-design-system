# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::FilterChipBar::Component, type: :component do
  describe "group chips" do
    let(:groups) do
      [
        { label: "All", count: 2307 },
        { label: "Distribution", count: 342, group: :distribution, href: "/contacts?group=distribution" },
        { label: "Outreach", count: 128, group: :outreach, href: "/contacts?group=outreach" }
      ]
    end

    it "renders group chips with GROUPS label" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Groups:")
      expect(page).to have_text("All 2307")
      expect(page).to have_text("Distribution 342")
    end

    it "renders group chips as links when href is provided" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("a[href='/contacts?group=distribution']", text: "Distribution 342")
    end

    it "highlights selected chip with group color" do
      selected_groups = [
        { label: "Distribution", count: 342, group: :distribution, selected: true, href: "#" }
      ]
      render_inline(described_class.new(groups: selected_groups))

      expect(page).to have_css("a[style*='border: 1px solid #E8733A'][style*='background: #FEF3EC']")
      expect(page).to have_css("a[aria-current='page']")
    end

    it "renders unselected chips with default styling" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("[style*='border: 1px solid #DEE2E6'][style*='background: #fff']")
    end

    it "wraps in a role=group with aria-label" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("[role='group'][aria-label='Filter by group']")
    end
  end

  describe "active filter pills" do
    let(:active_filters) do
      [
        { category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" },
        { category: "Group", value: "Distribution", remove_url: "/contacts?remove=group" }
      ]
    end

    it "renders active pills with ACTIVE label" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Active:")
      expect(page).to have_text("Keyword: investors")
      expect(page).to have_text("Group: Distribution")
    end

    it "renders pills in primary blue with white text" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css("span[style*='background: #2E75B6'][style*='color: #fff']")
    end

    it "renders remove button with aria-label" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css("a[aria-label='Remove filter: Keyword: investors']")
      expect(page).to have_css("i.bi.bi-x")
    end

    it "renders clear all link when clear_all_url is provided" do
      render_inline(described_class.new(active_filters: active_filters, clear_all_url: "/contacts"))

      expect(page).to have_css("a[aria-label='Clear all filters']", text: "Clear all")
    end

    it "does not render clear all when clear_all_url is nil" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).not_to have_text("Clear all")
    end
  end

  it "does not render groups section when groups are empty" do
    render_inline(described_class.new(active_filters: [ { category: "Keyword", value: "test" } ]))

    expect(page).not_to have_text("Groups:")
  end

  it "does not render active section when active_filters are empty" do
    render_inline(described_class.new(groups: [ { label: "All", count: 100 } ]))

    expect(page).not_to have_text("Active:")
  end

  it "renders reset all link when reset_all_url is provided" do
    groups = [
      { label: "All", count: 100 },
      { label: "Distribution", count: 50, group: :distribution, selected: true, href: "#" }
    ]
    render_inline(described_class.new(groups: groups, reset_all_url: "/contacts"))

    expect(page).to have_css("a[href='/contacts'][aria-label='Reset all filters']", text: "Reset all")
  end

  it "does not render reset all link when reset_all_url is nil" do
    groups = [ { label: "All", count: 100 } ]
    render_inline(described_class.new(groups: groups))

    expect(page).not_to have_text("Reset all")
  end
end
