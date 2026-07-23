# Dashboard

**Category:** Layout
**Issue:** #31
**Status:** Approved

## Description

CRM dashboard layout showing a personalized greeting, stat cards row, recent activity feed, quick actions, follow-up queue, and contacts by group chart. Renders inside the App Shell with CRM sub-nav active.

Since #153 the layout is **theme-adaptive**: every colour the component selects resolves from a Bootstrap semantic utility (`bg-body`, `text-body`, `text-body-secondary`, the `-subtle`/`-emphasis` families) rather than a pinned hex, so it follows `data-bs-theme` and the consuming app's mapped tokens. The one exception is the Contacts-by-Group chart, whose colours are **caller-supplied** (`group_data[:color]`) and deliberately out of scope for #153 — tracked by #172.

## Design Decisions

- **Greeting:** "Good morning, [Name]" + "Here's your CRM snapshot for [Day], [Date]". Time-of-day greeting (morning/afternoon/evening). Greeting text is `text-body`; the subtitle is `text-body-secondary`
- **Stat cards row:** 4 equal-width cards using StatCard component (rendered via the `stat_cards` slot). Placed in a `row g-3` of `col-md-6 col-lg-3` columns (two-up on medium, four-up on large)
- **Quick Actions repositioned:** Moved ABOVE the Follow-up Queue (Badie's feedback). Higher priority since it drives action. Right column order: Quick Actions first, then Follow-up Queue
- **Quick Actions relabeled:** Buttons changed to "Add new Contact", "Add new Account", "Add new Engagement" (in that order, per Badie). Outlined style (`border bg-body text-body`), not filled. They keep no underline (a button-like control, not body-text navigation)
- **Two-column body:** Left column (`col-lg-8`) has Recent Activity + Contacts by Group. Right column (`col-lg-4`) has Quick Actions + Follow-up Queue
- **Recent Activity:** activity entries with type icons (28px circles). The icon chip is a theme-adaptive `bg-#{semantic}-subtle text-#{semantic}-emphasis` pair. Contact and account names are links with **no** colour class — Bootstrap's adaptive `--bs-link-color` with its natural underline as the affordance. Relative timestamps in `text-body-secondary`
- **Follow-up Queue:** Priority list with avatars, description, and status. Status colours: overdue = `text-danger-emphasis`, due today = `text-danger-emphasis`, due tomorrow = `text-warning-emphasis`, future = `text-body-secondary`. "View all N &rarr;" link in header (same adaptive-link treatment as the activity links)
- **Contacts by Group:** Horizontal stacked bar chart using **caller-supplied** group colours + legend with counts. Full-width within the left column. The bar carries `role="img"` and an `aria-label`; the legend labels/counts are `text-body-secondary` / `text-body`

### Activity Icon Types

Five engagement types map onto **four** Bootstrap semantic hues. MPI's adaptive semantic families are primary / secondary / success / warning / danger (`info` aliases to `primary`), so a five-category palette collapses. The icon is `aria-hidden` decoration beside the always-present activity text, so the collapse costs no information.

| Type | Icon | Chip utilities | Semantic | Note |
|---|---|---|---|---|
| Email | `bi-envelope-fill` | `bg-primary-subtle text-primary-emphasis` | primary | was `#EBF3FB` / `#2E75B6` (`#2E75B6` *is* `$mpi-primary`) |
| Meeting | `bi-camera-video-fill` | `bg-secondary-subtle text-secondary-emphasis` | secondary | **purple has no MPI semantic**; `info` would render the same blue as Email, so the purple becomes neutral grey |
| New Contact | `bi-plus-circle-fill` | `bg-success-subtle text-success-emphasis` | success | was `#ECF8F4` / `#22A06B` (`#22A06B` *is* `$mpi-success`) |
| Call | `bi-telephone-fill` | `bg-success-subtle text-success-emphasis` | success | **collapses onto New Contact's green** — they already shared a pastel and the glyphs differ |
| Note | `bi-journal-text` | `bg-warning-subtle text-warning-emphasis` | warning | near — `$mpi-warning` is `#D4772C` |

Unknown type falls back to the Email (primary) pair.

### Follow-up Status Colors

| Status | Utility | Semantic | Example |
|---|---|---|---|
| Overdue | `text-danger-emphasis` | danger | "7d overdue", "5d overdue" |
| Due today | `text-danger-emphasis` | danger | "Due today" |
| Due tomorrow | `text-warning-emphasis` | warning | "Due tomorrow" |
| Future | `text-body-secondary` | muted body | "In 3 days" |

`-emphasis` (not base `text-danger` / `text-warning`) because the 12px status label is small text (AA 4.5:1), which base danger/warning fail; the emphasis tokens clear it and follow the colour mode. Unknown status falls back to the Future (`text-body-secondary`) class.

## Layout Structure

```
+---------------------------------------------------+
|  Good morning, Badie                               |
|  Here's your CRM snapshot for Tuesday, Feb 25      |
+---------------------------------------------------+
|  [Total    ] [Engagements] [Accounts ] [Overdue  ] |
|  [Contacts ] [This Week  ] [         ] [Follow-Up] |
+---------------------------------------------------+
|  col-lg-8               |  col-lg-4                |
|  +-------------------+  |  +-------------------+   |
|  | Recent Activity   |  |  | Quick Actions     |   |
|  | - Email logged    |  |  | + Add new Contact |   |
|  | - Meeting recorded|  |  | + Add new Account |   |
|  | - Contact added   |  |  | + Add new Engmnt  |   |
|  | - Call logged     |  |  +-------------------+   |
|  | - Note added      |  |  +-------------------+   |
|  +-------------------+  |  | Follow-up Queue   |   |
|  +-------------------+  |  | - Overdue items   |   |
|  | Contacts by Group |  |  | - Due today       |   |
|  | [stacked bar]     |  |  | - Upcoming        |   |
|  | Legend             |  |  +-------------------+   |
|  +-------------------+  |                          |
+---------------------------------------------------+
```

## Variants

| Variant | Description |
|---|---|
| **CRM Dashboard** | Full layout as described (Screen 7). This is the only currently designed variant |
| **Content Dashboard** | TBD -- Badie wants content search easily accessible. May be a separate layout or an extension of this one |

## States

| State | Description |
|---|---|
| Default | All widgets populated with data |
| Empty (new user) | Any collection (`activities`, `followups`, `quick_action_buttons`, `group_data`) that is empty simply **omits its widget** — the component renders no placeholder/CTA for an empty feed. Stat cards are supplied by the caller and can show zero. When every collection is empty, only the greeting (and any stat cards) render |
| No overdue | The Overdue stat card is a caller-supplied StatCard; pass `alert: false` for normal colour, `alert: true` for danger red |

## Props / API

```ruby
# MpiDesignSystem::Admin::Dashboard::Component
class MpiDesignSystem::Admin::Dashboard::Component < ViewComponent::Base
  # @param user_name [String] Current user's first name
  # @param greeting_time [Symbol] :morning, :afternoon, :evening
  # @param current_date [String] Formatted date string (e.g., "Tuesday, Feb 25")
  # @param activities [Array<Hash>] { type:, description:, timestamp:, contact_name:, contact_path:, account_name:, account_path: }
  # @param followups [Array<Hash>] { name:, description:, status:, status_label:, avatar_name: }
  # @param followup_count [Integer]  # for the "View all" link
  # @param followup_path [String]    # for the "View all" link
  # @param quick_action_buttons [Array<Hash>] { label:, path:, icon: }
  # @param group_data [Array<Hash>] { label:, count:, color:, percentage: }  # color is caller-supplied
  #
  # Composes these sub-components via slots (a slot bypasses the built-in markup entirely):
  # renders_many :stat_cards    # StatCard components
  # renders_one :activity_feed  # Recent activity list
  # renders_one :quick_actions  # Quick action buttons
  # renders_one :followup_queue # Follow-up queue list
  # renders_one :group_chart    # Contacts by group chart
end
```

Public constants: `ACTIVITY_TYPES` (`{ type => { icon:, variant: } }`) and `FOLLOWUP_CLASSES` (`{ status => utility_class }`). These replaced the retired hex maps `ACTIVITY_ICONS` and `FOLLOWUP_COLORS` in #153.

## Bootstrap Classes

- `row g-3`, `col-md-6 col-lg-3` -- stat cards row (two-up medium, four-up large)
- `row g-4`, `col-lg-8`, `col-lg-4` -- two-column body layout
- `bg-body border rounded-3` -- widget containers (adaptive surface + border; `rounded-3` = `--bs-border-radius-lg` = 8px under this engine's config)
- `text-body`, `text-body-secondary` -- adaptive foregrounds
- `bg-#{semantic}-subtle`, `text-#{semantic}-emphasis` -- activity-icon chips and follow-up status text
- `d-flex align-items-start gap-2` -- activity item layout
- `d-flex align-items-center gap-2` -- follow-up queue items
- `d-grid gap-2` -- quick actions button stack; each action is `border bg-body text-body`
- `d-flex flex-wrap gap-3`, `d-flex align-items-center gap-1` -- chart legend

## Key Styles

Colour now comes from the Bootstrap utilities above; only geometry/layout/typography survives inline. Representative surviving inline styles:

```
widget:        padding: 20px                                   (class: bg-body border rounded-3)
activity-icon: width: 28px; height: 28px; border-radius: 50%   (class: bg-#{sem}-subtle text-#{sem}-emphasis)
quick-action:  padding: 10px 14px; border-radius: 6px; text-decoration: none; display: block; text-align: left
                                                               (class: border bg-body text-body)
group-bar:     height: 16px; border-radius: 8px; overflow: hidden; display: flex; width: 100%
bar-segment:   background: #{caller hex}; width: #{pct}%; height: 100%   (caller-supplied colour — passthrough)
legend-dot:    width: 10px; height: 10px; border-radius: 50%; background: #{caller hex}
```

## Accessibility

Re-derived for the #153 conversion (a catalog entry's contrast claims are assertions, not decoration):

- Greeting uses an appropriate heading level (`<h5>`)
- Stat cards are the caller's StatCard components, which carry their own AA-derived colours
- Activity icons are `aria-hidden` decoration; the activity text carries the meaning, so the five-into-four hue collapse (meeting → grey, call sharing New Contact's green) conveys nothing on its own
- Activity/"View all" links use Bootstrap's adaptive `--bs-link-color` (`#2E75B6` ~4.6:1 on white light, `#82ACD3` on dark) and keep their underline — a non-colour affordance
- Follow-up status text uses `-emphasis` tokens, AA-clean (≥4.5:1) on the widget surface in both colour modes at 12px; the status **label text** carries the meaning, not the colour
- Quick action controls are keyboard-accessible links. Their `.border` is theme-adaptive but low-contrast against the card (≈1.3:1 light / 1.9:1 dark, below SC 1.4.11's 3:1 for a control boundary); this predates the conversion and is a tracked design question, not a #153 regression (the control was navy-on-white in the same `#DEE2E6` border before)
- Follow-up queue items have clear status text alongside colour coding
- Contacts by Group chart bar carries `role="img"` + `aria-label`, and a text legend below (label + count) — the bar alone is not the only representation. Bar/dot colours are caller-supplied and not guaranteed AA against each other; the text legend carries the data

## Usage Guidelines

- **Use** as the CRM Dashboard page layout (CRM sub-nav "Dashboard" active)
- **Do not** use for the global Markaz dashboard -- that is a different context (TBD)
- **Quick Actions are high priority** -- placed above Follow-up Queue per Badie's feedback
- **Quick Actions labels:** "Add new Contact", "Add new Account", "Add new Engagement" -- use these exact labels
- The greeting should dynamically adjust for time of day (morning before noon, afternoon until 5pm, evening after) — pass the resolved `greeting_time` symbol
- Stat card trends (up/down arrows, percentages) are contextual -- pass `trend_sentiment:` (`:positive` green / `:negative` red / `:neutral`) to StatCard
- The activity feed renders **every** activity you pass, in order — the component does not itself cap the list. Cap it caller-side (e.g. to the 5 most recent) and link a full activity log via the caller's own control if desired
