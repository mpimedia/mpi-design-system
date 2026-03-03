# Navigation

Design tokens and structure for MPI application navigation.

> **Status:** Confirmed — structure finalized by Badie (2026-03-02, Q&A Session 001).

## Navigation Model

MPI apps use a **two-level navigation** pattern:

1. **Top bar** — Main sections (always visible)
2. **Sub-nav** — Section-specific navigation (appears below top bar when a section is active)

## Markaz Top Bar (Canonical)

All MPI apps follow the Markaz navigation pattern. The top bar shows these sections:

| Position | Label | Notes |
|---|---|---|
| 1 | Dashboard | App-wide overview |
| 2 | Content | Includes Assets (formerly separate) |
| 3 | CRM | Customer relationship management |
| 4 | Rights & Avails | Combined (formerly separate sections) |
| 5 | Releases | Standalone section |
| 6 | Screenings | Standalone section |

### Section Mapping Decisions

- **Rights + Avails** — Combined into one top-bar item ("Rights & Avails")
- **Assets** — Moved under Content (not a top-bar item)
- **Websites** — Not in top bar (status TBD per app)

## CRM Sub-Navigation

When CRM is selected in the top bar, a second navigation bar appears below with:

| Position | Label |
|---|---|
| 1 | Dashboard |
| 2 | Contacts |
| 3 | Accounts |
| 4 | Engagements |

## Other Section Sub-Navs

Each section may define its own sub-nav items. These will be documented as each section's designs are finalized.

## Layout Pattern

```
┌──────────────────────────────────────────────────────┐
│  [Logo]  Dashboard  Content  CRM  Rights & Avails  … │  ← Top bar (always visible)
├──────────────────────────────────────────────────────┤
│  Dashboard  Contacts  Accounts  Engagements          │  ← Sub-nav (section-specific)
├──────────────────────────────────────────────────────┤
│                                                      │
│                   Page content                       │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## Bootstrap Implementation

- Top bar: Bootstrap `navbar` with `nav-link` items
- Sub-nav: Second `navbar` or `nav nav-tabs` bar below the main navbar
- Active states use `$mpi-primary` (`#2E75B6`)
- White background for both bars (V2 canonical style)
