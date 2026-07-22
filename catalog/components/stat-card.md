# StatCard

**Category:** Component
**Issue:** #21
**Status:** Approved

## Description

Top-level metric card for dashboards. Displays an ALL-CAPS label, a large number, and a trend indicator with directional arrow. Used in the CRM Dashboard (Screen 7) as a row of 4 cards.

## Design Decisions

Colour comes from Bootstrap 5.3 semantic utilities, so the card tracks `data-bs-theme`
instead of pinning a light palette. Only geometry (padding, font sizes/weights) is inline. (#150)

- **Visible borders:** Cards carry `.border` (theme-adaptive `--bs-border-color`), not a pinned `#DEE2E6` — confirmed, not borderless
- **Label style:** ALL-CAPS, 11px, `font-weight: 600`, `letter-spacing: 0.06em`, coloured by `.text-body-secondary` (adaptive) rather than a pinned gray
- **Number size:** 32px, `font-weight: 700`, `.text-body` (adaptive — brand navy in light mode) — or `.text-danger` for alerts. At 32px the value is *large text* (AA 3:1), which base `.text-danger` clears in both modes (4.53 light / 3.41 dark) while staying semantically red
- **Trend indicators:** Arrow icon + descriptive text below the number, coloured by `.text-success-emphasis` (positive) / `.text-danger-emphasis` (negative) / `.text-body-secondary` (neutral). The 12px trend is *small text* (AA 4.5:1), so the `-emphasis` variants are used deliberately — base `.text-success` (3.33:1) and `.text-danger` (3.41:1) fail AA at that size and do not follow the colour mode; the emphasis tokens pass (7.7–13.7:1) and are adaptive
- **Surface:** `.bg-body` card (adaptive — white in light mode) on the page background
- **Border radius:** `.rounded-3` == `--bs-border-radius-lg` == 8px, preserving the retired literal

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
| Default | Standard metric display — value in `.text-body` |
| Alert | Number displayed in danger red via `.text-danger` (adaptive) — for metrics that need attention |
| Loading | Skeleton placeholder or spinner in place of number |

## Props / API

```ruby
# MpiDesignSystem::Admin::StatCard::Component
class MpiDesignSystem::Admin::StatCard::Component < ViewComponent::Base
  # @param label [String] Metric label (displayed ALL-CAPS)
  # @param value [String] Formatted metric value (e.g., "2,307", "47")
  # @param trend_text [String] Trend description (e.g., "34 this month")
  # @param trend_direction [Symbol] :up, :down, :neutral
  # @param trend_sentiment [Symbol] :positive (green), :negative (red), :neutral (gray)
  # @param alert [Boolean] Display value in danger red (default: false)
end
```

## Bootstrap Classes

- Card surface: `.bg-body .border .rounded-3` — adaptive surface, border and 8px radius
- `row g-3`, `col-3` — 4-card dashboard layout
- `bi-arrow-up`, `bi-arrow-down` — trend direction icons
- Label: `.text-body-secondary`
- Value: `.text-body` (default) / `.text-danger` (alert)
- Trend: `.text-success-emphasis` (positive) / `.text-danger-emphasis` (negative) / `.text-body-secondary` (neutral) — `-emphasis` for AA at 12px

## Key Styles

The card carries **no colour of its own** — surface, border, radius and every foreground
come from Bootstrap utilities so they derive from the app's palette and colour mode. Only
geometry is declared inline. The `-emphasis` trend variants are a deliberate small-text AA
fix (base `.text-success`/`.text-danger` fail 4.5:1 at 12px). (#150)

```css
/* Card: classes `bg-body border rounded-3`, no background/border/radius declaration.
   rounded-3 == --bs-border-radius-lg == 8px (the retired literal). */
.stat-card { padding: 20px; }

/* Label: class `text-body-secondary`, no `color` declaration. */
.stat-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; }

/* Value: class `text-body` (or `text-danger` when alert), no `color` declaration. */
.stat-value { font-size: 32px; font-weight: 700; line-height: 1.1; }

/* Trend: classes text-success-emphasis / text-danger-emphasis / text-body-secondary,
   no `color` declaration. */
.stat-trend { font-size: 12px; font-weight: 500; }
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
