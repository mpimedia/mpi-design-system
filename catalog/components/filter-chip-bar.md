# FilterChipBar

**Category:** Component
**Issue:** #19
**Status:** Approved

## Description

Two filter bar patterns used in CRM list views. Group filter chips provide tag-group filtering with counts (Screen 2), and active filter pills show currently applied search/filter criteria with remove buttons (Screen 6).

## Design Decisions

- **Group chips:** Pill-shaped buttons with counts, one per tag group. "All" chip is always first
- **Selected chip:** Renders the group's **Bootstrap semantic** surface via `GROUP_VARIANTS`
  (#151) — `bg-#{sem}-subtle text-#{sem}-emphasis border border-#{sem}-subtle rounded-pill`.
  These derive from `--bs-*`, so the chip follows `data-bs-theme` and clears AA in both colour
  modes (unlike the frozen hex pairs it replaced). Distribution → `danger` (red), Outreach →
  `success` (green), Finance → `warning` (amber); the three cool categories collapse onto
  `primary` (blue) because MPI maps `$info` → `$primary`. See `catalog/elements/tag-chip.md` §
  Semantic Mapping
- **Unselected chip:** Neutral adaptive surface — `border bg-body text-body rounded-pill`
- **Active pills:** Filled primary pills using Bootstrap's `.rounded-pill.text-bg-primary`, whose background *and* foreground derive from the app's configured `$primary`. Do not hardcode `#2E75B6` — a literal desynchronises the moment a consumer overrides the token (every token is `!default`). The `×` remove button inherits the derived foreground (#130)
- **Labels:** ALL-CAPS prefix labels — "GROUPS:" and "ACTIVE:" — 11px, `font-weight: 600` (`FilterChipBar`) / `700` (`ActiveFilterBar`), colored by Bootstrap's `.text-body-secondary` rather than a pinned gray
- **Clear all:** Text link after active pills, `.text-body-secondary`. Note it does **not**
  turn blue on hover as this doc previously claimed — `.text-body-secondary` sets `color` with
  `!important`, so a hover colour would need its own utility or rule
- **Groups → Tags rethink:** Tracked in #32, does not block this component's implementation

## Variants

| Variant | Description | Source |
|---|---|---|
| **Group Filter Chips** | Horizontal row of tag group pills with counts | Screen 2 (Contact List) |
| **Active Filter Pills** | Applied filter criteria with `×` remove buttons | Screen 6 (Search Results) |

## Group Filter Chips

| Element | Description |
|---|---|
| Container | Horizontal flex row with `gap-2`, wraps on small screens |
| Label | "GROUPS:" in gray, ALL-CAPS, 11px |
| "All" chip | Shows total count, always first, neutral border |
| Group chip | Pill with group name + count (e.g., "Distribution 342") |
| Selected chip | Border + background in group's color pair |

### Group Chip Colors (Selected State) — `GROUP_VARIANTS` (#151)

Post-#151 the selected chip no longer pins the group's frozen hex pair. It renders the
group's Bootstrap **semantic** subtle/emphasis utilities, which adapt to `data-bs-theme`:

| Group | Semantic | Utilities |
|---|---|---|
| Distribution | `danger` | `bg-danger-subtle text-danger-emphasis border-danger-subtle` |
| Outreach | `success` | `bg-success-subtle text-success-emphasis border-success-subtle` |
| Finance | `warning` | `bg-warning-subtle text-warning-emphasis border-warning-subtle` |
| Press/Festival | `primary` | `bg-primary-subtle text-primary-emphasis border-primary-subtle` |
| Production | `primary` | `bg-primary-subtle text-primary-emphasis border-primary-subtle` |
| Vendors | `primary` | `bg-primary-subtle text-primary-emphasis border-primary-subtle` |
| Internal | `secondary` | `bg-secondary-subtle text-secondary-emphasis border-secondary-subtle` |

A selected chip whose group is unknown/absent falls back to the unselected neutral surface
(`bg-body text-body`). Exact painted values are proven in `spec/features/contrast_spec.rb`.

## Active Filter Pills

| Element | Description |
|---|---|
| Container | Horizontal flex row (`gap: 8px`) on a `.bg-body-secondary.rounded` bar — adaptive surface that follows `data-bs-theme`, replacing the pinned light `#F5F7FA` (#150) |
| Label | "ACTIVE:" in gray, ALL-CAPS, 11px |
| Pill | `.rounded-pill.text-bg-primary`, derived foreground, format: "Category: Value" |
| Remove button | `×` icon (`bi-x`), `text-reset bg-transparent border-0` — inherits the pill's derived foreground at full strength, **no opacity fade** (#151) |
| Clear all | Text link after pills, clears all active filters |

## States

| State | Element | Description |
|---|---|---|
| Default | Group chip | Adaptive body surface — `bg-body text-body border` (border colour from `--bs-border-color`) |
| Selected | Group chip | Group's semantic `-subtle` surface + `-emphasis` text via `GROUP_VARIANTS` (#151) |
| Default | Active pill | Filled primary, derived foreground |
| Hover | Pill remove | No opacity change — the retired `opacity: 0.8` faded the foreground to 3.71:1, below the AA floor (#130) |

## Props / API

```ruby
# MpiDesignSystem::Admin::FilterChipBar::Component
class MpiDesignSystem::Admin::FilterChipBar::Component < ViewComponent::Base
  # @param groups [Array<Hash>] Group chip data:
  #   [{ label: "All", count: 2307 },
  #    { label: "Distribution", count: 342, group: :distribution, selected: true }]
  # @param active_filters [Array<Hash>] Active filter pill data:
  #   [{ category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" },
  #    { category: "Group", value: "Distribution", remove_url: "/contacts?remove=group" }]
  # @param clear_all_url [String] URL to clear all active filters
end
```

## Bootstrap Classes

- `d-flex`, `align-items-center`, `flex-wrap`, `gap-2` — layout
- `.bg-body-secondary.rounded` — the `ActiveFilterBar` surface (adaptive, replaces the pinned light `#F5F7FA`; `.rounded` == `--bs-border-radius` == the retired 6px) (#150)
- `rounded-pill d-inline-block text-decoration-none` — group chip shape (geometry-only inline style: 5px/12px padding, 13px, weight 500)
- Selected chip: `bg-#{sem}-subtle text-#{sem}-emphasis border border-#{sem}-subtle` via `GROUP_VARIANTS` (#151)
- Unselected chip: `border bg-body text-body`
- `.rounded-pill.text-bg-primary` — active pill fill and derived foreground (replaces the former custom `.active-pill`)
- `.text-reset.bg-transparent.border-0` — active pill's `×` remove button (inherits the pill's derived foreground; #151)
- `.text-body-secondary` — labels, "Clear all", "Reset all"
- `bi-x` — remove icon in active pills

## Key Styles

Labels, pills, links **and group chips** carry **no colour of their own** — they use Bootstrap
classes so every colour derives from the app's palette and colour mode. Only geometry is
declared. (#130 tokenised the labels/pill; #151 tokenised the group chips and the pill's `×`.)

```css
/* Labels and links: class `text-body-secondary`, no `color` declaration.
   The retired `color: #6C757D` scored 4.37:1 on $mpi-background. */
.group-label, .active-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; }
.clear-all { font-size: 13px; }

/* Active pill: classes `rounded-pill text-bg-primary`, no `background`/`color`.
   The retired literals duplicated $mpi-primary and pinned white against it.
   Its `×` button: classes `text-reset bg-transparent border-0`, geometry only. */
.active-pill { padding: 4px 10px; font-size: 12px; font-weight: 500; }

/* Group chips carry NO colour of their own after #151 — geometry is the only inline
   style; every colour comes from a Bootstrap semantic utility, so the chip tracks
   data-bs-theme. Selected -> the group's -subtle/-emphasis family (AA in both modes);
   unselected -> bg-body text-body. Classes shown, not the pinned hex they replaced. */
.group-chip           { padding: 5px 12px; font-size: 13px; font-weight: 500; } /* + rounded-pill d-inline-block text-decoration-none */
/* .group-chip.selected  -> bg-#{sem}-subtle text-#{sem}-emphasis border border-#{sem}-subtle */
/* .group-chip:not(.selected) -> border bg-body text-body */
```

## Accessibility

- Group chips: Use `role="group"` with `aria-label="Filter by group"`
- Selected group chip: the shipped component marks a selected **link** chip with
  `aria-current="page"`, not `aria-pressed` (which belongs on a toggle button, not an anchor).
  A selected chip rendered **without** an `href` currently carries no programmatic state at all
  — a real gap, tracked in the #130 follow-up rather than changed here
- Active pills: Remove button needs `aria-label="Remove filter: [Category]: [Value]"`
- Clear all: `aria-label="Clear all filters"`
- Filter changes should announce results count via `aria-live="polite"`

## Usage Guidelines

- **Use** group filter chips on the main contact list view (Screen 2)
- **Use** active filter pills on search results and filtered views (Screen 6)
- **Use** both together when applicable — group chips above, active pills below
- **Do not** show active filter pills when no filters are applied
- **Do not** show "Clear all" with only one active filter (still shown in design but optional)
- Composes with SearchBar above and DataTable below
- Filter interactions use Turbo Frame navigation for instant updates
