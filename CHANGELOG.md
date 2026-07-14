# Changelog

All notable changes to `mpi_design_system` are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) (pre-1.0: minor bumps may
include breaking changes).

## [Unreleased]

### Changed
- **`Admin::BreadcrumbNav::Component` is now class/token-based.** Replaced every inline
  `style=` attribute and literal hex color (`#2E75B6`, `#6C757D`, `#1B2A4A`) with Bootstrap
  5.3 utility classes, mirroring the already-tokenized `EmptyState` (#121) and `Badge`.
  Removed the `container_styles`, `back_link_styles`, `separator_styles`, and `title_styles`
  private methods. The public API (`back_path:`, `back_label:`, `current_title:`) is
  unchanged — no consumer break. (#124, harvest#738 — epic harvest#692 Phase 3)

  The back link and current title deliberately carry **no** color class: they inherit
  `--bs-link-color` (`$link-color`, default `$primary`) and `--bs-body-color`
  (`$body-color` → `$mpi-text`), so the component resolves against each consumer's
  configured palette instead of a constant — and stays color-mode-adaptive for free.

  Two deliberate deltas, both accepted rather than shipped quietly:
  - **Container padding is `py-2` (`.5rem`/8px) against the previous 12px.** Bootstrap's
    spacer scale is 4/8/16/24/48; 12px is not expressible without custom SCSS, which would
    require every consumer to opt into importing an engine stylesheet.
  - **The separator color changes.** `text-body-secondary` is `rgba($body-color, .75)`, not
    `#6C757D`. Against the engine's navy `$body-color` it composites to a navy-tinted gray —
    on-brand, and measurably better: **4.53:1 (WCAG AA)** on a `#c2c2c2` header versus
    `#6C757D`'s 2.63:1 (fail). Separator *size* is preserved: nested `.small` compounds to
    ≈12.25px against the original 12px.

### Added
- **`Admin::BreadcrumbNav::Component` marks its current-page element with `aria-current="page"`.**
  The breadcrumb's current title now announces as the current page to assistive technology.
  (#124)

## [0.3.0] - 2026-07-14

Tokenizes `Admin::EmptyState::Component` — the first component change driven by real
adoption feedback (Harvest `#736`, epic `harvest#692` Phase 5). Removes the inline-hex
seam the component shipped with and makes its heading level configurable so consumers can
compose it under their own section headings.

### Added
- **`Admin::EmptyState::Component` gains a `heading_level:` parameter** (`:h1`–`:h6`,
  default `:h3`; invalid values fall back to `:h3`). Consumers can place the empty state
  under an existing section heading without a backward heading-level jump (e.g. `:h5`
  beneath a show-page `<h4>`). The visual size is held constant (`fs-5`) regardless of the
  chosen semantic level. (#121, harvest#736 — epic harvest#692 Phase 5)

### Changed
- **`Admin::EmptyState::Component` is now class/token-based.** Replaced every inline `style=`
  attribute and literal hex color (`#F5F7FA`, `#1B2A4A`, `#4EA8DE`, `#6C757D`, `#DEE2E6`,
  `#2E75B6`) with Bootstrap 5.3 utility classes that resolve against each consumer's
  configured palette (`bg-body-tertiary`, `text-primary`, `text-muted`, `rounded-3`, `p-5`,
  `fs-1`, `fs-5`, `fw-semibold`, `border`, `bg-body`, `text-decoration-none`, …), mirroring
  the already class-based `Badge`. Shortcut cards use the color-mode-aware `bg-body` (not a
  fixed `bg-white`) so they stay legible under Bootstrap dark mode, and the description /
  shortcut-cluster measures that were inline `max-width`s are now held by the responsive
  grid. No consumer-visible API change beyond the additive `heading_level:` parameter.
  Consuming specs that asserted the inline-hex seam (e.g. `div[style*='#F5F7FA']`) must
  re-point onto the class markers. (#121, harvest#736)

## [0.2.0] - 2026-07-02

First release cut to prepare the engine for its first real adoption (Harvest — see
`mpimedia/harvest#692`). Delivers the #103 "prepare engine for first adoption" epic:
component namespacing, a corrected asset-delivery contract, and preview-render fixes.
No app depended on the engine at release time, so these packaging corrections land
before the first consumer locks them in.

### Changed (breaking)
- **Components re-namespaced** from the bare top-level `Admin::` to `MpiDesignSystem::Admin::`
  (all 33 components), and Stimulus controller identifiers prefixed with `mpi--`
  (e.g. `mpi--tag-input`). This removes a hard constant/identifier collision with consuming
  apps. Consumers must reference `MpiDesignSystem::Admin::<Name>::Component`. (#109, #103)
- **Asset-delivery contract corrected to alias-only.** The engine no longer attempts to
  vendor Bootstrap; consuming apps compile Bootstrap SCSS against their own npm `bootstrap`
  package via a dart-sass `--load-path`. SCSS tokens are split into `_tokens_values.scss` so
  modern `@use`-based consumers get a values-only fallback alongside the legacy `@import`
  path. (#114, #103)

### Removed
- **`bootstrap` runtime dependency dropped from the gemspec** — nothing in the engine loads
  the Ruby `bootstrap` gem (Bootstrap is delivered via each app's npm package), so forcing it
  into every consumer's bundle was redundant. (#114, #103)

### Fixed
- **Two Lookbook preview render defects** surfaced by the namespace rename: the Dashboard
  preview passed a nonexistent `trend:` kwarg to `StatCard` (→ `trend_text:`), and the
  `tag_input` dropdown's inline style was missing a `;`, leaving the empty dropdown visible on
  initial load. (#116, #111)

### Added
- **Enforcing preview-render sweep** (`spec/components/previews/preview_rendering_spec.rb`) —
  renders every Lookbook preview scenario and fails if any raises, closing the blind spot that
  let the two defects above ship green (previews were eager-loaded but never rendered). (#116, #111)
- **Browser-level feature spec** for the `mpi--tag-input` Stimulus controller, proving
  hidden-on-load via computed style. (#116, #111)

### Internal
- DB-free CI (RuboCop, RSpec eager-load + browser, JS build) with `.tool-versions`. (#104, #103)
- Regenerated `yarn.lock` for Yarn 4.17.0 (lockfile v9 → v10). (#115)
- Reconciled `.claude/rules/testing.md` with the preview-render sweep and two testing gotchas. (#118, #117)

## 0.1.0

Initial internal version: the ViewComponent library, design tokens, Stimulus controllers,
and Lookbook previews, prior to the adoption-prep packaging corrections above. (No release
tag was cut for 0.1.0.)

[0.2.0]: https://github.com/mpimedia/mpi-design-system/releases/tag/v0.2.0
