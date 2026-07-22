# frozen_string_literal: true

require "spec_helper"

# Browser-level (real headless Chrome) proof that the #154 conversion of
# `_nav_bar.scss` from compile-time Sass variables to Bootstrap runtime CSS
# custom properties actually adapts to `data-bs-theme`.
#
# This conversion is invisible to `render_inline`: the components emit the same
# `.mds-*` class names before and after — only the CSS *rules* in the partial
# changed. A component spec would be a false green. The proof has to live where
# the change lives: the painted pixels under each colour mode. So this spec reads
# `getComputedStyle` off a real routed page (/nav_theme_demo) that renders the
# NavBar and AppShell once in light and once in dark, and recomputes the WCAG
# ratio from what the browser actually painted — the same technique as
# `spec/features/contrast_spec.rb` (#130) and the Pagination pilot (#149).
RSpec.describe "NavBar theme adaptivity", type: :feature, js: true do
  # Copied from spec/features/contrast_spec.rb: resolves what a user actually SEES.
  # `--bs-secondary-color` (the muted nav links and gear) is rgba(body-color, .75),
  # so reading its RGB channels and discarding alpha overstates contrast — it must
  # be composited over the opaque backdrop before the ratio is computed. The
  # backdrop walk also finds the real surface behind a transparent element (a nav
  # link's own background is transparent; the opaque one is the navbar). Kept
  # self-contained rather than extracted so contrast_spec.rb is not disturbed.
  NAVBAR_RESOLVE_JS = <<~JS
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

      const backdrop = opaqueBackdrop(el);
      const foreground = over(parse(getComputedStyle(el).color), backdrop);

      return { foreground: hex(foreground), background: hex(backdrop) };
    })()
  JS

  def resolve(selector)
    result = page.evaluate_script(NAVBAR_RESOLVE_JS.sub("SELECTOR", selector.to_json))
    raise "no element matched #{selector}" if result.nil?

    result.transform_keys(&:to_sym)
  end

  def ratio_for(selector)
    resolved = resolve(selector)
    measured = MpiDesignSystem::ColorContrast.ratio(resolved[:foreground], resolved[:background])

    [ measured, resolved[:foreground], resolved[:background] ]
  end

  def computed(selector, property)
    key = property == "color" ? :foreground : :background

    resolve(selector).fetch(key)
  end

  # `getComputedStyle` returns border colours as `rgb()`; read the specific side
  # (the nav underlines are border-BOTTOM, the sidebar is border-RIGHT — the
  # contrast_spec helper reads border-TOP, which is unset here and would return the
  # element's text colour instead).
  def border_rgb(selector, side)
    page.evaluate_script(
      "(() => { const e = document.querySelector(#{selector.to_json}); " \
      "if (!e) throw new Error('no element matched #{selector}'); " \
      "return getComputedStyle(e)['border#{side}Color']; })()"
    )
  end

  # `fill` on the logo polygons resolves `currentColor`/`var(--bs-link-color)` to
  # an rgb() the browser painted.
  def fill_rgb(selector)
    page.evaluate_script(
      "(() => { const e = document.querySelector(#{selector.to_json}); " \
      "if (!e) throw new Error('no element matched #{selector}'); " \
      "return getComputedStyle(e).fill; })()"
    )
  end

  def rgb_to_hex(rgb)
    nums = rgb.scan(/\d+/).first(3).map(&:to_i)
    format("#%02X%02X%02X", *nums)
  end

  before { visit "/nav_theme_demo" }

  # Expected painted values, MEASURED against the compiled bundle (not hand-derived):
  #   navbar/sidebar bg  = --bs-body-bg      (#FFFFFF / #212529)
  #   subnav/main/crumb  = --bs-tertiary-bg  (#F8F9FA / #2B3035)
  #   borders            = --bs-border-color (dee2e6 / 495057)
  #   brand text + arms  = --bs-body-color   (#1B2A4A / #DEE2E6)
  #   muted links + gear = --bs-secondary-color, composited (#545F77 / #AFB3B7)
  #   active/hover links = --bs-link-color   (#2E75B6 / #82ACD3)  ← AA-safe in dark
  NAVBAR_THEME_MODES = {
    "light" => {
      nav: "#nav-light", shell: "#shell-light",
      navbar_bg: "#FFFFFF", chrome_bg: "#F8F9FA", sidebar_bg: "#FFFFFF",
      border: "rgb(222, 226, 230)",
      brand: "#1B2A4A", muted: "#545F77", link: "#2E75B6",
      logo_fill: "rgb(27, 42, 74)"
    },
    "dark" => {
      nav: "#nav-dark", shell: "#shell-dark",
      navbar_bg: "#212529", chrome_bg: "#2B3035", sidebar_bg: "#212529",
      border: "rgb(73, 80, 87)",
      brand: "#DEE2E6", muted: "#AFB3B7", link: "#82ACD3",
      logo_fill: "rgb(222, 226, 230)"
    }
  }.freeze

  NAVBAR_THEME_MODES.each do |mode, expected|
    context "in #{mode} mode" do
      let(:nav) { expected[:nav] }
      let(:shell) { expected[:shell] }

      describe "surfaces" do
        it "paints the navbar on the adaptive body surface" do
          expect(computed("#{nav} .mds-navbar", "backgroundColor")).to eq(expected[:navbar_bg])
        end

        it "paints the subnav on the tertiary app-chrome surface" do
          expect(computed("#{nav} .mds-subnav", "backgroundColor")).to eq(expected[:chrome_bg])
        end

        it "paints the shell sidebar on the body surface and main/breadcrumb on tertiary" do
          expect(computed("#{shell} .mds-shell__sidebar", "backgroundColor")).to eq(expected[:sidebar_bg])
          expect(computed("#{shell} .mds-shell__main", "backgroundColor")).to eq(expected[:chrome_bg])
          expect(computed("#{shell} .mds-shell__breadcrumb", "backgroundColor")).to eq(expected[:chrome_bg])
        end

        it "paints the navbar, subnav and sidebar borders from the border token" do
          expect(border_rgb("#{nav} .mds-navbar", "Bottom")).to eq(expected[:border])
          expect(border_rgb("#{nav} .mds-subnav", "Bottom")).to eq(expected[:border])
          expect(border_rgb("#{shell} .mds-shell__sidebar", "Right")).to eq(expected[:border])
        end
      end

      describe "foregrounds clear WCAG AA" do
        it "paints the brand text above the 4.5:1 floor" do
          measured, fg, bg = ratio_for("#{nav} .mds-navbar__brand")

          expect(fg).to eq(expected[:brand])
          expect(bg).to eq(expected[:navbar_bg])
          expect(measured).to be >= 4.5, "#{mode} brand #{fg} on #{bg} = #{measured.round(2)}:1"
        end

        it "paints the muted default section link above the 4.5:1 floor" do
          selector = "#{nav} .mds-navbar__section-link:not(.mds-navbar__section-link--active)"
          measured, fg, bg = ratio_for(selector)

          expect(fg).to eq(expected[:muted])
          expect(bg).to eq(expected[:navbar_bg])
          expect(measured).to be >= 4.5, "#{mode} muted link #{fg} on #{bg} = #{measured.round(2)}:1"
        end

        it "paints the active section link above the 4.5:1 floor" do
          measured, fg, bg = ratio_for("#{nav} .mds-navbar__section-link--active")

          expect(fg).to eq(expected[:link])
          expect(bg).to eq(expected[:navbar_bg])
          expect(measured).to be >= 4.5, "#{mode} active link #{fg} on #{bg} = #{measured.round(2)}:1"
        end

        it "paints the active subnav link above the 4.5:1 floor against the tertiary surface" do
          measured, fg, bg = ratio_for("#{nav} .mds-subnav__link--active")

          expect(fg).to eq(expected[:link])
          expect(bg).to eq(expected[:chrome_bg])
          expect(measured).to be >= 4.5, "#{mode} active subnav #{fg} on #{bg} = #{measured.round(2)}:1"
        end

        it "paints the gear glyph above the 3:1 non-text UI floor" do
          measured, fg, bg = ratio_for("#{nav} .mds-navbar__gear")

          expect(fg).to eq(expected[:muted])
          expect(bg).to eq(expected[:navbar_bg])
          expect(measured).to be >= 3.0, "#{mode} gear #{fg} on #{bg} = #{measured.round(2)}:1"
        end
      end

      describe "active underlines clear the 3:1 non-text UI floor" do
        it "paints the section-link underline from the link token" do
          border = rgb_to_hex(border_rgb("#{nav} .mds-navbar__section-link--active", "Bottom"))
          measured = MpiDesignSystem::ColorContrast.ratio(border, expected[:navbar_bg])

          expect(border).to eq(expected[:link])
          expect(measured).to be >= 3.0, "#{mode} section underline #{border} = #{measured.round(2)}:1"
        end

        it "paints the subnav-link underline from the link token" do
          border = rgb_to_hex(border_rgb("#{nav} .mds-subnav__link--active", "Bottom"))
          measured = MpiDesignSystem::ColorContrast.ratio(border, expected[:chrome_bg])

          expect(border).to eq(expected[:link])
          expect(measured).to be >= 3.0, "#{mode} subnav underline #{border} = #{measured.round(2)}:1"
        end
      end

      describe "logo" do
        # The bug #154 fixes: the arms were a frozen navy (#1B2A4A) that paints at
        # ~1.09:1 (invisible) on the dark navbar. They now inherit currentColor
        # (= body-color), so the mark stays visible in both modes.
        it "paints the logo arms visibly (currentColor) against the navbar, not the frozen navy" do
          arm = "#{nav} .mds-navbar__brand svg polygon"
          painted = fill_rgb(arm)

          expect(painted).to eq(expected[:logo_fill])
          measured = MpiDesignSystem::ColorContrast.ratio(rgb_to_hex(painted), expected[:navbar_bg])
          expect(measured).to be >= 3.0, "#{mode} logo arm #{painted} on #{expected[:navbar_bg]} = #{measured.round(2)}:1"
        end
      end

      describe "hover states (exercised with Selenium)" do
        it "lightens the muted section link to the link colour on hover, above AA" do
          page.find("#{nav} a.mds-navbar__section-link", text: "Dashboard").hover

          selector = "#{nav} .mds-navbar__section-link:not(.mds-navbar__section-link--active)"
          measured, fg, bg = ratio_for(selector)

          expect(fg).to eq(expected[:link])
          expect(measured).to be >= 4.5, "#{mode} hovered link #{fg} on #{bg} = #{measured.round(2)}:1"
        end

        it "lightens the gear to the link colour on hover, above AA" do
          page.find("#{nav} .mds-navbar__gear").hover

          measured, fg, bg = ratio_for("#{nav} .mds-navbar__gear")

          expect(fg).to eq(expected[:link])
          expect(measured).to be >= 4.5, "#{mode} hovered gear #{fg} on #{bg} = #{measured.round(2)}:1"
        end
      end
    end
  end

  # The whole point of the conversion: the same markup paints DIFFERENTLY under each
  # colour mode. A per-mode value could be correct while adaptivity was broken (e.g.
  # both modes pinned light); these inequalities prove the flip actually happens.
  describe "surfaces differ between the two colour modes" do
    it "flips every nav surface and border between light and dark" do
      expect(computed("#nav-light .mds-navbar", "backgroundColor"))
        .not_to eq(computed("#nav-dark .mds-navbar", "backgroundColor"))
      expect(computed("#nav-light .mds-subnav", "backgroundColor"))
        .not_to eq(computed("#nav-dark .mds-subnav", "backgroundColor"))
      expect(computed("#shell-light .mds-shell__sidebar", "backgroundColor"))
        .not_to eq(computed("#shell-dark .mds-shell__sidebar", "backgroundColor"))
      expect(computed("#shell-light .mds-shell__main", "backgroundColor"))
        .not_to eq(computed("#shell-dark .mds-shell__main", "backgroundColor"))
      expect(computed("#shell-light .mds-shell__breadcrumb", "backgroundColor"))
        .not_to eq(computed("#shell-dark .mds-shell__breadcrumb", "backgroundColor"))
      expect(border_rgb("#nav-light .mds-navbar", "Bottom"))
        .not_to eq(border_rgb("#nav-dark .mds-navbar", "Bottom"))
    end
  end
end
