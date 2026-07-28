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
# So this is a WHITELIST on both axes. A colour-bearing property may hold only a value
# that re-resolves at runtime (`currentColor`, `transparent`, `inherit`, or a
# `var(--bs-*)` token); everything else fails, whether or not the value looks like a
# colour. Independently, NO property may carry a hex / rgb() / hsl() literal, which
# catches a colour smuggled into a property this list does not know about.
module ThemeAdaptivity
  # Properties that paint. `opacity` is here because a declared pair can be AA-clean and
  # still fail once faded — #130's ActiveFilterBar composited white at 0.8 to 3.71:1, and
  # TagChip's remove button did the same at 0.6.
  COLOUR_PROPERTIES = %w[
    color background background-color background-image
    border border-top border-right border-bottom border-left
    border-color border-style border-width
    outline outline-color outline-style box-shadow opacity fill stroke
  ].freeze

  # Geometry that merely shares a `border-*` prefix. `--bs-border-width` is the documented
  # escape DataTable uses to put a 2px rule on one edge without boxing all four (#151).
  GEOMETRY_EXCEPTIONS = %w[border-radius --bs-border-width].freeze

  # Values that re-resolve per colour mode, so they survive a `data-bs-theme` flip.
  ADAPTIVE_VALUES = %w[currentcolor transparent inherit].freeze

  # A hex literal, or an rgb()/rgba()/hsl()/hsla() function call.
  COLOUR_LITERAL = /#[0-9a-f]{3,8}\b|\brgba?\(|\bhsla?\(/i

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

  def adaptive_value?(value)
    normalised = value.strip.downcase
    ADAPTIVE_VALUES.include?(normalised) || normalised.start_with?("var(--bs-")
  end

  # Returns [] when the style makes no frozen-colour decision, else the offending
  # declarations with the reason each was rejected.
  def frozen_colour_offences(style)
    declarations(style).filter_map do |declaration|
      property = property_of(declaration)
      value = value_of(declaration)

      next if GEOMETRY_EXCEPTIONS.include?(property)

      if COLOUR_PROPERTIES.include?(property) && !adaptive_value?(value)
        "#{declaration.inspect} — `#{property}` paints, and #{value.inspect} does not " \
          "re-resolve per colour mode (allowed: currentColor, transparent, inherit, var(--bs-*))"
      elsif declaration.match?(COLOUR_LITERAL)
        "#{declaration.inspect} — carries a colour literal"
      end
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
