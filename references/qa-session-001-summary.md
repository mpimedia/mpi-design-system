# Q&A Session 001 — Summary & Questions for Badie

> **Date:** 2026-03-02
> **Designs reviewed:** 16 total (2 brand/app + 14 CRM)

## What Was Confirmed

1. Brand identity (The Nexus) is **stable** — ready to extract tokens
2. Markaz layout is **canonical** — all MPI apps follow this pattern
3. **Two-level navigation** — top bar always shows main sections; each section has its own sub-nav
4. **Colors V1** — green `#22A06B`, amber `#D4772C` (not Tailwind V2)
5. **Font** — Bootstrap default system stack (not DM Sans)

## Draft Token Values Extracted

All approximate — need Badie confirmation.

### Core Palette

| Token | Draft Value | Confidence | Source |
|---|---|---|---|
| `$mpi-primary` | ~`#2563EB` | Medium | Active nav, primary buttons |
| `$mpi-success` | `#22A06B` | **Confirmed** | Issue #5 |
| `$mpi-warning` | `#D4772C` | **Confirmed** | Issue #5 |
| `$mpi-danger` | ~`#DC3545` | Medium | May be Bootstrap default |
| `$mpi-info` | ~`#3B82F6` | Low | Informational badges |
| `$mpi-brand-navy` | ~`#1E2A4A` | Medium | Logo dark backgrounds |
| `$mpi-brand-blue-accent` | ~`#4A90D9` | Medium | Logo diamond |
| `$mpi-text` | ~`#1A1A2E` | Medium | Primary text |
| `$mpi-text-muted` | ~`#6C757D` | High | Likely Bootstrap default |
| `$mpi-border` | ~`#DEE2E6` | High | Likely Bootstrap default |
| `$mpi-background` | ~`#F5F7FA` | Medium | Page background |
| `$mpi-surface` | `#FFFFFF` | **Confirmed** | Cards, panels |

### Tag Group Colors (CRM — need exact values)

| Group | Draft Color |
|---|---|
| Buyers | ~`#D4772C` (amber/orange) |
| Press | ~`#3B82F6` (blue) |
| Festivals | ~`#06B6D4` (teal) |
| Sellers | ~`#22A06B` (green) |
| Institutional | ~`#8B5CF6` (purple) |
| Organizations | ~`#6B7280` (gray) |
| Internal | ~`#9CA3AF` (light gray) |

### Engagement Type Colors (CRM — need confirmation)

| Type | Draft Color |
|---|---|
| Email | ~`#2563EB` (blue) |
| Meeting | ~`#D4772C` (orange) |
| Call | ~`#22A06B` (green) |
| Note | ~`#6B7280` (gray) |

## Component Inventory

### Shared (Design System level) — 35 components total

**Already exist in apps (need redesign to match):**
- NavBar, NavItem, ActionButton, PageContainer, TableForShow, IndexPager, Badge

**New components identified from designs:**
- AvatarCircle, AvatarStack, TagChip, GroupChip, FilterChipBar
- StatCard, ProgressRing, SearchBar, FilterPanel, ActiveFilterPills
- DataTable (sortable), Pagination, EmptyState, ListCardToggle
- DetailCard, VersionedContent, BreadcrumbNav, QuickActionList
- InternalNote, AttachmentCard, FollowUpAlert, SidebarBrowser
- TitleHero, TabBar (with counts)

**CRM-specific (16 components):**
- ContactDetailPanel, ContactCard, ContactListRow
- AccountDetailPanel, AccountListRow
- EngagementCard, EngagementDetailView, EngagementTimeline, EmailThread
- DataQualityOverview, DataCompletenessChecklist, TagInput
- ActivityFeed, FollowUpQueue, ContactsByGroup, MetadataBadgeRow

## Layout Patterns Identified

| Pattern | Usage |
|---|---|
| Dashboard | Stat row + activity feed + sidebar widgets |
| List | Filter bar + data table |
| Search | Full search bar + filter sidebar + results |
| Detail (two-panel) | Left profile panel + right content with tabs |
| Detail (three-panel) | Breadcrumb + main content + right sidebar |
| Title detail | Hero + stats row + tabs + sectioned content |

## Consolidated Questions for Badie

### Colors (must answer for token files)
1. **Exact hex for primary blue** — the blue used in active nav items, primary buttons, links. Is it `#2563EB` or something else?
2. **Exact hex for brand navy** — the dark background in the logo lockups. Is it `#1E2A4A` or something else?
3. **Exact hex for brand blue accent** — the diamond in the X mark.
4. **Is danger/red Bootstrap default** (`#DC3545`) or a custom value?
5. **Tag group palette** — exact hex for each of the 7 tag group colors (Buyers, Press, Festivals, Sellers, Institutional, Organizations, Internal)?
6. **Engagement type colors** — are EMAIL=blue, MEETING=orange, CALL=green, NOTE=gray the final mapping?

### Navigation
7. **Section mapping** — Markaz has 7 sections (Rights, CRM, Content, Websites, Assets, Releases, Screenings) but the Content design shows 5 top-bar items (Dashboard, Content, CRM, Avails, Screenings). How do the missing sections map?
8. **CRM sub-nav integration** — when CRM is inside Markaz, does the CRM 4-item nav (Dashboard, Contacts, Accounts, Engagements) sit as a second bar below the Markaz top bar?

### Components
9. **Avatar color assignment** — are avatar colors deterministic (derived from name) or manual?
10. **Badge shape** — some badges are pill-shaped, others rectangular. Which is canonical?
11. **Contact detail right panel** — Screens 01 and 14 show different right-panel content (engagement timeline vs data completeness). Are these tabs on the same page?
12. **Progress ring / data quality thresholds** — at what percentages do grades change (Excellent ≥80%? Good ≥60%? Fair ≥40%? Poor <40%)?
13. **Card/list toggle** — available on all list pages or just contacts search?
14. **Sidebar browser pattern** — does every Markaz section have a left sidebar browser (like Content's title list), or is it section-specific?

## Files Reference

See detailed analysis in:
- `references/qa-session-001-figma-review.md` — Brand + Markaz Content designs
- `references/qa-session-001-crm-designs.md` — CRM designs (14 screens)
