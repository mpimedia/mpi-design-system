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
      "a color-mix() value" => "background: color-mix(in srgb, red, blue)",
      # Codex round 2, P1. A custom property can hold anything and nothing downstream
      # constrains it. `papayawhip` is deliberately absent from NAMED_COLOURS and is not a
      # literal, so ONLY the custom-property rule can reject this — which is what makes
      # the example isolating. With a value the blacklist knows (e.g. `red`), deleting
      # that rule would leave the test green.
      "a colour in a custom property" => "--tag-fill: papayawhip",
      "an unparseable var() fallback (must fail closed)" => "color: var(--bs-body-color, chartreuse) !important"
    }.each do |label, style|
      it "rejects #{label}" do
        expect(offences(style)).not_to be_empty
      end
    end
  end

  # Codex round 2, P1: the earlier examples for these two fixes were NOT isolating. A
  # frozen fallback was caught by the literal scan too, so removing the recursion left
  # them green; and the "independent scans" example was caught by the property rule too,
  # so restoring the `elsif` left IT green. Either fix could be deleted individually
  # without a red test — which is the mutation requirement, not merely a passing suite.
  # These target each mechanism directly.
  describe "the var() fallback recursion, in isolation" do
    it "accepts a bare adaptive token" do
      expect(described_class.adaptive_value?("var(--bs-body-color)")).to be true
    end

    it "rejects a token whose fallback is frozen" do
      expect(described_class.adaptive_value?("var(--bs-body-color, #fff)")).to be false
    end

    it "accepts a token whose fallback is itself adaptive" do
      expect(described_class.adaptive_value?("var(--bs-body-color, currentColor)")).to be true
    end

    it "recurses through a nested fallback" do
      expect(described_class.adaptive_value?("var(--bs-a, var(--bs-b, #fff))")).to be false
      expect(described_class.adaptive_value?("var(--bs-a, var(--bs-b, inherit))")).to be true
    end

    # Fail CLOSED: "did not parse" must not be answered the same way as "no fallback".
    # This is what let `var(--bs-body-color, chartreuse) !important` through.
    it "rejects a token it cannot parse confidently" do
      expect(described_class.adaptive_value?("var(--bs-body-color, chartreuse) !important")).to be false
      expect(described_class.adaptive_value?("var(--bs-body-color,)")).to be false
    end
  end

  describe "the two scans, in isolation" do
    # A value the PROPERTY rule accepts must still be examined by the literal scan.
    # Under the old `elsif` this returned zero offences.
    it "runs the literal scan even when the property rule accepts the value" do
      offending = offences("background-color: var(--bs-tertiary-bg, #F5F7FA)")

      expect(offending.any? { |o| o.include?("colour literal") }).to be true
    end

    # And a value the literal scan cannot see must still be caught by the property rule.
    it "runs the property rule even when the value carries no literal" do
      offending = offences("background-color: linear-gradient(in oklab, currentColor, currentColor)")

      expect(offending.any? { |o| o.include?("re-resolve per colour mode") }).to be true
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

  # ---------------------------------------------------------------------------------
  # AXIS 1 — the five paint properties added by #183 (ISS#174 §1)
  # ---------------------------------------------------------------------------------
  #
  # Each fixture is chosen so ONLY the property rule can reject it: its value is neither
  # a colour literal (no hex, no listed colour function) nor a listed named colour
  # (`papayawhip` is deliberately absent from NAMED_COLOURS — the #168 round-2 lesson
  # that `chartreuse` would have been caught by the blacklist too, leaving the example
  # green with the rule deleted). Asserting `size == 1` is what proves the isolation:
  # if a second scan also fired, deleting the property entry would leave the example
  # green. Mutation-proven: deleting one entry from COLOUR_PROPERTIES reddens exactly
  # its own example and no other.
  describe "the paint properties added in #183, each in isolation" do
    {
      "filter" => "filter: invert(1)",
      "backdrop-filter" => "backdrop-filter: blur(4px)",
      "background-blend-mode" => "background-blend-mode: multiply",
      "text-emphasis-color" => "text-emphasis-color: papayawhip",
      "-webkit-text-fill-color" => "-webkit-text-fill-color: papayawhip"
    }.each do |property, style|
      it "rejects `#{property}` by the property rule alone" do
        offending = offences(style)

        expect(offending.size).to eq(1)
        expect(offending.first).to include("does not re-resolve per colour mode")
        expect(offending.first).to include(property)
      end
    end

    it "still allows each of them when the value re-resolves per colour mode" do
      expect(offences("filter: inherit")).to be_empty
      expect(offences("backdrop-filter: inherit")).to be_empty
      expect(offences("background-blend-mode: inherit")).to be_empty
      expect(offences("text-emphasis-color: currentColor")).to be_empty
      expect(offences("-webkit-text-fill-color: var(--bs-body-color)")).to be_empty
    end
  end

  # ---------------------------------------------------------------------------------
  # AXIS 2 — utility classes
  # ---------------------------------------------------------------------------------
  describe "the utility-class axis (#183)" do
    def markup(*classes)
      %(<div class="card shadow-sm"><span class="#{classes.join(' ')}">Label</span></div>)
    end

    def class_offences(*classes, allowing: [])
      described_class.fixed_hue_utility_offences(markup(*classes), allowing: allowing)
    end

    # Each of these shipped GREEN in thirteen of the fourteen guarded specs before #183,
    # because the shared guard had no class axis at all and the 12-entry
    # `bg-white`/`text-dark` denylist the rest carried names none of them.
    describe "classes it must REJECT" do
      {
        "a fixed-hue button" => "btn-primary",
        "a fixed-hue link" => "link-danger",
        "a fixed-hue alert" => "alert-danger",
        "a fixed-hue badge modifier" => "badge-primary",
        "a fixed-hue list-group item" => "list-group-item-warning",
        # `text-bg-*` derives an accessible foreground but the BACKGROUND is
        # `--bs-#{'{sem}'}-rgb`, which Bootstrap does not shift per colour mode.
        "a text-bg pair" => "text-bg-primary",
        # A denylist of bg-white/bg-light/… misses every base semantic utility.
        "a bare semantic foreground" => "text-primary",
        "a bare semantic background" => "bg-success",
        "a bare semantic border" => "border-primary",
        "a fixed-scheme background" => "bg-white",
        "a fixed-scheme light background" => "bg-light",
        "a fixed-scheme dark foreground" => "text-dark",
        # Prefix-matching but in no tier: a new Bootstrap utility must be classified
        # deliberately rather than inherited silently.
        "an unclassified text-decoration utility" => "text-decoration-line-through"
      }.each do |label, klass|
        it "rejects #{label} (#{klass})" do
          expect(class_offences(klass)).to eq([ klass ])
        end
      end
    end

    describe "classes it must ALLOW" do
      it "allows the adaptive body families" do
        expect(class_offences("bg-body", "bg-body-secondary", "bg-body-tertiary")).to be_empty
        expect(class_offences("text-body", "text-body-secondary", "text-body-tertiary")).to be_empty
      end

      # Codex P1 on the first plan: tier 2 must mean ADAPTIVE, not "on MPI's palette".
      # `info`, `light` and `dark` all have genuinely adaptive -subtle/-emphasis forms in
      # Bootstrap 5.3, so a matcher named `fixed_hue_utility_offences` must not report
      # them. (`$mpi-info: $mpi-primary` makes `bg-info-subtle` render the same blue as
      # `bg-primary-subtle` — a palette fact, not an adaptivity one.)
      described_class::ADAPTIVE_SEMANTICS.each do |semantic|
        it "allows the adaptive #{semantic} family" do
          expect(
            class_offences("bg-#{semantic}-subtle", "text-#{semantic}-emphasis", "border-#{semantic}-subtle")
          ).to be_empty
        end
      end

      it "allows the tier-1 neutrals, which are classified by prefix but paint nothing" do
        expect(
          class_offences("bg-transparent", "text-reset", "border", "border-0", "border-bottom",
                         "text-decoration-none", "text-truncate", "text-uppercase", "text-center")
        ).to be_empty
      end

      it "ignores classes the colour classifier does not match at all" do
        expect(class_offences("rounded-pill", "d-inline-flex", "fw-semibold", "btn", "badge")).to be_empty
      end
    end

    it "reports every offending class, deduped and sorted, and only class names" do
      html = %(<span class="btn-primary bg-white">a</span><em class="bg-white text-primary">b</em>)

      expect(described_class.fixed_hue_utility_offences(html)).to eq(%w[bg-white btn-primary text-primary])
    end

    # The single most important property of `allowing:`. An implementation that returned
    # `[]` whenever anything was allowed — or that allowed by prefix — would disable the
    # matcher for every migrated spec at once and they would all go vacuously green.
    it "scopes `allowing:` to the named class, and is not a kill switch" do
      expect(class_offences("bg-danger")).to eq([ "bg-danger" ])
      expect(class_offences("bg-danger", allowing: [ "bg-danger" ])).to be_empty
      expect(class_offences("bg-danger", "bg-success", allowing: [ "bg-danger" ])).to eq([ "bg-success" ])
    end

    it "matches `allowing:` on the whole class name, not a prefix" do
      expect(class_offences("bg-danger-something", allowing: [ "bg-danger" ])).to eq([ "bg-danger-something" ])
    end

    it "accepts an already-allowlisted class in `allowing:` as a harmless no-op" do
      expect(class_offences("bg-body", "bg-white", allowing: [ "bg-body" ])).to eq([ "bg-white" ])
    end

    it "takes a Nokogiri fragment as well as an HTML string" do
      fragment = Nokogiri::HTML::DocumentFragment.parse(markup("btn-primary"))

      expect(described_class.fixed_hue_utility_offences(fragment)).to eq([ "btn-primary" ])
    end

    # `Node#css` / `NodeSet#css` search DESCENDANTS only. A guard scoped with
    # `fragment.css("nav")` would therefore never see the `nav`'s OWN class — so a
    # `bg-white` on the scoping element itself would ship green, in the one guard whose
    # whole job is to catch it. The roots of a scoped NodeSet are read too.
    it "reads the classes of the scoping element itself, not only its descendants" do
      fragment = Nokogiri::HTML::DocumentFragment.parse(
        %(<nav class="bg-white"><span class="text-body">x</span></nav>)
      )

      expect(described_class.fixed_hue_utility_offences(fragment.css("nav"))).to eq([ "bg-white" ])
      expect(described_class.applied_utility_classes(fragment.css("nav"))).to contain_exactly("bg-white", "text-body")
    end

    # Widening the shared default silently weakens all fourteen guarded specs at once, so
    # its contents are pinned here: an addition has to be made on purpose and shows up in
    # review as a change to this example.
    it "pins the shared allowlist so widening it is a deliberate, reviewable act" do
      expect(described_class::NEUTRAL_UTILITIES).to eq(%w[
        bg-transparent text-reset
        border border-0 border-1 border-2 border-3 border-4 border-5
        border-top border-end border-bottom border-start
        border-top-0 border-end-0 border-bottom-0 border-start-0
        text-start text-end text-center text-truncate text-nowrap text-wrap text-break
        text-decoration-none text-decoration-underline
        text-uppercase text-lowercase text-capitalize
        btn-sm btn-lg btn-close
      ])
      expect(described_class::ADAPTIVE_SEMANTICS).to eq(%w[primary secondary success warning danger info light dark])
      expect(described_class::ADAPTIVE_UTILITIES).to eq(%w[
        bg-body bg-body-secondary bg-body-tertiary
        text-body text-body-secondary text-body-tertiary
      ] + %w[primary secondary success warning danger info light dark].flat_map do |s|
        [ "bg-#{s}-subtle", "text-#{s}-emphasis", "border-#{s}-subtle" ]
      end)
      expect(described_class::ADAPTIVE_UTILITY_ALLOWLIST)
        .to eq(described_class::NEUTRAL_UTILITIES + described_class::ADAPTIVE_UTILITIES)
    end
  end

  describe "the be_free_of_fixed_hue_utilities matcher" do
    it "passes on adaptive markup and fails on a fixed hue" do
      expect(%(<span class="bg-body text-body-secondary">x</span>)).to be_free_of_fixed_hue_utilities
      expect(%(<span class="bg-white">x</span>)).not_to be_free_of_fixed_hue_utilities
    end

    it "accepts `allowing` as varargs or as an array, identically" do
      html = %(<span class="bg-danger bg-success">x</span>)

      expect(html).to be_free_of_fixed_hue_utilities.allowing("bg-danger", "bg-success")
      expect(html).to be_free_of_fixed_hue_utilities.allowing(%w[bg-danger bg-success])
      expect(html).not_to be_free_of_fixed_hue_utilities.allowing("bg-danger")
    end

    # Codex asked for this explicitly. `RSpec::Matchers.define` builds a fresh matcher
    # instance per `expect(...)`, so one call's `allowing` cannot leak into the next —
    # pinned rather than assumed.
    it "does not leak `allowing` across invocations" do
      html = %(<span class="bg-danger bg-success">x</span>)

      expect(html).to be_free_of_fixed_hue_utilities.allowing("bg-danger", "bg-success")
      expect(html).not_to be_free_of_fixed_hue_utilities.allowing("bg-danger")
      expect(html).not_to be_free_of_fixed_hue_utilities
    end

    it "names the offending classes in its failure message" do
      matcher = be_free_of_fixed_hue_utilities.allowing("bg-danger")
      matcher.matches?(%(<span class="bg-danger btn-primary">x</span>))

      expect(matcher.failure_message).to include("btn-primary")
      expect(matcher.failure_message).to include("Explicitly allowed here: bg-danger")
      expect(matcher.failure_message).not_to include("bg-danger btn-primary")
    end

    it "explains a negated failure by listing what it classified" do
      matcher = be_free_of_fixed_hue_utilities
      matcher.matches?(%(<span class="bg-body text-body">x</span>))

      expect(matcher.failure_message_when_negated).to include("bg-body, text-body")
      expect(matcher.failure_message_when_negated).to include("allowing: (none)")
    end
  end

  # ---------------------------------------------------------------------------------
  # AXIS 3 — markup literals
  # ---------------------------------------------------------------------------------
  #
  # This axis exists so the whole-markup hex sweeps DataTable, FilterChipBar, Pagination
  # and ActiveFilterBar each hand-rolled before #183 survive the migration. It reads the
  # SERIALISED fragment, so it sees attributes and text — an inline SVG `fill="#fff"` is
  # invisible to the declaration scan, which only ever reads `style`.
  describe "the markup-literal axis (#183)" do
    it "catches a hex in an ATTRIBUTE, which a style-declaration scan never reads" do
      expect(described_class.markup_colour_literals(%(<svg><path fill="#fff"/></svg>))).to eq([ "#fff" ])
    end

    {
      "a 3-digit hex" => %(<i data-x="#abc"></i>),
      "a 6-digit hex" => %(<i style="color: #2E75B6"></i>),
      "an 8-digit hex with alpha" => %(<i data-x="#2E75B6CC"></i>),
      "an rgb() function" => %(<i style="color: rgb(1,2,3)"></i>),
      "an rgba() function" => %(<i style="color: rgba(1,2,3,.5)"></i>),
      "an hsl() function" => %(<i style="color: hsl(1,2%,3%)"></i>),
      "a literal in a TEXT node" => %(<code>background: #FF0000</code>)
    }.each do |label, html|
      it "rejects #{label}" do
        expect(described_class.markup_colour_literals(html)).not_to be_empty
      end
    end

    it "passes clean, utility-only markup" do
      expect(described_class.markup_colour_literals(%(<span class="bg-body">Sony Pictures</span>))).to be_empty
    end

    # A four-digit numeric character reference (`&#8212;`, the em dash) is hex-shaped
    # behind its `#`, so a pattern without the `(?<!&)` lookbehind reads it as a colour
    # literal. Nokogiri happens to serialise UTF-8 text raw, so no current fixture
    # produces one — this pins the PATTERN's contract rather than claiming a live case,
    # and the positive half stops it passing on a pattern that matches nothing.
    # Mutation-proven: deleting `(?<!&)` reddens the first assertion only.
    it "does not mistake a numeric character reference for a hex literal" do
      expect("Festival &#8212; Director").not_to match(described_class::MARKUP_COLOUR_LITERAL)
      expect("Festival #8212 Director").to match(described_class::MARKUP_COLOUR_LITERAL)
    end

    it "reports what it found in its failure message" do
      matcher = be_free_of_colour_literals
      matcher.matches?(%(<svg><path fill="#fff"/></svg>))

      expect(matcher.failure_message).to include("#fff")
    end

    it "backs a matcher that reads both a fragment and a raw HTML string" do
      expect(%(<span class="bg-body">clean</span>)).to be_free_of_colour_literals
      expect(Nokogiri::HTML::DocumentFragment.parse(%(<i style="color: #fff"></i>)))
        .not_to be_free_of_colour_literals
    end
  end
end
