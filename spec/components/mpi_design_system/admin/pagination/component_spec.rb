# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::Pagination::Component, type: :component do
  let(:url_builder) { ->(page) { "/contacts?page=#{page}" } }

  it "renders results text with correct range" do
    render_inline(described_class.new(current_page: 1, total_pages: 4, total_count: 93, url_builder: url_builder))

    expect(page).to have_text("Showing 1\u201325 of 93 results")
  end

  it "renders results text in primary blue" do
    render_inline(described_class.new(current_page: 1, total_pages: 2, total_count: 50, url_builder: url_builder))

    expect(page).to have_css("span[style*='color: #2E75B6']")
  end

  it "renders page number buttons" do
    render_inline(described_class.new(current_page: 1, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("[aria-label='Page 1']")
    expect(page).to have_css("[aria-label='Page 2']")
    expect(page).to have_css("[aria-label='Page 3']")
  end

  it "highlights the active page" do
    render_inline(described_class.new(current_page: 2, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("span[aria-current='page'][style*='background: #2E75B6']", text: "2")
  end

  it "does not show left arrow on first page" do
    render_inline(described_class.new(current_page: 1, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).not_to have_css("[aria-label='Previous page']")
    expect(page).to have_css("[aria-label='Next page']")
  end

  it "does not show right arrow on last page" do
    render_inline(described_class.new(current_page: 3, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("[aria-label='Previous page']")
    expect(page).not_to have_css("[aria-label='Next page']")
  end

  it "shows both arrows on middle page" do
    render_inline(described_class.new(current_page: 2, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("[aria-label='Previous page']")
    expect(page).to have_css("[aria-label='Next page']")
  end

  it "wraps in a nav element with aria-label" do
    render_inline(described_class.new(current_page: 1, total_pages: 1, total_count: 6, url_builder: url_builder))

    expect(page).to have_css("nav[aria-label='Pagination']")
  end

  it "handles last page with fewer records" do
    render_inline(described_class.new(current_page: 4, total_pages: 4, total_count: 93, url_builder: url_builder))

    expect(page).to have_text("Showing 76\u201393 of 93 results")
  end

  it "renders a single page without arrows" do
    render_inline(described_class.new(current_page: 1, total_pages: 1, total_count: 6, url_builder: url_builder))

    expect(page).not_to have_css("[aria-label='Previous page']")
    expect(page).not_to have_css("[aria-label='Next page']")
    expect(page).to have_text("Showing 1\u20136 of 6 results")
  end

  it "handles zero results" do
    render_inline(described_class.new(current_page: 1, total_pages: 1, total_count: 0, url_builder: url_builder))

    expect(page).to have_text("Showing 0 results")
  end

  it "clamps current_page to valid range" do
    render_inline(described_class.new(current_page: 99, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("span[aria-current='page']", text: "3")
    expect(page).not_to have_css("[aria-label='Next page']")
  end

  it "does not render empty turbo frame attribute when not provided" do
    render_inline(described_class.new(current_page: 1, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).not_to have_css("[data-turbo-frame='']")
  end

  it "includes turbo frame data attribute when provided" do
    render_inline(described_class.new(
      current_page: 1, total_pages: 3, total_count: 75,
      url_builder: url_builder, turbo_frame: "contacts_list"
    ))

    expect(page).to have_css("a[data-turbo-frame='contacts_list']")
  end

  describe "windowing (max_links)" do
    # The ordered sequence of rendered page items: numeric page labels in document order,
    # with :gap for each non-interactive ellipsis. Excludes the prev/next arrows (their
    # aria-labels are "Previous page" / "Next page", not "Page N").
    def rendered_series
      page.all("[aria-label^='Page '], span[aria-hidden='true']").map do |el|
        el["aria-hidden"] == "true" ? :gap : el.text.strip
      end
    end

    it "renders every page (no gap) when max_links is nil — unchanged default" do
      render_inline(described_class.new(current_page: 3, total_pages: 6, total_count: 150, url_builder: url_builder, max_links: nil))

      expect(rendered_series).to eq(%w[1 2 3 4 5 6])
      expect(page).not_to have_css("span[aria-hidden='true']")
    end

    it "renders every page when total_pages <= max_links" do
      render_inline(described_class.new(current_page: 2, total_pages: 5, total_count: 120, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq(%w[1 2 3 4 5])
      expect(page).not_to have_css("span[aria-hidden='true']")
    end

    it "windows a middle page symmetrically with gaps on both sides" do
      render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq([ "1", :gap, "19", "20", "21", :gap, "47" ])
    end

    it "windows a near-first page with a single trailing gap" do
      render_inline(described_class.new(current_page: 2, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq([ "1", "2", "3", "4", "5", :gap, "47" ])
    end

    it "windows a near-last page with a single leading gap" do
      render_inline(described_class.new(current_page: 46, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq([ "1", :gap, "43", "44", "45", "46", "47" ])
    end

    it "keeps first and last present and truncates the interior (deep-table regression guard)" do
      render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(page).to have_css("[aria-label='Page 1']")
      expect(page).to have_css("[aria-label='Page 47']")
      expect(page).to have_css("span[aria-current='page']", text: "20")
      # interior pages far from the window are NOT rendered — the whole point of windowing
      expect(page).not_to have_css("[aria-label='Page 5']")
      expect(page).not_to have_css("[aria-label='Page 35']")
    end

    it "renders the gap as a non-interactive ellipsis (no href)" do
      render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      gap = page.first("span[aria-hidden='true']")
      expect(gap.text.strip).to eq("…")
      expect(page).not_to have_css("a[aria-hidden='true']")
    end
  end
end
