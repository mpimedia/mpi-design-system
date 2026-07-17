# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::TableForIndex::Component, type: :component do
  let(:row_class) { Struct.new(:id, :name, :active, :updated_at, keyword_init: true) }
  let(:rows) do
    [
      row_class.new(id: 1, name: "Acme Corporation", active: true, updated_at: Time.utc(2026, 7, 1)),
      row_class.new(id: 2, name: "Globex", active: false, updated_at: Time.utc(2026, 6, 15))
    ]
  end

  describe "block columns" do
    it "renders headers and captured cell content for each row" do
      render_inline(described_class.new(data: rows)) do |table|
        table.with_column("ID") { |record| record.id.to_s }
        table.with_column("Name") { |record| record.name }
      end

      expect(page).to have_css("thead.table-dark th", text: "ID")
      expect(page).to have_css("thead th", text: "Name")
      expect(page).to have_css("tbody tr", count: 2)
      expect(page).to have_css("tbody td", text: "Acme Corporation")
      expect(page).to have_css("tbody td", text: "Globex")
    end

    it "emits a pre-rendered SafeBuffer header (e.g. a sort_link) verbatim" do
      render_inline(described_class.new(data: rows)) do |table|
        table.with_column('<a href="/admin/orgs?sort=name">Name</a>'.html_safe) { |record| record.name }
      end

      expect(page).to have_css("thead th a[href='/admin/orgs?sort=name']", text: "Name")
    end
  end

  describe "helper columns" do
    it "renders a :text value from a symbol or callable without a block" do
      render_inline(described_class.new(data: rows)) do |table|
        table.with_column("ID", value: :id)
        table.with_column("Name", value: ->(record) { record.name })
      end

      expect(page).to have_css("tbody td", text: "1")
      expect(page).to have_css("tbody td", text: "Acme Corporation")
    end

    it "renders a :boolean cell as a filled Badge (never the inline-hex tag_group variant)" do
      render_inline(described_class.new(data: rows)) do |table|
        table.with_column("Active", value: :active, cell: :boolean)
      end

      expect(page).to have_css("td .badge.text-bg-success", text: "Yes")
      expect(page).to have_css("td .badge.text-bg-secondary", text: "No")
      expect(page).to have_no_css("td .badge[style]")
    end

    it "renders a :date cell formatted via to_fs(:long)" do
      render_inline(described_class.new(data: rows)) do |table|
        table.with_column("Updated", value: :updated_at, cell: :date)
      end

      expect(page).to have_css("tbody td", text: "July 01, 2026")
    end
  end

  describe "presentation options (Bootstrap utilities, no inline style)" do
    it "applies align / nowrap / width utilities to <th> and <td>" do
      render_inline(described_class.new(data: rows)) do |table|
        table.with_column("Actions", align: :end, nowrap: true, width: :sm) { |record| record.id.to_s }
      end

      expect(page).to have_css("th.text-end.text-nowrap.w-25")
      expect(page).to have_css("td.text-end.text-nowrap")
      expect(page).to have_no_css("[style]")
    end
  end

  describe "first-class sortable headers (Ransack-free)" do
    subject(:render_sortable) do
      render_inline(
        described_class.new(
          data: rows,
          sort_url: ->(key, dir) { "/admin/orgs?sort=#{key}&dir=#{dir}" },
          current_sort_key: :name,
          current_sort_dir: :asc
        )
      ) do |table|
        table.with_column("ID") { |record| record.id.to_s }
        table.with_column("Name", value: :name, sortable: true, sort_key: :name)
        table.with_column("Updated", value: :updated_at, cell: :date, sortable: true, sort_key: :updated_at)
      end
    end

    it "renders a clickable header whose href flips direction on the active column" do
      render_sortable
      # Name is active + asc, so its link toggles to desc.
      expect(page).to have_css("thead th[aria-sort='ascending'] a[href='/admin/orgs?sort=name&dir=desc']", text: "Name")
    end

    it "marks an inactive sortable column aria-sort=none and links ascending" do
      render_sortable
      expect(page).to have_css("thead th[aria-sort='none'] a[href='/admin/orgs?sort=updated_at&dir=asc']")
    end

    it "leaves a non-sortable column as a plain header, coexisting in the same thead" do
      render_sortable
      expect(page).to have_css("thead th", text: "ID")
      expect(page).to have_no_css("thead th a", text: "ID")
    end
  end

  describe "empty state" do
    it "renders EmptyState with a title-derived heading and does not render the table" do
      render_inline(described_class.new(data: [], title: "Organizations")) do |table|
        table.with_column("Name") { |record| record.name }
      end

      expect(page).to have_text("No organizations found")
      expect(page).to have_no_css("table")
      # Monotonic outline: :h5 beneath the show-page <h4> title section.
      expect(page).to have_css("h5", text: "No organizations found")
    end

    it "uses a generic heading at :h3 when there is no title" do
      render_inline(described_class.new(data: [])) do |table|
        table.with_column("Name") { |record| record.name }
      end

      expect(page).to have_css("h3", text: "No records found")
    end
  end

  describe "batch selection" do
    it "renders the toggle-all and per-row checkboxes wired to mpi--batch-actions when batch: true" do
      render_inline(described_class.new(data: rows, batch: true)) do |table|
        table.with_column("Name") { |record| record.name }
      end

      expect(page).to have_css("thead th input[name='toggle'][data-mpi--batch-actions-target='toggleCheckbox']")
      expect(page).to have_css("tbody td input[name='ids[]'][value='1'][data-mpi--batch-actions-target='checkbox']")
      expect(page).to have_css("tbody td input[name='ids[]'][value='2']")
    end

    it "omits the checkbox column by default" do
      render_inline(described_class.new(data: rows)) do |table|
        table.with_column("Name") { |record| record.name }
      end

      expect(page).to have_no_css("input[name='ids[]']")
    end

    it "renders the batch toolbar only when a batch-action slot is filled (slot? predicate, not bare ||)" do
      # Positive control: a filled slot with rows renders the toolbar.
      render_inline(described_class.new(data: rows, batch: true)) do |table|
        table.with_batch_action_button(:archive, label: "Archive selected")
        table.with_column("Name") { |record| record.name }
      end
      expect(page).to have_css("section.batch-actions button", text: "Archive selected")
    end

    it "does not render the batch toolbar band when no batch-action slot is filled" do
      render_inline(described_class.new(data: rows, batch: true)) do |table|
        table.with_column("Name") { |record| record.name }
      end

      expect(page).to have_no_css("section.batch-actions")
    end

    it "does not render the batch toolbar over an empty table even when a slot is filled" do
      render_inline(described_class.new(data: [], title: "Organizations", batch: true)) do |table|
        table.with_batch_action_button(:archive, label: "Archive selected")
        table.with_column("Name") { |record| record.name }
      end

      expect(page).to have_no_css("section.batch-actions")
      expect(page).to have_text("No organizations found")
    end
  end
end
