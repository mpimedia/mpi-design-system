# frozen_string_literal: true

# Computed-style contrast helpers shared by the browser feature specs.
#
# Extracted from `contrast_spec.rb` in #168 so the `mpi--tag-input` Stimulus spec can
# measure an interactively-added chip with the SAME machinery, rather than a second
# hand-rolled copy that could drift from it. Behaviour is unchanged.
module ContrastHelpers
  # Resolves what a user actually SEES, which is not the same as the declared
  # value in three ways this suite has to account for:
  #
  #   1. A colour may carry alpha. `.text-body-secondary` is
  #      `rgba(<body-color>, .75)`, so reading the RGB channels and discarding
  #      the alpha overstates contrast. Alpha is composited over the backdrop.
  #   2. A background may be transparent, in which case the visible backdrop is
  #      an ancestor's — so we walk up until we find an opaque one.
  #   3. `opacity` on any ancestor fades the whole subtree. It is invisible to
  #      the element's own computed `color`, which is how the retired
  #      `opacity: 0.8` hid a 3.71:1 failure behind an AA-clean declaration.
  RESOLVE_JS = <<~JS
    (() => {
      const parse = (value) => {
        const parts = (value.match(/[\\d.]+/g) || []).map(Number);
        return { r: parts[0], g: parts[1], b: parts[2], a: parts.length > 3 ? parts[3] : 1 };
      };
      const opaqueBackdrop = (node) => {
        for (let el = node; el; el = el.parentElement) {
          const bg = parse(getComputedStyle(el).backgroundColor);
          if (bg.a === 1) return bg;
        }
        return { r: 255, g: 255, b: 255, a: 1 };
      };
      const over = (fg, bg) => ({
        r: fg.r * fg.a + bg.r * (1 - fg.a),
        g: fg.g * fg.a + bg.g * (1 - fg.a),
        b: fg.b * fg.a + bg.b * (1 - fg.a),
      });
      const hex = (c) => '#' + [c.r, c.g, c.b]
        .map((v) => Math.round(v).toString(16).padStart(2, '0')).join('').toUpperCase();

      const el = document.querySelector(SELECTOR);
      if (!el) return null;

      let cumulativeOpacity = 1;
      for (let n = el; n; n = n.parentElement) {
        cumulativeOpacity *= parseFloat(getComputedStyle(n).opacity);
      }

      const backdrop = opaqueBackdrop(el);
      const foreground = over(parse(getComputedStyle(el).color), backdrop);

      return {
        foreground: hex(foreground),
        background: hex(backdrop),
        cumulativeOpacity: cumulativeOpacity,
      };
    })()
  JS

  def resolve(selector)
    result = page.evaluate_script(RESOLVE_JS.sub("SELECTOR", selector.to_json))
    raise "no element matched #{selector}" if result.nil?

    result.transform_keys(&:to_sym)
  end

  def ratio_for(selector)
    resolved = resolve(selector)
    measured = MpiDesignSystem::ColorContrast.ratio(resolved[:foreground], resolved[:background])

    [ measured, resolved[:foreground], resolved[:background] ]
  end

  def border_color_of(selector)
    page.evaluate_script(
      "(() => { const e = document.querySelector(#{selector.to_json}); " \
      "if (!e) throw new Error('no element matched'); " \
      "return getComputedStyle(e).borderTopColor; })()"
    )
  end

  def computed(selector, property)
    key = property == "color" ? :foreground : :background

    resolve(selector).fetch(key)
  end
end

RSpec.configure do |config|
  config.include ContrastHelpers, type: :feature
end
