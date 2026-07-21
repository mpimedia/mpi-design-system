# frozen_string_literal: true

require "spec_helper"

# Browser-level (real headless Chrome) proof that the derived foregrounds from
# issue #130 actually LAND — measured as computed style against the real compiled
# Bootstrap bundle.
#
# `render_inline` proves the ERB emits the right `class` and `style` attributes,
# and the render specs already cover that. What it cannot prove is the cascade:
#
#   * `.text-bg-primary` sets `color` with `!important` from a stylesheet, while
#     the pill also carries an inline `style` attribute. Inline styles normally
#     beat stylesheet rules, so "which wins" is a real question, not a given.
#   * The remove button is an `<a>` with inline `color: inherit`. An anchor does
#     NOT inherit color by default — Bootstrap styles `a { color: var(--bs-link-color) }`.
#     If `inherit` failed to win, the × would render link-blue on a blue pill: a
#     contrast regression *introduced* by the fix, invisible to every render spec.
#   * `.text-body-secondary` resolves through `--bs-secondary-color`, a variable
#     chain that only exists at runtime.
#
# So this spec reads `getComputedStyle` and recomputes the WCAG ratio from what the
# browser actually painted — following the computed-style precedent set by the
# `mpi--tag-input` spec (see `.claude/rules/testing.md`).
RSpec.describe "Derived foreground contrast", type: :feature, js: true do
  # getComputedStyle returns "rgb(r, g, b)" / "rgba(...)"; convert to a hex string
  # ColorContrast can consume.
  def hex_from_computed(value)
    channels = value.scan(/[\d.]+/).first(3).map { |c| c.to_f.round }
    raise "unparseable computed color: #{value.inspect}" unless channels.size == 3

    format("#%02X%02X%02X", *channels)
  end

  def computed(selector, property)
    raw = page.evaluate_script(
      "getComputedStyle(document.querySelector(#{selector.to_json})).#{property}"
    )
    raise "no element matched #{selector}" if raw.nil?

    hex_from_computed(raw)
  end

  def ratio_for(selector)
    foreground = computed(selector, "color")
    background = computed(selector, "backgroundColor")

    [ MpiDesignSystem::ColorContrast.ratio(foreground, background), foreground, background ]
  end

  before { visit "/contrast_demo" }

  describe "AvatarCircle" do
    MpiDesignSystem::Admin::AvatarCircle::Component::COLORS.each_with_index do |palette_color, index|
      it "paints palette index #{index} (#{palette_color}) at or above the 4.5:1 AA floor" do
        selector = "[data-avatar-index='#{index}'] .rounded-circle"

        expect(page).to have_css(selector)
        measured, foreground, background = ratio_for(selector)

        # The browser must have painted the palette background we expect — otherwise
        # a passing ratio could just mean the element rendered transparent.
        expect(background).to eq(palette_color.upcase)
        expect(measured).to be >= 4.5,
          "expected AA contrast for #{foreground} on #{background}, got #{measured.round(2)}:1"
      end
    end

    it "paints the placeholder above the AA floor" do
      measured, _foreground, background = ratio_for("[data-avatar-placeholder] .rounded-circle")

      expect(background).to eq("#6C757D")
      expect(measured).to be >= 4.5
    end

    it "paints dark initials on the accent color that was the worst failure at 2.63:1" do
      index = MpiDesignSystem::Admin::AvatarCircle::Component::COLORS.index("#4EA8DE")

      expect(computed("[data-avatar-index='#{index}'] .rounded-circle", "color")).to eq("#000000")
    end

    it "keeps white where white already passed, so nothing changed unnecessarily" do
      index = MpiDesignSystem::Admin::AvatarCircle::Component::COLORS.index("#2E75B6")

      expect(computed("[data-avatar-index='#{index}'] .rounded-circle", "color")).to eq("#FFFFFF")
    end
  end

  describe "AvatarStack overflow chip" do
    it "paints the +N chip above the AA floor" do
      measured, _foreground, background = ratio_for("#stack span[aria-hidden='true']")

      expect(background).to eq(MpiDesignSystem::Admin::AvatarStack::Component::OVERFLOW_COLOR)
      expect(measured).to be >= 4.5
    end
  end

  # The load-bearing part of this spec. Everything below is about whether the
  # cascade resolved, not whether the markup was emitted.
  %w[#active-filter-bar #filter-chip-bar].each do |section|
    describe "pill in #{section}" do
      let(:pill) { "#{section} .text-bg-primary" }

      it "paints the MPI primary background from the token, not a hardcoded literal" do
        _measured, _foreground, background = ratio_for(pill)

        expect(background).to eq("#2E75B6")
      end

      it "paints a pill foreground above the AA floor" do
        measured, foreground, background = ratio_for(pill)

        expect(measured).to be >= 4.5,
          "expected AA contrast for #{foreground} on #{background}, got #{measured.round(2)}:1"
      end

      # The regression this whole spec exists to catch.
      it "paints the remove button in the pill's own foreground, not Bootstrap's link color" do
        pill_foreground = computed(pill, "color")
        button_foreground = computed("#{pill} a", "color")

        expect(button_foreground).to eq(pill_foreground)
      end

      it "paints the remove button above the AA floor against the pill" do
        button_foreground = computed("#{pill} a", "color")
        pill_background = computed(pill, "backgroundColor")
        measured = MpiDesignSystem::ColorContrast.ratio(button_foreground, pill_background)

        expect(measured).to be >= 4.5,
          "expected AA contrast for #{button_foreground} on #{pill_background}, got #{measured.round(2)}:1"
      end

      # The retired `opacity: 0.8` composited white down to ~3.71:1. Full opacity
      # is what keeps the measured ratio equal to the declared one.
      it "paints the remove button at full opacity" do
        opacity = page.evaluate_script(
          "getComputedStyle(document.querySelector(#{"#{pill} a".to_json})).opacity"
        )

        expect(opacity.to_f).to eq(1.0)
      end
    end
  end

  describe "muted text" do
    it "paints the ActiveFilterBar label above the AA floor against the bar" do
      foreground = computed("#active-filter-bar .text-body-secondary", "color")
      background = computed("#active-filter-bar [role='toolbar']", "backgroundColor")

      expect(background).to eq("#F5F7FA")
      expect(MpiDesignSystem::ColorContrast.ratio(foreground, background)).to be >= 4.5
    end

    it "paints the retired #6C757D nowhere in the bar" do
      expect(computed("#active-filter-bar .text-body-secondary", "color")).not_to eq("#6C757D")
    end

    it "paints the FilterChipBar labels above the AA floor against the page" do
      foreground = computed("#filter-chip-bar .text-body-secondary", "color")
      background = page.evaluate_script("getComputedStyle(document.body).backgroundColor")
      background = background.include?("rgba(0, 0, 0, 0)") ? "#FFFFFF" : hex_from_computed(background)

      expect(MpiDesignSystem::ColorContrast.ratio(foreground, background)).to be >= 4.5
    end
  end
end
