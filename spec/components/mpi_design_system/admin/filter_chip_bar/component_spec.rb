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
  #
  # #183 replaced this block's hand-rolled declaration parser, hex regex and 12-entry
  # fixed-scheme denylist with the shared guard in `spec/support/theme_adaptivity.rb`.
  describe "theme-adaptivity guards" do
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

      # Attributes and text included, so a hex in an `svg fill=` or a `data-*` is caught
      # too — neither is visible to the declaration scan below.
      expect(rendered_fragment).to be_free_of_colour_literals
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
      rendered_fragment.css("[style]").each do |node|
        expect(node["style"]).to be_free_of_frozen_colour
      end
    end

    # `text-bg-primary` on the ACTIVE filter pill (component.html.erb:29) is a deliberate
    # fixed hue, not an oversight: the fill IS the selection affordance.
    # `.claude/rules/frontend.md` records this as the accepted selected-state exception —
    # #fff on #2E75B6 = 4.843:1, identical in both colour modes because neither value
    # re-resolves.
    #
    # Only the sanctioned CLASS is removed — never the node, and never
    # `.allowing("text-bg-primary")`. The allowance is class-scoped and not
    # placement-scoped: Codex's #183 review proved on the sibling ActiveFilterBar that a
    # fragment-wide allowance also passes the same class on a NON-selected label, which is
    # precisely the condition the rule imposes and the matcher cannot check. The group
    # chips are the case that matters here — a selected chip must render
    # `-subtle`/`-emphasis`, and a chip that regressed to `text-bg-primary` would have been
    # waved through by the allowance while failing this strip's count.
    #
    # Removing the whole PILL (the first correction) was too broad in the other direction:
    # it deleted the pill's other classes and its remove link from the scan as well, and
    # Codex's review of that fix commit shipped `bg-white` past it on both. Stripping only
    # `text-bg-primary` keeps the pill, its style and its `text-reset bg-transparent
    # border-0` remove link in scope, so either injection reddens.
    #
    # `strip_sanctioned_hue` pins the exact count (an OVER-strip is the silent failure mode;
    # `not_to be_empty` passes straight through one) and that the pill really carried the
    # class; the assertion below pins the "#{category}: #{value}" identity the component
    # builds for an active filter.
    let(:selected_pill) { "span.rounded-pill.text-bg-primary" }

    def without_selected_hue(fragment)
      pills = fragment.css(selected_pill)
      strip_sanctioned_hue(pills, [ "text-bg-primary" ])
      expect(pills.map { |pill| pill.text.squish }).to eq([ "Keyword: investors" ])
      fragment
    end

    it "applies only theme-adaptive colour utilities once the selected hue is stripped" do
      render_inline(populated)
      fragment = without_selected_hue(rendered_fragment)

      # Every element, enumerated — not a [class*=…] substring hunt, which would match
      # `border-danger-subtle` for `border-dark`.
      applied = ThemeAdaptivity.applied_utility_classes(fragment)
      expect(applied).to include(
        "text-body", "bg-body", "text-body-secondary",
        "bg-danger-subtle", "text-danger-emphasis"
      )

      # No `allowing:` at all — the fixed-hue exception was taken by placement above.
      expect(fragment).to be_free_of_fixed_hue_utilities
    end

    # The pill's own fixed hue and its selected-state semantics, pinned here rather than
    # left to the scan above. The negative halves are the placement condition the
    # matcher could not express: neither the "Active:" label nor a SELECTED GROUP CHIP
    # (which is a selected state, but one the rule sends to `-subtle`/`-emphasis`) may
    # carry the fill.
    it "still paints exactly the active filter in the fixed selected-state hue" do
      render_inline(populated)

      expect(page).to have_css(selected_pill, count: 1)
      expect(page).to have_css(selected_pill, text: "Keyword: investors")
      expect(page).to have_css("span.text-body-secondary", text: "Active:")
      expect(page).to have_no_css("span.text-bg-primary", text: "Active:")
      expect(page).to have_css(
        "a[aria-current='page'].bg-danger-subtle.text-danger-emphasis", text: "Distribution 342"
      )
      expect(page).to have_no_css("a[aria-current='page'].text-bg-primary")
    end
  end
end
