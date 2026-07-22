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

  describe "muted text" do
    it "paints the ActiveFilterBar label above the AA floor against the adaptive bar" do
      foreground = computed("#active-filter-bar .text-body-secondary", "color")
      background = computed("#active-filter-bar [role='toolbar']", "backgroundColor")

      # #150: the light bar now computes `--bs-secondary-bg` (#E9ECEF), not the retired
      # pinned `#F5F7FA`. The label follows the surface instead of assuming it.
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
end
