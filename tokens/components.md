# Component Tokens

Design decisions for shared component behavior across MPI applications.

> **Status:** Confirmed — decisions finalized by Badie (2026-03-02, Q&A Session 001).

## Avatar

- **Color assignment:** Deterministic — derived from the contact's name using a hash function
- No manual color assignment; colors are consistent for the same name across views

### Implementation Note

Use a deterministic hash of the contact's full name to select from a fixed palette. This ensures the same contact always gets the same avatar color without storing color assignments.

## Badge

- **Shape:** Pill (`border-radius: 999px`) for all badges across the system
- Applies to: tag chips, status badges, count indicators

```scss
// Badge override
$badge-border-radius: 999px;
```

## Contact Detail Panel

- **Layout:** Single page with two tabs in the right panel
- **Tab 1:** Engagement Timeline — chronological list of all engagements
- **Tab 2:** Data Quality — completeness scoring and field checklist

## Data Quality Scoring

Field-based tier system, not simple percentages.

| Tier | Required Fields | Approximate % |
|---|---|---|
| Poor | Name + Company only | 0–29% |
| Fair | Name + Company + (Email or Phone) | 30–49% |
| Good | Name + Company + Title + Email + Phone + Tags | 50–84% |
| Excellent | All of the above + Engagement History | 85–100% |

- When numeric scores are needed for sorting, weight fields by importance
- Display the tier label (Poor/Fair/Good/Excellent), not the percentage, in the UI
- Use color coding: Poor = danger, Fair = warning, Good = primary, Excellent = success

## List/Card Toggle

- **Default view:** List view
- **Toggle available:** Yes — users can switch between list and card view on list pages
- Implementation priority is secondary; list view must work first

## Sidebar Browser

- **Scope:** Section-specific, not universal
- **Content section:** Gets a title list sidebar for browsing content items
- **Other sections:** Get their own layout as appropriate (no forced sidebar pattern)
