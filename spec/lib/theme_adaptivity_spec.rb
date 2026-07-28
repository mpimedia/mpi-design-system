# frozen_string_literal: true

require "spec_helper"

# The guard in `spec/support/theme_adaptivity.rb` is itself a check, and an untested check
# is the shape `.claude/rules/testing.md` warns about hardest — one that cannot fail. Nine
# component specs lean on it, so a hole here is a hole in all of them at once.
#
# Every rejection case below corresponds to a real defect this repo has shipped:
# #130's `opacity`, #150's `outline`, #151's guard that rejected colour VALUES but not
# colour PROPERTIES (so `border: 1px solid red` and `border: none` sailed through).
RSpec.describe ThemeAdaptivity do
  def offences(style)
    described_class.frozen_colour_offences(style)
  end

  describe "styles it must ALLOW" do
    {
      "pure geometry" => "padding: 2px 8px; font-size: 11px; font-weight: 500",
      "currentColor, which the in-chip dot depends on" => "background-color: currentColor",
      "the documented geometry exceptions" => "border-radius: 50%; --bs-border-width: 2px",
      "an adaptive Bootstrap token" => "color: var(--bs-body-color)",
      "inherit" => "color: inherit",
      "transparent" => "background: transparent",
      "an empty style" => ""
    }.each do |label, style|
      it "allows #{label}" do
        expect(offences(style)).to be_empty
      end
    end
  end

  describe "styles it must REJECT" do
    {
      "a hex foreground" => "color: #E8733A",
      "a hex background" => "background-color: #FEF3EC",
      "an rgb() value" => "background: rgb(1, 2, 3)",
      "an hsl() value" => "background: hsl(1, 2%, 3%)",
      # The #151 hole: a guard scanning only for hex/rgb/hsl VALUES lets these through.
      "a NAMED colour on a border" => "border: 1px solid red",
      "border: none, which overrides a utility border" => "border: none",
      "a named colour in a box-shadow" => "box-shadow: 0 0 2px black",
      "an svg fill" => "fill: red",
      # #130 / #150: a declared pair can be AA-clean and still fail once faded or outlined.
      "opacity" => "opacity: 0.6",
      "an outline colour" => "outline: 1px solid #64748B",
      # Caught by the value scan rather than the property list, which is why both exist.
      "a colour in a property the list does not name" => "caret-color: #fff",
      "a hex inside a shorthand function" => "background: linear-gradient(#fff, #000)",
      # A non-Bootstrap custom property may not resolve at all, so its hex fallback is
      # what actually paints — a frozen colour by another name.
      "a non-Bootstrap var() with a hex fallback" => "background-color: var(--mds-avatar-0, #64748B)",
      # Codex PR review, P1-3. The prefix check alone accepted this, and the literal scan
      # was an `elsif`, so the frozen fallback was never examined. An absent token makes
      # that fallback the colour that actually paints (the #155 un-imported-partial case).
      "a var(--bs-*) whose FALLBACK is a frozen hex" => "background-color: var(--bs-body-bg, #fff)",
      "a var(--bs-*) whose fallback is a named colour" => "color: var(--bs-body-color, black)",
      # Same review: a named colour on a property the list does not name.
      "a named colour on an unlisted property" => "caret-color: red",
      "a named colour in a text-shadow" => "text-shadow: 0 0 2px black",
      # Modern colour spaces a narrow rgb()/hsl() regex misses entirely.
      "an oklch() value" => "caret-color: oklch(0.7 0.1 200)",
      "a color() value" => "caret-color: color(display-p3 1 0 0)",
      "a color-mix() value" => "background: color-mix(in srgb, red, blue)"
    }.each do |label, style|
      it "rejects #{label}" do
        expect(offences(style)).not_to be_empty
      end
    end
  end

  it "names the offending declaration and the reason, so a failure is actionable" do
    message = offences("padding: 0; border: 1px solid red").first

    expect(message).to include("border: 1px solid red")
    expect(message).to include("does not re-resolve per colour mode")
  end

  it "reports every offending declaration in a style, not merely the first" do
    reported = offences("color: #fff; opacity: 0.5; padding: 0")

    # One declaration can trip both scans (a hex on a paint property trips the property
    # rule AND the literal rule), so assert on which DECLARATIONS were named.
    expect(reported.select { |o| o.include?("color: #fff") }).not_to be_empty
    expect(reported.select { |o| o.include?("opacity: 0.5") }).not_to be_empty
    expect(reported.select { |o| o.include?("padding: 0") }).to be_empty
  end

  # The property scan and the literal scan must both run on the same declaration; when
  # they were an if/elsif, a value the property rule accepted skipped the literal scan.
  it "reports a nested literal even when the property rule accepts the value shape" do
    expect(offences("background-color: var(--bs-body-bg, #fff)")).not_to be_empty
  end

  it "still allows a var(--bs-*) whose fallback is itself adaptive" do
    expect(offences("color: var(--bs-body-color, currentColor)")).to be_empty
  end

  # A known, deliberate limitation rather than a defect: the `var(--mds-*, <hex>)` pattern
  # #169 introduced for AvatarCircle is rejected here. No component this guard is applied
  # to uses it, and for a TAG surface a frozen fallback really would be wrong — but anyone
  # reusing this guard for the avatar palette must widen the allowlist first.
  it "rejects the #169 avatar token pattern, which is out of scope for tag surfaces" do
    expect(offences("background-color: var(--mds-avatar-3, #4EA8DE)")).not_to be_empty
  end
end
