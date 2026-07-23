# frozen_string_literal: true

require "spec_helper"

# Browser-level (real headless Chrome) proof that the derived foregrounds from
# issue #130 actually LAND — measured as computed style against the real compiled
# Bootstrap bundle.
#
# `render_inline` proves the ERB emits the right `class` and `style` attributes,
# and the render specs already cover that. What it cannot prove is the cascade:
#
#   * `.text-bg-primary` sets `color` with `!important` from a stylesheet, while
#     the pill also carries an inline `style` attribute. Inline styles normally
#     beat stylesheet rules, so "which wins" is a real question, not a given.
#   * The remove button is an `<a>` with inline `color: inherit`. An anchor does
#     NOT inherit color by default — Bootstrap styles `a { color: var(--bs-link-color) }`.
#     If `inherit` failed to win, the × would render link-blue on a blue pill: a
#     contrast regression *introduced* by the fix, invisible to every render spec.
#   * `.text-body-secondary` resolves through `--bs-secondary-color`, a variable
#     chain that only exists at runtime.
#
# So this spec reads `getComputedStyle` and recomputes the WCAG ratio from what the
# browser actually painted — following the computed-style precedent set by the
# `mpi--tag-input` spec (see `.claude/rules/testing.md`).
RSpec.describe "Derived foreground contrast", type: :feature, js: true do
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

  before { visit "/contrast_demo" }

  describe "AvatarCircle" do
    MpiDesignSystem::Admin::AvatarCircle::Component::COLORS.each_with_index do |palette_color, index|
      it "paints palette index #{index} (#{palette_color}) at or above the 4.5:1 AA floor" do
        selector = "[data-avatar-index='#{index}'] .rounded-circle"

        expect(page).to have_css(selector)
        measured, foreground, background = ratio_for(selector)

        # The browser must have painted the palette background we expect — otherwise
        # a passing ratio could just mean the element rendered transparent.
        expect(background).to eq(palette_color.upcase)
        expect(measured).to be >= 4.5,
          "expected AA contrast for #{foreground} on #{background}, got #{measured.round(2)}:1"
      end
    end

    it "paints the placeholder above the AA floor" do
      measured, _foreground, background = ratio_for("[data-avatar-placeholder] .rounded-circle")

      expect(background).to eq("#6C757D")
      expect(measured).to be >= 4.5
    end

    it "paints dark initials on the accent color that was the worst failure at 2.63:1" do
      index = MpiDesignSystem::Admin::AvatarCircle::Component::COLORS.index("#4EA8DE")

      expect(computed("[data-avatar-index='#{index}'] .rounded-circle", "color")).to eq("#000000")
    end

    it "keeps white where white already passed, so nothing changed unnecessarily" do
      index = MpiDesignSystem::Admin::AvatarCircle::Component::COLORS.index("#2E75B6")

      expect(computed("[data-avatar-index='#{index}'] .rounded-circle", "color")).to eq("#FFFFFF")
    end
  end

  describe "AvatarStack overflow chip" do
    it "paints the +N chip above the AA floor" do
      measured, _foreground, background = ratio_for("#stack span[aria-hidden='true']")

      expect(background).to eq(MpiDesignSystem::Admin::AvatarStack::Component::OVERFLOW_COLOR)
      expect(measured).to be >= 4.5
    end

    # #150: the separator ring is `border: 2px solid var(--bs-body-bg)`. render_inline
    # can only see the literal `var(--bs-body-bg)` string in the style attribute — it
    # cannot prove the variable RESOLVES. A browser can: an unresolved/transparent ring
    # would compute rgba(0, 0, 0, 0) (or the currentColor fallback), not the surface
    # colour. In light mode `--bs-body-bg` is the page body bg (#FFFFFF).
    it "resolves the ring border to the light body background (var(--bs-body-bg) = #FFFFFF)" do
      expect(page).to have_css("#stack span[aria-hidden='true']")
      expect(border_color_of("#stack span[aria-hidden='true']")).to eq("rgb(255, 255, 255)")
    end

    # And the whole point of the conversion: under data-bs-theme='dark' the ring tracks
    # the dark surface (--bs-body-bg = #212529) instead of staying the retired white.
    it "tracks the dark surface for the ring under data-bs-theme='dark' (#212529)" do
      expect(page).to have_css("#dark-stack span[aria-hidden='true']")
      expect(border_color_of("#dark-stack span[aria-hidden='true']")).to eq("rgb(33, 37, 41)")
    end
  end

  # StatCard (#150). render_inline proves the `-emphasis` trend classes and `.text-body`
  # value class are EMITTED (the unit spec covers that); only a browser proves they PAINT
  # an AA-clean colour once the runtime `--bs-*-text-emphasis` / `--bs-body-color` chain
  # resolves against the compiled bundle. The 12px trend is small text (AA 4.5:1); this is
  # the external-oracle proof that the deliberate `-emphasis` choice actually clears it in
  # BOTH colour modes, and that the value colour resolves. Painted values measured in Chrome.
  describe "StatCard" do
    {
      "light" => { root: "#stat-card", trend_fg: "#0E402B", value_fg: "#1B2A4A", surface: "#FFFFFF" },
      "dark" => { root: "#dark-stat-card", trend_fg: "#7AC6A6", value_fg: "#DEE2E6", surface: "#212529" }
    }.each do |mode, expected|
      context "in #{mode} mode" do
        # Pinning the painted trend_fg is load-bearing: base `.text-success` would paint
        # #22A06B (3.33:1 on the light card — below the 4.5:1 small-text floor), and a
        # dropped class would fall back to inherited body colour. Only the exact
        # `-emphasis` value distinguishes "the AA fix resolved" from either.
        it "paints the -emphasis trend token AA-clean on the card surface (12px small text, 4.5:1)" do
          measured, foreground, background = ratio_for("#{expected[:root]} .text-success-emphasis")

          expect(foreground).to eq(expected[:trend_fg])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} trend #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the value in the adaptive body colour above the AA floor" do
          measured, foreground, background = ratio_for("#{expected[:root]} .text-body")

          expect(foreground).to eq(expected[:value_fg])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} value #{foreground} on #{background} = #{measured.round(2)}:1"
        end
      end
    end
  end

  # The load-bearing part of this spec. Everything below is about whether the
  # cascade resolved, not whether the markup was emitted.
  %w[#active-filter-bar #filter-chip-bar].each do |section|
    describe "pill in #{section}" do
      let(:pill) { "#{section} .text-bg-primary" }

      it "paints the MPI primary background from the token, not a hardcoded literal" do
        _measured, _foreground, background = ratio_for(pill)

        expect(background).to eq("#2E75B6")
      end

      it "paints a pill foreground above the AA floor" do
        measured, foreground, background = ratio_for(pill)

        expect(measured).to be >= 4.5,
          "expected AA contrast for #{foreground} on #{background}, got #{measured.round(2)}:1"
      end

      # The regression this whole spec exists to catch.
      it "paints the remove button in the pill's own foreground, not Bootstrap's link color" do
        pill_foreground = computed(pill, "color")
        button_foreground = computed("#{pill} a", "color")

        expect(button_foreground).to eq(pill_foreground)
      end

      it "paints the remove button above the AA floor against the pill" do
        button_foreground = computed("#{pill} a", "color")
        pill_background = computed(pill, "backgroundColor")
        measured = MpiDesignSystem::ColorContrast.ratio(button_foreground, pill_background)

        expect(measured).to be >= 4.5,
          "expected AA contrast for #{button_foreground} on #{pill_background}, got #{measured.round(2)}:1"
      end

      # The retired `opacity: 0.8` composited white down to ~3.71:1. This checks
      # CUMULATIVE opacity up the whole ancestor chain, not just the button's own:
      # `opacity` on the pill (or any wrapper) would fade the × just as effectively
      # while leaving the button's own computed value at 1.
      it "paints the remove button at full opacity, ancestors included" do
        expect(resolve("#{pill} a")[:cumulativeOpacity]).to eq(1.0)
      end

      it "paints the pill itself at full opacity, ancestors included" do
        expect(resolve(pill)[:cumulativeOpacity]).to eq(1.0)
      end
    end
  end

  # Bootstrap 5.3 colour modes. After #150 ActiveFilterBar's surface is
  # `.bg-body-secondary` (adaptive), so the bar AND its `.text-body-secondary` label
  # flip together with `data-bs-theme` — the inverse of #130, which had to PIN the bar's
  # colour mode because its surface was a frozen light hex ($mpi-background) that would
  # have rendered light-on-light (1.16:1) under a theme-aware label. With an adaptive
  # surface the pin is gone and the dark bar computes `--bs-secondary-bg` = #343A40, the
  # value the engine leaves at Bootstrap's dark default. (#150)
  describe "under data-bs-theme='dark'" do
    it "flips the ActiveFilterBar surface with the colour mode and keeps its label readable" do
      foreground = computed("#dark-active-filter-bar .text-body-secondary", "color")
      background = computed("#dark-active-filter-bar [role='toolbar']", "backgroundColor")

      # Pin the PAINTED foreground, not just the ratio. `.text-body-secondary` composites
      # to rgba(dark body-color, .75) over the #343A40 bar = #B4B8BD (measured in Chrome).
      # Without this, dropping the class lets the label fall back to inherited body colour
      # and the ratio alone can't tell "the token resolved" from "something else painted".
      expect(foreground).to eq("#B4B8BD")
      expect(background).to eq("#343A40")
      expect(MpiDesignSystem::ColorContrast.ratio(foreground, background)).to be >= 4.5,
        "dark-mode label #{foreground} on adaptive bar #{background} = " \
        "#{MpiDesignSystem::ColorContrast.ratio(foreground, background).round(2)}:1"
    end

    it "keeps the ActiveFilterBar pill readable" do
      measured, foreground, background = ratio_for("#dark-active-filter-bar .text-bg-primary")

      expect(measured).to be >= 4.5,
        "dark-mode pill #{foreground} on #{background} = #{measured.round(2)}:1"
    end

    # FilterChipBar pins no background, so its muted text should track the dark
    # surface rather than being pinned light — the opposite treatment, and correct
    # for the same reason.
    it "lets FilterChipBar's muted text follow the dark surface it sits on" do
      foreground = computed("#dark-filter-chip-bar .text-body-secondary", "color")
      background = computed("#dark-mode", "backgroundColor")

      expect(MpiDesignSystem::ColorContrast.ratio(foreground, background)).to be >= 4.5,
        "dark-mode label #{foreground} on #{background} = " \
        "#{MpiDesignSystem::ColorContrast.ratio(foreground, background).round(2)}:1"
    end

    it "keeps avatar initials readable" do
      measured, foreground, background = ratio_for("#dark-avatars .rounded-circle")

      expect(measured).to be >= 4.5,
        "dark-mode avatar #{foreground} on #{background} = #{measured.round(2)}:1"
    end
  end

  # Pagination (#149) — the Track 2 pilot conversion. Every example asserts the PAINTED
  # value as well as the ratio, because a ratio alone is a false green here: if a utility
  # stopped applying, the element falls back to inherited body text, which passes AA in
  # both modes (#1B2A4A on #FFFFFF = 14.22:1, #DEE2E6 on #212529 = 11.85:1). Only the
  # painted value distinguishes "the utility resolved" from "something else was readable".
  #
  # The expected values below were measured against the compiled bundle, not derived by
  # hand. Note `--bs-body-color` maps to MPI navy, so light mode paints the exact #1B2A4A
  # the retired inline style pinned.
  describe "Pagination" do
    {
      "light" => {
        root: "#pagination",
        results_text: "#122F49",
        surface: "#FFFFFF",
        body_text: "#1B2A4A",
        # text-body-secondary is rgba(body-color, .75); these are the composited values.
        gap_text: "#545F77",
        border: "rgb(222, 226, 230)"
      },
      "dark" => {
        root: "#dark-pagination",
        results_text: "#82ACD3",
        surface: "#212529",
        body_text: "#DEE2E6",
        gap_text: "#AFB3B7",
        border: "rgb(73, 80, 87)"
      }
    }.each do |mode, expected|
      context "in #{mode} mode" do
        let(:root) { expected[:root] }

        # The example that would have caught the 3.185:1 defect the issue's literal
        # `text-primary` mapping would have shipped.
        it "paints the results text from the colour-mode-aware emphasis token above the AA floor" do
          measured, foreground, background = ratio_for("#{root} .text-primary-emphasis")

          expect(foreground).to eq(expected[:results_text])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} results text #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the active page pill from the primary token with a derived foreground" do
          measured, foreground, background = ratio_for("#{root} [aria-current='page']")

          # Theme colours themselves do not flip under data-bs-theme — only the
          # subtle/emphasis derivatives do — so the pill is MPI primary in both modes.
          expect(background).to eq("#2E75B6")
          expect(foreground).to eq("#FFFFFF")
          expect(measured).to be >= 4.5,
            "#{mode} active pill #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        # If `.text-body` stopped applying, this anchor would paint Bootstrap's link
        # colour instead — #2E75B6 in light, which still clears 4.5:1 on white. The
        # foreground assertion is what catches that; the ratio never would.
        it "paints an inactive page button on the adaptive body surface above the AA floor" do
          measured, foreground, background = ratio_for("#{root} a[aria-label='Page 1']")

          expect(foreground).to eq(expected[:body_text])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} inactive button #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the truncation gap marker above the AA floor" do
          measured, foreground, background = ratio_for("#{root} span[aria-hidden='true']")

          # Without the foreground assertion this passes in light mode on inherited
          # body text (#1B2A4A on #FFFFFF = 14.22:1) even if text-body-secondary
          # stopped applying — the same false green the block header describes.
          expect(foreground).to eq(expected[:gap_text])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} gap marker #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "tracks the colour mode with its separator and button borders" do
          expect(border_color_of("#{root} nav[aria-label='Pagination']")).to eq(expected[:border])
          expect(border_color_of("#{root} a[aria-label='Page 1']")).to eq(expected[:border])
        end

        # `.border` and `.border-primary` are both !important at identical specificity,
        # so which one paints is decided by stylesheet source order — exactly the kind
        # of "which wins" question this browser layer exists to answer rather than
        # assume. The retired literal was an explicit `border: 1px solid #2E75B6`.
        it "paints the active pill border from the primary token, not the adaptive one" do
          expect(border_color_of("#{root} [aria-current='page']")).to eq("rgb(46, 117, 182)")
        end
      end
    end

    # The conversion is live on a Harvest production page, so the geometry it replaced
    # must come back byte-for-byte, not merely accessibly. (The results-text colour is
    # the one deliberate light-mode change; it is asserted above, not here.)
    it "reproduces the retired geometry literals exactly in light mode" do
      styles = page.evaluate_script(<<~JS)
        (() => {
          const btn = document.querySelector("#pagination a[aria-label='Page 1']");
          const nav = document.querySelector("#pagination nav[aria-label='Pagination']");
          const cs = getComputedStyle(btn);
          return {
            radius: cs.borderTopLeftRadius,
            width: cs.borderTopWidth,
            style: cs.borderTopStyle,
            decoration: cs.textDecorationLine,
            navWidth: getComputedStyle(nav).borderTopWidth,
          };
        })()
      JS

      # `rounded` resolves to the consumer's $border-radius token; under this engine's
      # configuration that is Bootstrap's 0.375rem = the retired literal 6px.
      expect(styles["radius"]).to eq("6px")
      expect(styles["width"]).to eq("1px")
      expect(styles["style"]).to eq("solid")
      # Was `text-decoration: none` inline; without the utility Bootstrap underlines links.
      expect(styles["decoration"]).to eq("none")
      expect(styles["navWidth"]).to eq("1px")
    end
  end

  # NavBar brand mark. #155 tokenised the default diamond's fills from inline hex to the
  # `.mds-navbar__brand-arm`/`.mds-navbar__brand-center` classes; #154 then made those classes
  # theme-adaptive — arm `fill: var(--bs-body-color)`, centre `fill: var(--bs-link-color)` — with a
  # `currentColor` fallback still in the markup. The contrast_demo page is unthemed (light), where
  # `--bs-body-color` resolves to the brand navy (#1B2A4A) and `--bs-link-color` to primary
  # (#2E75B6), so the painted values below are those. render_inline proves the classes and
  # `fill="currentColor"` are emitted; only a browser proves the author CSS class wins over the
  # presentation attribute and paints the two-tone. The load-bearing assertion is the CENTRE:
  # currentColor would fall back to the arms' body-color (navy), so centre == link-color (primary)
  # is exactly what distinguishes "the .mds-navbar__brand-center rule resolved" from "the fallback
  # painted".
  describe "NavBar brand mark" do
    def fill_of(selector)
      page.evaluate_script(
        "(() => { const e = document.querySelector(#{selector.to_json}); " \
        "if (!e) throw new Error('no element matched'); " \
        "return getComputedStyle(e).fill; })()"
      )
    end

    it "paints the arm polygons navy from var(--bs-body-color) (light: #1B2A4A), not the monochrome fallback" do
      expect(page).to have_css("#nav-bar-mark polygon.mds-navbar__brand-arm")
      expect(fill_of("#nav-bar-mark polygon.mds-navbar__brand-arm")).to eq("rgb(27, 42, 74)")
    end

    it "paints the center polygon primary from var(--bs-link-color) (light: #2E75B6) — the value the currentColor fallback cannot produce" do
      expect(page).to have_css("#nav-bar-mark polygon.mds-navbar__brand-center")
      expect(fill_of("#nav-bar-mark polygon.mds-navbar__brand-center")).to eq("rgb(46, 117, 182)")
    end
  end

  # Dashboard (#153). Every colour the component SELECTS moved onto Bootstrap semantic
  # utilities so the layout tracks `data-bs-theme`. render_inline proves the classes are
  # emitted; only a browser proves the runtime `--bs-*` chains resolve AA-clean against the
  # compiled bundle. Each assertion pins the PAINTED value AND the ratio: inherited body
  # text clears AA in both modes, so a ratio-only check would be a false green (the #149
  # rule). The chart's caller-supplied colours are the documented passthrough and are not
  # asserted here. Painted values corroborated by the Pagination/StatCard/FilterChipBar
  # blocks above (same tokens, same formulas).
  describe "Dashboard (#153)" do
    {
      "light" => {
        root: "#dashboard", surface: "#FFFFFF",
        icons: {
          primary: %w[#122F49 #D5E3F0], secondary: %w[#2B2F32 #E2E3E5],
          success: %w[#0E402B #D3ECE1], warning: %w[#553012 #F6E4D5]
        },
        danger_emphasis: "#58151C", warning_emphasis: "#553012", muted: "#545F77",
        link: "#2E75B6", body: "#1B2A4A", border: "rgb(222, 226, 230)"
      },
      "dark" => {
        root: "#dark-dashboard", surface: "#212529",
        icons: {
          primary: %w[#82ACD3 #091724], secondary: %w[#A7ACB1 #161719],
          success: %w[#7AC6A6 #072015], warning: %w[#E5AD80 #2A1809]
        },
        danger_emphasis: "#EA868F", warning_emphasis: "#E5AD80", muted: "#AFB3B7",
        link: "#82ACD3", body: "#DEE2E6", border: "rgb(73, 80, 87)"
      }
    }.each do |mode, expected|
      context "in #{mode} mode" do
        let(:root) { expected[:root] }

        it "paints the widget surface from the adaptive bg-body" do
          expect(computed("#{root} .bg-body.border.rounded-3", "backgroundColor")).to eq(expected[:surface])
        end

        %i[primary secondary success warning].each do |variant|
          it "paints the #{variant} activity icon -emphasis on its -subtle chip above the AA floor" do
            fg_expected, bg_expected = expected[:icons][variant]
            measured, foreground, background = ratio_for("#{expected[:root]} .bg-#{variant}-subtle.text-#{variant}-emphasis")

            expect(foreground).to eq(fg_expected)
            expect(background).to eq(bg_expected)
            expect(measured).to be >= 4.5,
              "#{mode} #{variant} icon #{foreground} on #{background} = #{measured.round(2)}:1"
          end
        end

        it "paints the danger follow-up status emphasis AA-clean on the widget surface (12px small text)" do
          measured, foreground, background = ratio_for("#{root} .text-danger-emphasis[style*='font-weight: 600']")

          expect(foreground).to eq(expected[:danger_emphasis])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} danger status #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the warning follow-up status emphasis AA-clean on the widget surface" do
          measured, foreground, background = ratio_for("#{root} .text-warning-emphasis[style*='font-weight: 600']")

          expect(foreground).to eq(expected[:warning_emphasis])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} warning status #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the muted (text-body-secondary) status AA-clean on the widget surface" do
          measured, foreground, background = ratio_for("#{root} .text-body-secondary[style*='font-weight: 600']")

          expect(foreground).to eq(expected[:muted])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} muted status #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the activity contact link in the adaptive --bs-link-color above the AA floor" do
          measured, foreground, background = ratio_for("#{root} a[href='/contacts/1']")

          # The value a `text-primary` regression could not produce (it would paint the
          # solid primary, identical in both modes; the link colour flips per mode).
          expect(foreground).to eq(expected[:link])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} activity link #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the 'View all' link in the adaptive --bs-link-color above the AA floor" do
          measured, foreground, background = ratio_for("#{root} a[href='/followups']")

          expect(foreground).to eq(expected[:link])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} view-all link #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        it "paints the quick action in adaptive body text on the adaptive bg-body surface" do
          measured, foreground, background = ratio_for("#{root} a.border.bg-body.text-body")

          expect(foreground).to eq(expected[:body])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} quick action #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        # The quick action `.border` is theme-adaptive but low-contrast — ~1.30:1 in light,
        # ~1.89:1 in dark — below SC 1.4.11's 3:1 for a control boundary. The conversion does
        # NOT introduce it: the control was navy-on-white inside that same `#DEE2E6` border
        # before #153. Pin the PAINTED border value so the limitation is measured, not the 3:1
        # asserted (a pre-existing design question, deliberately not folded into this colour
        # conversion — see the CHANGELOG dot/border note).
        it "tracks the colour mode with the quick action border (documented low-contrast limit)" do
          expect(border_color_of("#{root} a.border.bg-body.text-body")).to eq(expected[:border])
        end
      end
    end
  end

  describe "muted text" do
    it "paints the ActiveFilterBar label above the AA floor against the adaptive bar" do
      foreground = computed("#active-filter-bar .text-body-secondary", "color")
      background = computed("#active-filter-bar [role='toolbar']", "backgroundColor")

      # #150: the light bar now computes `--bs-secondary-bg` (#E9ECEF), not the retired
      # pinned `#F5F7FA`. The label follows the surface instead of assuming it.
      #
      # Pin the PAINTED foreground too: `.text-body-secondary` composites to
      # rgba(MPI navy body-color, .75) over #E9ECEF = #4F5B73 (measured in Chrome). The
      # ratio alone is a false green here — if the class stopped applying the label falls
      # back to inherited navy body text (#1B2A4A), which STILL clears AA on this light
      # bar, so only the painted value distinguishes "token resolved" from "fell back".
      expect(foreground).to eq("#4F5B73")
      expect(background).to eq("#E9ECEF")
      expect(MpiDesignSystem::ColorContrast.ratio(foreground, background)).to be >= 4.5
    end

    it "paints the retired #6C757D nowhere in the bar" do
      expect(computed("#active-filter-bar .text-body-secondary", "color")).not_to eq("#6C757D")
    end

    # FilterChipBar sets no background, so `resolve` walks up to whatever opaque
    # surface it actually sits on — which is the point: a pinned foreground here
    # would only ever be verified against an assumed backdrop.
    it "paints the FilterChipBar labels above the AA floor against the page" do
      measured, foreground, background = ratio_for("#filter-chip-bar .text-body-secondary")

      expect(measured).to be >= 4.5,
        "label #{foreground} on inherited backdrop #{background} = #{measured.round(2)}:1"
    end
  end

  # FilterChipBar selected chip (#151). The selected chip carries its group's semantic
  # `-subtle` surface with its `-emphasis` foreground, both resolved from the compiled
  # bundle — so the pair follows `data-bs-theme`. The demo's selected chip is Finance
  # (-> warning). Exact painted values were measured against the compiled bundle, not
  # derived by hand; the ratio alone would be a false green (inherited body text on the
  # page also clears AA), so both the value and the ratio are asserted.
  describe "FilterChipBar selected chip (#151)" do
    {
      "light" => { root: "#filter-chip-bar", foreground: "#553012", background: "#F6E4D5" },
      "dark" => { root: "#dark-filter-chip-bar", foreground: "#E5AD80", background: "#2A1809" }
    }.each do |mode, expected|
      it "paints the selected chip's #{mode} emphasis-on-subtle above the AA floor" do
        measured, foreground, background = ratio_for("#{expected[:root]} a[aria-current='page']")

        expect(foreground).to eq(expected[:foreground])
        expect(background).to eq(expected[:background])
        expect(measured).to be >= 4.5,
          "#{mode} selected chip #{foreground} on #{background} = #{measured.round(2)}:1"
      end
    end
  end

  # DataTable (#151). The conversion moved every DataTable colour onto Bootstrap
  # utilities. Three things a render spec cannot prove and this layer must:
  #   * the 2px header separator lands on the BOTTOM edge only — `border-2` would box
  #     all four sides of a `.table th` (the P0 the conversion had to avoid);
  #   * the account link paints Bootstrap's adaptive `--bs-link-color` (no pinned
  #     `text-*` class), a different value per colour mode;
  #   * the decorative dots keep a FIXED identity hue across themes (the documented
  #     exception) and still clear the 3:1 non-text floor against each row backdrop.
  describe "DataTable (#151)" do
    # Expected solid fill per Bootstrap semantic, measured against the compiled engine
    # bundle. Theme colours do not flip under data-bs-theme (only subtle/emphasis
    # derivatives do), so each holds in both light and dark mode.
    DOT_HEX = {
      primary: "#2E75B6", success: "#22A06B", warning: "#D4772C",
      danger: "#DC3545", secondary: "#6C757D"
    }.freeze

    def border_widths(selector)
      page.evaluate_script(
        "(() => { const e = document.querySelector(#{selector.to_json}); " \
        "if (!e) throw new Error('no element matched'); const cs = getComputedStyle(e); " \
        "return { top: cs.borderTopWidth, right: cs.borderRightWidth, " \
        "bottom: cs.borderBottomWidth, left: cs.borderLeftWidth }; })()"
      )
    end

    def border_bottom_color_of(selector)
      page.evaluate_script(
        "(() => { const e = document.querySelector(#{selector.to_json}); " \
        "if (!e) throw new Error('no element matched'); " \
        "return getComputedStyle(e).borderBottomColor; })()"
      )
    end

    # A dot is an empty span whose FILL is its own background-color. Measure that fill
    # against the first opaque ANCESTOR (never the dot itself, which is opaque), and
    # composite any bg-opacity — mirroring the RESOLVE_JS approach for backgrounds.
    def dot_contrast(selector)
      js = <<~JS
        (() => {
          const parse = (v) => { const p = (v.match(/[\\d.]+/g) || []).map(Number);
            return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 }; };
          const over = (fg, bg) => ({ r: fg.r*fg.a + bg.r*(1-fg.a), g: fg.g*fg.a + bg.g*(1-fg.a), b: fg.b*fg.a + bg.b*(1-fg.a) });
          const hex = (c) => '#' + [c.r, c.g, c.b].map((x) => Math.round(x).toString(16).padStart(2, '0')).join('').toUpperCase();
          const el = document.querySelector(#{selector.to_json});
          if (!el) return null;
          let backdrop = { r: 255, g: 255, b: 255, a: 1 };
          for (let n = el.parentElement; n; n = n.parentElement) {
            const bg = parse(getComputedStyle(n).backgroundColor);
            if (bg.a === 1) { backdrop = bg; break; }
          }
          const fill = over(parse(getComputedStyle(el).backgroundColor), backdrop);
          return { fill: hex(fill), backdrop: hex(backdrop) };
        })()
      JS
      result = page.evaluate_script(js)
      raise "no element matched #{selector}" if result.nil?

      result = result.transform_keys(&:to_sym)
      [ MpiDesignSystem::ColorContrast.ratio(result[:fill], result[:backdrop]), result[:fill], result[:backdrop] ]
    end

    {
      "light" => { root: "#datatable", surface: "#FFFFFF", link: "#2E75B6", border: "rgb(222, 226, 230)" },
      "dark" => { root: "#dark-datatable", surface: "#212529", link: "#82ACD3", border: "rgb(73, 80, 87)" }
    }.each do |mode, expected|
      context "in #{mode} mode" do
        let(:root) { expected[:root] }

        it "puts the 2px header separator on the bottom edge alone" do
          widths = border_widths("#{root} thead th")

          expect(widths["bottom"]).to eq("2px")
          expect(widths["top"]).to eq("0px")
          expect(widths["right"]).to eq("0px")
          expect(widths["left"]).to eq("0px")
        end

        it "tracks the colour mode with the header separator colour" do
          expect(border_bottom_color_of("#{root} thead th")).to eq(expected[:border])
        end

        it "paints the account link in Bootstrap's adaptive link colour above the AA floor" do
          measured, foreground, background = ratio_for("#{root} a[href='/accounts/1']")

          expect(foreground).to eq(expected[:link])
          expect(background).to eq(expected[:surface])
          expect(measured).to be >= 4.5,
            "#{mode} account link #{foreground} on #{background} = #{measured.round(2)}:1"
        end

        # Tag dots — row 1's tags column (2nd cell) carries one dot per distinct
        # GROUP_VARIANTS hue. Loop the whole mapping (so a new/renamed variant is proven
        # too), asserting each solid fill AND that it clears >=3:1 on the RESTING
        # (non-hover) row backdrop. The dots are decorative (the adjacent label carries
        # the meaning), so the transient table-hover dip below 3:1 is out of scope and
        # deliberately not asserted — see the CHANGELOG dot note. (#151, P0)
        MpiDesignSystem::Admin::DataTable::Component::GROUP_VARIANTS.values.uniq.each do |variant|
          it "keeps the decorative #{variant} tag dot >=3:1 on the resting row backdrop" do
            measured, fill, backdrop = dot_contrast("#{root} tbody td:nth-child(2) span.d-inline-block.bg-#{variant}")

            expect(fill).to eq(DOT_HEX.fetch(variant))
            expect(backdrop).to eq(expected[:surface])
            expect(measured).to be >= 3.0,
              "#{mode} #{variant} tag dot #{fill} on resting #{backdrop} = #{measured.round(2)}:1"
          end
        end

        # Status dots — the status column (4th cell) carries one dot per distinct
        # STATUS_VARIANTS hue across the three rows. Same resting-backdrop >=3:1 proof.
        MpiDesignSystem::Admin::DataTable::Component::STATUS_VARIANTS.values.uniq.each do |variant|
          it "keeps the decorative #{variant} status dot >=3:1 on the resting row backdrop" do
            measured, fill, backdrop = dot_contrast("#{root} tbody td:nth-child(4) span.d-inline-block.bg-#{variant}")

            expect(fill).to eq(DOT_HEX.fetch(variant))
            expect(backdrop).to eq(expected[:surface])
            expect(measured).to be >= 3.0,
              "#{mode} #{variant} status dot #{fill} on resting #{backdrop} = #{measured.round(2)}:1"
          end
        end
      end
    end
  end
end
