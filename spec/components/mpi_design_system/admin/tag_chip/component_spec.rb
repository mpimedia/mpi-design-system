# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::TagChip::Component, type: :component do
  it "renders a tag chip with group color" do
    render_inline(described_class.new(label: "Distribution", group: :distribution))

    expect(page).to have_css("span[style*='#E8733A']", text: "Distribution")
    expect(page).to have_css("span[style*='#FEF3EC']")
  end

  it "renders different colors for different groups" do
    render_inline(described_class.new(label: "Outreach", group: :outreach))

    expect(page).to have_css("span[style*='#2DA67E']", text: "Outreach")
  end

  it "renders a colored dot indicator before the label" do
    render_inline(described_class.new(label: "Distribution", group: :distribution))

    expect(page).to have_css("span[style*='background-color: #E8733A'][style*='border-radius: 50%']")
  end

  it "renders dot with correct color for each group" do
    render_inline(described_class.new(label: "Press/Festival", group: :press_festival))

    expect(page).to have_css("span[style*='background-color: #2E75B6'][style*='border-radius: 50%']")
  end

  it "renders a removable chip with close button (no URL)" do
    render_inline(described_class.new(label: "MIPCOM 2025", group: :distribution, removable: true))

    expect(page).to have_css("button[aria-label='Remove MIPCOM 2025']")
    expect(page).to have_css("i.bi.bi-x-lg")
  end

  it "renders a removable chip as turbo link when remove_url provided" do
    render_inline(described_class.new(label: "MIPCOM 2025", group: :distribution, removable: true, remove_url: "/tags/1"))

    expect(page).to have_css("a[href='/tags/1'][aria-label='Remove MIPCOM 2025']")
    expect(page).to have_css("a[data-turbo-method='delete']")
  end

  it "does not show remove button by default" do
    render_inline(described_class.new(label: "Press/Festival", group: :press_festival))

    expect(page).not_to have_css("button")
  end

  it "renders at small size" do
    render_inline(described_class.new(label: "Test", group: :internal, size: :sm))

    expect(page).to have_css("span[style*='font-size: 12px']")
  end

  it "renders at default size" do
    render_inline(described_class.new(label: "Test", group: :internal))

    expect(page).to have_css("span[style*='font-size: 13px']")
  end

  it "has pill shape" do
    render_inline(described_class.new(label: "Test", group: :vendors))

    expect(page).to have_css("span[style*='border-radius: 999px']")
  end

  # GROUP_VARIANTS is the shared tag-group -> Bootstrap-semantic mapping that
  # FilterChipBar and DataTable consume (#151). Every GROUPS key must have a mapping,
  # or a converted consumer would hit `nil` and silently fall back to `secondary`.
  describe "GROUP_VARIANTS mapping (#151)" do
    it "maps every GROUPS key to a semantic variant" do
      expect(described_class::GROUP_VARIANTS.keys).to match_array(described_class::GROUPS.keys)
    end

    # The consumer loops (FilterChipBar/DataTable) read this same constant, so a
    # semantic REMAP (e.g. distribution: :danger -> :success) would render and assert
    # the new value identically and ship green there. Pinning the exact mapping makes
    # any category recolour a deliberate, test-updating change — the crux design
    # decision of #151 (info==primary collapses the three cool categories onto blue).
    it "maps each category to its issue-specified semantic" do
      expect(described_class::GROUP_VARIANTS).to eq(
        press_festival: :primary,
        production: :primary,
        vendors: :primary,
        outreach: :success,
        finance: :warning,
        distribution: :danger,
        internal: :secondary
      )
    end

    it "maps only to real Bootstrap theme colours" do
      valid = %i[primary secondary success warning danger info light dark]
      expect(described_class::GROUP_VARIANTS.values.uniq - valid).to be_empty
    end

    # TagChip's OWN rendering stays hex this phase — the conversion is limited to the
    # two list-view consumers. This pins that scope: the chip still emits its frozen
    # colour pair, so a future TagChip conversion is a deliberate, tested change rather
    # than an accident. (#151 follow-up)
    it "leaves TagChip's own rendering on the frozen hex palette" do
      render_inline(described_class.new(label: "Distribution", group: :distribution))

      expect(page).to have_css("span[style*='color: #E8733A'][style*='background-color: #FEF3EC']", text: "Distribution")
    end
  end
end
