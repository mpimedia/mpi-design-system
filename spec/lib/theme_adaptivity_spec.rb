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
      "a non-Bootstrap var() with a hex fallback" => "background-color: var(--mds-avatar-0, #64748B)"
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

  it "reports every offence in a style, not merely the first" do
    expect(offences("color: #fff; opacity: 0.5; padding: 0").size).to eq(2)
  end

  # A known, deliberate limitation rather than a defect: the `var(--mds-*, <hex>)` pattern
  # #169 introduced for AvatarCircle is rejected here. No component this guard is applied
  # to uses it, and for a TAG surface a frozen fallback really would be wrong — but anyone
  # reusing this guard for the avatar palette must widen the allowlist first.
  it "rejects the #169 avatar token pattern, which is out of scope for tag surfaces" do
    expect(offences("background-color: var(--mds-avatar-3, #4EA8DE)")).not_to be_empty
  end
end
