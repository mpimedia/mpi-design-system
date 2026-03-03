# EmptyState

**Category:** Component
**Issue:** #20
**Status:** Approved

## Description

Empty state shown when no results or content is present. Features a centered icon, heading, description text, and optional CTA button or quick-access shortcut cards. Used in search initial states, empty lists, and empty tab panels.

## Design Decisions

- **Background:** Light gray (`#F5F7FA`) rounded container, centered content
- **Icon:** Large (40px) Bootstrap Icon in brand accent (`#4EA8DE`)
- **Heading:** 18px, `font-weight: 600`, brand navy (`#1B2A4A`)
- **Description:** 14px, muted (`#6C757D`), max-width 420px, centered
- **Shortcut cards:** 2×2 grid of clickable cards for search initial state (Screen 5)
- **CTA button:** Primary blue button for actionable empty states

## Variants

| Variant | Description | Source |
|---|---|---|
| **Search Initial** | Icon + heading + description + 4 shortcut cards | Screen 5 |
| **No Results** | Icon + heading + description + "Clear filters" button | After search returns nothing |
| **Generic Empty** | Icon + heading + description + action button | Empty list/tab content |

### Shortcut Cards (Search Initial State)

| Card | Title | Description |
|---|---|---|
| 1 | Buyers — no engagement in 30 days | Follow-up candidates |
| 2 | Press — all critics | Online + print journalists |
| 3 | Festival contacts — EFM Berlin | Recent market contacts |
| 4 | Recently added | Last 7 days |

These are configurable quick-access saved searches, not hardcoded.

## States

| State | Description |
|---|---|
| Default | Centered content on light background |
| Shortcut hover | Card border turns blue (`#2E75B6`) |

## Props / API

```ruby
# Admin::EmptyState::Component
class Admin::EmptyState::Component < ViewComponent::Base
  # @param icon [String] Bootstrap Icon class (e.g., "bi-search", "bi-inbox")
  # @param heading [String] Heading text
  # @param description [String] Description text
  # @param action_label [String] Optional CTA button text
  # @param action_url [String] Optional CTA button URL
  # @param action_icon [String] Optional icon for CTA button (e.g., "bi-plus-lg")
  # @param shortcuts [Array<Hash>] Optional shortcut cards:
  #   [{ title: "Buyers — no engagement", description: "Follow-up candidates", href: "#" }]
end
```

## Bootstrap Classes

- `text-center` — centered content
- `row g-3`, `col-6` — 2×2 shortcut card grid
- `btn btn-sm` with primary blue — CTA button
- `card` / custom `.shortcut-card` — clickable shortcut cards
- `bi-search`, `bi-inbox`, `bi-journal-text` — common empty state icons

## Key Styles

```css
.empty-area { background: #F5F7FA; border-radius: 8px; padding: 60px 40px; text-align: center; }
.empty-icon { font-size: 40px; color: #4EA8DE; }
.empty-heading { font-size: 18px; font-weight: 600; color: #1B2A4A; }
.empty-text { font-size: 14px; color: #6C757D; max-width: 420px; line-height: 1.5; }
.shortcut-card { background: #fff; border: 1px solid #DEE2E6; border-radius: 8px; padding: 16px; }
.shortcut-card:hover { border-color: #2E75B6; }
.shortcut-title { font-size: 14px; font-weight: 600; color: #2E75B6; }
.shortcut-desc { font-size: 12px; color: #6C757D; }
```

## Accessibility

- Icon is decorative — use `aria-hidden="true"`
- Heading should be the appropriate heading level for the page context (`h2`, `h3`, etc.)
- Shortcut cards are links — must be keyboard focusable with visible focus indicator
- CTA button follows standard ActionButton accessibility requirements
- Use `aria-label` on the shortcut card section if cards are present

## Usage Guidelines

- **Use** search initial variant on the CRM search page before any query is entered
- **Use** no results variant when a search/filter returns zero results
- **Use** generic empty variant in tabs and lists that have no content yet
- **Do not** show empty state when data is loading — show a loading indicator instead
- **Do not** leave empty states without guidance — always include a description and ideally an action
- Shortcut cards are saved-search links and should be configurable per section
- CTA button should use the primary action for that context (e.g., "Log engagement", "Add contact")
