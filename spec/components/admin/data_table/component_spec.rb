# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::DataTable::Component, type: :component do
  let(:columns) do
    [
      { key: :name, label: "Name", sortable: true },
      { key: :tags, label: "Tags" },
      { key: :last_engagement, label: "Last Engagement", sortable: true },
      { key: :account, label: "Account" }
    ]
  end

  let(:rows) do
    [
      {
        name: "John Smith",
        title: "Theatrical Buyer",
        name_href: "/contacts/1",
        tags: [{ label: "Buyer — Theatrical", group: :buyers }],
        last_engagement: "2 days ago",
        account: "Sony Pictures",
        account_href: "/accounts/1"
      }
    ]
  end

  it "renders column headers in uppercase" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("th[style*='text-transform: uppercase']", text: "Name")
    expect(page).to have_css("th[style*='text-transform: uppercase']", text: "Tags")
  end

  it "renders a row with avatar and name" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("span.rounded-circle", text: "JS")
    expect(page).to have_css("div[style*='font-weight: 600']", text: "John Smith")
  end

  it "renders name as a link when name_href is provided" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("a[href='/contacts/1']", text: "John Smith")
  end

  it "renders contact title below name" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("div[style*='font-size: 12px']", text: "Theatrical Buyer")
  end

  it "renders tag dots with group colors" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("span[style*='background: #E8733A']")
    expect(page).to have_text("Buyer — Theatrical")
  end

  it "renders account as a blue link" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("a[style*='color: #2E75B6'][href='/accounts/1']", text: "Sony Pictures")
  end

  it "renders sort indicator on sorted column" do
    render_inline(described_class.new(columns: columns, rows: rows, sort_by: :name, sort_dir: :asc))

    expect(page).to have_css("th[aria-sort='ascending']", text: /Name/)
  end

  it "renders descending sort indicator" do
    render_inline(described_class.new(columns: columns, rows: rows, sort_by: :name, sort_dir: :desc))

    expect(page).to have_css("th[aria-sort='descending']", text: /Name/)
  end

  it "uses table-hover class for row hover effect" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("table.table.table-hover")
  end

  it "renders an empty table body when rows are empty" do
    render_inline(described_class.new(columns: columns, rows: []))

    expect(page).to have_css("thead th", count: 4)
    expect(page).not_to have_css("tbody tr")
  end

  it "renders search results variant with status column" do
    search_columns = [
      { key: :name, label: "Name" },
      { key: :tags, label: "Tags" },
      { key: :match_found_in, label: "Match Found In" },
      { key: :status, label: "Status" }
    ]
    search_rows = [
      {
        name: "Jane Doe",
        tags: [{ label: "Press — Critic", group: :press }],
        match_found_in: "Title contains <strong>investor</strong>",
        status: "Active",
        status_key: :active
      }
    ]
    render_inline(described_class.new(columns: search_columns, rows: search_rows, variant: :search_results))

    expect(page).to have_css("span[style*='background: #22A06B']")
    expect(page).to have_text("Active")
  end
end
