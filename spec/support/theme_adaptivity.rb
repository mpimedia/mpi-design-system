# frozen_string_literal: true

# THE canonical theme-adaptivity guard for the inline-style -> semantic-utility
# conversions (#149, #150, #151, #152, #168, #183). Before #183 fourteen component specs
# guarded theme adaptivity four different ways: three carried divergent hand-rolled copies
# of the declaration scan, one carried a class-level allowlist, five carried a weaker
# class-level denylist, and eight had no class-level check at all. This module is the
# single place all of that now lives.
#
# It exposes THREE independent axes, one matcher each. They overlap deliberately — a
# regression usually trips more than one — but each catches something the others cannot,
# so a spec that needs whole-component coverage uses all three:
#
#   1. DECLARATION — `be_free_of_frozen_colour`, over one element's surviving inline
#      `style` string. Sees `border: none`; blind to classes and to attributes.
#   2. UTILITY CLASS — `be_free_of_fixed_hue_utilities`, over a rendered fragment. Sees
#      `btn-primary` / `bg-white` / `text-bg-primary`; blind to inline style entirely.
#   3. MARKUP LITERAL — `be_free_of_colour_literals`, over a rendered fragment's
#      serialised HTML, ATTRIBUTES included. Sees an SVG `fill="#fff"`, which axis 1
#      never reads because it is not a `style` declaration.
#
# ---------------------------------------------------------------------------------
# Axis 1 — declaration
# ---------------------------------------------------------------------------------
# It answers one question about a converted element: does its SURVIVING inline style
# still make a colour decision?
#
# The shape matters. `.claude/rules/testing.md` records two ways an earlier version of
# this guard shipped green while broken:
#
#   * rejecting colour VALUES (hex/rgb/hsl) but not colour PROPERTIES, so
#     `border: 1px solid red` (a named colour) and `border: none` both passed;
#   * rejecting a blacklist of named colours, which can never be complete.
#
# The PROPERTY axis is the authoritative whitelist and is where the real strength lies:
# any property that can paint — including every un-excepted `--*` custom property — may
# hold only a value that re-resolves at runtime (`currentColor`, `transparent`,
# `inherit`, or a `var(--bs-*)` whose fallback is itself adaptive). Everything else
# fails, whether or not the value looks like a colour, and an unparseable `var()` fails
# CLOSED.
#
# The VALUE axis is a deliberate best-effort BACKSTOP, not a whitelist: it catches hex,
# colour functions and common named colours smuggled into a property the list does not
# know about. A named-colour blacklist can never be complete, and claiming otherwise
# would be the sort of prose-only assurance `.claude/rules/testing.md` warns about — so
# the honest statement is that a novel named colour on an unlisted property can still
# slip through. Widen COLOUR_PROPERTIES when that matters.
#
# ---------------------------------------------------------------------------------
# Axis 2 — utility class
# ---------------------------------------------------------------------------------
# TWO layers, and only the SECOND one is an allowlist. Describing the whole axis as "an
# allowlist" — as this file did before Codex's PR review of #183 — is the prose-only
# assurance `.claude/rules/testing.md` forbids, because it hides the first layer entirely:
#
#   LAYER 1 — the FAMILY CLASSIFIER (`COLOUR_UTILITY_PATTERN`). Blacklist-shaped and
#   necessarily incomplete: it enumerates the Bootstrap class families known to paint.
#   A class matching NO family is not examined at all — it passes silently, whatever it
#   does. That is the axis's real limit, and it is where #183's first review found a
#   live hole: `.table-primary`, `.table-dark`, `.focus-ring-primary`,
#   `.dropdown-menu-dark` and `.navbar-dark` are all colour-bearing and were all
#   unclassified, so `fixed_hue_utility_offences('<div class="table-primary">')` returned
#   `[]` — with DataTable and TableForIndex both rendering a `<table>`. Widening the
#   pattern is how that class of hole is closed; there is no way to make layer 1 complete,
#   so a new Bootstrap family must be ADDED here deliberately.
#
#   LAYER 2 — within a classified family, an ALLOWLIST. The `bg-white`/`text-dark`/…
#   denylist five pre-#183 specs carried (12 entries in three, 14 in the other two) missed
#   every base utility (`text-primary`, `bg-success`) and every non-`bg`/`text`/`border`
#   family — the hole ISS#183 exists to close. Only classes that genuinely re-resolve
#   under `data-bs-theme` (tier 2) or genuinely paint nothing (tier 1) are allowed;
#   anything else in a classified family is an offence unless a call site takes an
#   explicit, commented exception.
#
# Layer 2 fails CLOSED: an unnamed member of a classified family is rejected. The tiers
# name only members verified against COMPILED Bootstrap 5.3
# (`node_modules/bootstrap/dist/css/bootstrap.css`, both the `:root` and the
# `[data-bs-theme=dark]` blocks) — so a geometry-only member nobody has needed yet
# (`link-offset-2`, `link-underline-opacity-50`) rejects until someone adds it with that
# citation. Over-rejection costs one commented exception at a call site; under-rejection
# is a silent false green.
#
# A tier-3 exception — a class that is a DELIBERATE fixed hue — is preferably taken by
# removing the offending NODES (see the decorative-dot and selected-state patterns in the
# component specs) rather than by `allowing:`, because `allowing:` is class-scoped, not
# placement-scoped: `.allowing("bg-danger")` also passes a `bg-danger` on a text-bearing
# element elsewhere in the same fragment. Codex's #183 review demonstrated that on the
# live specs — `text-bg-primary` added to ActiveFilterBar's NON-selected "Active:" label
# shipped green under `.allowing("text-bg-primary")` — so the four selected-state call
# sites now remove nodes too, and no component spec passes `allowing:` at all.
#
# ---------------------------------------------------------------------------------
# Axis 3 — markup literal
# ---------------------------------------------------------------------------------
# A pure best-effort backstop over the serialised fragment: hex, `rgb(`/`rgba(`,
# `hsl(`/`hsla(`. It reads attributes and text as well as `style`, which is the whole
# point — an inline SVG `fill="#fff"` is invisible to axis 1. It knows nothing about
# named colours or modern colour functions; axis 1 owns those.
module ThemeAdaptivity
  # Properties that paint. `opacity` is here because a declared pair can be AA-clean and
  # still fail once faded — #130's ActiveFilterBar composited white at 0.8 to 3.71:1, and
  # TagChip's remove button did the same at 0.6.
  #
  # `filter`/`backdrop-filter` recolour a whole subtree without naming a colour at all
  # (`filter: invert(1)`), `background-blend-mode` changes what a background paints, and
  # `text-emphasis-color`/`-webkit-text-fill-color` paint text through a property the
  # value scan has no reason to look at.
  #
  # The DIRECTIONAL and LOGICAL border longhands are the hole Codex's #183 review found by
  # injection: the list carried `border-color` and the four physical shorthands but not
  # `border-top-color`, so `border-top-color: papayawhip` dropped into ActiveFilterBar's
  # `bar_styles` left 111 examples GREEN — a standard paint property shipping a frozen hue
  # past a guard whose whole job is that. `-webkit-text-stroke*`, `scrollbar-color`,
  # `text-emphasis` (the shorthand, not just `-color`) and the SVG paint-server properties
  # `stop-color`/`flood-color`/`lighting-color` were missing for the same reason.
  #
  # No component emits any of the preventive entries today — each is proven by a fixture
  # only the property rule can reject (a value that is neither a colour literal nor a
  # listed named colour), so deleting one entry reddens exactly its own example.
  COLOUR_PROPERTIES = %w[
    color background background-color background-image background-blend-mode
    border border-top border-right border-bottom border-left
    border-color border-style border-width
    border-top-color border-right-color border-bottom-color border-left-color
    border-block border-block-color border-block-start border-block-start-color
    border-block-end border-block-end-color
    border-inline border-inline-color border-inline-start border-inline-start-color
    border-inline-end border-inline-end-color
    outline outline-color outline-style box-shadow text-shadow opacity fill stroke
    accent-color caret-color column-rule column-rule-color text-decoration-color
    filter backdrop-filter text-emphasis text-emphasis-color
    -webkit-text-fill-color -webkit-text-stroke -webkit-text-stroke-color
    scrollbar-color stop-color flood-color lighting-color
  ].freeze

  # Geometry that merely shares a `border-*` prefix. `--bs-border-width` is the documented
  # escape DataTable uses to put a 2px rule on one edge without boxing all four (#151).
  GEOMETRY_EXCEPTIONS = %w[border-radius --bs-border-width].freeze

  # Values that re-resolve per colour mode, so they survive a `data-bs-theme` flip.
  ADAPTIVE_VALUES = %w[currentcolor transparent inherit].freeze

  # A hex literal, or any CSS colour function. The function list is deliberately broad —
  # a guard that knows only rgb()/hsl() lets a modern colour space through silently.
  COLOUR_LITERAL = /
    \#[0-9a-f]{3,8}\b
    | \b(?:rgba?|hsla?|hwb|lab|lch|oklab|oklch|color|color-mix|device-cmyk|light-dark)\(
  /xi

  # CSS named colours. Not exhaustive by intent — it covers the ones a human would
  # actually reach for, and the property whitelist above is what catches the rest on a
  # colour-bearing property. Its job is the residual case: a named colour on a property
  # COLOUR_PROPERTIES does not list (e.g. `caret-color: red`).
  NAMED_COLOURS = %w[
    black white red green blue yellow orange purple pink brown grey gray silver gold
    navy teal aqua cyan magenta maroon olive lime indigo violet crimson salmon coral
    tomato khaki plum orchid tan beige ivory azure lavender turquoise chocolate
    firebrick forestgreen goldenrod hotpink lightblue lightgreen midnightblue
    rebeccapurple seagreen skyblue slategray slategrey steelblue whitesmoke
  ].freeze

  NAMED_COLOUR_PATTERN = /\b(?:#{NAMED_COLOURS.join('|')})\b/i

  # --- Axis 2 constants ------------------------------------------------------------

  # LAYER 1 (see the header). Bootstrap's colour-bearing class families — a blacklist-shaped
  # enumeration, NOT an allowlist: a class matching none of these alternations is never
  # examined and passes silently. Every widening below is therefore a deliberate act.
  #
  #   bg / text / border  — bare `border` included, via the `(?:-|\z)` alternation.
  #   table               — bare `table` included: `.table` itself binds
  #                         `--bs-table-bg`/`--bs-table-color`, and `.table-primary` …
  #                         `.table-dark` are LITERAL colours (`--bs-table-bg: #cfe2ff`,
  #                         verified in the compiled 5.3 CSS, with no `[data-bs-theme=dark]`
  #                         override), so they are fixed hues on the element DataTable and
  #                         TableForIndex both render. Unclassified until Codex's #183
  #                         review injected `table-primary` into Dashboard and watched 144
  #                         examples stay green.
  #   btn / link / alert /
  #   badge / list-group-item — the component families whose `-#{semantic}` modifier
  #                         paints. Added in #173.
  #   focus-ring          — bare included: `.focus-ring` binds `--bs-focus-ring-color`,
  #                         which resolves to `rgba(var(--bs-primary-rgb), …)` — and
  #                         `--bs-primary-rgb` does not shift per colour mode, so both the
  #                         base and every `.focus-ring-#{semantic}` are fixed hues.
  #   dropdown-menu-dark /
  #   navbar-dark         — fixed COLOUR SCHEME components (`.dropdown-menu-dark` pins
  #                         `#343a40`/`#dee2e6`; `.navbar-dark` pins white rgba()s). Matched
  #                         by exact name rather than by family prefix, so the structural
  #                         `dropdown-menu-end` / `navbar-expand-lg` / `navbar-brand` stay
  #                         out. The `-light` forms do not exist in compiled 5.3 (they are
  #                         Bootstrap 4 legacy) and are matched anyway: if a consuming app
  #                         still emits one, it is a fixed light scheme and should say so.
  #
  # None of the FOURTEEN guarded components emits a `btn-*` / `link-*` / `alert-*` /
  # `focus-ring-*` / `table-#{semantic}`, so within their specs those branches are proven by
  # mutation injection rather than by real markup. The engine as a whole is a different
  # matter: `SearchBar`, `NavBar`, `ActionButton`, `BatchActionButton` and
  # `BatchActionModalButton` all emit `btn-primary` / `btn-outline-#{color}` /
  # `btn-secondary` / `btn-link`, and `TableForIndex` emits `table-dark` on its `<thead>` —
  # none of them is guarded yet, which is why the branches stay in the classifier rather
  # than being trimmed as dead (ISS#183 triage).
  COLOUR_UTILITY_PATTERN = /
    \A(?:bg|text|border|table|focus-ring)(?:-|\z)
    | \A(?:btn|link|alert|badge|list-group-item)-
    | \A(?:dropdown-menu|navbar)-(?:dark|light)\z
  /x

  # TIER 1 — classified by prefix, but paint nothing. Without these, `bg-transparent`
  # (TagChip's remove button), `border-0`, `border-bottom` (DataTable's header rule) and
  # `text-decoration-none` all read as fixed-hue offences.
  #
  # `border-1`..`border-5` are width utilities and `border-*-0` are per-side resets;
  # both are geometry. `btn-sm`/`btn-lg`/`btn-close` are the only `btn-*` classes this
  # engine emits and none of them names a colour (`.btn-close`'s icon is driven by
  # `--bs-btn-close-filter`, which Bootstrap 5.3 re-resolves per colour mode).
  #
  # The `table-*` entries arrived with the layer-1 widening (#183 round 2). Verified in the
  # compiled 5.3 CSS: `.table-sm` sets padding only; `.table-bordered`/`.table-borderless`
  # set `border-width` only; `.table-responsive*` sets `overflow`. `.alert-dismissible` sets
  # `padding-right` only.
  NEUTRAL_UTILITIES = %w[
    bg-transparent text-reset
    border border-0 border-1 border-2 border-3 border-4 border-5
    border-top border-end border-bottom border-start
    border-top-0 border-end-0 border-bottom-0 border-start-0
    text-start text-end text-center text-truncate text-nowrap text-wrap text-break
    text-decoration-none text-decoration-underline
    text-uppercase text-lowercase text-capitalize
    btn-sm btn-lg btn-close
    table-sm table-bordered table-borderless
    table-responsive table-responsive-sm table-responsive-md
    table-responsive-lg table-responsive-xl table-responsive-xxl
    alert-dismissible
  ].freeze

  # TIER 2 — every family Bootstrap 5.3 re-resolves under `data-bs-theme`.
  #
  # `info`, `light` and `dark` ARE present, deliberately. Their `-subtle`/`-emphasis`
  # forms are genuinely adaptive, and this matcher answers "does it re-resolve?", not
  # "is it on MPI's palette". (`$mpi-info: $mpi-primary` means `bg-info-subtle` renders
  # the same blue as `bg-primary-subtle` — a palette fact, and not this guard's
  # business.) The BASE `bg-light`/`text-dark`/`bg-info` forms are absent and therefore
  # still rejected, which is correct: those are fixed-scheme.
  ADAPTIVE_SEMANTICS = %w[primary secondary success warning danger info light dark].freeze

  # `alert-#{semantic}` and `list-group-item-#{semantic}` are here because they ARE
  # adaptive, which #173 got backwards and #183 inherited. Compiled 5.3:
  # `.alert-danger { --bs-alert-color: var(--bs-danger-text-emphasis);
  # --bs-alert-bg: var(--bs-danger-bg-subtle); --bs-alert-border-color:
  # var(--bs-danger-border-subtle) }` — the same three tokens `bg-danger-subtle` /
  # `text-danger-emphasis` resolve through, and all three are redefined in the
  # `[data-bs-theme=dark]` block (`--bs-danger-text-emphasis: #ea868f`,
  # `--bs-danger-bg-subtle: #2c0b0e`). `.list-group-item-warning` is built identically.
  # A matcher whose stated question is "does it re-resolve?" cannot call those fixed hues.
  #
  # The rest, each verified the same way:
  #   text-body-emphasis / link-body-emphasis — `var(--bs-emphasis-color)` /
  #     `RGBA(var(--bs-emphasis-color-rgb), …)`; `--bs-emphasis-color-rgb` flips to
  #     `255, 255, 255` in the dark block.
  #   btn-link            — `--bs-btn-color: var(--bs-link-color)`, which re-resolves.
  #   alert-heading       — `color: inherit`.
  #   alert-link          — `var(--bs-alert-link-color)`, i.e. the alert's own emphasis token.
  #   list-group-item-action — every declaration is a `--bs-list-group-action-*` token.
  #   table               — `--bs-table-color: var(--bs-emphasis-color)`,
  #     `--bs-table-bg: var(--bs-body-bg)`, `--bs-table-border-color: var(--bs-border-color)`.
  #   table-striped / -striped-columns / -active / -hover — each re-points
  #     `--bs-table-*-type`/`-state` at `rgba(var(--bs-emphasis-color-rgb), …)` on `.table`.
  #   table-group-divider — `border-top: … solid currentcolor`.
  # `table-#{semantic}` is deliberately ABSENT: those are literal hexes (see the classifier).
  ADAPTIVE_UTILITIES = (
    %w[
      bg-body bg-body-secondary bg-body-tertiary
      text-body text-body-secondary text-body-tertiary text-body-emphasis
      link-body-emphasis btn-link alert-heading alert-link list-group-item-action
      table table-striped table-striped-columns table-active table-hover table-group-divider
    ] +
    ADAPTIVE_SEMANTICS.flat_map do |s|
      [ "bg-#{s}-subtle", "text-#{s}-emphasis", "border-#{s}-subtle",
        "alert-#{s}", "list-group-item-#{s}" ]
    end
  ).freeze

  ADAPTIVE_UTILITY_ALLOWLIST = (NEUTRAL_UTILITIES + ADAPTIVE_UTILITIES).freeze

  # --- Axis 3 constants ------------------------------------------------------------

  # Hex (3/4/6/8 digit) or an rgb()/hsl() function, anywhere in the serialised markup.
  # The trailing (?!\h) stops a 6-digit match inside a longer run; the leading (?<!&)
  # keeps a numeric character reference such as `&#8212;` (em dash) from reading as a
  # 4-digit hex literal once Nokogiri re-serialises the fragment.
  MARKUP_COLOUR_LITERAL = /(?<!&)#(?:\h{8}|\h{6}|\h{4}|\h{3})(?!\h)|\brgba?\(|\bhsla?\(/i

  module_function

  # The matchers take a Nokogiri fragment, a Capybara node, or a raw HTML string, so the
  # guard's own spec (`spec/lib/theme_adaptivity_spec.rb`, which sets no `type:` and
  # therefore has no `page`) can unit-test them directly.
  def to_fragment(markup)
    return markup if markup.is_a?(Nokogiri::XML::Node) || markup.is_a?(Nokogiri::XML::NodeSet)
    return to_fragment(markup.native) if markup.respond_to?(:native)

    Nokogiri::HTML::DocumentFragment.parse(markup.to_s)
  end

  # Every colour-bearing utility class applied anywhere in `fragment` that is neither
  # theme-adaptive nor explicitly allowed, deduped and sorted. Returns ONLY class names
  # — no diagnostic prose — so a caller can compare against an expected set.
  #
  # There is deliberately NO vacuity branch: "this fragment applies no colour-bearing
  # class" is a legitimate result (a geometry-only element), and an unrelated embedded
  # child would satisfy a vacuity check anyway. Each call site pins its own subject
  # positively instead, per `.claude/rules/testing.md` False Green #2.
  def fixed_hue_utility_offences(markup, allowing: [])
    allowed = ADAPTIVE_UTILITY_ALLOWLIST + Array(allowing).flatten.map(&:to_s)

    applied_utility_classes(markup)
      .select { |klass| klass.match?(COLOUR_UTILITY_PATTERN) }
      .reject { |klass| allowed.include?(klass) }
      .sort
  end

  # Every distinct class applied anywhere in the fragment, in no particular order.
  #
  # The roots are included alongside their descendants. `NodeSet#css` and `Node#css`
  # search DESCENDANTS only, so scoping a guard with `fragment.css("nav")` and then
  # reading `.css("[class]")` would silently skip the `nav`'s own classes — a scoped
  # guard that cannot see the element it was scoped to.
  def applied_utility_classes(markup)
    # NOT `Array(...)`: Nokogiri::XML::Node is Enumerable over its ATTRIBUTES, so
    # `Array(node)` silently yields attribute pairs instead of the node.
    parsed = to_fragment(markup)
    roots = parsed.is_a?(Nokogiri::XML::NodeSet) ? parsed.to_a : [ parsed ]

    roots.flat_map { |root| [ root ] + root.css("[class]").to_a }
         .flat_map { |node| node["class"].to_s.split }
         .uniq
  end

  # Every colour literal in the SERIALISED fragment — attributes and text included, not
  # just `style` declarations.
  def markup_colour_literals(markup)
    to_fragment(markup).to_html.scan(MARKUP_COLOUR_LITERAL)
  end

  # "a: b; c: d" -> ["a: b", "c: d"]. Splits on ";" only — no CSS value in this engine
  # contains one, and `var(--x, #fff)` fallbacks keep their comma.
  def declarations(style)
    style.to_s.split(";").map(&:strip).reject(&:empty?)
  end

  def property_of(declaration)
    declaration.split(":", 2).first.to_s.strip.downcase
  end

  def value_of(declaration)
    declaration.split(":", 2).last.to_s.strip
  end

  # A `var(--bs-*)` reference re-resolves per colour mode — but only if it actually
  # resolves. `var(--bs-body-bg, #fff)` falls back to a FROZEN colour whenever the token
  # is absent, which is precisely the situation an un-imported partial creates (#155).
  # So the token form is adaptive only when its fallback is itself adaptive, or absent.
  def adaptive_value?(value)
    normalised = value.strip.downcase
    return true if ADAPTIVE_VALUES.include?(normalised)
    return false unless normalised.start_with?("var(--bs-")

    # Fail CLOSED. A `var(--bs-*)` with no fallback is adaptive; one WITH a fallback is
    # adaptive only if the fallback is too. Anything this cannot parse confidently —
    # a trailing `!important`, nested parens, an empty fallback — is rejected rather
    # than waved through, because "did not parse" and "no fallback" are different
    # answers and conflating them is how the guard shipped fail-open.
    return true if normalised.match?(/\Avar\(\s*--bs-[a-z0-9-]+\s*\)\z/)

    fallback = normalised[/\Avar\(\s*--bs-[a-z0-9-]+\s*,(.*)\)\z/m, 1]
    return false if fallback.nil? || fallback.strip.empty?

    adaptive_value?(fallback)
  end

  # Returns [] when the style makes no frozen-colour decision, else the offending
  # declarations with the reason each was rejected.
  #
  # The two scans are INDEPENDENT, not an if/elsif chain: a value accepted by the
  # property rule must still be checked for an embedded literal, or
  # `background-color: var(--bs-body-bg, #fff)` passes on the strength of its prefix
  # while a frozen hex rides along in the fallback.
  def frozen_colour_offences(style)
    declarations(style).flat_map do |declaration|
      property = property_of(declaration)
      value = value_of(declaration)
      next [] if GEOMETRY_EXCEPTIONS.include?(property)

      # A custom property can hold anything, including a colour, and nothing downstream
      # constrains it — so treat every un-excepted `--*` as colour-bearing.
      paints = COLOUR_PROPERTIES.include?(property) || property.start_with?("--")

      offences = []
      if paints && !adaptive_value?(value)
        offences << "#{declaration.inspect} — `#{property}` paints, and #{value.inspect} does not " \
          "re-resolve per colour mode (allowed: currentColor, transparent, inherit, var(--bs-*))"
      end
      if value.match?(COLOUR_LITERAL)
        offences << "#{declaration.inspect} — carries a colour literal"
      elsif value.match?(NAMED_COLOUR_PATTERN)
        offences << "#{declaration.inspect} — carries a named CSS colour"
      end
      offences
    end
  end
end

RSpec::Matchers.define :be_free_of_frozen_colour do
  match { |style| ThemeAdaptivity.frozen_colour_offences(style).empty? }

  failure_message do |style|
    offences = ThemeAdaptivity.frozen_colour_offences(style)
    "expected the surviving inline style to make no frozen-colour decision, but found " \
      "#{offences.size} offence(s) in #{style.inspect}:\n  - #{offences.join("\n  - ")}"
  end

  failure_message_when_negated do |style|
    "expected #{style.inspect} to carry at least one frozen-colour declaration, but it was clean"
  end
end

# Axis 2. `allowing` is class-scoped, not placement-scoped — see the module header
# before reaching for it; removing the offending nodes is usually the stronger move.
RSpec::Matchers.define :be_free_of_fixed_hue_utilities do
  chain(:allowing) { |*extra| @allowing = Array(extra).flatten }

  match { |markup| ThemeAdaptivity.fixed_hue_utility_offences(markup, allowing: @allowing.to_a).empty? }

  failure_message do |markup|
    offences = ThemeAdaptivity.fixed_hue_utility_offences(markup, allowing: @allowing.to_a)
    allowed = @allowing.to_a.empty? ? "(none)" : @allowing.to_a.join(", ")
    "expected every colour-bearing utility class to be theme-adaptive, but #{offences.size} " \
      "class(es) pin a fixed hue or a fixed colour scheme: #{offences.join(', ')}.\n" \
      "Adaptive classes are the bg-body*/text-body* family, the -subtle/-emphasis semantic " \
      "families, and the tier-1 neutrals. Explicitly allowed here: #{allowed}"
  end

  failure_message_when_negated do |markup|
    classified = ThemeAdaptivity.applied_utility_classes(markup)
                                .select { |k| k.match?(ThemeAdaptivity::COLOUR_UTILITY_PATTERN) }
    allowed = @allowing.to_a.empty? ? "(none)" : @allowing.to_a.join(", ")
    "expected at least one fixed-hue or fixed-scheme colour utility, but every colour-bearing " \
      "class applied was adaptive or allowed (allowing: #{allowed}); " \
      "classified classes were: #{classified.sort.join(', ')}"
  end
end

# Axis 3.
RSpec::Matchers.define :be_free_of_colour_literals do
  match { |markup| ThemeAdaptivity.markup_colour_literals(markup).empty? }

  failure_message do |markup|
    literals = ThemeAdaptivity.markup_colour_literals(markup)
    "expected the rendered markup to carry no colour literal in any attribute or text node, " \
      "but found #{literals.size}: #{literals.uniq.join(', ')}"
  end

  failure_message_when_negated do |_markup|
    "expected the rendered markup to carry at least one hex / rgb() / hsl() colour literal, " \
      "but it was clean"
  end
end

module ThemeAdaptivityHelpers
  # Both Dashboard and DataTable hand-rolled this before #183. Child subtrees are
  # stripped at the call site, so each component's guards scan only its OWN markup.
  def rendered_fragment
    Nokogiri::HTML::DocumentFragment.parse(rendered_content)
  end

  # The `style` attribute of every node matching `selector`, in document order.
  def inline_styles(selector)
    page.all(selector, visible: :all).map { |node| node[:style].to_s }
  end

  # Convenience for the common single-element case.
  def inline_style(selector)
    styles = inline_styles(selector)
    raise "expected exactly one #{selector.inspect}, found #{styles.size}" unless styles.one?

    styles.first
  end
end

RSpec.configure do |config|
  config.include ThemeAdaptivityHelpers, type: :component
end
