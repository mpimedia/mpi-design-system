# Changelog

All notable changes to `mpi_design_system` are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) (pre-1.0: minor bumps may
include breaking changes).

## [Unreleased]

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
