# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::ColorContrast do
  # Every ratio below is an INDEPENDENTLY published value, never one produced by
  # this module. That is the point: a spec that checked `ratio` using `ratio`
  # would agree with itself no matter how wrong the luminance math was. See
  # `bin/verify-contrast-oracle` for the other half of the anchor — Bootstrap's
  # own compiled `color-contrast()`. (#130)
  describe ".ratio" do
    it "returns 21:1 for black on white, the WCAG maximum" do
      expect(described_class.ratio("#000000", "#FFFFFF")).to be_within(0.001).of(21.0)
    end

    it "returns 1:1 for a color against itself, the WCAG minimum" do
      expect(described_class.ratio("#2E75B6", "#2E75B6")).to be_within(0.001).of(1.0)
    end

    it "is order-independent" do
      expect(described_class.ratio("#2E75B6", "#FFFFFF"))
        .to be_within(0.0001).of(described_class.ratio("#FFFFFF", "#2E75B6"))
    end

    # #767676 is the canonical lightest gray that clears AA on white, and #777777
    # the next step up that fails. A luminance implementation that got the sRGB
    # linearization wrong would not land on both sides of 4.5 correctly.
    it "matches the published ratio for the reference AA-boundary grays" do
      expect(described_class.ratio("#767676", "#FFFFFF")).to be_within(0.01).of(4.54)
      expect(described_class.ratio("#777777", "#FFFFFF")).to be_within(0.01).of(4.48)
    end

    it "matches the published ratio for a mid-tone and a AAA-grade gray" do
      expect(described_class.ratio("#595959", "#FFFFFF")).to be_within(0.01).of(7.00)
      expect(described_class.ratio("#0000FF", "#FFFFFF")).to be_within(0.01).of(8.59)
    end

    # Established in issue #128 via Bootstrap's compiled output, before this
    # module existed — so it cannot have been fitted to this implementation.
    it "reproduces the 3.33:1 failure issue #128 measured for white on $mpi-success" do
      expect(described_class.ratio("#22A06B", "#FFFFFF")).to be_within(0.01).of(3.33)
    end

    it "reproduces the 6.31:1 figure issue #128 measured for black on $mpi-success" do
      expect(described_class.ratio("#22A06B", "#000000")).to be_within(0.01).of(6.31)
    end
  end

  describe ".relative_luminance" do
    it "returns 0.0 for black and 1.0 for white" do
      expect(described_class.relative_luminance("#000000")).to be_within(0.0001).of(0.0)
      expect(described_class.relative_luminance("#FFFFFF")).to be_within(0.0001).of(1.0)
    end

    # The sRGB linearization is the step most likely to be silently wrong: a
    # naive implementation treating channels as already linear returns 0.5 here.
    it "applies the sRGB transfer curve rather than treating channels as linear" do
      expect(described_class.relative_luminance("#808080")).to be_within(0.001).of(0.2159)
    end

    it "weights green most heavily and blue least, per WCAG coefficients" do
      red = described_class.relative_luminance("#FF0000")
      green = described_class.relative_luminance("#00FF00")
      blue = described_class.relative_luminance("#0000FF")

      expect(green).to be > red
      expect(red).to be > blue
      expect(green).to be_within(0.0001).of(0.7152)
      expect(red).to be_within(0.0001).of(0.2126)
      expect(blue).to be_within(0.0001).of(0.0722)
    end
  end

  describe ".accessible_foreground" do
    it "returns dark text on a light background" do
      expect(described_class.accessible_foreground("#FFFFFF")).to eq("#000")
    end

    it "returns light text on a dark background" do
      expect(described_class.accessible_foreground("#000000")).to eq("#fff")
    end

    # Bootstrap tries the LIGHT foreground first and returns it as soon as it
    # clears the bar, rather than picking the higher-contrast option. #DC3545 is
    # the case that distinguishes the two rules: white is 4.53:1 (passes, so
    # Bootstrap keeps it) while black would score marginally higher at 4.64:1.
    it "prefers the light foreground when it clears the threshold, as Bootstrap does" do
      expect(described_class.accessible_foreground("#DC3545")).to eq("#fff")
      expect(described_class.ratio("#DC3545", "#000")).to be > described_class.ratio("#DC3545", "#fff")
    end

    it "uses a >= comparison, so a color exactly at the threshold keeps the light foreground" do
      # Contrived background whose white ratio is just above / just below 4.5.
      expect(described_class.accessible_foreground("#767676")).to eq("#fff")
      expect(described_class.accessible_foreground("#777777")).to eq("#000")
    end

    # At the crossover point where white and black are equally legible, both
    # score ~4.583:1 — above the AA floor. So for black/white candidates at
    # min_ratio 4.5 the fallback is unreachable and SOME foreground always
    # passes. This is what lets the AvatarCircle gate below be absolute rather
    # than best-effort, and it is why a palette can never be "unfixable" at AA.
    it "always finds a passing foreground at the AA floor, for any background" do
      worst = (0..255).step(3).map { |v| format("#%02x%02x%02x", v, v, v) }.map do |gray|
        [ described_class.ratio(gray, "#fff"), described_class.ratio(gray, "#000") ].max
      end.min

      expect(worst).to be >= 4.5
    end

    it "falls back to the highest-contrast candidate when neither clears the bar" do
      # No background fails BOTH at 4.5, so the fallback only engages at a
      # stricter threshold — e.g. AAA (7:1), where this mid-gray fails both.
      expect(described_class.ratio("#808080", "#fff")).to be < 7.0
      expect(described_class.ratio("#808080", "#000")).to be < 7.0
      expect(described_class.accessible_foreground("#808080", min_ratio: 7.0)).to eq("#000")
    end

    it "honours a custom min_ratio" do
      # White on #2E75B6 is 4.84:1 — enough for AA, so AA returns it outright.
      expect(described_class.accessible_foreground("#2E75B6")).to eq("#fff")
      # At AAA neither candidate clears 7:1, so the fallback picks the stronger
      # of the two, which is still white at 4.84:1 vs black's 4.34:1.
      expect(described_class.accessible_foreground("#2E75B6", min_ratio: 7.0)).to eq("#fff")
    end
  end

  describe ".accessible?" do
    it "is true at or above the AA floor and false below it" do
      expect(described_class.accessible?("#fff", "#2E75B6")).to be(true)
      expect(described_class.accessible?("#fff", "#22A06B")).to be(false)
    end

    it "honours a custom min_ratio" do
      expect(described_class.accessible?("#fff", "#22A06B", min_ratio: 3.0)).to be(true)
    end
  end

  describe "hex parsing" do
    it "accepts a leading hash or none" do
      expect(described_class.relative_luminance("2E75B6"))
        .to be_within(0.0001).of(described_class.relative_luminance("#2E75B6"))
    end

    it "accepts mixed case" do
      expect(described_class.relative_luminance("#2e75b6"))
        .to be_within(0.0001).of(described_class.relative_luminance("#2E75B6"))
    end

    it "expands 3-digit shorthand to its 6-digit equivalent" do
      expect(described_class.relative_luminance("#abc"))
        .to be_within(0.0001).of(described_class.relative_luminance("#aabbcc"))
    end

    it "tolerates surrounding whitespace" do
      expect(described_class.relative_luminance("  #2E75B6  "))
        .to be_within(0.0001).of(described_class.relative_luminance("#2E75B6"))
    end

    # Raises rather than defaulting: no single foreground is safe against an
    # UNKNOWN background, so a silent fallback would be the very defect this
    # module exists to prevent. All callers pass frozen palette constants.
    [ nil, "", "   ", "#12", "#12345", "#1234567", "rebeccapurple", "#GGGGGG", 42 ].each do |bad|
      it "raises ArgumentError for #{bad.inspect} rather than guessing a foreground" do
        expect { described_class.relative_luminance(bad) }.to raise_error(ArgumentError)
        expect { described_class.accessible_foreground(bad) }.to raise_error(ArgumentError)
      end
    end

    it "names the offending value in the error message" do
      expect { described_class.accessible_foreground("nope") }
        .to raise_error(ArgumentError, /nope/)
    end
  end

  # The frozen map. Every pair here was read off Bootstrap's compiled
  # `color-contrast()` output (see spec/fixtures/scss/avatar_contrast_oracle.scss),
  # NOT generated by this module. `bin/verify-contrast-oracle` re-checks the same
  # table against a fresh Bootstrap compile in CI, so if Bootstrap and this module
  # ever diverge, the build fails instead of quietly shipping.
  describe "frozen expectations for the AvatarCircle palette" do
    EXPECTED_FOREGROUNDS = {
      "#2E75B6" => "#fff",
      "#8B5CF6" => "#000",
      "#E8733A" => "#000",
      "#2DA67E" => "#000",
      "#D97706" => "#000",
      "#6366F1" => "#000",
      "#DC3545" => "#fff",
      "#4EA8DE" => "#000",
      "#22A06B" => "#000",
      "#64748B" => "#fff",
      "#6C757D" => "#fff"
    }.freeze

    it "covers exactly the shipped palette plus the placeholder, so a new color cannot land unreviewed" do
      shipped = MpiDesignSystem::Admin::AvatarCircle::Component::COLORS +
                [ MpiDesignSystem::Admin::AvatarCircle::Component::PLACEHOLDER_COLOR ]

      expect(shipped).to match_array(EXPECTED_FOREGROUNDS.keys)
    end

    EXPECTED_FOREGROUNDS.each do |background, foreground|
      it "derives #{foreground} on #{background}, matching Bootstrap's compiled output" do
        expect(described_class.accessible_foreground(background)).to eq(foreground)
      end

      it "clears the 4.5:1 AA floor for #{foreground} on #{background}" do
        expect(described_class.ratio(background, foreground)).to be >= 4.5
      end
    end

    it "fixes a real failure rather than restating the status quo" do
      failing = EXPECTED_FOREGROUNDS.keys.reject do |background|
        described_class.accessible?("#fff", background)
      end

      # The 7 colors that were shipping white text below the AA floor before #130.
      expect(failing).to contain_exactly(
        "#8B5CF6", "#E8733A", "#2DA67E", "#D97706", "#6366F1", "#4EA8DE", "#22A06B"
      )
      expect(failing.map { |background| EXPECTED_FOREGROUNDS[background] }).to all(eq("#000"))
    end
  end
end
