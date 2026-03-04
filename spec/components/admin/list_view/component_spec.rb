# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::ListView::Component, type: :component do
  let(:groups) do
    [
      { label: "All", count: 342 },
      { label: "Buyers", count: 120, group: :buyers, selected: false },
      { label: "Press", count: 85, group: :press, selected: false }
    ]
  end

  it "renders the FilterChipBar with group chips" do
    render_inline(described_class.new(entity_type: :contacts, groups: groups, total_count: 342))

    expect(page).to have_text("All 342")
    expect(page).to have_text("Buyers 120")
    expect(page).to have_text("Press 85")
  end

  it "renders the ListCardToggle with result count" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 342))

    expect(page).to have_text("342 contacts")
  end

  it "renders sort dropdown with entity-specific options" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10))

    expect(page).to have_css("select[aria-label='Sort by']")
    expect(page).to have_css("option", text: "Last Engaged")
    expect(page).to have_css("option", text: "Name A\u2013Z")
  end

  it "renders accounts sort options for accounts entity type" do
    render_inline(described_class.new(entity_type: :accounts, total_count: 10))

    expect(page).to have_css("option", text: "Health")
    expect(page).to have_css("option", text: "Contacts")
  end

  it "defaults to list view mode" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10))

    expect(page).to have_css("a[aria-pressed='true'][title='List view']")
  end

  it "highlights card view when view_mode is card" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10, view_mode: :card))

    expect(page).to have_css("a[aria-pressed='true'][title='Card view']")
  end

  it "does not render sub-group bar by default" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10))

    expect(page).not_to have_css("div[role='toolbar'][aria-label='Sub-group filters']")
  end

  it "renders sub-group bar when sub_groups are provided" do
    sub_groups = [
      { name: "All", selected: true },
      { name: "Theatrical", selected: false },
      { name: "Digital", selected: false }
    ]
    render_inline(described_class.new(
      entity_type: :contacts, total_count: 10,
      sub_groups: sub_groups,
      selected_group_color: "#2E75B6",
      selected_group_bg: "#EBF3FB"
    ))

    expect(page).to have_css("div[role='toolbar'][aria-label='Sub-group filters']")
    expect(page).to have_text("All")
    expect(page).to have_text("Theatrical")
    expect(page).to have_text("Digital")
  end

  it "highlights selected sub-group pill with group color" do
    sub_groups = [ { name: "Theatrical", selected: true } ]
    render_inline(described_class.new(
      entity_type: :contacts, total_count: 10,
      sub_groups: sub_groups,
      selected_group_color: "#C05621",
      selected_group_bg: "#FEF3EC"
    ))

    expect(page).to have_css("button[aria-pressed='true'][style*='color: #C05621']", text: "Theatrical")
  end

  it "renders sub-group pills as links when href is provided" do
    sub_groups = [ { name: "Theatrical", selected: false, href: "/contacts?sub=theatrical" } ]
    render_inline(described_class.new(
      entity_type: :contacts, total_count: 10,
      sub_groups: sub_groups
    ))

    expect(page).to have_css("a[href='/contacts?sub=theatrical']", text: "Theatrical")
  end

  it "renders sub-group pills as buttons when no href" do
    sub_groups = [ { name: "Theatrical", selected: false } ]
    render_inline(described_class.new(
      entity_type: :contacts, total_count: 10,
      sub_groups: sub_groups
    ))

    expect(page).to have_css("button[type='button']", text: "Theatrical")
    expect(page).not_to have_css("a", text: "Theatrical")
  end

  it "clamps per_page to minimum of 1" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10, per_page: 0))

    expect(page).to have_text("10 contacts")
  end

  it "renders table content slot in list mode" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10, view_mode: :list)) do |lv|
      lv.with_table_content { "<table><tr><td>Row</td></tr></table>".html_safe }
    end

    expect(page).to have_css("table")
    expect(page).to have_text("Row")
  end

  it "renders card content slot in card mode" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10, view_mode: :card)) do |lv|
      lv.with_card_content { "<div class='col-4'>Card</div>".html_safe }
    end

    expect(page).to have_css("div.row.g-3 div.col-4", text: "Card")
  end

  it "renders Pagination when total exceeds per_page" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 100, per_page: 25, current_page: 1))

    expect(page).to have_css("nav[aria-label='Pagination']")
  end

  it "does not render Pagination when total fits one page" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 20, per_page: 25))

    expect(page).not_to have_css("nav[aria-label='Pagination']")
  end

  it "renders search query highlight in result count" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 5, search_query: "investors"))

    expect(page).to have_text("investors")
  end

  it "renders sub-group label text" do
    sub_groups = [ { name: "All", selected: true } ]
    render_inline(described_class.new(entity_type: :contacts, total_count: 10, sub_groups: sub_groups))

    expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Sub-groups")
  end

  it "renders search summary when provided" do
    render_inline(described_class.new(
      entity_type: :contacts,
      total_count: 5,
      search_summary: "5 contacts match investors in Buyers"
    ))

    expect(page).to have_text("5 contacts match investors in Buyers")
  end

  it "does not render search summary when not provided" do
    render_inline(described_class.new(entity_type: :contacts, total_count: 10))

    expect(page).not_to have_css("div[style*='font-style: italic']")
  end
end
