# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::FilterPanel::Component, type: :component do
  let(:sections) do
    [
      {
        title: "Tag Group",
        field_name: "tag_group[]",
        options: [
          { label: "Buyers", value: "buyers", count: 42, checked: false },
          { label: "Press", value: "press", count: 28, checked: true },
          { label: "Festivals", value: "festivals", count: 15, checked: false }
        ]
      },
      {
        title: "Engagement Type",
        field_name: "engagement_type[]",
        collapsed: true,
        options: [
          { label: "Email", value: "email", count: 120 },
          { label: "Meeting", value: "meeting", count: 35 },
          { label: "Call", value: "call", count: 18 }
        ]
      }
    ]
  end

  it "renders aside with Filters aria-label" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("aside[aria-label='Filters']")
  end

  it "renders Filters heading" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Filters")
  end

  it "renders section titles as collapse toggle buttons" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("button[data-bs-toggle='collapse']", text: "Tag Group")
    expect(page).to have_css("button[data-bs-toggle='collapse']", text: "Engagement Type")
  end

  it "renders options with checkbox inputs" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("input[type='checkbox'][name='tag_group[]'][value='buyers']")
    expect(page).to have_css("input[type='checkbox'][name='tag_group[]'][value='press']")
    expect(page).to have_css("input[type='checkbox'][name='tag_group[]'][value='festivals']")
  end

  it "renders checked options" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("input[type='checkbox'][value='press'][checked]")
  end

  it "renders option labels" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_text("Buyers")
    expect(page).to have_text("Press")
    expect(page).to have_text("Festivals")
  end

  it "renders option counts" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "42")
    expect(page).to have_css("span[style*='color: #6C757D']", text: "28")
  end

  it "renders zero count values" do
    sections_with_zero = [
      {
        title: "Status",
        field_name: "status[]",
        options: [ { label: "Archived", value: "archived", count: 0 } ]
      }
    ]
    render_inline(described_class.new(sections: sections_with_zero))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "0")
  end

  it "hides count when not provided" do
    sections_no_count = [
      {
        title: "Date",
        field_name: "date[]",
        options: [ { label: "Last 7 days", value: "7d" } ]
      }
    ]
    render_inline(described_class.new(sections: sections_no_count))

    expect(page).to have_text("Last 7 days")
    expect(page).not_to have_css("span[style*='font-size: 11px']")
  end

  it "renders collapsed sections without show class" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("#filter-section-1.collapse:not(.show)")
  end

  it "renders expanded sections with show class" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("#filter-section-0.collapse.show")
  end

  it "renders aria-expanded attributes on toggle buttons" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("button[aria-expanded='true']", text: "Tag Group")
    expect(page).to have_css("button[aria-expanded='false']", text: "Engagement Type")
  end

  it "renders form with GET method and action URL" do
    render_inline(described_class.new(sections: sections, form_action: "/search"))

    expect(page).to have_css("form[action='/search'][method='get']")
  end

  it "renders dividers between sections" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("hr[style*='border-top: 1px solid #DEE2E6']")
  end

  it "renders chevron-down icons on all section headers" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("i.bi.bi-chevron-down", count: 2)
  end

  it "rotates chevron for collapsed sections" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("i.bi.bi-chevron-down[style*='rotate(-90deg)']")
  end

  it "renders empty panel without errors" do
    render_inline(described_class.new(sections: []))

    expect(page).to have_css("aside[aria-label='Filters']")
  end

  it "renders white card background with border" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("aside[style*='background: #fff'][style*='border: 1px solid #DEE2E6']")
  end
end
