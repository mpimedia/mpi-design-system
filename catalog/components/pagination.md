# Pagination

**Category:** Component
**Issue:** #18
**Status:** Approved

## Description

Page navigation for list views. Shows a "Showing X–Y of Z results" summary on the left and numbered page buttons on the right. Used below DataTable and other paginated lists.

## Design Decisions

- **Layout:** Left-aligned results text + right-aligned page buttons (flexbox `justify-content-between`)
- **Theme-adaptive (#149):** the bar pins no colour. Every colour resolves from a Bootstrap
  semantic utility, so the component follows `data-bs-theme` and the consuming app's mapped
  `$primary` rather than a hardcoded light palette
- **Results text:** "Showing X–Y of Z results" in `text-primary-emphasis`, 13px. Deliberately
  **not** `text-primary` — measured at 3.19:1 against Bootstrap's dark body, below the AA floor
- **Page buttons:** 32×32px (inline), `rounded` + `border`
- **Active page:** `text-bg-primary` — Bootstrap derives the foreground with `color-contrast()`
  rather than pinning white by hand, giving 4.84:1 on the MPI primary. (`color-contrast()` is
  best-effort: it returns the highest-contrast candidate and only `@warn`s if none clears the
  floor. Every MPI theme colour clears it today — `danger` `#DC3545` is the tightest, at
  4.53:1 on white — and `bin/verify-contrast-oracle` checks Bootstrap and the Ruby helper
  still agree in CI.)
- **Inactive page:** `bg-body text-body`, so it tracks the surface it sits on
- **Arrow buttons:** `→` and `←` characters (not chevron icons)
- **First page:** No left arrow shown (arrow is absent, not disabled)
- **Last page:** No right arrow shown
- **Separator:** `border-top` above the pagination bar

## Variants

| Variant | Description |
|---|---|
| **Default** | Results text + page numbers + arrows |
| **First page** | Active page 1, right arrow only |
| **Middle page** | Left arrow + pages + right arrow |
| **Last page** | Left arrow + pages, active on last |

## States

| State | Element | Description |
|---|---|---|
| Default | Page button | `bg-body text-body` — body surface, body text, adaptive border |
| Active | Page button | `text-bg-primary border-primary` — filled primary, derived foreground |
| Gap | Ellipsis marker | `text-body-secondary`, `aria-hidden="true"`, non-interactive |

**No hover or disabled state.** The component renders no hover treatment, and it *omits*
arrows on the first and last page rather than disabling them — so there is no disabled
arrow to style. Earlier revisions of this entry documented both; they described a mockup,
not the component. (#149)

## Props / API

```ruby
# MpiDesignSystem::Admin::Pagination::Component
class MpiDesignSystem::Admin::Pagination::Component < ViewComponent::Base
  # @param current_page [Integer] Current active page (1-based)
  # @param total_pages [Integer] Total number of pages
  # @param total_count [Integer] Total number of records
  # @param per_page [Integer] Records per page (default: 25)
  # @param url_builder [Proc] Lambda that builds page URLs: ->(page) { "?page=#{page}" }
  # @param turbo_frame [String] Turbo Frame target for page loads
  # @param max_links [Integer, nil] Max page slots (numeric links + gap markers) before
  #   the middle truncates with a … gap. First and last page always show, so 7 slots on a
  #   middle page is 5 numbers + 2 gaps. nil (default) shows every page — unchanged for CRM.
  #   Set it (e.g. 7) on high-page-count lists (audit/log tables); values < 5 clamp to 5.
end
```

## Bootstrap Classes

- `d-flex`, `align-items-center`, `justify-content-between` — layout
- `gap-1` — spacing between page buttons
- `border-top` — separator above pagination
- `text-primary-emphasis` — results text
- `border rounded text-decoration-none text-bg-primary border-primary` — active page
- `border rounded text-decoration-none bg-body text-body` — inactive pages and arrows
- `text-body-secondary` — truncation gap marker

(The two page-button strings are quoted in the order the component emits them; both share
the same `border rounded text-decoration-none` base.)

## Key Styles

All colour comes from the utilities above. What remains inline is geometry with no
Bootstrap equivalent — `rounded` and `text-decoration-none` replaced the two declarations
that did have one:

```css
/* the complete set of inline styles the component emits */
.showing-text { font-size: 13px; }
.page-btn     { width: 32px; height: 32px; font-size: 13px; font-weight: 500;
                display: inline-flex; align-items: center; justify-content: center; }
.gap          { width: 32px; height: 32px; font-size: 13px;
                display: inline-flex; align-items: center; justify-content: center; }
nav           { padding-top: 12px; }  /* off Bootstrap's 4/8/16/24/48 spacer scale */
```

Measured against the compiled bundle (`spec/features/contrast_spec.rb` asserts each):

| Element | Light | Dark |
|---|---|---|
| Results text | `#122F49` on `#FFFFFF` — 13.74:1 | `#82ACD3` on `#212529` — 6.46:1 |
| Active page | `#FFFFFF` on `#2E75B6` — 4.84:1 | `#FFFFFF` on `#2E75B6` — 4.84:1 |
| Inactive page | `#1B2A4A` on `#FFFFFF` — 14.22:1 | `#DEE2E6` on `#212529` — 11.85:1 |
| Border / separator | `#DEE2E6` | `#495057` |

Under default configuration the light-mode **page buttons and separator** are pixel-identical
to the literals this replaced: `--bs-body-color` is mapped to MPI navy, `--bs-border-color` is
`#DEE2E6`, and `rounded` resolves to 6px. These now resolve from `$body-bg`, `$body-color`,
`$border-color` and `$border-radius`, which a consuming app may override — the bar following
that override is the intent, not a regression. The **results text is the one deliberate change
under default configuration** — `#2E75B6` (4.84:1) darkens to `#122F49` (13.74:1), because
`text-primary` measures 3.19:1 against Bootstrap's dark body and cannot be used on an
adaptive surface.

## Accessibility

- Wrap in `<nav aria-label="Pagination">`
- Current page: `aria-current="page"`
- Arrow buttons: `aria-label="Previous page"` / `aria-label="Next page"`
- Unavailable arrows are **omitted**, not marked `aria-disabled` — there is no disabled
  control in the accessibility tree to announce
- Gap marker: `aria-hidden="true"` — decorative, and skipped by screen readers
- Page buttons: `aria-label="Page N"`
- Results text provides context for screen readers
- Contrast holds in both colour modes because no foreground is pinned beside a variable
  background — see the measured table above, asserted in `spec/features/contrast_spec.rb`

## Usage Guidelines

- **Use** below DataTable on all paginated list views
- **Use** Turbo Frame navigation for page changes (no full page reload)
- **Default** shows all page numbers (page counts are typically small in CRM) — no ellipsis
- **On high-page-count lists** (e.g. audit/log tables, first adopted in `harvest#769`), pass `max_links:` to window the numbers with a `…` gap; first and last page stay visible
- **Do not** add a per-page selector unless explicitly requested
- The results text always shows even on single-page results ("Showing 1–6 of 6 results")
- Page buttons should be links (`<a>`) for proper URL state and back button support
