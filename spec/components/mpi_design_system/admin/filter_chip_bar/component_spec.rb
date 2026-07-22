# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::FilterChipBar::Component, type: :component do
  describe "group chips" do
    let(:groups) do
      [
        { label: "All", count: 2307 },
        { label: "Distribution", count: 342, group: :distribution, href: "/contacts?group=distribution" },
        { label: "Outreach", count: 128, group: :outreach, href: "/contacts?group=outreach" }
      ]
    end

    it "renders group chips with GROUPS label" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Groups:")
      expect(page).to have_text("All 2307")
      expect(page).to have_text("Distribution 342")
    end

    it "renders group chips as links when href is provided" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("a[href='/contacts?group=distribution']", text: "Distribution 342")
    end

    # Looped over the whole mapping — a spot-check on one group would let a typo in
    # GROUP_VARIANTS ship green (testing.md, "loop the constant"). Each selected chip
    # renders its group's semantic `-subtle` surface + `-emphasis` foreground, which
    # are theme-adaptive; the always-present count text pins WHICH chip is asserted.
    it "renders a selected chip in its group's semantic subtle/emphasis utilities" do
      described_class::GROUP_VARIANTS.each do |group, variant|
        render_inline(described_class.new(groups: [
          { label: group.to_s, count: 5, group: group, selected: true, href: "/contacts?group=#{group}" }
        ]))

        expect(page).to have_css(
          "a.rounded-pill.border.border-#{variant}-subtle.bg-#{variant}-subtle.text-#{variant}-emphasis[aria-current='page']",
          text: "#{group} 5"
        )
      end
    end

    it "renders unselected chips on the adaptive body surface" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("a.rounded-pill.border.bg-body.text-body", text: "Distribution 342")
      expect(page).to have_css("a.rounded-pill.border.bg-body.text-body", text: "Outreach 128")
    end

    # A selected chip whose group is unknown gets the UNSELECTED treatment. `bg-body`
    # is a state the selected branch cannot produce (it emits `-subtle`/`-emphasis`),
    # so this distinguishes "fell back" from "was ignored" (testing.md False Green #1).
    it "treats a selected chip with an unknown group as unselected" do
      render_inline(described_class.new(groups: [
        { label: "Mystery", count: 3, group: :nope, selected: true, href: "/contacts?group=nope" }
      ]))

      expect(page).to have_css("a.rounded-pill.border.bg-body.text-body[aria-current='page']", text: "Mystery 3")
      expect(page).not_to have_css("a[class*='-subtle']")
    end

    # Colour left the chip's inline style; padding/size/weight did not, and have no
    # Bootstrap equivalent. The theme-adaptivity guards below only assert ABSENCE, so
    # without this a wiped group_chip_styles would ship green. Watched red by emptying
    # that helper.
    it "keeps the non-colour chip geometry inline" do
      render_inline(described_class.new(groups: [ { label: "All", count: 5 } ]))

      expect(page).to have_css(
        "span.rounded-pill[style*='padding: 5px 12px'][style*='font-size: 13px'][style*='font-weight: 500']",
        text: "All 5"
      )
    end

    it "wraps in a role=group with aria-label" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("[role='group'][aria-label='Filter by group']")
    end
  end

  describe "active filter pills" do
    let(:active_filters) do
      [
        { category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" },
        { category: "Group", value: "Distribution", remove_url: "/contacts?remove=group" }
      ]
    end

    it "renders active pills with ACTIVE label" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Active:")
      expect(page).to have_text("Keyword: investors")
      expect(page).to have_text("Group: Distribution")
    end

    # The pill renders the same derived-foreground fill as ActiveFilterBar. (#130)
    it "renders pills with a Bootstrap-derived foreground rather than pinned white" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css("span.rounded-pill.text-bg-primary", text: "Keyword: investors")
      expect(page).to have_no_css("span[style*='background: #2E75B6']")
      expect(page).to have_no_css("span[style*='color: #fff']")
    end

    # The retired `opacity: 0.8` faded white to 3.71:1 (#130); the retired inline
    # `color: inherit; background: none; border: none` became the utility trio
    # `text-reset bg-transparent border-0`, so the button pins no colour of its own
    # while still inheriting the pill's derived foreground. (#151)
    it "resets the remove button to the pill's own foreground without pinning colour" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css("a.text-reset.bg-transparent.border-0[aria-label='Remove filter: Keyword: investors']", count: 1)
      expect(page).to have_css("a.text-reset.bg-transparent.border-0", count: 2)
      expect(page).to have_no_css("a[style*='color']")
      expect(page).to have_no_css("a[style*='opacity']")
    end

    # remove_btn_styles keeps padding/font-size/line-height/cursor inline (no Bootstrap
    # equivalent). Pin them POSITIVELY — the theme-adaptivity guards only assert ABSENCE,
    # so without this, emptying remove_btn_styles ships green. Watched red by emptying it.
    # (#151, FIX 5)
    it "keeps the remove button's non-colour geometry inline" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css(
        "a.text-reset.bg-transparent.border-0[style*='padding: 0'][style*='font-size: inherit']" \
        "[style*='line-height: 1'][style*='cursor: pointer']",
        count: 2
      )
    end

    it "derives the label and clear-all foreground rather than pinning #6C757D" do
      render_inline(described_class.new(active_filters: active_filters, clear_all_url: "/contacts"))

      expect(page).to have_css("span.text-body-secondary", text: "Active:")
      expect(page).to have_css("a.text-body-secondary", text: "Clear all")
    end

    it "renders remove button with aria-label" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).to have_css("a[aria-label='Remove filter: Keyword: investors']")
      expect(page).to have_css("i.bi.bi-x")
    end

    it "renders clear all link when clear_all_url is provided" do
      render_inline(described_class.new(active_filters: active_filters, clear_all_url: "/contacts"))

      expect(page).to have_css("a[aria-label='Clear all filters']", text: "Clear all")
    end

    it "does not render clear all when clear_all_url is nil" do
      render_inline(described_class.new(active_filters: active_filters))

      expect(page).not_to have_text("Clear all")
    end
  end

  it "does not render groups section when groups are empty" do
    render_inline(described_class.new(active_filters: [ { category: "Keyword", value: "test" } ]))

    expect(page).not_to have_text("Groups:")
  end

  it "does not render active section when active_filters are empty" do
    render_inline(described_class.new(groups: [ { label: "All", count: 100 } ]))

    expect(page).not_to have_text("Active:")
  end

  it "renders reset all link when reset_all_url is provided" do
    groups = [
      { label: "All", count: 100 },
      { label: "Distribution", count: 50, group: :distribution, selected: true, href: "#" }
    ]
    render_inline(described_class.new(groups: groups, reset_all_url: "/contacts"))

    expect(page).to have_css("a[href='/contacts'][aria-label='Reset all filters']", text: "Reset all")
  end

  it "does not render reset all link when reset_all_url is nil" do
    groups = [ { label: "All", count: 100 } ]
    render_inline(described_class.new(groups: groups))

    expect(page).not_to have_text("Reset all")
  end

  # This component sets no background of its own, so a pinned muted foreground is
  # only ever verified against an assumed one — `#6C757D` scored 4.69:1 on white
  # but 4.37:1 on $mpi-background. `.text-body-secondary` derives from
  # --bs-body-color and clears AA on both (6.40:1 / 6.14:1). (#130)
  describe "muted text contrast (#130)" do
    let(:groups) { [ { label: "All", count: 100 } ] }

    it "derives the groups label foreground" do
      render_inline(described_class.new(groups: groups))

      expect(page).to have_css("span.text-body-secondary", text: "Groups:")
    end

    it "derives the reset-all foreground" do
      render_inline(described_class.new(groups: groups, reset_all_url: "/contacts"))

      expect(page).to have_css("a.text-body-secondary", text: "Reset all")
    end

    it "emits no hardcoded muted foreground anywhere in the rendered markup" do
      render_inline(described_class.new(
        groups: groups,
        active_filters: [ { category: "Tag", value: "Acquisitions", remove_url: "#" } ],
        clear_all_url: "/contacts",
        reset_all_url: "/contacts"
      ))

      expect(page.native.to_html).not_to include("#6C757D")
    end
  end

  # #151 moved every chip colour (selected surface, unselected surface, remove button)
  # onto Bootstrap semantic utilities so the bar tracks `data-bs-theme`. Each guard
  # pins the element it is about POSITIVELY before asserting an absence, and each was
  # proven by watching it fail against a mutation that trips it (testing.md, "A Guard
  # Is Not Real Until You Have Watched It Fail"). The 12-entry fixed-scheme list is the
  # exact one from pagination/component_spec.rb.
  describe "theme-adaptivity guards" do
    let(:fixed_scheme_utilities) do
      %w[
        bg-white bg-black bg-light bg-dark
        text-white text-black text-light text-dark
        border-white border-black border-light border-dark
      ]
    end

    # Matches 3-, 4-, 6- and 8-digit CSS hex; the trailing (?!\h) stops a 6-digit
    # match inside a longer run and the 4/8 branches close the alpha forms.
    let(:hex_literal) { /#(?:\h{8}|\h{6}|\h{4}|\h{3})(?!\h)/ }

    # A colour/border/opacity-bearing property, matched on the name to the LEFT of the
    # colon. `--bs-border-width` (custom-property prefix) and `border-radius` (radius is
    # not one of the side/attribute suffixes) fall OUTSIDE this pattern and stay allowed
    # geometry — so a re-introduced `border: 1px solid red` or `border: none` is caught
    # while the surviving `--bs-border-width: 2px` is not. (#151, FIX 3)
    let(:colour_or_border_prop) do
      /\A(color|background(-color)?|border(-(top|right|bottom|left|color|style|width))?|outline|box-shadow|opacity)\z/
    end

    # A colour literal in a declaration VALUE: hex, rgb()/hsl(), or a common named colour
    # as a whole word — so a hue smuggled into an allowed property's value is still caught.
    let(:colour_value_literal) do
      /#(?:\h{3,8})|\brgb|\bhsl|\b(?:red|green|blue|white|black|orange|yellow|purple|gr[ae]y)\b/i
    end

    # Every surviving inline "property: value" declaration that names a colour/border
    # property OR carries a colour literal in its value.
    def offending_style_declarations(fragment)
      fragment.css("[style]")
              .flat_map { |el| el["style"].to_s.split(";") }
              .map(&:strip).reject(&:empty?)
              .select do |decl|
        prop, value = decl.split(":", 2)
        prop.to_s.strip.downcase.match?(colour_or_border_prop) ||
          value.to_s.strip.downcase.match?(colour_value_literal)
      end
    end

    let(:populated) do
      described_class.new(
        groups: [
          { label: "All", count: 2307 },
          { label: "Distribution", count: 342, group: :distribution, selected: true, href: "/contacts?group=distribution" },
          { label: "Outreach", count: 128, group: :outreach, href: "/contacts?group=outreach" }
        ],
        active_filters: [ { category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" } ],
        clear_all_url: "/contacts",
        reset_all_url: "/contacts"
      )
    end

    it "emits no literal colour anywhere in the markup" do
      render_inline(populated)

      # Prove the markup under scrutiny actually rendered — a scan over an empty
      # string matches nothing and would pass forever.
      expect(page).to have_css("a[aria-current='page']", text: "Distribution 342")
      expect(page).to have_css("span.text-bg-primary", text: "Keyword: investors")

      expect(rendered_content).not_to match(hex_literal)
      expect(rendered_content).not_to include("rgb(")
      expect(rendered_content).not_to include("hsl(")
    end

    it "emits no colour, border, or opacity declaration in the inline styles that remain" do
      render_inline(populated)

      # Inline styles DO still exist (geometry) — without this the assertion below would
      # pass on a component that emitted no style at all.
      expect(page).to have_css("[style*='padding: 5px 12px']")

      # Only geometry may survive inline. Matching on the PROPERTY name catches a
      # re-introduced `border: 1px solid red` / `border: none` (named colour / keyword) a
      # `[style*='color']` / `[style*='background']` substring scan let through;
      # `--bs-border-width` and `border-radius` remain allowed. Proven by mutation: a
      # `border: 1px solid red` injected into a style helper reddens this. (#151, FIX 3)
      fragment = Nokogiri::HTML::DocumentFragment.parse(rendered_content)
      expect(offending_style_declarations(fragment)).to eq([])
    end

    it "pins no fixed-scheme utility that would break under data-bs-theme" do
      render_inline(populated)

      # Every element, enumerated — not a [class*=…] substring hunt, which would match
      # `border-danger-subtle` for `border-dark`.
      elements = page.all("*")
      expect(elements.size).to be > 1

      applied = elements.flat_map { |el| el[:class].to_s.split }.uniq
      expect(applied).to include(
        "text-body", "bg-body", "text-body-secondary",
        "text-bg-primary", "bg-danger-subtle", "text-danger-emphasis"
      )
      expect(applied & fixed_scheme_utilities).to be_empty
    end
  end
end
