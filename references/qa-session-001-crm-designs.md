# Q&A Session 001 — CRM Design Review

> **Date:** 2026-03-02
> **Files reviewed:** 14 Markaz CRM screens from Figma project
> **Status:** Draft — pending confirmation from Badie on exact values

## Screen Inventory

| # | File | Screen Name | Type |
|---|---|---|---|
| 01 | `3cZj3apxFbZAIp4Cv3q9uy` | Contact Detail View | Detail |
| 02 | `vz73o3WIpZQ5vJiKxKTHD9` | Contact List View | List |
| 03 | `e2pP4dW9xKY4wc92s1wAOp` | Tag Input — Type-Ahead | Interaction |
| 04 | `LgjNUzu6QdKz7kocs8K7pY` | Compact Card View | List (alt) |
| 05 | `whBwTP18dOGKXxreGovpL0` | Search Initial State | Search |
| 06 | `0Vk6JGBynsacpYrqPukYkG` | Active Search Results | Search |
| 07 | `QmPw8Hyi8qIbzVcmOZItFX` | Dashboard | Dashboard |
| 08 | `Nnil0hCxAoJ95x0M28qB8Y` | Accounts List View | List |
| 09 | `2PyGqSK3zDjpo35IukJc0o` | Account / Organization Detail | Detail |
| 10 | `rvDJMDg91S6L34qUhFiDrg` | Engagements View | List/Timeline |
| 11 | `ltHGpk0KgeXdN6UI5hv04V` | Engagement Detail View | Detail |
| 12 | `mSPRhRJsGLlp8pXlIdvU0l` | Data Quality Dashboard | Dashboard |
| 13 | `lSW6GbDYqmrx9wA1jaspNa` | Contacts List — Data Quality Column | List |
| 14 | `r5HmNLkOsGERD0DG4aSgxT` | Contact Detail — Data Completeness Panel | Detail |

## CRM Navigation Pattern

CRM uses 4 top-bar items: **Dashboard**, **Contacts**, **Accounts**, **Engagements**

This confirms the two-level nav pattern:
- **Level 1 (Markaz-wide):** Dashboard, Content, CRM, Avails, Screenings, etc.
- **Level 2 (within CRM):** Dashboard, Contacts, Accounts, Engagements

The CRM screens show level 2 only (no parent Markaz nav visible above). When integrated, the Markaz top bar would sit above with "CRM" active, and these 4 items would form the section sub-nav.

## Color System — CRM-Specific Findings

### Tag Group Colors (categorical, by group)

Tags are color-coded by their **group**, not individually. This is the most important color pattern in CRM.

| Tag Group | Dot/Chip Color | Example Tags |
|---|---|---|
| Buyers | Orange/coral (~`#E85D3A` or `#D4772C`) | Buyer — Theatrical, Buyer — Digital, Buyer — Television |
| Press | Blue (~`#3B82F6`) | Press — Online Critic, Press — Podcaster, Press — Publicist |
| Festivals | Teal/green-blue (~`#0EA5E9` or `#06B6D4`) | Festival — Programmer, Fest — Acquisitions, Fest — Screener |
| Sellers | Green (~`#22A06B`) | Seller — Sales Agent |
| Institutional | Purple (~`#8B5CF6`) | Institutional — University |
| Organizations | Dark gray (~`#6B7280`) | — |
| Internal | Gray (~`#9CA3AF`) | — |

> **Open question for Badie:** Exact hex values for each tag group color?

### Engagement Type Colors

| Type | Badge Color | Notes |
|---|---|---|
| EMAIL | Blue (~`#2563EB`) | Outlined badge on Screen 01, filled on Screen 10 |
| MEETING | Orange (~`#D4772C` or `#F59E0B`) | |
| CALL | Green (~`#22A06B`) | |
| NOTE | Gray (~`#6B7280`) | |

### Health / Status Colors

| Status | Color | Usage |
|---|---|---|
| Active | Green (`#22A06B`) | Account health, contact status |
| Warm | Amber (`#D4772C`) | Account health |
| Cold | Red (~`#DC3545`) | Account health |
| Follow up | Orange/amber | Contact status in search results |

### Data Quality Grade Colors

| Grade | Color | Usage |
|---|---|---|
| Excellent | Green (~`#22A06B`) | 80%+ completeness |
| Good | Blue (~`#2563EB`) | 60-79% |
| Fair | Orange (~`#D4772C`) | 40-59% |
| Poor | Red (~`#DC3545`) | Below 40% |

### Priority Level Colors

| Level | Color | Usage |
|---|---|---|
| HIGH | Orange/red (~`#E85D3A`) | Data completeness field priority |
| MED | Blue/gray (~`#6B7280`) | Data completeness field priority |
| LOW | Light gray (~`#9CA3AF`) | Data completeness field priority |

### Follow-up Urgency Colors

| Urgency | Color | Examples from Screen 07 |
|---|---|---|
| Overdue | Red (~`#DC3545`) | "7d overdue", "5d overdue" |
| Due today | Orange (~`#D4772C`) | "Due today" |
| Due tomorrow | Orange (lighter) | "Due tomorrow" |
| Upcoming | Gray (~`#6B7280`) | "In 3 days", "In 5 days", "In 7 days" |

### Trend Indicator Colors

| Direction | Color | Example from Dashboard |
|---|---|---|
| Positive trend | Green (~`#22A06B`) | "↑ 34 this month", "↑ 12% vs last week" |
| Negative/alert trend | Red (~`#DC3545`) | "↑ 3 since yesterday" (overdue follow-ups) |

## Avatar Color System

Contact avatars use colored circle backgrounds with white initials. Colors appear to be assigned per-person (not per-role). Observed colors:

- Dark navy/blue (SC — Sarah Chen)
- Orange (JP — James Park, NR — Nora Ramirez)
- Green (ML — Maria Lopez, SC — Sarah Chen in Screen 06)
- Teal (AW — Alex Wright)
- Purple (TH — Tom Harris)
- Red (DK — David Kim, RN — Rachel Nakamura in Screen 12)
- Yellow/gold (NH — Nathan Hayes)

> **Open question:** Is avatar color deterministic (derived from initials/name hash) or manually assigned?

## Components Identified — CRM

### New Shared Components (Design System level)

These components appear across multiple CRM screens and would generalize to other apps:

| Component | Screens | Description |
|---|---|---|
| **AvatarCircle** | All | Colored circle with initials, multiple sizes (sm/md/lg) |
| **AvatarStack** | 08 | Overlapping avatars with "+N" overflow count |
| **TagChip** | 01-06, 08-11, 13-14 | Colored dot + "Group — Role" label, removable variant |
| **GroupChip** | 01, 03 | Outline chip for auto-derived groups (Buyers, Festivals, Press) |
| **FilterChipBar** | 02, 08, 13 | Row of toggle chips with counts, active state (filled) |
| **StatCard** | 07, 12 | All-caps label + large number + trend indicator |
| **SearchBar** | 05, 06 | Full-width input with Search (primary) + Export (outline) buttons |
| **FilterPanel** | 05, 06, 10 | Left sidebar with collapsible accordion filter sections |
| **ActiveFilterPills** | 06 | Removable pills showing active filters above results |
| **DataTable** | 02, 06, 08, 13 | Sortable table with column headers, row hover |
| **Pagination** | 06 | Numbered page buttons with arrow navigation |
| **EmptyState** | 05 | Centered icon + message + quick-access shortcut cards |
| **ProgressRing** | 12, 13, 14 | Circular progress with percentage, color-graded |
| **HealthBadge** | 08 | Colored dot + "Active"/"Warm"/"Cold" text |
| **PriorityBadge** | 14 | "HIGH"/"MED"/"LOW" colored label |
| **BreadcrumbNav** | 11 | "← Back / Page Title" breadcrumb |
| **ListCardToggle** | 06 | Switch between list and card view |
| **InternalNote** | 11 | Yellow/amber highlighted text block |
| **AttachmentCard** | 11 | File type icon (XLS/PDF) + filename + size |
| **FollowUpAlert** | 11 | Amber card: description + due date + Complete/Snooze buttons |
| **QuickActionList** | 07 | List of "+ Action" buttons (Log engagement, Add contact, etc.) |

### CRM-Specific Components

| Component | Screens | Description |
|---|---|---|
| **ContactDetailPanel** | 01, 14 | Left panel: avatar, name, title, account, stats, contact info, tags, groups |
| **ContactCard** | 04, 09 | Card: avatar + name + company + tags + last engaged + engagement count |
| **ContactListRow** | 02, 13 | Table row: avatar + name + title + tags + quality + last engaged + account |
| **AccountDetailPanel** | 09 | Left panel: avatar, company, type badge, stats, info, tag groups, titles |
| **AccountListRow** | 08 | Table row: avatar + name + type + location, stacked contacts, tags, health |
| **EngagementCard** | 10 | Timeline card: type badge + time + title + summary + contacts + linked items |
| **EngagementDetailView** | 11 | Full email/meeting view: header + content + attachments + notes + thread |
| **EngagementTimeline** | 01, 11 | Chronological list of engagement entries with type badges |
| **EmailThread** | 11 | List of email messages in a thread with status dots |
| **DataQualityOverview** | 12 | Donut chart + grade distribution + gap stat cards |
| **DataCompletenessChecklist** | 14 | Field-by-field checklist with priority, status, progress bar |
| **TagInput** | 03 | Type-ahead input with grouped dropdown, chip display, auto-groups |
| **ActivityFeed** | 07 | Recent activity list with type icons + descriptions + timestamps |
| **FollowUpQueue** | 07 | List with avatar + task + urgency color-coded timing |
| **ContactsByGroup** | 07 | Stacked bar chart + legend with group colors |

## Layout Patterns

### Dashboard Layout (Screen 07)

```
+-------------------------------------------------------+
| NavBar                                                 |
+-------------------------------------------------------+
| Greeting + Date                                        |
+--------+--------+--------+--------+                    |
| Stat   | Stat   | Stat   | Stat   |                   |
+--------+--------+--------+----------------------------+
| Recent Activity (wide)   | Follow-up Queue             |
|                          |                              |
|                          |                              |
+--------------------------+------------------------------+
| Contacts by Group (wide) | Quick Actions                |
+--------------------------+------------------------------+
```

### List Layout (Screens 02, 08)

```
+-------------------------------------------------------+
| NavBar                                                 |
+-------------------------------------------------------+
| [Search...] FilterChips [+ New]                        |
+-------------------------------------------------------+
| Column Headers                                         |
+-------------------------------------------------------+
| Row 1                                                  |
| Row 2                                                  |
| ...                                                    |
+-------------------------------------------------------+
```

### Search Layout (Screens 05, 06)

```
+-------------------------------------------------------+
| NavBar                                                 |
+-------------------------------------------------------+
| [Full-width Search Bar]         [Search] [Export]      |
+-------------------------------------------------------+
| Active Filter Pills                                    |
+-----------+-------------------------------------------+
| Filters   | Results Table / Empty State                |
| Panel     |                                            |
| (sidebar) |                                            |
+-----------+-------------------------------------------+
```

### Detail Layout — Two-Panel (Screens 01, 09, 14)

```
+-------------------------------------------------------+
| NavBar                                                 |
+-----------+-------------------------------------------+
| Left      | Tabs                                       |
| Panel     +-------------------------------------------+
| (profile) | Tab Content                                |
|           | (cards, timeline, table)                   |
+-----------+-------------------------------------------+
```

### Detail Layout — Three-Panel (Screen 11)

```
+-------------------------------------------------------+
| NavBar                                                 |
+-------------------------------------------------------+
| ← Breadcrumb                                           |
+-------------------------------------------+-----------+
| Main Content                              | Right     |
| (email body, attachments, thread)         | Sidebar   |
|                                           | (linked   |
|                                           |  records) |
+-------------------------------------------+-----------+
```

## Cross-Reference: CRM vs Markaz Content Designs

| Pattern | Markaz Content | CRM | Shared? |
|---|---|---|---|
| Top bar (white, brand + nav + search) | Yes | Yes | YES — identical |
| Two-level nav | Section tabs below hero | CRM sub-nav in top bar | YES — pattern shared, content differs |
| Left sidebar browser | Title browser with filters | Filter panel on search | SIMILAR — both use left sidebar for filtering |
| Detail with left panel | Poster + title + metadata | Avatar + name + contact info | YES — same layout pattern |
| Right sidebar | Not seen | Linked records (Screen 11) | CRM-specific |
| Stat cards row | Progress circles + counts | Large number + trend | YES — same pattern, different content |
| Data table | Technical Specs key-value | Contact/Account lists | YES — shared table component |
| Tab navigation | Content tabs (Metadata, Files...) | Detail tabs (Contacts, Engagements...) | YES — same Bootstrap nav-tabs |
| Badge system | Status badges (Active, Original...) | Tag chips + type badges | SIMILAR — both use colored badges |
| Card grid | Not seen | Compact contact cards (Screen 04, 09) | CRM introduces card grid |
| Progress ring | Yes (Metadata %, Archive %) | Yes (Data Quality %) | YES — identical component |
| Timeline | Not seen | Engagement timeline | CRM introduces timeline |
| Empty state | Not seen | Search initial state | CRM introduces empty state |

## Consistency Notes

### Consistent Across All Designs
- White top bar with X MARKAZ brand, blue active nav + underline
- Light gray page background (`~#F5F7FA`)
- White card surfaces
- Light gray borders on cards/tables
- All-caps letter-spaced section labels
- Bootstrap-compatible spacing patterns
- System font stack (no custom fonts)

### Inconsistencies to Resolve
1. **CRM nav shows 4 items** (Dashboard, Contacts, Accounts, Engagements) — the Markaz Content nav shows 5 (Dashboard, Content, CRM, Avails, Screenings). When CRM is nested under Markaz, does the CRM sub-nav replace the top bar or sit below it?
2. **Tag chip styles** vary slightly between screens — some have outline style, others filled
3. **Badge shape** — some badges are pill-shaped (rounded), others are more rectangular
4. **Screen 01 vs Screen 14** both show contact detail but with different right-panel content (engagement timeline vs data completeness). Are these tabs on the same page, or different views?

## Open Questions for Badie (CRM-specific)

8. **Tag group color palette** — exact hex values for each group (Buyers, Press, Festivals, Sellers, Institutional, Organizations, Internal)?
9. **Avatar color assignment** — how are avatar colors determined per contact?
10. **CRM sub-nav integration** — when CRM is a section within Markaz, does the 4-item CRM nav appear as a second bar, or replace the main nav items?
11. **Contact detail tabs** — Screens 01 and 14 show different right-panel content. Is the data completeness panel a tab alongside the engagement timeline?
12. **Engagement type colors** — are EMAIL=blue, MEETING=orange, CALL=green, NOTE=gray the final assignments?
13. **Data quality thresholds** — at what percentages do quality grades change (Excellent/Good/Fair/Poor)?
14. **Card vs list view** — is the card/list toggle (Screen 06) available on all list pages, or just contacts search?
