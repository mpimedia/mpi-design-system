# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::ListCardToggle::Component, type: :component do
  let(:sort_options) do
    [
      ["Last Engaged", "last_engaged"],
      ["Name A–Z", "name_asc"],
      ["Name Z–A", "name_desc"],
      ["Date Added (newest)", "date_desc"],
      ["Date Added (oldest)", "date_asc"]
    ]
  end

  let(:default_params) do
    {
      result_count: 247,
      result_label: "contacts",
      sort_options: sort_options,
      sort_by: "last_engaged",
      list_url: "/contacts?view=list",
      card_url: "/contacts?view=card"
    }
  end

  it "renders result count with label" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("247 contacts")
  end

  it "renders list view as active by default" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[title='List view'][aria-pressed='true'][style*='background: #2E75B6']")
  end

  it "renders card view as inactive by default" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[title='Card view'][aria-pressed='false'][style*='background: #fff']")
  end

  it "renders card view as active when active_view is :card" do
    render_inline(described_class.new(**default_params.merge(active_view: :card)))

    expect(page).to have_css("a[title='Card view'][aria-pressed='true'][style*='background: #2E75B6']")
    expect(page).to have_css("a[title='List view'][aria-pressed='false']")
  end

  it "renders list button with divider border" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[title='List view'][style*='border-right: 1px solid #DEE2E6']")
  end

  it "renders toggle icons" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("i.bi.bi-list-ul")
    expect(page).to have_css("i.bi.bi-grid-3x2-gap")
  end

  it "renders toggle group with border and rounded corners" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='border: 1px solid #DEE2E6'][style*='border-radius: 6px']")
  end

  it "renders list and card URLs" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/contacts?view=list']")
    expect(page).to have_css("a[href='/contacts?view=card']")
  end

  it "renders sort dropdown" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("select[aria-label='Sort by']")
    expect(page).to have_css("option[value='last_engaged'][selected]", text: "Last Engaged")
    expect(page).to have_css("option[value='name_asc']", text: "Name A–Z")
  end

  it "renders all sort options" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("option", count: 5)
  end

  it "hides sort dropdown when no options" do
    render_inline(described_class.new(**default_params.merge(sort_options: [])))

    expect(page).not_to have_css("select")
  end

  it "highlights search query in result text" do
    render_inline(described_class.new(**default_params.merge(search_query: "theatrical")))

    expect(page).to have_css("span[style*='background: #FFF3CD']", text: "theatrical")
  end

  it "renders without search highlight by default" do
    render_inline(described_class.new(**default_params))

    expect(page).not_to have_css("span[style*='background: #FFF3CD']")
  end

  it "defaults invalid active_view to list" do
    render_inline(described_class.new(**default_params.merge(active_view: :invalid)))

    expect(page).to have_css("a[title='List view'][aria-pressed='true']")
  end

  it "renders toggle buttons with aria-hidden icons" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("i[aria-hidden='true'].bi-list-ul")
    expect(page).to have_css("i[aria-hidden='true'].bi-grid-3x2-gap")
  end
end
