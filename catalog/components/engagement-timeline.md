# EngagementTimeline

**Category:** Component
**Issue:** #25
**Status:** Approved

## Description

Chronological list of engagement entries displayed in a contact's detail view right panel (Screen 1). Each entry shows a type badge, date/time with timezone, subject, and optional note excerpt. Includes a header with "Engagements" title and "+ New Engagement" button. Also has a compact variant for account detail panels.

## Design Decisions

- **Layout:** Vertical list with no connecting line or dots -- simple stacked entries separated by light borders (`1px solid #F0F0F0`)
- **Type badges:** Outlined uppercase, same style as EngagementCard (10px, 700 weight, `border-radius: 4px`, `border: 1.5px solid`, transparent background)
- **Date format:** "Feb 21, 2026 . 3:42 PM CT" -- includes timezone abbreviation (CT) per Badie's feedback. Important since team members work across all US timezones
- **Engagement creator:** Shown on the right side of the header line for each entry, in gray text. This is the internal user who logged the engagement. Badie corrected his earlier #24 suggestion -- header-right is preferred over bottom-right
- **"+ New Engagement" button:** Dark navy background (`#1B2A4A`), white text, 13px, `border-radius: 6px`
- **Panel styling:** White background, `1px solid #DEE2E6` border, `border-radius: 8px`, `padding: 20px`
- **Compact variant:** Useful for account detail panels. No excerpts, just type badge + date + subject. Smaller title ("Recent Engagements", 14px). Tighter padding (10px per entry). Not a deal-breaker if omitted initially

## Variants

| Variant | Description |
|---|---|
| **Full** | Header + button + entries with type badge, date/time/timezone, subject, excerpt, and creator |
| **Compact** | Smaller heading, entries with type badge + date + subject only (no excerpts, no creator) |

## States

| State | Description |
|---|---|
| Default | Chronological list of entries |
| Empty | No engagements yet -- show empty state message with CTA to create first engagement |
| Loading | Placeholder skeleton for entries (implementation detail) |

## Props / API

```ruby
# Admin::EngagementTimeline::Component
class Admin::EngagementTimeline::Component < ViewComponent::Base
  # @param engagements [Array<Hash>] Each: { type: Symbol, date: String, time: String,
  #   timezone: String, subject: String, excerpt: String, creator_name: String }
  # @param variant [Symbol] :full (default), :compact
  # @param new_engagement_path [String] URL for "+ New Engagement" button
  # @param contact [Contact] Parent contact (for context)
end
```

## Bootstrap Classes

- `d-flex`, `justify-content-between`, `align-items-center` -- header layout
- `d-flex`, `align-items-center` -- badge + date row within each entry
- Custom `.timeline-panel`, `.timeline-header`, `.timeline-title`, `.btn-new-eng`, `.eng-entry`, `.eng-date`, `.eng-subject`, `.eng-excerpt`
- Type badge classes: `.type-badge`, `.type-email`, `.type-meeting`, `.type-call`, `.type-note`

## Key Styles

```css
.eng-entry { padding: 14px 0; border-bottom: 1px solid #F0F0F0; }
.eng-entry:last-child { border-bottom: none; }
.eng-date { font-size: 12px; color: #6C757D; margin-left: 8px; }
.eng-subject { font-weight: 600; color: #1B2A4A; font-size: 14px; margin-top: 4px; }
.eng-excerpt { font-size: 13px; color: #6C757D; margin-top: 4px; line-height: 1.4; }
```

## Accessibility

- Timeline is a `<div>` with entries as semantic blocks; consider `role="feed"` for screen readers
- Each entry has readable type label text ("EMAIL", "MEETING", etc.)
- "+ New Engagement" button is keyboard accessible with visible focus indicator
- Timestamps include timezone for clarity
- Creator name is visible text (not tooltip-only)

## Usage Guidelines

- **Use** the full variant in the contact detail view right panel
- **Use** the compact variant in account detail panels or summary contexts
- **Do not** use for the engagements master timeline (Screen 10) -- use EngagementCard instead
- Entries should always be sorted chronologically (newest first)
- The creator field answers "who logged this?" -- always include it in the full variant
- Timezone should default to CT but could be configurable per user in the future
