# Detail View

**Category:** Layout
**Issue:** #30
**Status:** Approved

## Description

Two-panel detail page layout used for contact and account detail views. Left panel (~1/3 width) shows a profile/summary card with avatar, name, tags, contact info, groups, and owner. Right panel (~2/3 width) shows an engagement timeline with chronological entries. Used inside the App Shell.

## Design Decisions

- **Panel ratio:** 4:8 Bootstrap column split (~1/3 : 2/3), confirmed by Badie
- **Owner field (critical):** An "Owner" field must be prominently placed in the left profile panel's contact info section. This is the internal user who owns the contact relationship. Badie emphasized this is "very important"
- **Engagement owner:** Each engagement entry in the right panel must show who logged it (the internal user), consistent with EngagementCard (#24) and EngagementTimeline (#25) requirements
- **Left panel:** Bootstrap card with multiple sections separated by `<hr>` dividers
- **Avatar:** 64px circle with deterministic color and initials (22px font)
- **Tag chips in profile:** Colored dot + text in a pill chip with colored border and light background. Different format from the inline dot tags in the list view -- detail view uses bordered pill chips
- **"+ Add tag" link:** Blue link below tags for adding new tags
- **Groups (Auto):** Auto-assigned group chips (e.g., "Distribution", "Press/Festival") based on tags. Light background with group color text, pill shape
- **Contact info section:** Key-value pairs in a compact two-column layout (label left, value right). Fields: Email (link), Phone, Account (link), Location, Added date, Owner (link)
- **Right panel:** Uses EngagementTimeline component (full variant) with header, "+ New Engagement" button, and chronological entries

## Layout Structure

```
+---------------------------------------------------+
|                   App Shell                        |
+---------------------------------------------------+
|  col-4           |  col-8                          |
|  +-------------+ |  +---------------------------+  |
|  | Avatar      | |  | Engagements    [+ New]    |  |
|  | Name        | |  |                           |  |
|  | Title       | |  | EMAIL  Feb 21 ... Creator |  |
|  | Company     | |  | Subject line              |  |
|  |-------------| |  | Excerpt...                |  |
|  | TAGS        | |  |                           |  |
|  | [chips]     | |  | MEETING Feb 18 .. Creator |  |
|  | + Add tag   | |  | Subject line              |  |
|  |-------------| |  | Excerpt...                |  |
|  | CONTACT INFO| |  |                           |  |
|  | Email: ...  | |  | ...                       |  |
|  | Phone: ...  | |  +---------------------------+  |
|  | Account: ...| |                                 |
|  | Location: ..| |                                 |
|  | Added: ...  | |                                 |
|  | Owner: ...  | |                                 |
|  |-------------| |                                 |
|  | GROUPS(Auto)| |                                 |
|  | [Buyers]    | |                                 |
|  +-------------+ |                                 |
+-------------------+---------------------------------+
```

## Variants

| Variant | Description |
|---|---|
| **Contact Detail** | Full profile card (Screen 1). Left: avatar, name, title, company, tags, contact info (with Owner), groups. Right: EngagementTimeline (full) |
| **Account Detail** | Adapted for accounts (Screen 9). Left: account name, account type, associated contacts list. Right: EngagementTimeline (compact or full) |

## States

| State | Description |
|---|---|
| Default | Profile card + engagement timeline populated |
| Empty timeline | Right panel shows empty state with CTA to create first engagement |
| Loading | Skeleton placeholders for both panels |

## Props / API

```ruby
# Admin::DetailView::Component
class Admin::DetailView::Component < ViewComponent::Base
  # @param variant [Symbol] :contact (default), :account
  #
  # Renders panels via slots:
  # renders_one :profile_panel  # Left panel (profile card)
  # renders_one :activity_panel # Right panel (engagement timeline)
end

# Left panel content is composed of sub-components:
# - Admin::AvatarCircle::Component (64px variant)
# - Admin::TagChip::Component (for tag chips)
# - Admin::Badge::Component (for auto-groups)
# Right panel uses:
# - Admin::EngagementTimeline::Component (full variant)
```

## Bootstrap Classes

- `row`, `g-4` -- two-panel grid
- `col-4` -- left panel
- `col-8` -- right panel
- `card`, `card-body` -- left panel card container
- `d-flex`, `justify-content-between` -- contact info key-value pairs
- `d-flex`, `flex-wrap`, `gap-1` -- tag chip layout
- Custom `.avatar-xl` (64px), `.info-label`, `.info-value`, `.tag-chip`, `.group-auto-chip`

## Key Styles

```css
.avatar-xl { width: 64px; height: 64px; font-size: 22px; }
.info-label { font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: #6C757D; }
.info-value { font-size: 13px; color: #1B2A4A; margin-bottom: 10px; }
.tag-chip { padding: 2px 8px; border-radius: 999px; font-size: 11px; font-weight: 500; border: 1px solid; }
```

## Accessibility

- Left panel card uses appropriate heading hierarchy (`<h5>` for name)
- Contact info fields use semantic label/value pairs (could use `<dl>`, `<dt>`, `<dd>`)
- Email and account links are descriptive and keyboard accessible
- Tag chips are read as text by screen readers
- Right panel EngagementTimeline handles its own accessibility

## Usage Guidelines

- **Use** for contact and account detail pages in CRM
- **Do not** use for content detail pages -- Content section has its own layout with sidebar browser
- **Always include** the Owner field in the contact info section -- this is critical for relationship accountability
- **Always include** the engagement creator on timeline entries -- consistent with EngagementTimeline spec
- The left panel is scrollable independently if content exceeds viewport height
- On mobile, panels stack vertically (profile on top, timeline below)
- Tag chips in the detail view use the bordered pill style; this is intentionally different from the inline dot format in list rows
