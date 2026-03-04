# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::Pagination::Component, type: :component do
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
end
