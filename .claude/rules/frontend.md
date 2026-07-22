# Frontend Rules

Applies to: `app/components/**`, `app/javascript/**`, `app/assets/**`

## Framework

- This repo is a Rails engine gem — everything under `app/` ships to every consuming app (Markaz, SFA, Garden, Harvest)
- Hotwire only (Turbo + Stimulus) — never React, Vue, or other JS frameworks
- ViewComponent for all UI components
- Bootstrap 5.3 for all styling — never Tailwind CSS

## ViewComponent Conventions

- Components follow the `MpiDesignSystem::Admin::Name::Component` pattern:
  `app/components/mpi_design_system/admin/<name>/component.rb` + `component.html.erb`
- Components inherit directly from `ViewComponent::Base`. There is **no**
  `ApplicationComponent` base class in this engine — do not reference or invent one
- Every component ships with a spec (`spec/components/mpi_design_system/admin/<name>/component_spec.rb`)
  and a Lookbook preview (`spec/components/previews/mpi_design_system/admin/<name>/component_preview.rb`)
- Validate params in the component and fall back to safe defaults (e.g. `MpiDesignSystem::Admin::Badge::Component`
  maps an unknown color to `primary`) — never let bad input render broken markup

## Renaming a Component, Namespace, or Styling Convention

A component/namespace rename — or a change to a styling convention (e.g. a Bootstrap class
pattern) — is not finished when the constants resolve or the component renders. Blind spots
routinely survive a narrow sweep and ship green:

- **Path strings, not just constants.** Old paths also live in lowercase string literals a
  `grep 'Admin::'` never sees: `render_with_template(template: "…")`, `render partial: "…"`,
  Lookbook `@display`/template annotations, and asset paths. After renaming, grep the old
  *path fragment* (e.g. `admin/`) separately from the old *constant*, and confirm with a full
  preview render sweep (see `.claude/rules/testing.md`). Zeitwerk rewires constant→path but
  will not flag a hard-coded template string pointing at the moved directory.
- **`catalog/previews/*.html` are hand-written and drift silently.** They are static mockups with
  their own inline `<style>` block and hardcoded hex — nothing compiles, renders, or tests them,
  so they never fail a build no matter how stale they get. Sweep them alongside the `.md` catalog
  entry, and treat a contradiction between the two as a defect in the sweep. (Reference: #136
  rewrote `action-button.md`'s Accessibility section to describe Bootstrap's derived foregrounds;
  the sibling `action-button.html` was still forcing `color: #fff` on warning at **3.24:1** and
  success at **3.33:1** — both WCAG AA failures, and both the exact claim the `.md` had just
  retired. `badge.html` still carries pre-#128 `bg-secondary` + inline hex.)
- **Converting a mockup from hardcoded hex to semantic utilities makes it render *Bootstrap's*
  palette, not MPI's — add a `:root` token block.** The `catalog/previews/*.html` files load
  **stock** Bootstrap from the CDN (`bootstrap@5.3.x/dist`), which ships `--bs-primary: #0d6efd`.
  So the moment you replace a mockup's hardcoded `#2E75B6` with `text-bg-primary` / `text-primary`
  / `bg-body` — the correct move for the component — the mockup silently switches to Bootstrap's
  indigo, cyan, and grey, and now contradicts the component it documents while *looking* converted.
  The engine avoids this only because it compiles Bootstrap with MPI's tokens; the CDN mockups do
  not. Fix: add a `:root` block (and a `[data-bs-theme="dark"]` block for the emphasis tokens)
  mirroring `_tokens.scss` — `--bs-primary`, `--bs-primary-rgb` (which `text-bg-*` reads at
  runtime), `--bs-primary-text-emphasis`, `--bs-body-color`, `--bs-body-color-rgb`,
  `--bs-secondary-color`. The precedent is `filter-chip-bar.html`. **Verify in a browser, not by
  reading**: loading `pagination.html` against stock Bootstrap paints the pill `rgb(46, 117, 182)`
  *with* the block and `rgb(13, 110, 253)` *without* it — the second is the bug, and nothing in CI
  catches it. (Reference: #149 converted `pagination.html` and the `list-view.html` slice; both
  needed the block. Every remaining Track 2 phase converts a mockup and will hit this identically.)
- **A catalog entry's accessibility claims are assertions, not decoration — re-derive them when
  you touch the component.** Three separate cycles found a catalog file asserting a contrast
  property the code did not have: #128 (`Badge`), #130 (`avatar-circle.md` claimed "White text on
  all background colors meets WCAG AA 4.5:1" — false for 7 of 10), and #136
  (`action-button.md` claimed white text met AA on every button color). A prose claim about
  contrast ages the moment a palette value or a foreground rule changes, and nothing in CI reads
  it. Recompute the ratio rather than trusting the sentence.
- **The repo's own docs, not just code.** Sweep `CLAUDE.md`, `AGENTS.md`, `.claude/rules/**`,
  `catalog/**`, `references/**`, and `docs/standards/**` for the old token too — leaving the
  convention documented one way while the code does another tells the next agent to re-create
  the old pattern. (Reference: #103 renamed `Admin::` → `MpiDesignSystem::Admin::`; the catalog
  and standards docs had to be swept in the same change.)
- **A styling-convention change is a rename too — grep the pattern, not the lines you know.**
  When you change a Bootstrap class convention (e.g. `bg-#{color}` + `text-white`/`text-dark`
  → `text-bg-#{color}`), `git grep` the *old class pattern* across the whole repo — specs,
  `catalog/**`, and `.claude/rules/**` included — rather than editing a known list of line
  numbers; a line-scoped sweep misses second occurrences in the same file. (Reference: #128
  tokenized Badge's filled contrast; the external review caught a retired `bg-warning` +
  `text-dark` example still in `.claude/rules/testing.md` that a line-scoped sweep skipped.)
- **Re-run the sweep against the *rebased* file, not the one you branched from — a sibling PR can
  re-introduce the pattern you're removing.** A conversion often sits in review while another PR
  touches the same component; its new rules land in your file on rebase and, because they compile,
  ship green through your already-passing guards. Before finalizing a conversion, re-grep the
  *rebased* artifact (e.g. `grep '\$' the-partial` for a Sass-var conversion), not the version at
  branch time. (Reference: #154 converted `_nav_bar.scss` to `var(--bs-*)`; #155 merged mid-review
  and added `.mds-navbar__brand-arm { fill: $mpi-brand-navy }` / `-center { fill: $mpi-primary }` —
  two fresh frozen fills the rebase surfaced, which #154 then had to convert too, and whose
  per-selector bindings the compile guard had to grow.)

## Component Catalog First

Before creating a new component, check the catalog for an existing spec:

- `catalog/elements/` — buttons, badges, inputs, chips (Atoms)
- `catalog/components/` — cards, tables, pagination, navbars (Molecules)
- `catalog/patterns/` — forms, search, filters (Organisms)
- `catalog/layouts/` — app shell, dashboard, detail/list views (Templates)

If a catalog entry exists, implement to that spec. If not, raise it with the HC before building.

## Design a Public API Against Real Call Sites, Not the Issue Text

Everything under `app/` ships to Markaz, SFA, Garden, and Harvest. When adding or changing a
component parameter, **read how those apps actually call the component** before settling on the
design. There are no local checkouts, but the call sites are one command away:

```bash
gh search code "ActionButton::Component" --owner mpimedia --limit 20 \
  --json repository,path --jq '.[] | "\(.repository.nameWithOwner): \(.path)"'

gh api "repos/mpimedia/harvest/contents/<path>" --jq '.content' | base64 -d > /tmp/x.rb
```

What this catches that reasoning alone does not:

- **Defaults that make a conditional universal.** An API gated on "did the caller pass `method:`?"
  is meaningless if the caller's own wrapper supplies a default for it
- **Naming the ecosystem already settled.** If three apps have converged on a parameter name,
  adopt it rather than inventing a better one — the engine exists to absorb those local
  components, and a rename is migration friction with no user-visible payoff
- **Which call shapes are load-bearing**, so specs pin the real ones

(Reference: #136 proposed `role="button"` on any `href:` anchor and the plan narrowed it to
`href:` + `method:` present. Harvest's local component defines `DEFAULT_METHOD = :get` and passes
`method:` on *every* button, so that gate would have applied the role to 100% of its anchors —
including plain navigation links, announcing them as buttons to assistive technology. Gating on a
non-GET verb was only discoverable by reading the consumer. The same read showed Markaz and
Harvest already used `classes_append:`, which the engine adopted over the issue's `extra_classes:`.)

## Styling and Tokens

- Use Bootstrap utility and component classes — no arbitrary hex values, sizes, or spacing
- Token documentation lives in `tokens/*.md` (colors, typography, spacing, components,
  navigation, bootstrap-overrides) — consult it before choosing values

### Tokens ship through TWO pipelines — change both, verify both

There are two SCSS entry points, and a token added to one is invisible to consumers on the
other. This is the single easiest way to ship a wrong color to all four apps.

| File | Consumer path | Role |
|------|---------------|------|
| `_tokens_values.scss` | modern — `@use "mpi_design_system/tokens_values"` | Raw `$mpi-*` values, every one `!default`, **no Bootstrap dependency** |
| `_tokens.scss` | legacy — `@import "mpi_design_system/tokens"` | `@import`s the values, then maps them onto Bootstrap's `$primary`/`$success`/… |

Rules:

- **Declare the raw value in `_tokens_values.scss`, always.** `_tokens.scss` should only *map*
  (`$info: $mpi-info;`), never hardcode a value or alias another token
  (`$info: $mpi-primary;`). A value that exists only in `_tokens.scss` reaches legacy
  consumers and silently leaves modern ones on Bootstrap's default
- **Declaring it is not enough — modern consumers map tokens themselves.** Bootstrap keeps its
  own default for anything an app does not map, so a new token also needs the README's modern
  snippet and `spec/fixtures/scss/modern_use.scss` updated, or the documented path stays broken
- **Verify with `yarn build:css:compat`**, which compiles the legacy, modern, and
  `@use … with ()` override fixtures and asserts the palette reaches the compiled CSS. Adding a
  semantic token means adding its assertion. Grep the emitted custom property
  (`--bs-info: #2E75B6`), not just the hex — the hex may appear from an unrelated token
- **Prove a new build guard by breaking it.** Revert the mapping, confirm the build actually
  fails, restore. (Reference: #136 added `:info`. `$info` was hardcoded in `_tokens.scss` only,
  so modern consumers got Bootstrap's cyan `#0DCAF0` on `btn-info` — a color outside the MPI
  palette — and the engine's own `modern_use.scss` fixture demonstrated the broken path. The
  obvious guard, `! grep "#0dcaf0"`, would have false-passed forever: Bootstrap emits
  `--bs-cyan: #0dcaf0` unconditionally, independent of `$info`.) This is the build-level twin of
  the Accessibility section's "verify against an external oracle, never against itself" (#130):
  there, the risk is a check that grades its own homework; here, it is a check that never fails.
  Both are answered the same way — make the guard fail on purpose before you trust a pass.
- Custom SCSS only when Bootstrap genuinely cannot express the design; keep it in a
  dedicated partial under `app/assets/stylesheets/mpi_design_system/` (existing example:
  `_nav_bar.scss`, which styles NavBar/AppShell) and import it from `application.scss`
- **A custom partial must still be theme-adaptive — resolve colour from `var(--bs-*)`, never a
  Sass `$var`.** A Sass variable freezes one palette at compile time; a Bootstrap runtime CSS
  custom property re-resolves when `data-bs-theme` flips. `_nav_bar.scss` is the reference: after
  #154 it draws every colour from `var(--bs-body-bg)`, `var(--bs-border-color)`,
  `var(--bs-body-color)`, `var(--bs-secondary-color)`, `var(--bs-link-color)`, `var(--bs-primary)`,
  `var(--bs-danger)` and `var(--bs-tertiary-bg)` — so it has **no compile-time Sass-var
  dependency** (it compiles standalone) and adapts to the colour mode like the rest of the system.
  Interactive link *text* maps to `var(--bs-link-color)` (AA-safe in dark: `#82ACD3`), **not**
  `var(--bs-primary)` (which stays `#2E75B6` → ~3.19:1 on the dark navbar `#212529` and only ~2.75:1
  on the dark subnav `#2B3035`, both below the 4.5:1 AA/UI floor). The conversion is proven at the
  compile level by `bin/verify-nav-bar-adaptive` (run from `yarn build:css:compat`, asserting every
  colour is `var(--bs-*)`-driven) and in a browser by `spec/features/nav_bar_theme_spec.rb` — both
  proven by breaking them. When a custom partial ships hardcoded hex to the emitted markup (e.g. an
  inline SVG `fill`), that hex is frozen too: #154's logo arms had to move to `fill="currentColor"`
  (and, in #155, onto `.mds-navbar__brand-arm/-center` classes whose `fill` this partial now drives
  from `var(--bs-body-color)`/`var(--bs-link-color)`).
- **Moving a component's colour from inline to CSS makes it depend on the component partial being
  loaded — and that partial is not on the documented consumer path.** The engine ships SCSS as
  source (`lib/mpi_design_system/engine.rb` — "No asset-pipeline initializer by design"); the
  README's install snippet and the dummy app both import only `mpi_design_system/tokens` +
  Bootstrap, **not** `_nav_bar.scss` (the only component partial). So converting an inline colour
  (an SVG `fill="#…"`, an inline `style`) to token-sourced classes silently regresses to its
  fallback anywhere the partial isn't imported — including the dev Lookbook until the dummy
  stylesheet imports it. Two consequences: (1) verify the compiled colour against a stylesheet that
  *actually imports the partial* — the engine `application.scss`, or the dummy `application.scss`
  once it imports the component — **not** bare `yarn build:css`, which compiles the dummy app and
  never saw the partial; grep the specific `selector{property:value}`, since Bootstrap emits the
  token hex elsewhere (`--bs-primary: #2E75B6`). (2) Add a browser computed-style spec (the
  `contrast_demo`/`contrast_spec` pattern) asserting a *painted* value only the correct rule can
  produce — e.g. a two-tone mark whose centre must compute `var(--bs-link-color)`, since a
  `currentColor` fallback would paint it the arms' `var(--bs-body-color)`. (Reference: #155
  tokenised the NavBar mark's fills; without importing `_nav_bar.scss` in the dummy app the mark
  rendered monochrome in Lookbook, and `yarn build:css` could not see the rule at all — a grep
  guard against it would have false-passed.)
- **A partial's compile guard must pin each selector's binding, not merely that a token appears —
  and be proven by a *swap*, not only a deletion.** A guard that greps "`var(--bs-body-bg)` occurs
  somewhere" false-greens on a token *swap* (navbar↔subnav) because both tokens still appear, and
  on a raw colour in a property it never scanned (`fill`, `outline`, `box-shadow`). Parse the
  compiled `.mds-*` CSS and assert `selector{property:value}` for every rule, and reject a raw
  colour (hex/rgb/hsl/named) in *any* declaration. Prove it by swapping two valid tokens, not just
  by deleting one — a deletion-only test passes a guard that cannot tell two tokens apart.
  (Reference: #154's `bin/verify-nav-bar-adaptive` began as a token-presence check; the PR review
  caught that a navbar↔subnav swap and a `fill: red` both shipped green, so it was rewritten as a
  per-selector binding proof.)

## Stimulus Controllers

- Controllers live in `app/javascript/mpi_design_system/controllers/`
- Every controller must be registered in `controllers/index.js` inside
  `registerMpiControllers(application)` (e.g. `application.register("mpi--tag-input", TagInputController)`)
  and exported from that file — consuming apps call `registerMpiControllers` to wire up
  all engine controllers at once
- The top-level `app/javascript/mpi_design_system/index.js` re-exports
  `registerMpiControllers` and the individual controllers — keep it in sync when adding one
- No inline JavaScript in ERB templates — attach behavior via `data-controller` attributes

## Accessibility (WCAG 2.1 AA minimum)

- All interactive elements keyboard-accessible
- Appropriate ARIA roles and labels (e.g. Badge adds `aria-label` for its count)
- Contrast: 4.5:1 for normal text, 3:1 for large text — prefer Bootstrap's `text-bg-*`
  utilities, which derive an accessible foreground automatically (e.g. `text-bg-warning`
  yields dark text), rather than hand-pairing a background with a `text-*` class
- **Never hardcode a foreground next to a variable background.** Where a component must emit
  colour in an *inline style* and `text-bg-*` cannot reach, derive it with
  `MpiDesignSystem::ColorContrast.accessible_foreground(background)` — the Ruby counterpart of
  Bootstrap's `color-contrast()`. Pinning `color: #fff` beside a dynamic
  `background-color` is the exact defect #130 fixed in `AvatarCircle`, where 7 of 10 palette
  colours shipped below the AA floor (`#4EA8DE` at 2.63:1). Where the background *is* a theme
  colour, use `text-bg-*` and let Bootstrap derive it — do not reach for the Ruby helper
- **Audit `opacity`, not just `color:`.** A declared pair can be AA-clean and still fail once
  faded: `ActiveFilterBar`'s remove button paired white with `opacity: 0.8`, compositing to an
  effective `#D5E3F0` at 3.71:1. A sweep that reads only `color:` declarations will not see it
- **Verify a contrast rule against an external oracle, never against itself.** A spec asserting
  `ratio(bg, accessible_foreground(bg)) >= 4.5` calls the code under test on both sides — wrong
  luminance math agrees with itself and still ships a failure. `bin/verify-contrast-oracle`
  compiles Bootstrap's own `color-contrast()` over the palette in CI for exactly this reason
- Visible focus indicators on every focusable element

## Anti-Patterns

- Never add CSS frameworks beyond Bootstrap 5.3 (no Tailwind)
- Never invent colors, sizes, or spacing outside the tokens and Bootstrap's scale
- Never add a Stimulus controller without registering it in `registerMpiControllers`
- Never subclass a nonexistent `ApplicationComponent`
