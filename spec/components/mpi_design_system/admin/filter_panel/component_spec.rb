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

    # Structurally specific via child combinators: text-body must be on the option
    # ROW that directly wraps `<label> > <input>`. `div.text-body input` alone would
    # false-pass if the class moved to an ancestor div (.filter-section / .pb-2). (Codex)
    expect(page).to have_css("div.text-body > label > input[type='checkbox'][name='tag_group[]'][value='distribution']")
    expect(page).to have_css("div.text-body > label > input[type='checkbox'][name='tag_group[]'][value='outreach']")
    expect(page).to have_css("div.text-body > label > input[type='checkbox'][name='tag_group[]'][value='press_festival']")
  end

  it "renders checked options" do
    render_inline(described_class.new(sections: sections))

    expect(page).to have_css("div.text-body > label > input[type='checkbox'][value='outreach'][checked]")
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
    expect(page).to have_css("div.text-body > label > input[type='checkbox'][value='7d']")
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

  # Guard what survives (EXACT match): the conversion stripped colour but kept the
  # geometry, layout, typography, and button resets inline. Per .claude/rules/testing.md
  # "guard what survives" (#149) — and Codex's PR review — pin the COMPLETE surviving
  # inline style of every changed element, not one representative declaration, so any
  # later edit that drops, adds, or reorders a survivor reddens rather than shipping
  # green. (render_inline proves the emitted style string, not computed paint.)
  it "keeps every surviving non-colour inline style of each converted element exactly" do
    render_inline(described_class.new(sections: sections))

    # panel <aside>
    expect(page).to have_css(
      "aside.bg-body.border[style='border-radius: 8px; padding: 0; min-width: 220px']"
    )
    # title <div>
    expect(page).to have_css(
      "div.text-body[style='font-size: 13px; font-weight: 700; text-transform: uppercase; " \
      "letter-spacing: 0.06em; padding: 14px 16px 10px']",
      text: "Filters"
    )
    # section-header <button> — incl. the transparent/borderless reset that keeps it
    # chromeless; dropping either reset regresses the toggle to a default grey button.
    expect(page).to have_css(
      "button.text-body[style='display: flex; align-items: center; " \
      "justify-content: space-between; padding: 10px 16px; cursor: pointer; border: none; " \
      "background: transparent; width: 100%; font-size: 13px; font-weight: 600; text-align: left']",
      text: "Tag Group"
    )
    # option row <div>
    expect(page).to have_css(
      "div.text-body[style='display: flex; align-items: center; justify-content: space-between; " \
      "padding: 4px 16px 4px 20px; font-size: 13px']"
    )
    # count <span>
    expect(page).to have_css("span.text-body-secondary[style='font-size: 11px;']", text: "42")
    # chevron <i> — expanded (no rotate)
    expect(page).to have_css(
      "i.bi.bi-chevron-down.text-body-secondary" \
      "[style='font-size: 12px; transition: transform 0.2s ease;']",
      count: 1
    )
    # chevron <i> — collapsed (adds the rotate)
    expect(page).to have_css(
      "i.bi.bi-chevron-down.text-body-secondary" \
      "[style='font-size: 12px; transition: transform 0.2s ease; transform: rotate(-90deg);']",
      count: 1
    )
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
