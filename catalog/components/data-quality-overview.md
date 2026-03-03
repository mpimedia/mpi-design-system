# DataQualityOverview

**Category:** Component
**Issue:** #26
**Status:** Approved

## Description

Two separate components for CRM data quality reporting. The **DataQualityDashboard** shows CRM-wide health metrics (Screen 12). The **DataQualityPanel** shows per-contact field completeness (Screen 14). Badie confirmed these should be separate components.

## Design Decisions

- **Two components confirmed:** CRM-wide dashboard and per-contact panel are separate ViewComponents
- **4-tier grading system:** Poor (danger), Fair (warning), Good (primary), Excellent (success) -- based on field completeness, not arbitrary percentages
- **Score rings:** Circular SVG progress rings, NOT progress bars. Large ring (120px) for dashboard, small ring (48px) for contact panel, mini rings (32px) for priority fixes list
- **Grade badges:** Uppercase text on light background. EXCELLENT = `#22A06B` on `#ECF8F4`, GOOD = `#2E75B6` on `#EBF3FB`, FAIR = `#D4772C` on `#FEF3EC`, POOR = `#DC3545` on `#FEE2E2`
- **Priority badges:** Field importance markers. HIGH = red (`#DC3545` on `#FEE2E2`), MED = orange (`#D4772C` on `#FEF3EC`), LOW = gray (`#64748B` on `#F1F5F9`). 9px uppercase text
- **Missing field highlighting:** Yellow background (`#FFFBEB`) on missing field rows, red X icon, red field name text
- **Complete field indicator:** Green check circle icon (`#22A06B`) + current value shown

### Tier Definitions (from `tokens/components.md`)

| Tier | Required Fields | Approximate % |
|---|---|---|
| Poor | Name + Company only | 0--29% |
| Fair | Name + Company + (Email or Phone) | 30--49% |
| Good | Name + Company + Title + Email + Phone + Tags | 50--84% |
| Excellent | All of the above + Engagement History | 85--100% |

## Variants

### DataQualityDashboard (CRM-wide, Screen 12)

| Section | Description |
|---|---|
| **Overall score ring** | 120px ring with percentage + tier label, grade distribution bars below |
| **Grade distribution** | 4 horizontal bars (Excellent/Good/Fair/Poor) with counts and percentages |
| **Gap stat cards** | 3 cards showing top data gaps (No Email, No Tags, No Account) with count + percentage |
| **Priority fixes list** | Recently active contacts with worst data quality -- avatar, name, org, missing fields, mini ring, recency |

### DataQualityPanel (Per-contact, Screen 14)

| Section | Description |
|---|---|
| **Header** | 48px score ring + "Data Completeness" title + "N of M fields complete" + grade badge |
| **Field checklist** | List of all tracked fields with check/X icon, field name, priority badge, current value (or empty for missing) |
| **Progress bar** | Bootstrap progress bar at bottom showing field count fraction |

## States

| State | Description |
|---|---|
| Default | Normal display with current data |
| Loading | Skeleton placeholders for rings and field rows |
| No Data | Dashboard: show "No contacts" message. Panel: unlikely (contact always has some data) |

## Props / API

```ruby
# Admin::DataQualityDashboard::Component (CRM-wide)
class Admin::DataQualityDashboard::Component < ViewComponent::Base
  # @param overall_score [Integer] 0-100 percentage
  # @param overall_tier [Symbol] :poor, :fair, :good, :excellent
  # @param grade_distribution [Hash] { excellent: Integer, good: Integer, fair: Integer, poor: Integer }
  # @param total_contacts [Integer] Total contact count
  # @param total_accounts [Integer] Total account count
  # @param gaps [Array<Hash>] Each: { label: String, count: Integer, percentage: Float }
  # @param priority_fixes [Array<Hash>] Each: { contact: Contact, missing_fields: Array, score: Integer, last_active: String }
end

# Admin::DataQualityPanel::Component (Per-contact)
class Admin::DataQualityPanel::Component < ViewComponent::Base
  # @param score [Integer] 0-100 percentage
  # @param tier [Symbol] :poor, :fair, :good, :excellent
  # @param fields_complete [Integer] Number of complete fields
  # @param fields_total [Integer] Total tracked fields
  # @param fields [Array<Hash>] Each: { name: String, complete: Boolean, priority: Symbol, value: String }
end
```

## Bootstrap Classes

- `row`, `col-3`, `col-4`, `col-9`, `g-3` -- dashboard grid layout
- `d-flex`, `align-items-start`, `gap-3` -- panel header layout
- `progress`, `progress-bar` -- per-contact progress bar
- `border-bottom` -- priority fixes list item separator
- Custom `.score-ring`, `.grade-badge`, `.priority-badge`, `.field-row`, `.gap-stat-card`, `.mini-ring`

## Accessibility

- Score rings include text values (not visual-only) readable by screen readers
- Check/X icons use `aria-hidden="true"` with a text alternative for the field status
- Color coding is always paired with text labels (tier names, priority labels)
- Grade badges have sufficient contrast (verified against WCAG AA)
- Missing field highlight uses both color (yellow background) and icon (X) -- not color alone

## Usage Guidelines

- **Use** DataQualityDashboard on the CRM data quality dashboard page (Screen 12)
- **Use** DataQualityPanel in the contact detail view as a tab in the right panel (Tab 2, per `tokens/components.md`)
- **Do not** combine these into a single component -- they serve different contexts and audiences
- Display tier labels (Poor/Fair/Good/Excellent), not raw percentages, as the primary indicator
- Priority fixes list should be sorted by recency of activity, showing the most recently active low-quality contacts
- Field priority (HIGH/MED/LOW) helps users know which missing fields to address first
