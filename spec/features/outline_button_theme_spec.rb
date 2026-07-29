# frozen_string_literal: true

require "spec_helper"

# Browser-level (real headless Chrome) proof that the ISS#183 follow-up fix in
# `_buttons.scss` makes every `.btn-outline-*` resting foreground adapt to
# `data-bs-theme` and clear WCAG AA in BOTH colour modes.
#
# This fix is invisible to `render_inline`: the component emits a byte-identical
# `btn btn-outline-primary` before and after — only a CSS rule changed, re-pointing
# `--bs-btn-color` at `--bs-primary-text-emphasis`. A component spec asserting those
# class names would be a false green by construction (`.claude/rules/testing.md`, "a
# conversion that lives in an SCSS partial is invisible to render_inline"). The proof
# has to live where the change lives: the painted pixels under each colour mode.
#
# The defect this locks down was real and shipped. Bootstrap 5.3 defines
# `.btn-outline-#{semantic}` exactly once, never under a `[data-bs-theme]` scope, so the
# resting text kept its raw semantic hue while the surface flipped. Measured on the
# engine's own palette, EVERY variant failed AA in one mode or the other — primary/info
# 3.185, danger 3.407, secondary 3.290 in dark; success 3.329, warning 3.243 in light.
#
# Per `.claude/rules/testing.md` ("a browser contrast spec must pin the painted
# foreground, not only the ratio"), each example asserts the exact painted colour as well
# as the ratio. A ratio-only assertion would false-green if the rule stopped applying:
# the button would fall back to inherited body text, which clears AA against the same
# surface in both modes and would sail through.
RSpec.describe "Outline button theme adaptivity", type: :feature, js: true do
  # Resolves what a user actually SEES: composites the element's (possibly alpha'd)
  # colour over the nearest opaque backdrop. An outline button's own background is
  # transparent, so the walk finds the `bg-body` demo section — which is exactly the
  # surface whose flip caused the defect. Mirrors spec/features/nav_bar_theme_spec.rb.
  RESOLVE_JS = <<~JS
    (() => {
      const parse = (value) => {
        const parts = (value.match(/[\\d.]+/g) || []).map(Number);
        return { r: parts[0], g: parts[1], b: parts[2], a: parts.length > 3 ? parts[3] : 1 };
      };
      const opaqueBackdrop = (node) => {
        for (let el = node.parentElement; el; el = el.parentElement) {
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

      const backdrop = opaqueBackdrop(el);
      return {
        foreground: hex(over(parse(getComputedStyle(el).color), backdrop)),
        background: hex(backdrop),
      };
    })()
  JS

  def resolve(selector)
    result = page.evaluate_script(RESOLVE_JS.sub("SELECTOR", selector.to_json))
    raise "no element matched #{selector}" if result.nil?

    result.transform_keys(&:to_sym)
  end

  # The exact colour each variant must PAINT in each mode — the compiled
  # `--bs-#{semantic}-text-emphasis` for MPI's palette. Hardcoded deliberately: these are
  # the values the fix exists to produce, so a change to the token pipeline that moves
  # them should redden here and be re-derived on purpose, not absorbed silently.
  # `info` matches `primary` because `_tokens_values.scss` sets `$mpi-info: $mpi-primary`.
  EXPECTED = {
    light: {
      primary: "#122F49", secondary: "#2B2F32", success: "#0E402B",
      info: "#122F49", warning: "#553012", danger: "#58151C"
    },
    dark: {
      primary: "#82ACD3", secondary: "#A7ACB1", success: "#7AC6A6",
      info: "#82ACD3", warning: "#E5AD80", danger: "#EA868F"
    }
  }.freeze

  # The body surface each mode paints, asserted so a demo page that silently lost its
  # `data-bs-theme` wrapper cannot make both modes measure the same thing and pass twice.
  EXPECTED_SURFACE = { light: "#FFFFFF", dark: "#212529" }.freeze

  before { visit "/outline_button_theme_demo" }

  # Loop the DOMAIN (every colour the component accepts), not a sample. `COLORS` drives
  # the rendered variants, so a colour added to the constant without a matching adaptive
  # binding reddens here rather than shipping unproven.
  MpiDesignSystem::Admin::ActionButton::Component::COLORS.each do |semantic|
    %i[light dark].each do |mode|
      it "paints btn-outline-#{semantic} at its #{mode}-mode emphasis token and clears AA" do
        selector = "##{'outline'}-#{mode}-mode .mds-demo-outline-#{semantic}"
        resolved = resolve(selector)
        measured = MpiDesignSystem::ColorContrast.ratio(resolved[:foreground], resolved[:background])

        # Pin the SURFACE first: if the mode wrapper stopped applying, both modes would
        # measure against the same backdrop and the pair of examples would agree wrongly.
        expect(resolved[:background]).to eq(EXPECTED_SURFACE[mode]),
          "#{mode} surface painted #{resolved[:background]}, expected #{EXPECTED_SURFACE[mode]}"

        # Pin the painted FOREGROUND, not just the ratio. Inherited body text clears AA
        # on this surface in both modes, so a ratio-only assertion cannot tell "the
        # emphasis token is driving this" from "the rule stopped applying".
        expect(resolved[:foreground]).to eq(EXPECTED[mode][semantic]),
          "#{selector} painted #{resolved[:foreground]}, expected #{EXPECTED[mode][semantic]} " \
          "(--bs-#{semantic}-text-emphasis). A raw-hue regression paints the pre-fix value."

        expect(measured).to be >= 4.5,
          "#{selector} measured #{measured.round(3)}:1 " \
          "(#{resolved[:foreground]} on #{resolved[:background]}), below the 4.5:1 AA floor"
      end
    end
  end

  # The border is deliberately NOT converted — it is a non-text UI boundary held to SC
  # 1.4.11's 3:1, and keeping the raw hue preserves the button's identity colour. Pinned
  # so that "make it adaptive" applied uniformly to the border reddens here and has to be
  # an argued change rather than a reflex. (`.claude/rules/frontend.md`: a foreground is
  # only safe to make adaptive where its surface adapts too — the converse also needs
  # recording.)
  it "leaves the outline border on the raw semantic hue, still clearing the 3:1 UI floor" do
    %i[light dark].each do |mode|
      raw = page.evaluate_script(
        "(() => { const e = document.querySelector(" \
        "#{"#outline-#{mode}-mode .mds-demo-outline-primary".to_json}); " \
        "return getComputedStyle(e).borderTopColor; })()"
      )
      channels = raw.scan(/[\d.]+/).map(&:to_f)
      hex = format("#%02X%02X%02X", *channels.first(3).map(&:round))

      expect(hex).to eq("#2E75B6"), "#{mode} border painted #{hex}, expected the raw #2E75B6"

      ratio = MpiDesignSystem::ColorContrast.ratio(hex, EXPECTED_SURFACE[mode])
      expect(ratio).to be >= 3.0,
        "#{mode} border measured #{ratio.round(3)}:1, below the 3:1 SC 1.4.11 floor"
    end
  end
end
