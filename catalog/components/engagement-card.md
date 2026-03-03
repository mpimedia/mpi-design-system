# EngagementCard

**Category:** Component
**Issue:** #24
**Status:** Approved

## Description

Card component for displaying an individual engagement entry in the CRM engagements master timeline (Screen 10). Shows the engagement type badge, time, subject, note excerpt, linked contacts as avatar chips, and right-side metadata including account, tags, linked titles, and engagement creator.

## Design Decisions

- **Type badges:** Outlined uppercase text, NOT filled. 10px, 700 weight, `letter-spacing: 0.04em`, `border-radius: 4px`, `border: 1.5px solid`, transparent background
- **Type colors:** Email = `#2E75B6`, Meeting = `#8B5CF6`, Call = `#16A34A`, Note = `#E8913A`
- **Two-column layout:** Left column (content: type badge + time, subject, excerpt, contact chips) + right column (metadata: account link, tags, linked titles)
- **Engagement creator:** Gray text in the card header-right area showing who logged the engagement (internal user). This is important for accountability -- corrected from initial bottom-right placement per Badie's feedback on #25
- **Contact chips:** Avatar (22px, deterministic color) + name in a pill-shaped chip with `#F5F7FA` background
- **Linked titles:** Text links (format TBD -- film icon format needs revisiting per Badie's feedback). May simplify to plain text links without icons
- **Card styling:** White background, `1px solid #DEE2E6` border, `border-radius: 8px`, `padding: 16px 20px`
- **Excerpt:** 13px, muted gray, `line-height: 1.4`. No explicit truncation limit confirmed; current display approved as-is

## Variants

| Variant | Description |
|---|---|
| **Email** | Blue outline badge, typically has subject line and excerpt |
| **Meeting** | Purple outline badge, often lists multiple contact chips |
| **Call** | Green outline badge, standard layout |
| **Note** | Orange outline badge, internal notes typically have longer excerpts |

## States

| State | Description |
|---|---|
| Default | Standard card display |
| Hover | Subtle border or shadow change (implementation detail) |

## Props / API

```ruby
# Admin::EngagementCard::Component
class Admin::EngagementCard::Component < ViewComponent::Base
  # @param engagement_type [Symbol] :email, :meeting, :call, :note
  # @param time [String] Display time (e.g., "10:42 AM")
  # @param subject [String] Engagement subject line
  # @param excerpt [String] Note/body excerpt text
  # @param contacts [Array<Hash>] Each: { initials: String, color: String, name: String, path: String }
  # @param account_name [String] Linked account name
  # @param account_path [String] URL to account detail
  # @param tags [Array<Hash>] Each: { group: String, role: String, color: String }
  # @param linked_titles [Array<Hash>] Each: { name: String, path: String } (format TBD)
  # @param creator_name [String] Internal user who logged the engagement
end
```

## Bootstrap Classes

- `d-flex`, `justify-content-between` -- two-column card layout
- `d-flex`, `align-items-center` -- type badge + time row
- `d-flex`, `gap-2` -- contact chip row
- `flex-grow-1` -- left column fill
- `rounded-pill` -- contact avatar chips
- Custom `.eng-card`, `.type-badge`, `.type-email`/`.type-meeting`/`.type-call`/`.type-note`, `.avatar-chip`, `.eng-subject`, `.eng-excerpt`, `.right-meta`

## Accessibility

- Type badge text is readable (not icon-only) -- "EMAIL", "MEETING", "CALL", "NOTE"
- Account and contact links are descriptive
- Card is a semantic `<article>` or `<div>` with appropriate heading structure
- Engagement creator text is visible (not hidden behind hover or tooltip)
- Color is not the only differentiator -- type text label accompanies the color coding

## Usage Guidelines

- **Use** in the engagements master timeline view (Screen 10)
- **Do not** use in the contact detail engagement timeline -- use EngagementTimeline entries instead
- **Do not** confuse with EngagementTimeline entries, which are simpler (no right metadata column)
- The creator field is important for internal accountability -- always show who logged the engagement
- Linked titles format will be finalized in a future design pass
