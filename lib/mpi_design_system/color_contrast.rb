# frozen_string_literal: true

module MpiDesignSystem
  # WCAG 2.1 contrast math, and the Ruby counterpart to Bootstrap's SCSS
  # `color-contrast()` function.
  #
  # Components that must emit a foreground colour in an *inline style* cannot
  # use Bootstrap's `text-bg-*` utilities (which derive the foreground at SCSS
  # compile time). Where the background is a per-instance value — e.g.
  # `AvatarCircle`'s name-hashed palette — the foreground has to be derived in
  # Ruby instead, or it ends up hand-pinned and drifts out of compliance. That
  # is the defect issue #130 fixed: 7 of AvatarCircle's 10 palette colours were
  # shipping white text below the 4.5:1 AA floor.
  #
  # Prefer a Bootstrap `text-bg-*` class whenever the background is one of the
  # theme colours — let the framework derive it. Reach for this module only when
  # the background is genuinely dynamic.
  #
  # ## Bootstrap parity
  #
  # `accessible_foreground` deliberately mirrors Bootstrap 5.3's
  # `color-contrast()`: it tries the light foreground first, then the dark one,
  # and returns the first whose ratio is **>=** `$min-contrast-ratio` (4.5),
  # falling back to whichever scores highest if neither clears the bar.
  #
  # One narrowing: Bootstrap's candidate list is four entries —
  # `$color-contrast-light, $color-contrast-dark, $white, $black` — so a project
  # that overrode the first two would still get white/black as a fallback. This
  # module implements the two-candidate case, which is equivalent under Bootstrap's
  # defaults (light == white, dark == black) and is what this engine ships: it
  # overrides neither, as `_tokens.scss` shows. If a consumer ever configures a
  # non-white/black contrast pair, revisit this.
  #
  # The two are not guaranteed to agree byte-for-byte at the threshold, and that
  # is intentional. Bootstrap computes luminance from a *rounded* lookup table
  # (`$_luminance-list`), so a colour sitting within ~0.001 of 4.5:1 can resolve
  # differently there than here. This module implements the WCAG formula
  # exactly; where the two could diverge, the standard wins. No colour in the
  # engine's palette is anywhere near that boundary — the closest is `#DC3545`
  # at 4.53:1 — and `spec/fixtures/scss/avatar_contrast_oracle.scss` compiles
  # Bootstrap's own function over the palette so CI proves the two agree in
  # practice.
  module ColorContrast
    # Bootstrap's `$color-contrast-light` / `$color-contrast-dark` defaults.
    LIGHT = "#fff"
    DARK = "#000"

    # Bootstrap's `$min-contrast-ratio`, which is also the WCAG 2.1 AA floor for
    # normal-size text. Large text (>= 24px, or >= 18.66px bold) may use 3.0.
    MIN_CONTRAST_RATIO = 4.5

    HEX_FORMAT = /\A(\h{3}|\h{6})\z/

    class << self
      # WCAG 2.1 relative luminance of an sRGB colour (0.0 = black, 1.0 = white).
      # https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
      def relative_luminance(color)
        r, g, b = channels(color).map do |channel|
          channel <= 0.03928 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4
        end

        (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
      end

      # WCAG 2.1 contrast ratio between two colours, from 1.0 (identical) to
      # 21.0 (black on white). Order-independent.
      def ratio(one, other)
        lighter, darker = [ relative_luminance(one), relative_luminance(other) ].minmax.reverse

        (lighter + 0.05) / (darker + 0.05)
      end

      # The accessible foreground for +background+, mirroring Bootstrap's
      # `color-contrast()`. Returns LIGHT or DARK.
      def accessible_foreground(background, min_ratio: MIN_CONTRAST_RATIO)
        candidates = [ LIGHT, DARK ]

        candidates.find { |foreground| ratio(background, foreground) >= min_ratio } ||
          candidates.max_by { |foreground| ratio(background, foreground) }
      end

      # True when +foreground+ on +background+ meets the AA floor.
      def accessible?(foreground, background, min_ratio: MIN_CONTRAST_RATIO)
        ratio(foreground, background) >= min_ratio
      end

      private

      def channels(color)
        normalize(color).scan(/../).map { |pair| pair.to_i(16) / 255.0 }
      end

      # Callers pass frozen palette constants, so an unparseable colour is a
      # programming error rather than user input. It raises instead of falling
      # back to a default: no single foreground is safe against an *unknown*
      # background, so silently returning one would be the very bug this module
      # exists to prevent.
      def normalize(color)
        value = color.to_s.strip.delete_prefix("#")

        unless value.match?(HEX_FORMAT)
          raise ArgumentError, "expected a 3- or 6-digit hex colour, got #{color.inspect}"
        end

        value = value.chars.flat_map { |char| [ char, char ] }.join if value.length == 3
        value.downcase
      end
    end
  end
end
