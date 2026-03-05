# FilterChipBar

**Category:** Component
**Issue:** #19
**Status:** Approved

## Description

Two filter bar patterns used in CRM list views. Group filter chips provide tag-group filtering with counts (Screen 2), and active filter pills show currently applied search/filter criteria with remove buttons (Screen 6).

## Design Decisions

- **Group chips:** Pill-shaped buttons with counts, one per tag group. "All" chip is always first
- **Selected chip:** Uses the tag group's own color (e.g., Distribution selected = orange border/background `#E8733A` / `#FEF3EC`)
- **Active pills:** Filled primary blue (`#2E75B6`) pills with white text and `×` remove button
- **Labels:** ALL-CAPS prefix labels — "GROUPS:" and "ACTIVE:" — in gray, 11px, `font-weight: 600`
- **Clear all:** Text link after active pills, gray by default, blue on hover
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
| Press | `#2DA67E` | `#ECF8F4` |
| Press/Festival | `#2E75B6` | `#EBF3FB` |
| Vendors | `#8B5CF6` | `#F3EFFE` |
| Finance | `#D97706` | `#FEF9EC` |
| Production | `#6366F1` | `#EEEFFE` |
| Internal | `#64748B` | `#F1F5F9` |

## Active Filter Pills

| Element | Description |
|---|---|
| Container | Horizontal flex row with `gap-2` |
| Label | "ACTIVE:" in gray, ALL-CAPS, 11px |
| Pill | Filled blue (`#2E75B6`), white text, format: "Category: Value" |
| Remove button | `×` icon (`bi-x`), opacity 0.8 → 1.0 on hover |
| Clear all | Text link after pills, clears all active filters |

## States

| State | Element | Description |
|---|---|---|
| Default | Group chip | White background, gray border (`#DEE2E6`), dark text |
| Hover | Group chip | Blue border (`#2E75B6`) |
| Selected | Group chip | Group color border + light background |
| Default | Active pill | Filled blue, white text |
| Hover | Pill remove | `×` opacity increases to 1.0 |

## Props / API

```ruby
# Admin::FilterChipBar::Component
class Admin::FilterChipBar::Component < ViewComponent::Base
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
- Custom `.group-chip` (pill, border, padding)
- Custom `.active-pill` (filled blue, white text)
- `bi-x` — remove icon in active pills

## Key Styles

```css
.group-label, .active-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: #6C757D; }
.group-chip { padding: 5px 12px; border-radius: 999px; border: 1px solid #DEE2E6; font-size: 13px; }
.group-chip.selected { border-color: #E8733A; background: #FEF3EC; color: #E8733A; }
.active-pill { padding: 4px 10px; border-radius: 999px; background: #2E75B6; color: #fff; font-size: 12px; }
.clear-all { font-size: 13px; color: #6C757D; }
```

## Accessibility

- Group chips: Use `role="group"` with `aria-label="Filter by group"`
- Active chip: `aria-pressed="true"` on selected group chip
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
