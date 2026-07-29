# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::ActiveFilterBar::Component, type: :component do
  let(:filters) do
    [
      { category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" },
      { category: "Group", value: "Distribution", remove_url: "/contacts?remove=group" }
    ]
  end

  # The pill carries Bootstrap's `.text-bg-primary`, so its background AND foreground
  # derive from the consuming app's actual $primary rather than a literal. (#130)
  it "renders active filter pills" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("span.rounded-pill.text-bg-primary", text: "Keyword: investors")
    expect(page).to have_css("span.rounded-pill.text-bg-primary", text: "Group: Distribution")
  end

  it "renders ACTIVE label" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Active:")
  end

  it "renders remove buttons for each filter" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("a[aria-label='Remove filter: Keyword: investors']")
    expect(page).to have_css("a[data-turbo-method='delete']", count: 2)
  end

  it "renders clear all link" do
    render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

    expect(page).to have_css("a[href='/contacts?clear']", text: "Clear all")
  end

  it "renders as a toolbar with aria label" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("div[role='toolbar'][aria-label='Active filters']")
  end

  # #150: the bar surface was a pinned light `#F5F7FA` scoped to `data-bs-theme="light"`.
  # It is now `.bg-body-secondary.rounded` — adaptive — so the theme pin is gone (it
  # would now BLOCK dark mode). `.rounded` == --bs-border-radius == 6px under this
  # engine's config, preserving the retired `border-radius: 6px`.
  it "renders the bar on the adaptive secondary body surface with no colour-mode pin" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("div.bg-body-secondary.rounded[role='toolbar']")
    expect(page).to have_no_css("div[style*='background']")
    expect(page).to have_no_css("[data-bs-theme]")
  end

  describe "contrast (#130) and theme-adaptivity (#150)" do
    it "derives the pill foreground from Bootstrap instead of pinning white" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("span.text-bg-primary")
      expect(page).to have_no_css("span[style*='color: #fff']")
      expect(page).to have_no_css("span[style*='background: #2E75B6']")
    end

    # The retired `opacity: 0.8` faded white to an effective #D5E3F0 over the pill —
    # 3.71:1, an AA failure invisible to any audit that only reads `color:`. The
    # button now inherits the pill's derived foreground at full strength.
    it "does not fade the remove button, which eroded contrast to 3.71:1" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("a[style*='color: inherit']", count: 2)
      expect(page).to have_no_css("a[style*='opacity']")
    end

    it "derives the label and clear-all foreground rather than pinning #6C757D" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      expect(page).to have_css("span.text-body-secondary", text: "Active:")
      expect(page).to have_css("a.text-body-secondary", text: "Clear all")
      expect(page).to have_no_css("[style*='color: #6C757D']")
    end

    # The component now carries NO colour hex at all (surface, pill, label and remove
    # button are all Bootstrap utilities), so a single sweep over the whole rendered
    # document catches a hardcoded literal reintroduced anywhere in this template —
    # including markup this spec does not enumerate. The positive pin proves the
    # markup actually rendered, so the regex is not passing over an empty string.
    it "emits no literal hex anywhere in the rendered markup" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      expect(page).to have_css("div.bg-body-secondary[role='toolbar']")
      expect(page).to have_css("span.text-bg-primary", text: "Keyword: investors")

      # Attributes and text included, so a hex in an `svg fill=` or a `data-*` is caught
      # too — neither is visible to a declaration scan.
      expect(rendered_fragment).to be_free_of_colour_literals
    end

    # ISS#183 triage. The shared declaration guard reaches this component for the first
    # time here, and it reports the remove control's UA reset — `background: none` and
    # `border: none` (component.rb:60-71), once per filter.
    #
    # That is a deliberately conservative TRUE POSITIVE of the guard's shape rather than
    # a frozen colour: `none` freezes no hue in either colour mode, and the rule rejects
    # it because #151 caught `border: none` silently overriding a UTILITY border — which
    # is not what is happening on a bare `<a>` with no border utility. The clean fix is
    # the one TagChip, TagInput and FilterChipBar already took, replacing the reset with
    # `text-reset bg-transparent border-0` classes; that is an `app/` change and out of
    # scope for a spec consolidation.
    #
    # So it is PINNED rather than skipped: the complete offence multiset is asserted, so
    # a genuinely frozen colour reintroduced anywhere in this template — including on the
    # remove control itself — pushes the set off and reddens this.
    it "emits no frozen-colour declaration beyond the remove control's reset" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      # Geometry inline styles DO still exist — without this the scan below could pass
      # on markup that emitted no style at all.
      expect(page).to have_css("[style*='text-transform: uppercase']")

      offences = rendered_fragment.css("[style]").flat_map do |node|
        ThemeAdaptivity.frozen_colour_offences(node["style"]).map { |offence| offence.split(" — ").first }
      end

      # One reset per RENDERED remove control — a filter without a `remove_url` renders no
      # control, so count those rather than the filters.
      remove_controls = filters.count { |filter| filter[:remove_url] }
      expect(remove_controls).to eq(2)
      expect(offences).to contain_exactly(
        *Array.new(remove_controls) { [ '"background: none"', '"border: none"' ] }.flatten
      )
    end

    # The active-filter pills are the one place this bar deliberately paints a FIXED hue.
    # `.claude/rules/frontend.md` records that as the accepted SELECTED-STATE exception —
    # the fill IS the affordance, and #fff on #2E75B6 = 4.843:1, identical in both colour
    # modes because neither value re-resolves (#130: background AND foreground derive from
    # the consuming app's real `$primary` rather than a literal).
    #
    # Only the sanctioned CLASS is removed — never the node. `.allowing("text-bg-primary")`
    # is class-scoped, not placement-scoped, so Codex's #183 review shipped the fill on the
    # NON-selected "Active:" label past 111 green examples; keying the strip on this selector
    # fixes that, because the label does not match it and survives into the scan.
    #
    # But the first correction removed the whole PILL, which is wider than the exception:
    # deleting the subtree also deletes every other regression on it. Codex's review of that
    # fix commit proved it — `bg-white` on the pill itself, and `bg-white` on the remove
    # link INSIDE it, both shipped green. Stripping just `text-bg-primary` leaves the pill,
    # its geometry style and its remove link in the scan, so either injection now reddens.
    #
    # `strip_sanctioned_hue` pins the count (its `sanctioned` list has one entry per pill —
    # an OVER-strip is the silent failure mode, and `not_to be_empty` passes straight through
    # one) and that each pill really carried the class. The identity assertion here is the
    # other half: each stripped node must actually BE an active filter, identified by the
    # "#{category}: #{value}" label the component builds for it.
    let(:selected_pill) { "span.rounded-pill.text-bg-primary" }

    def without_selected_hue(fragment)
      pills = fragment.css(selected_pill)
      strip_sanctioned_hue(pills, Array.new(filters.length) { "text-bg-primary" })
      expect(pills.map { |pill| pill.text.squish })
        .to eq(filters.map { |filter| "#{filter[:category]}: #{filter[:value]}" })
      fragment
    end

    it "applies only theme-adaptive colour utilities once the selected hue is stripped" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))
      fragment = without_selected_hue(rendered_fragment.css("div[role='toolbar']"))

      applied = ThemeAdaptivity.applied_utility_classes(fragment)
      expect(applied).to include("bg-body-secondary", "text-body-secondary")

      # No `allowing:` at all — the fixed-hue exception was taken by placement above.
      expect(fragment).to be_free_of_fixed_hue_utilities
    end

    # The pills' own fixed hue and their selected-state semantics, pinned here rather than
    # left to the scan above: stripping the class from the SCAN must not remove it from the
    # SUITE. The negative half is the placement condition the matcher could not express —
    # the "Active:" label is not a selected state and may never carry the fill.
    it "still paints exactly the active filters in the fixed selected-state hue" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      expect(page).to have_css(selected_pill, count: filters.length)
      expect(page).to have_css(selected_pill, text: "Keyword: investors")
      expect(page).to have_css(selected_pill, text: "Group: Distribution")
      expect(page).to have_css("span.text-body-secondary", text: "Active:")
      expect(page).to have_no_css("span.text-bg-primary", text: "Active:")
    end
  end

  describe "edge cases" do
    it "renders nothing when filters are empty" do
      render_inline(described_class.new(filters: []))

      # show? is false, so the whole template is elided — assert the output itself
      # is empty rather than merely that the toolbar is absent (a positive check on
      # the rendered string, not a bare absence).
      expect(rendered_content.strip).to be_empty
    end

    it "renders nothing and does not raise when filters is nil" do
      output = nil
      expect { output = render_inline(described_class.new(filters: nil)) }.not_to raise_error
      expect(output.to_html.strip).to be_empty
    end

    it "renders a pill without a remove button when remove_url is missing" do
      render_inline(described_class.new(filters: [ { category: "Tag", value: "Acquisitions" } ]))

      expect(page).to have_css("span.text-bg-primary", text: "Tag: Acquisitions")
      expect(page).to have_no_css("a[data-turbo-method='delete']")
    end

    it "omits the clear-all link when no url is given" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("span.text-bg-primary", text: "Keyword: investors")
      expect(page).to have_no_css("a[aria-label='Clear all filters']")
    end
  end
end
