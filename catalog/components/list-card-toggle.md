# ListCardToggle

**Category:** Component
**Issue:** #27
**Status:** Approved

## Description

View switcher toolbar that appears above list/table content in CRM views. Contains a result count, a list/card toggle button group, and a sort dropdown. Allows users to switch between list (table) and card (grid) layouts.

## Design Decisions

- **Default view:** List view is always the default (confirmed Q&A Session 001)
- **Toggle style:** Icon button group with `1px solid #DEE2E6` border, `border-radius: 6px`. Active button gets `background: #2E75B6` + white icon. Inactive button gets white background + gray icon (`#6C757D`)
- **Toggle icons:** List = `bi-list-ul`, Card = `bi-grid-3x2-gap` (Bootstrap Icons)
- **Button size:** 36px wide x 32px tall per button
- **Result count:** 14px, `#1B2A4A` text. In search context, keyword match highlighted with yellow background (`#FFF3CD`, `border-radius: 2px`)
- **Sort dropdown:** Native `<select>` styled with `font-size: 13px`, gray text, `border-radius: 6px`, `1px solid #DEE2E6` border
- **Toolbar position:** Always above the table/grid content, below any filter bars
- **Card view priority:** Lower priority than list view -- list must work first (per `tokens/components.md`)

### Sort Dropdown Options

| Option | Description |
|---|---|
| Last Engaged (default) | Most recently engaged contacts first |
| Name A--Z | Alphabetical by last name |
| Name Z--A | Reverse alphabetical |
| Date Added (newest) | Most recently created contacts first |
| Date Added (oldest) | Oldest contacts first |
| Account A--Z | Alphabetical by linked account name |
| Engagement Count | Most engaged contacts first |

*Sort options to be finalized during implementation per Badie's request.*

## Variants

| Variant | Description |
|---|---|
| **Default** | Result count + toggle + sort. No keyword highlighting |
| **Search context** | Result count with keyword match highlighting (yellow background on search term) |

## States

| State | Element | Description |
|---|---|---|
| List active | Toggle | List icon filled blue, card icon default gray |
| Card active | Toggle | Card icon filled blue, list icon default gray |
| Hover | Inactive button | Blue icon (`#2E75B6`) + light background (`#F5F7FA`) |

## Props / API

```ruby
# Admin::ListCardToggle::Component
class Admin::ListCardToggle::Component < ViewComponent::Base
  # @param result_count [Integer] Total number of results
  # @param result_label [String] Contextual label (e.g., "contacts", "accounts")
  # @param active_view [Symbol] :list (default), :card
  # @param sort_by [Symbol] Current sort option
  # @param sort_options [Array<Array>] Options for sort dropdown [[label, value], ...]
  # @param search_query [String] Optional search term for keyword highlighting
  # @param list_url [String] URL/Turbo action for list view
  # @param card_url [String] URL/Turbo action for card view
end
```

## Bootstrap Classes

- `d-flex`, `align-items-center`, `justify-content-between` -- toolbar row layout
- `d-flex`, `gap-2` -- toggle + sort grouping
- Custom `.toggle-group`, `.toggle-btn`, `.sort-select`, `.result-count`, `.result-highlight`

## Key Styles

```css
.toggle-group { display: inline-flex; border: 1px solid #DEE2E6; border-radius: 6px; overflow: hidden; }
.toggle-btn { width: 36px; height: 32px; background: #fff; color: #6C757D; border: none; }
.toggle-btn:not(:last-child) { border-right: 1px solid #DEE2E6; }
.toggle-btn.active { background: #2E75B6; color: #fff; }
.toggle-btn:hover:not(.active) { color: #2E75B6; background: #F5F7FA; }
```

## Accessibility

- Toggle buttons use `aria-pressed="true/false"` to indicate active state
- Toggle buttons have `title` attributes ("List view", "Card view") for tooltips and screen readers
- Sort dropdown is a native `<select>` element, fully keyboard accessible
- Active state communicated via `aria-pressed`, not just color

## Usage Guidelines

- **Use** above any list/table view in CRM that supports view switching (Contacts, Accounts, Engagements)
- **Use** Turbo Frames to swap content between list and card views without full page reload
- **Do not** default to card view -- list is always the default
- **Do not** hide the toggle on mobile -- both views should be available at all breakpoints
- The sort dropdown should persist the user's selection across page loads (store in session or URL params)
- Result count should update dynamically when filters change
