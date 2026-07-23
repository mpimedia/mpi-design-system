# Changelog

All notable changes to `mpi_design_system` are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) (pre-1.0: minor bumps may
include breaking changes).

## [Unreleased]

### Changed
- **`Admin::Dashboard` is theme-adaptive** — the CRM dashboard stopped pinning a light
  palette in inline styles; every colour the component *selects* now resolves from a
  Bootstrap semantic utility, so it follows `data-bs-theme` and the consuming app's mapped
  tokens. Widgets are `bg-body border rounded-3` (was `#fff` / `1px solid #DEE2E6`; `rounded-3`
  = `--bs-border-radius-lg` = 8px, preserving the retired radius — the StatCard #150 precedent);
  greeting/titles/names/counts are `text-body`; subtitle/timestamps/legend labels are
  `text-body-secondary`; the activity-type icon chips are `bg-#{sem}-subtle text-#{sem}-emphasis`;
  follow-up statuses are `text-danger-emphasis` / `text-warning-emphasis` / `text-body-secondary`;
  quick actions are `border bg-body text-body`. The two activity links and "View all" drop their
  colour class for Bootstrap's adaptive `--bs-link-color` (`#2E75B6` light / `#82ACD3` dark) with
  their underline restored (the DataTable #151 treatment). Five activity types map onto four
  adaptive hues (`meeting → secondary` — purple has no MPI semantic and `info` aliases to
  `primary`; `call` shares `success` with `new_contact`); the icons are `aria-hidden`, so the
  collapse conveys nothing on its own. Deliberate visible shifts, **by mode**:
  `text-danger-emphasis` is darker than `#DC3545` in light and *lighter* in dark (`#EA868F`);
  `text-body-secondary` (`#545F77`) replaces the fixed `#6C757D`; meeting's purple becomes grey.
  Proven in a real browser (`spec/features/contrast_spec.rb`) — painted value **and** ratio, both
  colour modes. The Contacts-by-Group chart's **caller-supplied** `group_data[:color]` is a
  documented data-viz passthrough, deferred to #172 — so the *rendered* Dashboard is not yet fully
  theme-adaptive. (#153 — Track 2 phase 5, epic #147.)
- **Removed (pre-1.0):** the public constants `Dashboard::Component::ACTIVITY_ICONS` and
  `FOLLOWUP_COLORS` — the two frozen hex maps the conversion replaced with `ACTIVITY_TYPES`
  (`{ icon:, variant: }`) and `FOLLOWUP_CLASSES`. Both were public Ruby constants; no consumer
  call sites were found across the MPI apps (`gh search code --owner mpimedia`).

## [0.10.0] - 2026-07-22

### Changed
- **`Admin::FilterPanel` is theme-adaptive** — the filter panel stopped pinning a light palette in
  inline styles; every converted colour now resolves from a Bootstrap semantic utility, so it
  follows `data-bs-theme` and the consuming app's mapped tokens. The `<aside>` card is
  `bg-body border` (was `#fff` / `1px solid #DEE2E6`); the panel title, section-toggle buttons, and
  option rows are `text-body` (was `#1B2A4A` = MPI navy = `--bs-body-color`, exact in light); the
  option counts and chevrons are `text-body-secondary` (was the fixed neutral grey `#6C757D`; now the
  adaptive `rgba(body-color, .75)` = `#545F77` light / `#AFB3B7` dark — the one deliberate visible
  shift, matching the #149/#150 treatment). The inter-section divider becomes a classes-only
  `<hr class="border-top opacity-100 m-0">` — the utilities are `!important`, so they override the
  `<hr>` reboot to paint a crisp `--bs-border-color` line that flips to `#495057` in dark. All
  geometry/layout/typography and the button `transparent`/`none` resets stay inline. (#152, phase 4;
  the AvatarCircle half of phase 4 is split to #169.)
- **`Admin::FilterChipBar` and `Admin::DataTable` are theme-adaptive** — both stopped pinning
  a light palette in inline styles; every colour now resolves from a Bootstrap semantic
  utility, so they follow `data-bs-theme` and the consuming app's mapped tokens. A new shared
  map, `TagChip::Component::GROUP_VARIANTS`, translates each CRM tag group onto a Bootstrap
  semantic (`press_festival`/`production`/`vendors` → `primary`, `outreach` → `success`,
  `finance` → `warning`, `distribution` → `danger`, `internal` → `secondary`). Because MPI maps
  `$info` → `$primary`, the palette offers **five** distinct adaptive hues, so the three cool
  categories collapse onto blue — an accepted trade of the smallest-blast conversion; the tag's
  always-present text label carries the identity (see `catalog/elements/tag-chip.md` § Semantic
  Mapping). Mapping:
  - **FilterChipBar** — selected chip `bg-#{sem}-subtle text-#{sem}-emphasis border border-#{sem}-subtle`
    (AA in both modes, unlike the frozen hex pairs); unselected `border bg-body text-body`; the
    active pill's `×` moved from inline `color: inherit` to `text-reset bg-transparent border-0`.
  - **DataTable** — header muted via `text-body-secondary`, its 2px separator the `border-bottom`
    utility with an inline `--bs-border-width: 2px` on the bottom edge only (`border-2` would box
    all four sides of a `.table th`); name/tag text `text-body`, title/meta `text-body-secondary`;
    the account link uses Bootstrap's default adaptive `--bs-link-color` (`#2E75B6` light,
    `#82ACD3` dark) and keeps its natural underline; cells `align-middle`.

  The tag/status **dots** are the one deliberate exception: `bg-#{sem}` reads `--bs-#{sem}-rgb`, a
  **fixed identity hue across colour modes** (decorative — the adjacent label carries the meaning,
  mirroring the nav env-bar's fixed status hues). Every variant (all five group hues, all three
  status hues) is browser-proven ≥3:1 against the **resting** row backdrop in **both** themes;
  because the dots are decorative — the text label conveys the category — the transient dip below
  3:1 on a **hovered** row (`table-hover` composites an inset shadow over the backdrop) is
  acceptable per WCAG 2.1 SC 1.4.11 and is deliberately not claimed. `TagChip`'s own rendering still uses the frozen hex pairs this
  phase; converting the remaining `GROUPS` consumers is a tracked follow-up. Both partials are
  proven in a real browser (`spec/features/contrast_spec.rb`) — painted value **and** ratio, in
  both colour modes. No public API change to the components' parameters. (#151 — Track 2 phase 3,
  epic #147)

  **Removed (internal, pre-1.0):** `DataTable::Component::STATUS_COLORS` and
  `DataTable::Component::TAG_DOT_COLORS` — the two frozen hex maps the conversion replaced with
  `STATUS_VARIANTS` and the shared `GROUP_VARIANTS`. Both were public Ruby constants; no consumer
  call sites were found. Formally breaking only if an app referenced them directly.

## [0.9.0] - 2026-07-22

### Changed
- **`Admin::StatCard`, `Admin::AvatarStack`, and `Admin::ActiveFilterBar` are theme-adaptive** —
  the three components no longer pin a light palette in inline styles; every converted colour now
  resolves from a Bootstrap semantic utility (the one documented exception is AvatarStack's
  `#64748B` chip background, which has no Bootstrap semantic equivalent — see below), so each
  follows `data-bs-theme` and the consuming app's mapped tokens. **StatCard**: the card is `bg-body border rounded-3` (was `#fff` / `1px solid #DEE2E6` /
  `border-radius: 8px` — `rounded-3` is `--bs-border-radius-lg` = 8px, so the radius is preserved),
  the label `text-body-secondary` (was `#6C757D`), the value `text-body` or, when `alert:`,
  `text-danger` (was `#1B2A4A` / `#DC3545`), and the trend `text-success-emphasis` /
  `text-danger-emphasis` / `text-body-secondary` (was `#22A06B` / `#DC3545` / `#6C757D`). The trend
  uses the `-emphasis` variants deliberately: at 12px (small text, AA 4.5:1) base `.text-success`
  (3.33:1 on the light card) and `.text-danger` (3.41:1 on the dark card) both fail the floor and
  do not follow the colour mode, while the emphasis tokens pass (7.7–13.7:1) and adapt — a contrast
  improvement, like the pilot's results text. The 32px value keeps base `.text-danger` for alerts
  (large text, AA 3:1, and semantically red in both modes). **AvatarStack**: the `+N` overflow
  chip's separator ring moves from `#fff` to `var(--bs-body-bg)`, so it tracks the surface in
  either colour mode; the chip's own `#64748B` background (`$mpi-tag-internal`, which has no
  Bootstrap semantic equivalent) and its #130-derived accessible foreground are unchanged.
  **ActiveFilterBar**: the bar surface moves from `#F5F7FA` to `bg-body-secondary rounded`, and the
  `data-bs-theme="light"` pin is removed — it existed only to freeze the light hex against a
  theme-aware label, and an adaptive surface makes it a dark-mode regression instead. **For a
  consumer that does not remap Bootstrap's defaults**, the StatCard card, border and radius are
  pixel-identical to the literals they replace, and the one deliberate light-mode shift is the
  filter-bar surface (`#F5F7FA` → `#E9ECEF`, Bootstrap's `--bs-secondary-bg`). Dark mode is new
  behaviour. ActiveFilterBar's pills, labels and remove buttons were already tokenised (#130). No
  public API change. (#150 — Track 2 phase 2, epic #147)
- **`Admin::NavBar` and `Admin::AppShell` are theme-adaptive** — `_nav_bar.scss` (which styles
  both) no longer pins a light palette in compile-time Sass variables. Every colour now resolves
  from a Bootstrap **runtime CSS custom property** (`var(--bs-*)`), so the nav follows
  `data-bs-theme` and the consuming app's mapped tokens: surfaces are `var(--bs-body-bg)` (navbar,
  sidebar) and `var(--bs-tertiary-bg)` (sub-nav, shell main, breadcrumb), borders are
  `var(--bs-border-color)`, the brand is `var(--bs-body-color)`, muted links and the gear are
  `var(--bs-secondary-color)`, and every interactive link (hover/active text and the active
  underlines) is `var(--bs-link-color)`. The env-bar strips stay `var(--bs-primary)` /
  `var(--bs-danger)` — fixed status hues. **For a consumer that does not remap Bootstrap's
  defaults, light mode is near-identical** (`--bs-body-color` maps to MPI navy `#1B2A4A`,
  `--bs-border-color` is `#DEE2E6`); the two deliberate light-mode shifts are semantic and remain
  AA — muted text `#6C757D` → `var(--bs-secondary-color)` (a muted navy) and the app-chrome
  `#F5F7FA` → `var(--bs-tertiary-bg)` (`#F8F9FA`). Dark mode is new behaviour: interactive links
  map to `var(--bs-link-color)` (`#82ACD3` in dark = AA-safe), **not** `var(--bs-primary)`, which
  stays `#2E75B6` (~3.19:1 on the dark navbar `#212529` and only ~2.75:1 on the dark subnav
  `#2B3035` — the worst surface — both below the 4.5:1 floor). The partial now has **no
  compile-time Sass-var dependency** — it compiles standalone, so consumers import it after
  Bootstrap (`@import "mpi_design_system/nav_bar";`). Geometry (heights, padding, weights, the
  avatar sizing) is byte-identical.

  Two dark-mode gaps in the rendered nav are fixed alongside the conversion:
  - **Logo** — the `NavBar` brand SVG hardcoded `fill="#1B2A4A"` on its four arms, which paint at
    ~1.09:1 (invisible) on a dark navbar. The arms now inherit `currentColor` (the brand link's
    `var(--bs-body-color)`) and the centre accent draws `var(--bs-link-color)`.
  - **SearchBar** — the search-icon prepend used `bg-white`, a white patch inside a dark navbar; it
    is now `bg-body`, which follows the colour mode.

  A compile-level guard (`bin/verify-nav-bar-adaptive`, run from `yarn build:css:compat`) asserts
  every colour in the compiled partial is `var(--bs-*)`-driven with no frozen hex, and a browser
  feature spec (`spec/features/nav_bar_theme_spec.rb`) proves every surface, foreground and the
  logo adapt and clear WCAG AA under both colour modes — both proven by breaking them. No public
  API change. (#154 — Track 2 phase 6, epic #147)

## [0.8.0] - 2026-07-21

### Changed
- **`Admin::Pagination::Component` is theme-adaptive** — the bar no longer pins a light
  palette in inline styles. Every colour now resolves from a Bootstrap semantic utility, so
  the component follows `data-bs-theme` and the consuming app's mapped `$primary`: the top
  rule is `border-top`, the results text `text-primary-emphasis`, the active page
  `text-bg-primary border border-primary rounded`, and inactive pages and arrows
  `bg-body text-body border rounded`. `border-radius: 6px` and `text-decoration: none` moved
  to `rounded` / `text-decoration-none`; the surviving inline styles are geometry only
  (32px box, 13px text, the nav's 12px top padding — 12px is off Bootstrap's spacer scale).
  **For a consumer that does not remap Bootstrap's defaults, the light-mode page buttons and
  separator are pixel-identical** to the literals they replace — `--bs-body-color` is mapped
  to MPI navy `#1B2A4A`, `--bs-border-color` is `#DEE2E6`, and `rounded` resolves to 6px.
  Note the change in kind, though: these values now come from `$body-bg`, `$body-color`,
  `$border-color` and `$border-radius`, which are **yours to override**. An app that maps
  them — say `$body-bg: $mpi-background` — will see the bar follow, which is the intent.
  The one deliberate change under default configuration is the results text, which darkens
  from `#2E75B6` (4.84:1) to `#122F49` (13.74:1) — a contrast improvement. Dark mode is new
  behaviour rather than changed behaviour.

  The results text uses `text-primary-emphasis` rather than the `text-primary` the issue
  specified: measured against the compiled bundle, `text-primary` paints `#2E75B6` on
  Bootstrap's dark body for **3.19:1**, below the 4.5:1 AA floor — the same defect
  `6062954` already fixed once in `EmptyState`. `text-primary-emphasis` measures 13.74:1
  light and 6.46:1 dark.

  No public API change: the three affected helpers are private, and no consumer couples to
  the component's colours. `spec/features/contrast_spec.rb` now proves the claim in a real
  browser — asserting the painted value as well as the ratio, because inherited body text
  clears AA in both modes and would make a ratio-only assertion a false green.
  (#149 — Track 2 phase 1, epic #147)

## [0.7.0] - 2026-07-21

### Added
- **`MpiDesignSystem::ColorContrast`** — WCAG 2.1 relative-luminance and contrast-ratio math,
  plus `accessible_foreground`, the Ruby counterpart of Bootstrap's SCSS `color-contrast()`.
  For components that must emit a foreground in an *inline style*, where `text-bg-*` cannot
  reach. Prefer `text-bg-*` whenever the background is a theme colour.
- **A contrast oracle in CI** — `spec/fixtures/scss/avatar_contrast_oracle.scss` runs
  Bootstrap's own `color-contrast()` over the avatar palette, and `bin/verify-contrast-oracle`
  (wired into `yarn build:css:compat`) fails the build if Bootstrap and the Ruby helper ever
  disagree. This exists because a contrast spec written against the helper's own `ratio`
  method would be self-referential: wrong luminance math would agree with itself and still
  ship a real failure. #128 could only produce this evidence by hand, recorded in prose.
- **`Admin::ActionButton::Component` accepts `classes_append:`** (default `nil`) — extra layout
  utility classes appended after the derived `btn`/color/size classes, so a consumer can place a
  shipped button (`float-end`, `me-2`, `w-100`) without wrapping it in a positioning `<div>` or
  forking the component. Accepts a String, a space-separated String, or an Array of Strings; all
  class composition now runs through Rails' `token_list`, which flattens, splits, rejects blanks,
  and dedupes — collapsing the previous two composition paths (the class list and the disabled-link
  string concat) into one. Omitting it is byte-identical to the prior output, so existing consumers
  see no drift. It is for layout utilities only — `btn-*`, color, and size classes conflict with the
  derived classes and are resolved by stylesheet source order, not attribute order. (#136 —
  harvest#776, harvest#778)
- **Verb-gated `role="button"` on link-styled action buttons** — an `href:` anchor carrying a
  non-GET Turbo verb (`:post`, `:put`, `:patch`, `:delete`) is an *action*, and now renders
  `role="button"` so assistive technology announces it as such; the role persists when the link is
  `disabled:`. An `href:` with `method: :get` or no method is *navigation* and deliberately renders
  no role — Harvest passes `method: :get` on every navigation button (its `DEFAULT_METHOD` is
  `:get`), so gating on the mere presence of `method:` would have mislabelled every navigation link.
  A new `role:` param makes this three-state: `nil` derives, a String overrides (covering
  anchors driven by `data:` alone — `data-bs-toggle`, a Stimulus action — with no HTTP verb),
  and `false` suppresses. Suppression exists because `role="button"` tells assistive technology
  to expect **Enter and Space** activation while a native `<a href>` activates on Enter only,
  and this component ships no Space-key handler; the derived role is still the right default
  (it matches Bootstrap's guidance for link-styled buttons), but a consumer that wants true
  link semantics can now opt out. (#136 — harvest#776, harvest#778)
- **`:info` joins the semantic color set** on `Admin::ActionButton`, `Admin::Badge`, and
  `Admin::AccountDetailPanel` (`account_type_color:`), rendering `btn-info` / `btn-outline-info` /
  `text-bg-info` in MPI blue with Bootstrap's derived foreground. Unknown colors still coerce
  silently to `:primary` — unchanged. (#136 — harvest#776, harvest#778)

### Changed
- **Visible design change:** avatars whose name hashes to one of the seven failing colours now
  render **dark initials** instead of white. The palette itself is unchanged. This reverses a
  design decision that `catalog/elements/avatar-circle.md` previously documented — the claim
  "White text on all background colors meets WCAG AA 4.5:1 contrast" was false for 7 of 10 —
  and the catalog is corrected in the same change.
- `Admin::ActiveFilterBar` / `Admin::FilterChipBar` active pills use
  `.rounded-pill.text-bg-primary` rather than a hardcoded `#2E75B6`, so they track a consumer's
  `$primary` override instead of silently desynchronising from it. Pill geometry is unchanged.

### Fixed
- **`$mpi-info` is now a real token, so `:info` is MPI blue on *both* consumer paths.** The value
  was previously hardcoded as `$info: $mpi-primary` in `_tokens.scss`, which covers only the legacy
  `@import` pipeline. Modern Sass-module consumers (`@use "mpi_design_system/tokens_values"`) had no
  `$mpi-info` to map at all, so Bootstrap's default cyan (`#0DCAF0`) reached `btn-info` /
  `text-bg-info` — a color outside the MPI palette. `_tokens_values.scss` now declares
  `$mpi-info: $mpi-primary !default` and `_tokens.scss` routes through it, so both pipelines emit
  `--bs-info: #2E75B6`, and a `@use … with ($mpi-primary: …)` override carries through to info.
  No rendered value changes for existing legacy consumers. The `build:css:compat` script now
  asserts `--bs-info` on both compiled fixtures, so a future regression fails the build rather than
  shipping cyan. (#136)
- **WCAG AA contrast in four inline-styled components** (#130) — the inline-style siblings of
  the `Badge` fix in #128. `Admin::AvatarCircle` paired a name-hashed background with a
  hardcoded `color: #fff`; **7 of its 10 palette colours failed the 4.5:1 AA floor**, worst
  among them `$mpi-brand-accent` (`#4EA8DE`) at **2.63:1** — below even the relaxed
  large-text threshold — and `$mpi-success` (`#22A06B`) at **3.33:1**, the identical pairing
  #128 had just fixed in `Badge`, still shipping in a second component. **7 of the 10 palette
  entries** failed; how that distributes over real contacts depends on the name-byte-sum hash,
  which has not been measured against consumer data. The foreground is now derived per
  background and every pairing clears AA, worst case 4.53:1.
- `Admin::ActiveFilterBar` and `Admin::FilterChipBar` — the remove button's `opacity: 0.8`
  faded white to an effective `#D5E3F0` over the pill, **3.71:1**. The opacity is gone and the
  button inherits the pill's derived foreground. A declared-pair audit misses this class of
  defect entirely, since the `color:` declaration on its own is AA-clean.
- `Admin::ActiveFilterBar` labels and "Clear all" — `#6C757D` on the `#F5F7FA` bar was
  **4.37:1**. Now Bootstrap's `.text-body-secondary` (6.14:1).
- `Admin::AvatarStack` — the "+N" overflow chip hand-copied `AvatarCircle`'s markup including
  a pinned foreground, so it would not have inherited the fix. Now derived (resolves to `#fff`,
  4.76:1 — unchanged visually, but it tracks the background rather than assuming it).

### Internal
- **The changelog release guard can now fail.** `spec/packaging/changelog_spec.rb` asserted
  `include("0.2.0")` — but a changelog keeps history, so that passed forever regardless of the
  version being released (VERSION had since reached 0.6.0). It now matches a release *heading*
  anchored to `MpiDesignSystem::VERSION`, so it re-aims at every release, plus a decoy example
  proving the guard rejects a changelog that mentions the version only in prose and in a link
  reference — the shape the old substring form accepted. (#127)
- **Repaired the link-reference block.** Only `[0.2.0]:` was defined, so the `[Unreleased]`,
  `[0.6.0]`, `[0.5.0]`, `[0.4.1]`, `[0.4.0]`, and `[0.3.0]` headings rendered as literal
  bracketed text instead of links. All six are now defined as Keep-a-Changelog compare links.
  `## 0.1.0` stays unbracketed and undefined — no tag was ever cut for it. A new spec example
  asserts every bracketed heading has a matching definition, so the block cannot silently rot
  again. (#127)
- **Named a third false-green shape in `.claude/rules/testing.md`.** "A Guard Is Not Real Until
  You Have Watched It Fail" — for every element an assertion documents as load-bearing, remove
  it and watch a test go red. #127's own fix broke that rule twice (the `^` anchor and the
  `[ \t]+` scan were both documented as load-bearing while nothing reddened without them), and
  both were caught only by execution. Joins the existing build-level and contrast-oracle twins
  in `.claude/rules/frontend.md`. (#127)

## [0.6.0] - 2026-07-17

### Added
- **`Admin::TableForIndex::Component` + `Admin::TableForIndexColumn::Component`** — a neutral,
  slot/block-based admin index & association listing table, generalizing the byte-identical
  local `Admin::TableForIndex` shared by the MPI apps (Optimus/Garden/Harvest) into the design
  system (harvest#692). The block column form — `table.with_column(header) { |record| … }` — is
  the default escape hatch, so cells can be arbitrary host HTML (links, `mail_to`, action
  buttons, badges) and the gem takes **no** Ransack/Pundit/Pagy/route-helper dependency. Headers
  accept a plain string or pre-rendered HTML (e.g. a Ransack `sort_link`) verbatim. Opt-in,
  presentation-only column keywords layer on top — `align:`/`nowrap:`/`width:` (whitelisted
  Bootstrap utilities) and `cell: :text|:boolean|:date` (`:boolean` renders the filled `Badge`).
  Empty collections render the shipped `EmptyState` with a title-derived heading and a
  monotonic heading level (`:h5` under a `title:` section, `:h3` for a bare index). Styled with
  Bootstrap utilities only — no inline hex.
- **First-class sortable headers (Ransack-free)** — a column opts in with `sortable:`/`sort_key:`,
  and the table renders the clickable header, caret, and `aria-sort` from a host-supplied
  `sort_url: ->(key, dir) { … }` lambda plus `current_sort_key:`/`current_sort_dir:`. The gem
  never imports a sort backend. A pre-rendered `sort_link` passed as the header still works, so
  consumers adopt mechanically first and opt into first-class sorting later.
- **Batch selection** — opt-in via `batch:` (checkbox toggle + per-row `ids[]` column) plus the
  `Admin::BatchActionButton` / `Admin::BatchActionModalButton` slot components, driven by a new
  `mpi--batch-actions` Stimulus controller (generalized from SFA's working implementation) that
  `registerMpiControllers` registers. The consuming app owns the `<form>` (submit URL + route +
  authorization); the gem owns the checkbox UI, the button/modal slots, and the controller
  behavior. (harvest#692, folds in harvest#768's dead-code cleanup on the consumer side.)

## [0.5.0] - 2026-07-16

Adds opt-in link **windowing** to `Admin::Pagination`, driven by the first real high-page-count
adoption (Harvest's admin log/audit tables — `harvest#769`, epic `harvest#692`). The component
previously rendered *every* page number — fine for small CRM lists, but it dumps thousands of
links on deep tables. The default is unchanged (all pages shown), so existing consumers are
unaffected.

### Added
- **`Admin::Pagination::Component` accepts `max_links:`** (default `nil`) — the maximum number of
  page *slots* (numeric links plus `…` gap markers) to render before the middle truncates. Page 1
  and the last page are always visible, so e.g. 7 slots on a middle page is 5 numbers + 2 gaps;
  the window stays centered on the current page (values `< 5`, including `0`/negative, are treated
  as `5`, and even values round down to odd for symmetry). `nil` is the only "unlimited" value; it
  or a value `>= total_pages` renders every page — the prior behavior. (harvest#769, epic harvest#692)

### Changed
- **The pagination button row now wraps (`flex-wrap`)** so a windowed row degrades gracefully on
  narrow viewports instead of forcing horizontal overflow. (harvest#769)

## [0.4.1] - 2026-07-16

Patch release delivering the `Admin::Badge` filled-contrast fix, so consumers (Harvest —
epic `harvest#692`) can retire the copied 3.33:1 badge instead of patching it downstream.
Badge-fix-only — the sole change on `main` since v0.4.0.

### Fixed
- **`Admin::Badge::Component` filled variant now derives its foreground via Bootstrap's
  `text-bg-*` utility instead of a hand-maintained `text-white`/`text-dark` table.** The
  `:success` badge rendered white on `$mpi-success` (`#22A06B`) at **3.33:1**, failing WCAG
  AA; it now derives `#000` at **6.31:1**. `:primary`/`:secondary`/`:danger` are unchanged
  (white); `:warning` shifts from `#212529` to `#000` (both AA-pass) and its special-case is
  removed. The public API (constructor, accepted colors) is unchanged, so consumers inherit
  the fix on upgrade with no code change. (#128, #129 — harvest#692)

## [0.4.0] - 2026-07-14

Tokenizes `Admin::BreadcrumbNav::Component` — the second component change driven by real
adoption feedback (Harvest `#738`, epic `harvest#692` Phase 3), following the same
Bootstrap-utility approach `EmptyState` took in v0.3.0. Removes the last inline-hex seam
standing between the breadcrumb and consumer-configured palettes, and marks the
current-page element with `aria-current="page"`.

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

  Three deliberate deltas, all accepted rather than shipped quietly:
  - **Container padding is `py-2` (`.5rem`/8px) against the previous 12px.** Bootstrap's
    spacer scale is 4/8/16/24/48; 12px is not expressible without custom SCSS, which would
    require every consumer to opt into importing an engine stylesheet.
  - **The separator color changes.** `text-body-secondary` is `rgba($body-color, .75)`, not
    `#6C757D`. Against the engine's navy `$body-color` it composites to a navy-tinted gray —
    on-brand, and measurably better: **4.53:1 (WCAG AA)** on a `#c2c2c2` header versus
    `#6C757D`'s 2.63:1 (fail).
  - **The separator is ≈12.25px, not exactly 12px.** Nested `.small` compounds (`.875em` of
    the nav's already-`.875em`), landing near — but not on — the original value.

  Sizing is now **relative rather than fixed**: `gap-2`/`gap-1` are `rem`-based and `.small`
  is `em`-based, so the 8px/4px/14px equivalences above hold against a 16px root and an
  unscaled parent. This is the intended trade — it's what lets the component respond to a
  consumer's type scale instead of pinning pixels — but it is a behavioral change from the
  fixed-pixel inline styles, not a pure refactor.

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

[Unreleased]: https://github.com/mpimedia/mpi-design-system/compare/v0.10.0...HEAD
[0.10.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/mpimedia/mpi-design-system/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/mpimedia/mpi-design-system/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/mpimedia/mpi-design-system/releases/tag/v0.2.0
