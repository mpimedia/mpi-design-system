# frozen_string_literal: true

# Shared guard for the inline-style -> semantic-utility conversions (#149, #150, #151,
# #152, #168). It answers one question about a converted element: does its SURVIVING
# inline style still make a colour decision?
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
module ThemeAdaptivity
  # Properties that paint. `opacity` is here because a declared pair can be AA-clean and
  # still fail once faded — #130's ActiveFilterBar composited white at 0.8 to 3.71:1, and
  # TagChip's remove button did the same at 0.6.
  COLOUR_PROPERTIES = %w[
    color background background-color background-image
    border border-top border-right border-bottom border-left
    border-color border-style border-width
    outline outline-color outline-style box-shadow text-shadow opacity fill stroke
    accent-color caret-color column-rule column-rule-color text-decoration-color
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

  module_function

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

module ThemeAdaptivityHelpers
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
