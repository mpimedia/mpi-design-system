# List View

**Category:** Layout
**Issue:** #29
**Status:** Approved

## Description

Full list view layout combining nav bar, group filter chips, sub-group filter bar, result toolbar with list/card toggle, data table, and pagination. Used for Contacts, Accounts, and Engagements list pages. The primary CRM workhorse layout.

## Design Decisions

- **Top-to-bottom flow:** Nav bar → group filter chips → sub-group filter bar (conditional) → toolbar → data table → pagination
- **Sub-group filter bar** — Appears below the group chips when a group is selected. Shows sub-groups as small pills. Selected sub-group highlighted in the parent group's color
- **Multi-group filtering** — Users can select multiple groups (OR logic). Active selections shown as removable filter pills per FilterChipBar (#19)
- **List/card toggle** — List view is default. Card toggle switches to ContactCard (#23) grid. Toggle uses icon buttons (list icon active = blue)
- **Sort dropdown** — "Sort: Last Engaged" with chevron. Options: Last Engaged, Name A–Z, Name Z–A, Date Added, Account, Engagement Count
- **Contacts vs. Accounts** — Different column structures per entity type
- **Pagination** — Uses the standard Pagination component. Default 25 per page. A per-page selector (e.g., 25/50/100) is added only when explicitly requested. "Load more" option also acceptable; Badie does not want to limit users to just 25 items
- **Tag Groups column (Accounts)** — Show group names as colored pills (not just dots). Confirmed per Badie's re-review
- **Brand mark** — Nexus SVG (not "X MARKAZ" text)

## Variants

### Contacts List

Columns: Name (avatar + name + title), Tags (dot format), Last Engagement (relative time), Account (link)

### Accounts List

Columns: Account (avatar + name), Primary Contact, Contacts (count), Tag Groups (colored pills), Health (Good/Fair/Poor badge), Last Engaged, Owner

### With Sub-Group Filter

When a group chip is selected, the sub-group bar appears with pills for each sub-category in that group. "All" is the default sub-group selection.

### With Active Filters

When search or advanced filters are applied, active filter pills appear (per FilterChipBar #19).

## Composition

```
┌─────────────────────────────────────────────┐
│ NavBar (Level 1 + Level 2)                  │
├─────────────────────────────────────────────┤
│ GROUPS: [All] [Buyers ●] [Press] [Fest]...  │
├─────────────────────────────────────────────┤
│ SUB-GROUPS: [All] [Theatrical ●] [Digital]  │  ← conditional
├─────────────────────────────────────────────┤
│ Showing 1–25 of 342    [≡][⊞] Sort: ▾      │
├─────────────────────────────────────────────┤
│ Name    │ Tags    │ Last Engaged │ Account  │
│─────────│─────────│──────────────│──────────│
│ row     │ row     │ row          │ row      │
│ row     │ row     │ row          │ row      │
├─────────────────────────────────────────────┤
│ Showing 1–25 of 342        [< 1 2 3 ... >] │
└─────────────────────────────────────────────┘
```

## Props / API

```ruby
# Admin::ListView::Component
class Admin::ListView::Component < ViewComponent::Base
  # @param entity_type [Symbol] :contacts, :accounts, :engagements
  # @param groups [Array<Hash>] Each: { name: String, count: Integer, color: String, selected: Boolean }
  # @param sub_groups [Array<Hash>] Each: { name: String, selected: Boolean } (shown when a group is selected)
  # @param total_count [Integer] Total results
  # @param current_page [Integer]
  # @param per_page [Integer] Default 25
  # @param sort_by [String] Current sort field
  # @param view_mode [Symbol] :list (default) or :card
  # Yields table content or card grid based on view_mode
end
```

## Child Components

- **NavBar** (#15) — Top navigation
- **FilterChipBar** (#19) — Group filter chips + active filter pills
- **ListCardToggle** (#27) — View toggle + sort + result count
- **DataTable** (#17) — Table content (Contacts or Accounts variant)
- **ContactCard** (#23) — Card grid content (when card view selected)
- **Pagination** (#18) — Page navigation with per-page selector

## Sub-Group Filter Bar Styles

```css
.subgroup-bar { display: flex; align-items: center; gap: 6px; padding: 8px 12px;
  background: #fff; border: 1px solid #DEE2E6; border-radius: 6px; }
.subgroup-label { font-size: 10px; font-weight: 600; text-transform: uppercase;
  letter-spacing: 0.06em; color: #6C757D; }
.subgroup-pill { padding: 3px 10px; border-radius: 999px; border: 1px solid #DEE2E6;
  background: #fff; font-size: 11px; font-weight: 500; color: #6C757D; }
.subgroup-pill.selected { border-color: [group-color]; background: [group-bg]; color: [group-color]; }
```

## Accessibility

- Group and sub-group filter bars use `role="toolbar"` with `aria-label`
- Selected filter chips use `aria-pressed="true"`
- Data table uses proper `<thead>`, `<th scope="col">` structure
- Pagination uses `<nav aria-label="Pagination">`
- Sort dropdown is keyboard-accessible
- List/card toggle buttons have descriptive `title` attributes

## Usage Guidelines

- **Use** for all CRM list pages (Contacts, Accounts, Engagements)
- **Default view** is always list (not card)
- **Contacts and Accounts have different columns** — do not use the same table structure for both
- Sub-group bar only appears when a group is selected — do not show it by default
- Per-page selector should be prominent — users should easily find it
- The tag system is evolving (see #32) — the group/sub-group structure may change
