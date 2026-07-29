# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::TagChip::Component, type: :component do
  # The chip's complete surviving inline style. Pinned by EXACT equality rather than
  # `[style*=…]` fragments: a substring pin polices only the declarations it names, so
  # every unnamed survivor stays deletable-green (#152). Any dropped, added or reordered
  # declaration reddens this, which is the intent — a deliberate geometry change updates
  # the constant on purpose.
  let(:chip_style_md) { "font-size: 13px; padding: 0.25em 0.75em; line-height: 1.4" }
  let(:chip_style_sm) { "font-size: 12px; padding: 0.25em 0.75em; line-height: 1.4" }
  let(:dot_style) { "width: 8px; height: 8px; border-radius: 50%; background-color: currentColor; flex-shrink: 0" }
  let(:remove_style) { "padding: 0; font-size: inherit; line-height: 1; cursor: pointer" }

  it "renders the label inside a pill carrying its group's semantic pair" do
    render_inline(described_class.new(label: "Distribution", group: :distribution))

    expect(page).to have_css(
      "span.rounded-pill.bg-danger-subtle.text-danger-emphasis", text: "Distribution"
    )
  end

  # Plumbing: every group reaches the utilities its mapping specifies. This does NOT
  # prove the mapping itself — both sides read the same constant, so a remap would move
  # them together and stay green. The exact-mapping example below is what pins that.
  described_class::GROUP_VARIANTS.each do |group, variant|
    it "renders the #{group} chip as the #{variant} subtle/emphasis pair" do
      render_inline(described_class.new(label: group.to_s, group: group))

      expect(page).to have_css("span.bg-#{variant}-subtle.text-#{variant}-emphasis", text: group.to_s)
    end
  end

  describe "the decorative dot" do
    # Child combinator, not a descendant selector: `span.bg-danger-subtle span[…]` would
    # also pass if the semantic class landed on some ancestor wrapper rather than the
    # chip itself — the exact regression this asserts against (#152).
    it "nests directly inside the chip so it inherits the chip's foreground" do
      render_inline(described_class.new(label: "Distribution", group: :distribution))

      expect(page).to have_css(
        "span.bg-danger-subtle.text-danger-emphasis > span[aria-hidden='true'][style='#{dot_style}']"
      )
    end

    # currentColor is load-bearing, not incidental. A solid `bg-#{variant}` fill inside a
    # `-subtle` chip measures 2.67:1 (success) / 2.62:1 (warning) — under the 3:1 floor
    # `.claude/rules/frontend.md` sets for a decorative semantic dot. Inheriting the
    # `-emphasis` foreground instead measures 9.43:1 / 9.34:1.
    it "paints currentColor rather than a solid semantic fill" do
      render_inline(described_class.new(label: "Outreach", group: :outreach))

      expect(page).to have_css("span[aria-hidden='true'][style*='background-color: currentColor']")
      expect(page).not_to have_css("span[aria-hidden='true'][class*='bg-']")
    end
  end

  describe "the remove control" do
    it "renders a button that pins no colour and no opacity of its own" do
      render_inline(described_class.new(label: "MIPCOM 2025", group: :distribution, removable: true))

      # Positive pin FIRST — an unpaired `not_to` would also pass if nothing rendered.
      expect(page).to have_css(
        "button.text-reset.bg-transparent.border-0[aria-label='Remove MIPCOM 2025'][style='#{remove_style}']"
      )
      expect(page).to have_css("i.bi.bi-x-lg")
      # The retired `opacity: 0.6` faded an already-sub-AA foreground further (#130).
      expect(page).not_to have_css("button[style*='opacity']")
      expect(page).not_to have_css("button[style*='color']")
    end

    it "renders a turbo link with the same treatment when remove_url is given" do
      render_inline(described_class.new(label: "MIPCOM 2025", group: :distribution, removable: true, remove_url: "/tags/1"))

      expect(page).to have_css(
        "a.text-reset.bg-transparent.border-0[href='/tags/1'][aria-label='Remove MIPCOM 2025'][style='#{remove_style}']"
      )
      expect(page).to have_css("a[data-turbo-method='delete']")
      expect(page).not_to have_css("a[style*='opacity']")
    end

    it "does not show a remove control by default" do
      render_inline(described_class.new(label: "Press/Festival", group: :press_festival))

      expect(page).to have_css("span.rounded-pill", text: "Press/Festival")
      expect(page).not_to have_css("button")
      expect(page).not_to have_css("a")
    end
  end

  describe "sizes" do
    it "renders the default size with its complete geometry" do
      render_inline(described_class.new(label: "Test", group: :internal))

      expect(page).to have_css("span.rounded-pill[style='#{chip_style_md}']", text: "Test")
    end

    it "renders the small size with its complete geometry" do
      render_inline(described_class.new(label: "Test", group: :internal, size: :sm))

      expect(page).to have_css("span.rounded-pill[style='#{chip_style_sm}']", text: "Test")
    end

    it "falls back to the default size for an unknown size" do
      render_inline(described_class.new(label: "Test", group: :internal, size: :enormous))

      expect(page).to have_css("span.rounded-pill[style='#{chip_style_md}']", text: "Test")
    end
  end

  describe "edge cases" do
    # :internal maps to :secondary, so this also proves the initializer's group
    # coercion still runs after the conversion.
    it "coerces an unknown group to internal" do
      render_inline(described_class.new(label: "Mystery", group: :not_a_group))

      expect(page).to have_css("span.bg-secondary-subtle.text-secondary-emphasis", text: "Mystery")
    end

    it "renders an empty label without raising" do
      render_inline(described_class.new(label: "", group: :finance))

      expect(page).to have_css("span.rounded-pill.bg-warning-subtle.text-warning-emphasis")
    end
  end

  # #168's conversion guard. `.claude/rules/testing.md` requires this be watched RED
  # against a real mutation — reintroducing `color: #{'#'}E8733A` into `chip_styles`
  # reddens it, as does `opacity: 0.6` on the remove button.
  describe "theme adaptivity (#168)" do
    described_class::GROUP_VARIANTS.each_key do |group|
      it "leaves no frozen-colour declaration on the #{group} chip, dot or remove button" do
        render_inline(described_class.new(label: group.to_s, group: group, removable: true))

        expect(page).to have_css("span.rounded-pill", text: group.to_s)
        inline_styles("span, button, a").each do |style|
          expect(style).to be_free_of_frozen_colour
        end
      end
    end

    it "emits no hex literal anywhere in the rendered chip" do
      render_inline(described_class.new(label: "Distribution", group: :distribution, removable: true))

      expect(page).to have_css("span.bg-danger-subtle", text: "Distribution")
      # Widened by #183 from a 6-digit-hex regex to the shared markup scan: 3/4/8-digit
      # hex, rgb()/rgba() and hsl()/hsla() are covered too, in attributes as well as
      # `style` — an inline SVG `fill="#fff"` was invisible to the old pattern.
      expect(rendered_fragment).to be_free_of_colour_literals
    end

    # #183. The chip's colour is carried entirely by CLASSES, so a declaration scan is
    # blind to the regression that matters most here: `bg-danger-subtle` silently
    # becoming `bg-danger` (fixed hue), or the remove control's neutral reset becoming a
    # `btn-danger`. Looped over every GROUP_VARIANTS key rather than the five distinct
    # hues, because `press_festival`/`production`/`vendors` share `primary` and a
    # per-hue loop leaves two of the seven keys unproven.
    described_class::GROUP_VARIANTS.each_key do |group|
      it "applies only theme-adaptive colour utilities on the #{group} chip" do
        render_inline(described_class.new(label: group.to_s, group: group, removable: true))
        fragment = rendered_fragment

        variant = described_class::GROUP_VARIANTS.fetch(group)
        applied = ThemeAdaptivity.applied_utility_classes(fragment)
        expect(applied).to include("bg-#{variant}-subtle", "text-#{variant}-emphasis", "text-reset")

        expect(fragment).to be_free_of_fixed_hue_utilities
      end
    end
  end

  # GROUP_VARIANTS is the shared tag-group -> Bootstrap-semantic mapping. Since #168
  # every engine renderer of tag-group colour reads it, so a defect here is systemic.
  describe "GROUP_VARIANTS mapping" do
    it "maps every GROUPS key to a semantic variant" do
      expect(described_class::GROUP_VARIANTS.keys).to match_array(described_class::GROUPS.keys)
    end

    # The consumer loops throughout the suite read this same constant, so a semantic
    # REMAP (e.g. distribution: :danger -> :success) would render and assert the new
    # value identically and ship green everywhere. Pinning the exact mapping is the only
    # assertion in the suite that catches it — it must not be replaced by a loop.
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
  end

  # GROUPS is retained post-#168 as the canonical key set and the brand-hex reference,
  # but nothing may render from it. #167 pinned the opposite ("leaves TagChip's own
  # rendering on the frozen hex palette") so that converting TagChip could not happen by
  # accident; #168 IS that deliberate change, so the guard is inverted rather than
  # deleted — it now holds the chip to the semantics.
  describe "GROUPS (retained, deprecated for rendering)" do
    it "still defines the canonical group key set" do
      expect(described_class::GROUPS.keys).to match_array(
        %i[production distribution finance press_festival internal vendors outreach]
      )
    end

    it "no longer supplies any rendered colour" do
      described_class::GROUPS.each do |group, pair|
        render_inline(described_class.new(label: group.to_s, group: group))

        expect(page).to have_css("span.rounded-pill", text: group.to_s)
        expect(page.native.to_html).not_to include(pair[:color])
        expect(page.native.to_html).not_to include(pair[:bg])
      end
    end
  end
end
