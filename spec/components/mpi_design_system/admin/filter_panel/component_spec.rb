# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::FilterPanel::Component, type: :component do
  let(:sections) do
    [
      {
        title: "Tag Group",
        field_name: "tag_group[]",
        options: [
          { label: "Distribution", value: "distribution", count: 42, checked: false },
          { label: "Outreach", value: "outreach", count: 28, checked: true },
          { label: "Press/Festival", value: "press_festival", count: 15, checked: false }
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

  it "renders the panel as a theme-adaptive card" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("aside.bg-body.border[aria-label='Filters']")
  end

  it "renders the Filters heading in body text" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("div.text-body[style*='text-transform: uppercase']", text: "Filters")
  end

  it "renders section titles as collapse toggle buttons in body text" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("button.text-body[data-bs-toggle='collapse']", text: "Tag Group")
    expect(page).to have_css("button.text-body[data-bs-toggle='collapse']", text: "Engagement Type")
  end

  it "renders option rows as body-text rows wrapping their checkbox" do
    render_inline(described_class.new(sections: sections))

    # Structurally specific: the checkbox must be a descendant of the .text-body
    # row itself, so the class landing on an ancestor would not false-pass.
    expect(page).to have_css("div.text-body input[type='checkbox'][name='tag_group[]'][value='distribution']")
    expect(page).to have_css("div.text-body input[type='checkbox'][name='tag_group[]'][value='outreach']")
    expect(page).to have_css("div.text-body input[type='checkbox'][name='tag_group[]'][value='press_festival']")
  end

  it "renders checked options" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("div.text-body input[type='checkbox'][value='outreach'][checked]")
  end

  it "renders option labels" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_text("Distribution")
    expect(page).to have_text("Outreach")
    expect(page).to have_text("Press/Festival")
  end

  it "renders option counts in secondary body text" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("span.text-body-secondary[style*='font-size: 11px']", text: "42")
    expect(page).to have_css("span.text-body-secondary[style*='font-size: 11px']", text: "28")
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

    expect(page).to have_css("span.text-body-secondary[style*='font-size: 11px']", text: "0")
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

    # Positive first: prove the option row rendered, then the absence of its count.
    expect(page).to have_css("div.text-body input[type='checkbox'][value='7d']")
    expect(page).to have_text("Last 7 days")
    expect(page).not_to have_css("span.text-body-secondary")
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

  it "renders theme-adaptive dividers between sections" do
    render_inline(described_class.new(sections: sections))

    # Two sections -> exactly one divider, carrying all three utility classes.
    expect(page).to have_css("hr.border-top.opacity-100.m-0", count: 1)
  end

  it "renders chevron-down icons in secondary body text on all section headers" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("i.bi.bi-chevron-down.text-body-secondary", count: 2)
  end

  it "rotates chevron for collapsed sections" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("i.bi.bi-chevron-down[style*='rotate(-90deg)']")
  end

  it "renders empty panel without errors" do
    render_inline(described_class.new(sections: []))

    expect(page).to have_css("aside.bg-body.border[aria-label='Filters']")
  end

  # Guard what survives: the conversion stripped colour but kept the geometry,
  # layout, and typography inline. These declarations have no Bootstrap
  # equivalent here, so pin one surviving declaration per changed helper —
  # otherwise the next edit that drops one ships green. (See
  # .claude/rules/testing.md "guard what survives", modelled on #149 Pagination.)
  it "keeps the non-colour geometry, layout, and typography that has no Bootstrap equivalent" do
    render_inline(described_class.new(sections: sections))

    # panel geometry
    expect(page).to have_css("aside.bg-body.border[style*='min-width: 220px']")
    # title typography
    expect(page).to have_css(
      "div.text-body[style*='font-weight: 700'][style*='letter-spacing: 0.06em']",
      text: "Filters"
    )
    # section-button layout
    expect(page).to have_css(
      "button.text-body[style*='justify-content: space-between'][style*='width: 100%']",
      text: "Tag Group"
    )
    # section-button reset: transparent, borderless chrome. Dropping either
    # `background: transparent` or `border: none` regresses the collapse toggle
    # to a default grey button — a visible regression no colour test catches.
    expect(page).to have_css(
      "button.text-body[style*='background: transparent'][style*='border: none']",
      text: "Tag Group"
    )
    # option-row spacing
    expect(page).to have_css("div.text-body[style*='padding: 4px 16px 4px 20px']")
    # count sizing
    expect(page).to have_css("span.text-body-secondary[style*='font-size: 11px']", text: "42")
    # chevron transition (both chevrons keep it)
    expect(page).to have_css("i.bi.bi-chevron-down[style*='transition: transform 0.2s ease']", count: 2)
  end

  # Absence guard, paired after the positive card assertion: the conversion's
  # contract is that NO surviving inline style pins a palette hex. Re-adding any
  # `color: #...` (or `background: #fff`) to an inline style reddens this.
  it "leaves no palette hex in any surviving inline style" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("aside.bg-body.border[aria-label='Filters']")
    expect(page).to have_no_css("[style*='#']")
  end
end
