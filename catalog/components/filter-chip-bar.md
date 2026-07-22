# FilterChipBar

**Category:** Component
**Issue:** #19
**Status:** Approved

## Description

Two filter bar patterns used in CRM list views. Group filter chips provide tag-group filtering with counts (Screen 2), and active filter pills show currently applied search/filter criteria with remove buttons (Screen 6).

## Design Decisions

- **Group chips:** Pill-shaped buttons with counts, one per tag group. "All" chip is always first
- **Selected chip:** Uses the tag group's own color (e.g., Distribution selected = orange border/background `#E8733A` / `#FEF3EC`)
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

### Group Chip Colors (Selected State)

| Group | Border/Text | Background |
|---|---|---|
| Distribution | `#E8733A` | `#FEF3EC` |
| Outreach | `#2DA67E` | `#ECF8F4` |
| Press/Festival | `#2E75B6` | `#EBF3FB` |
| Vendors | `#8B5CF6` | `#F3EFFE` |
| Finance | `#D97706` | `#FEF9EC` |
| Production | `#6366F1` | `#EEEFFE` |
| Internal | `#64748B` | `#F1F5F9` |

## Active Filter Pills

| Element | Description |
|---|---|
| Container | Horizontal flex row (`gap: 8px`) on a `.bg-body-secondary.rounded` bar — adaptive surface that follows `data-bs-theme`, replacing the pinned light `#F5F7FA` (#150) |
| Label | "ACTIVE:" in gray, ALL-CAPS, 11px |
| Pill | `.rounded-pill.text-bg-primary`, derived foreground, format: "Category: Value" |
| Remove button | `×` icon (`bi-x`), `color: inherit` at full strength — **no opacity fade** |
| Clear all | Text link after pills, clears all active filters |

## States

| State | Element | Description |
|---|---|---|
| Default | Group chip | White background, gray border (`#DEE2E6`), dark text |
| Hover | Group chip | Blue border (`#2E75B6`) |
| Selected | Group chip | Group color border + light background |
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
- Custom `.group-chip` (pill, border, padding)
- `.rounded-pill.text-bg-primary` — active pill fill and derived foreground (replaces the former custom `.active-pill`)
- `.text-body-secondary` — labels, "Clear all", "Reset all"
- `bi-x` — remove icon in active pills

## Key Styles

Labels, pills and links carry **no colour of their own** — they use Bootstrap classes so the
foreground derives from the app's palette and colour mode. Only geometry is declared. (#130)

```css
/* Labels and links: class `text-body-secondary`, no `color` declaration.
   The retired `color: #6C757D` scored 4.37:1 on $mpi-background. */
.group-label, .active-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; }
.clear-all { font-size: 13px; }

/* Active pill: classes `rounded-pill text-bg-primary`, no `background`/`color`.
   The retired literals duplicated $mpi-primary and pinned white against it. */
.active-pill { padding: 4px 10px; font-size: 12px; font-weight: 500; }

/* Group chips still declare a fixed colour PAIR (both halves pinned together, so
   they are internally coherent). Their contrast is tracked separately — all seven
   tag pairs currently fail AA. See the #130 follow-up. */
.group-chip { padding: 5px 12px; border-radius: 999px; border: 1px solid #DEE2E6; font-size: 13px; }
.group-chip.selected { border-color: #E8733A; background: #FEF3EC; color: #E8733A; }
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
