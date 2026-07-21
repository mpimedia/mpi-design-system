# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::ActiveFilterBar::Component, type: :component do
  let(:filters) do
    [
      { category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" },
      { category: "Group", value: "Distribution", remove_url: "/contacts?remove=group" }
    ]
  end

  # These two examples previously asserted `style*='background: #2E75B6'`, which
  # pinned a hardcoded duplicate of $mpi-primary. The pill now carries Bootstrap's
  # `.text-bg-primary`, so its background AND foreground derive from the consuming
  # app's actual $primary rather than a literal that silently desynchronises when
  # a consumer overrides the token. (#130)
  it "renders active filter pills" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("span.rounded-pill.text-bg-primary", text: "Keyword: investors")
    expect(page).to have_css("span.rounded-pill.text-bg-primary", text: "Group: Distribution")
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

  describe "contrast (#130)" do
    it "derives the pill foreground from Bootstrap instead of pinning white" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("span.text-bg-primary")
      expect(page).to have_no_css("span[style*='color: #fff']")
      expect(page).to have_no_css("span[style*='background: #2E75B6']")
    end

    # The retired `opacity: 0.8` faded white to an effective #D5E3F0 over the
    # pill — 3.71:1, an AA failure invisible to any audit that only reads
    # `color:` declarations. The button now inherits the pill's derived
    # foreground at full strength.
    it "does not fade the remove button, which eroded contrast to 3.71:1" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("a[style*='color: inherit']", count: 2)
      expect(page).to have_no_css("a[style*='opacity']")
    end

    it "derives the label and clear-all foreground rather than pinning #6C757D" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      expect(page).to have_css("span.text-body-secondary", text: "Active:")
      expect(page).to have_css("a.text-body-secondary", text: "Clear all")
      expect(page).to have_no_css("[style*='color: #6C757D']")
    end

    # A single sweep over the whole rendered document, so a hardcoded pair
    # reintroduced anywhere in this template fails the suite — including in
    # markup this spec does not enumerate.
    it "emits no hardcoded foreground color anywhere in the rendered markup" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      expect(page.native.to_html).not_to match(/color:\s*#(?!\{)[0-9a-f]{3,6}/i)
    end
  end

  describe "edge cases" do
    it "does not raise when filters is nil" do
      expect { render_inline(described_class.new(filters: nil)) }.not_to raise_error
    end

    it "renders a pill without a remove button when remove_url is missing" do
      render_inline(described_class.new(filters: [ { category: "Tag", value: "Acquisitions" } ]))

      expect(page).to have_css("span.text-bg-primary", text: "Tag: Acquisitions")
      expect(page).to have_no_css("a[data-turbo-method='delete']")
    end

    it "omits the clear-all link when no url is given" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_no_css("a[aria-label='Clear all filters']")
    end
  end
end
