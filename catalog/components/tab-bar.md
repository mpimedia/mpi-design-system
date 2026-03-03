# TabBar

**Category:** Component
**Issue:** #16
**Status:** Approved

## Description

Horizontal tab navigation with optional counts, used for switching between content panels within a page. Two styles: underline tabs (default for content sections) and pill tabs (used in account detail and similar contexts).

## Design Decisions

- **Count format:** Parenthetical — `(47)` — confirmed as the standard format for tab counts
- **Underline style:** 2px bottom border in primary blue (`#2E75B6`) for active tab
- **Pill style:** Filled primary blue background with white text for active pill tab
- **Font size:** 14px for underline tabs, 13px for pill tabs
- **Active weight:** `font-weight: 600` on active tab, 500 on inactive
- **In-panel tabs:** Underline tabs work inside cards/panels (e.g., Contact Detail right panel with Engagements / Data Quality)

## Variants

| Variant | Description | Source |
|---|---|---|
| **Underline** | Bottom border active indicator. Default for content panels | Content Detail, Engagement Detail |
| **Pill** | Rounded pill buttons with filled active state | Account Detail (Screen 9) |
| **In-panel** | Underline tabs inside a card or panel | Contact Detail right panel (Screen 1) |

## Tab Configurations (from Figma)

| Context | Tabs |
|---|---|
| Content Detail | Metadata, Archive Files (47), Delivery Tracking, Press (8), Awards (12), Rights & Avails |
| Engagement Detail | Content, Thread (4), Activity Log |
| Account Detail (pills) | Contacts (7), Engagements (34), Titles (12) |
| Contact Detail Panel | Engagements, Data Quality |

## States

| State | Description |
|---|---|
| Default | Gray text (`#6C757D`), no underline/fill |
| Hover | Primary blue text (`#2E75B6`) |
| Active (underline) | Primary blue text + bold + 2px blue bottom border |
| Active (pill) | White text on primary blue background |
| With Count | Count in parentheses after label — `(47)` |
| Disabled | Light gray text (`#CED4DA`), `cursor: not-allowed` |

## Props / API

```ruby
# Admin::TabBar::Component
class Admin::TabBar::Component < ViewComponent::Base
  # @param tabs [Array<Hash>] Tab definitions:
  #   [{ label: "Metadata", href: "#", active: true },
  #    { label: "Archive Files", href: "#", count: 47 },
  #    { label: "Disabled", href: "#", disabled: true }]
  # @param variant [Symbol] :underline (default), :pill
  # @param size [Symbol] :md (default), :sm (for in-panel use)
end
```

## Bootstrap Classes

### Underline Variant
- Custom `.tab-bar` container with `border-bottom: 1px solid #DEE2E6`
- `.tab-link` items with `border-bottom: 2px solid transparent`
- Active: `border-bottom-color: #2E75B6`

### Pill Variant
- `d-flex gap-2` container
- `.pill-tab` with `border-radius: 999px`, `border: 1px solid #DEE2E6`
- Active: `background: #2E75B6`, `color: #fff`, `border-color: #2E75B6`

## Key Styles

```css
.tab-link { color: #6C757D; font-size: 14px; font-weight: 500; padding: 10px 16px; border-bottom: 2px solid transparent; }
.tab-link.active { color: #2E75B6; font-weight: 600; border-bottom-color: #2E75B6; }
.tab-link .count { font-size: 12px; color: #6C757D; margin-left: 4px; }
.pill-tab { padding: 6px 16px; border-radius: 999px; font-size: 13px; border: 1px solid #DEE2E6; }
.pill-tab.active { background: #2E75B6; color: #fff; }
```

## Accessibility

- Use `role="tablist"` on the container
- Each tab: `role="tab"`, `aria-selected="true|false"`, `aria-controls="panel-id"`
- Tab panels: `role="tabpanel"`, `aria-labelledby="tab-id"`
- Arrow keys navigate between tabs, Enter/Space activates
- Disabled tabs: `aria-disabled="true"`, `tabindex="-1"`

## Usage Guidelines

- **Use** underline tabs for switching between content panels on detail pages
- **Use** pill tabs for compact tab bars in card-like contexts (Account Detail)
- **Use** in-panel variant for tabs inside cards (Contact Detail right panel)
- **Use** parenthetical count format `(47)` when showing record counts
- **Do not** use tabs for primary navigation — use NavBar instead
- **Do not** nest tab bars — one level of tabs per panel
- Tab content should load via Turbo Frames for smooth transitions
