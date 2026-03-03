# Dashboard

**Category:** Layout
**Issue:** #31
**Status:** Approved

## Description

CRM dashboard layout showing a personalized greeting, stat cards row, recent activity feed, quick actions, follow-up queue, and contacts by group chart. Renders inside the App Shell with CRM sub-nav active.

## Design Decisions

- **Greeting:** "Good morning, [Name]" + "Here's your CRM snapshot for [Day], [Date]". Time-of-day greeting (morning/afternoon/evening)
- **Stat cards row:** 4 equal-width cards using StatCard component. Total Contacts, Engagements This Week, Accounts, Overdue Follow-Ups (red text for danger emphasis)
- **Quick Actions repositioned:** Moved ABOVE the Follow-up Queue (Badie's feedback). Higher priority since it drives action. Right column order: Quick Actions first, then Follow-up Queue
- **Quick Actions relabeled:** Buttons changed to "Add new Contact", "Add new Account", "Add new Engagement" (in that order, per Badie). Outlined style, not filled
- **Two-column body:** Left column (8 cols) has Recent Activity + Contacts by Group. Right column (4 cols) has Quick Actions + Follow-up Queue
- **Recent Activity:** 5 activity entries with colored type icons (28px circles). Icon backgrounds use engagement type light colors. Linked contact and account names as blue links. Relative timestamps
- **Follow-up Queue:** Priority list with avatars, description, and status. Colors: overdue = danger red, due today = danger red, due tomorrow = warning orange, future = muted gray. "View all N -->" link in header
- **Contacts by Group:** Horizontal stacked bar chart using tag group colors + legend with counts. Full-width within the left column

### Activity Icon Types

| Type | Icon | Background | Color |
|---|---|---|---|
| Email | `bi-envelope-fill` | `#EBF3FB` | `#2E75B6` |
| Meeting | `bi-camera-video-fill` | `#F3EFFE` | `#8B5CF6` |
| New Contact | `bi-plus-circle-fill` | `#ECF8F4` | `#22A06B` |
| Call | `bi-telephone-fill` | `#ECF8F4` | `#16A34A` |
| Note | `bi-journal-text` | `#FEF3EC` | `#E8913A` |

### Follow-up Status Colors

| Status | Color | Example |
|---|---|---|
| Overdue | `#DC3545` (danger) | "7d overdue", "5d overdue" |
| Due today | `#DC3545` (danger) | "Due today" |
| Due tomorrow | `#D4772C` (warning) | "Due tomorrow" |
| Future | `#6C757D` (muted) | "In 3 days" |

## Layout Structure

```
+---------------------------------------------------+
|  Good morning, Badie                               |
|  Here's your CRM snapshot for Tuesday, Feb 25      |
+---------------------------------------------------+
|  [Total    ] [Engagements] [Accounts ] [Overdue  ] |
|  [Contacts ] [This Week  ] [         ] [Follow-Up] |
+---------------------------------------------------+
|  col-8                  |  col-4                   |
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
| Empty (new user) | Stat cards at zero, empty activity feed with CTA, empty follow-up queue |
| No overdue | Overdue stat card shows 0 in normal color (not red) |

## Props / API

```ruby
# Admin::Dashboard::Component
class Admin::Dashboard::Component < ViewComponent::Base
  # @param user_name [String] Current user's first name
  # @param greeting_time [Symbol] :morning, :afternoon, :evening
  # @param current_date [Date] Today's date for display
  #
  # Composes these sub-components via slots:
  # renders_many :stat_cards    # 4 StatCard components
  # renders_one :activity_feed  # Recent activity list
  # renders_one :quick_actions  # Quick action buttons
  # renders_one :followup_queue # Follow-up queue list
  # renders_one :group_chart    # Contacts by group chart
end
```

## Bootstrap Classes

- `row`, `g-3`, `col-3` -- stat cards row (4 equal columns)
- `row`, `g-4`, `col-8`, `col-4` -- two-column body layout
- `card`, `card-body` -- widget containers
- `d-flex`, `align-items-start`, `gap-2` -- activity item layout
- `d-flex`, `align-items-center`, `gap-2` -- follow-up queue items
- `d-grid`, `gap-2` -- quick actions button stack
- Custom `.stat-card`, `.activity-item`, `.activity-icon`, `.followup-status`, `.group-bar`, `.quick-action`, `.widget-title`

## Key Styles

```css
.stat-card { background: #fff; border: 1px solid #DEE2E6; border-radius: 8px; padding: 16px; }
.stat-value { font-size: 28px; font-weight: 700; color: #1B2A4A; }
.activity-icon { width: 28px; height: 28px; border-radius: 50%; }
.quick-action { padding: 10px 14px; border: 1px solid #DEE2E6; border-radius: 6px; background: #fff; }
.quick-action:hover { border-color: #2E75B6; }
.group-bar { height: 16px; border-radius: 8px; overflow: hidden; display: flex; }
```

## Accessibility

- Greeting uses appropriate heading level (`<h5>`)
- Stat cards are grouped logically; values use `aria-label` if the label is insufficient
- Overdue count uses both color (red) and an icon/label -- not color alone
- Activity links are descriptive (contact name, action type)
- Quick action buttons are keyboard accessible with visible focus indicators
- Follow-up queue items have clear status text alongside color coding
- Contacts by Group chart bar segments have a text legend below -- bar alone is not the only representation

## Usage Guidelines

- **Use** as the CRM Dashboard page layout (CRM sub-nav "Dashboard" active)
- **Do not** use for the global Markaz dashboard -- that is a different context (TBD)
- **Quick Actions are high priority** -- placed above Follow-up Queue per Badie's feedback
- **Quick Actions labels:** "Add new Contact", "Add new Account", "Add new Engagement" -- use these exact labels
- The greeting should dynamically adjust for time of day (morning before noon, afternoon until 5pm, evening after)
- Stat card trends (up/down arrows, percentages) are contextual -- green up arrow for positive metrics, red for negative (like overdue count increasing)
- Activity feed should show the 5 most recent activities; "View all" links to a full activity log
