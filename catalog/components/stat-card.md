# StatCard

**Category:** Component
**Issue:** #21
**Status:** Approved

## Description

Top-level metric card for dashboards. Displays an ALL-CAPS label, a large number, and a trend indicator with directional arrow. Used in the CRM Dashboard (Screen 7) as a row of 4 cards.

## Design Decisions

- **Visible borders:** Cards have `border: 1px solid #DEE2E6` — confirmed, not borderless
- **Label style:** ALL-CAPS, 11px, `font-weight: 600`, `letter-spacing: 0.06em`, gray (`#6C757D`)
- **Number size:** 32px, `font-weight: 700`, brand navy (`#1B2A4A`) — or danger red for alerts
- **Trend indicators:** Arrow icon + descriptive text below the number
- **Background:** White card on `#F5F7FA` page background
- **Border radius:** 8px

## Variants

| Variant | Description | Example |
|---|---|---|
| **Positive Trend** | Green arrow up + green text | "↑ 34 this month" |
| **Negative/Alert** | Red number + red arrow/text | "12" in red, "↑ 3 since yesterday" in red |
| **Neutral** | Gray trend text, no arrow | "8 added this month" |
| **Percentage** | Green arrow + percentage | "↑ 12% vs last week" |

## Dashboard Layout (Screen 7)

| Position | Label | Value | Trend |
|---|---|---|---|
| 1 | TOTAL CONTACTS | 2,307 | ↑ 34 this month (green) |
| 2 | ENGAGEMENTS THIS WEEK | 47 | ↑ 12% vs last week (green) |
| 3 | ACCOUNTS | 418 | 8 added this month (gray) |
| 4 | OVERDUE FOLLOW-UPS | 12 (red) | ↑ 3 since yesterday (red) |

## States

| State | Description |
|---|---|
| Default | Standard metric display |
| Alert | Number displayed in danger red (`#DC3545`) — for metrics that need attention |
| Loading | Skeleton placeholder or spinner in place of number |

## Props / API

```ruby
# Admin::StatCard::Component
class Admin::StatCard::Component < ViewComponent::Base
  # @param label [String] Metric label (displayed ALL-CAPS)
  # @param value [String] Formatted metric value (e.g., "2,307", "47")
  # @param trend_text [String] Trend description (e.g., "34 this month")
  # @param trend_direction [Symbol] :up, :down, :neutral
  # @param trend_sentiment [Symbol] :positive (green), :negative (red), :neutral (gray)
  # @param alert [Boolean] Display value in danger red (default: false)
end
```

## Bootstrap Classes

- `card` with custom border and radius — or custom `.stat-card`
- `row g-3`, `col-3` — 4-card dashboard layout
- `bi-arrow-up`, `bi-arrow-down` — trend direction icons
- Text colors: `text-success` (green), `text-danger` (red), `text-muted` (gray)

## Key Styles

```css
.stat-card { background: #fff; border: 1px solid #DEE2E6; border-radius: 8px; padding: 20px; }
.stat-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: #6C757D; }
.stat-value { font-size: 32px; font-weight: 700; color: #1B2A4A; line-height: 1.1; }
.stat-trend { font-size: 12px; font-weight: 500; }
.trend-up { color: #22A06B; }
.trend-down { color: #DC3545; }
.trend-neutral { color: #6C757D; }
```

## Accessibility

- Card label serves as the accessible name — no additional `aria-label` needed
- Trend arrow icons are decorative when accompanied by text — use `aria-hidden="true"`
- For alert cards (red numbers), consider `role="alert"` or `aria-live="polite"` for dynamic updates
- Numbers should use proper formatting (commas for thousands) and not abbreviations

## Usage Guidelines

- **Use** in dashboard views as a row of 3-4 metric cards
- **Use** `col-3` grid for 4-card rows (Bootstrap responsive grid)
- **Use** alert variant (red number) only for metrics that need immediate attention (e.g., overdue items)
- **Do not** mix positive (green) and alert (red) trend text on the same card — pick one sentiment
- **Do not** use more than 4 stat cards in a single row
- **Do not** truncate or abbreviate numbers — show full formatted values
- Cards should be responsive — stack to `col-6` on tablet and `col-12` on mobile
- Metric values update via Turbo Streams for real-time dashboards
