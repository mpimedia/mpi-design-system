# Q&A Session 001 — Summary

> **Date:** 2026-03-02
> **Designs reviewed:** 16 total (2 brand/app + 14 CRM)
> **Status:** All 14 questions answered. Token files updated.

## What Was Confirmed (Before Q&A)

1. Brand identity (The Nexus) is **stable** — ready to extract tokens
2. Markaz layout is **canonical** — all MPI apps follow this pattern
3. **Two-level navigation** — top bar always shows main sections; each section has its own sub-nav
4. **Colors V1** — green `#22A06B`, amber `#D4772C` (not Tailwind V2)
5. **Font** — Bootstrap default system stack (not DM Sans)

## Badie's Answers (14 Questions)

### Colors (Q1–Q6)

**Q1. Primary blue hex?**
Answer: `#2E75B6` — used for buttons, links, active nav states.

**Q2. Brand navy hex?**
Answer: `#1B2A4A` — used for logo backgrounds, headings, body text.

**Q3. Brand blue accent (Nexus diamond) hex?**
Answer: `#4EA8DE`

**Q4. Is danger/red Bootstrap default?**
Answer: Yes — `#DC3545`, no custom value needed.

**Q5. Tag group palette?**
Answer: Confirmed with exact values:

| Group | Primary | Background |
|---|---|---|
| Buyers | `#E8733A` | `#FEF3EC` |
| Press | `#2DA67E` | `#ECF8F4` |
| Festivals | `#2E75B6` | `#EBF3FB` |
| Sellers | `#8B5CF6` | `#F3EFFE` |
| Institutional | `#D97706` | `#FEF9EC` |
| Organizations | `#6366F1` | `#EEEFFE` |
| Internal | `#64748B` | `#F1F5F9` |

**Q6. Engagement type colors?**
Answer: Confirmed with one change from draft (Meeting changed to purple, Note changed to orange):

| Type | Color |
|---|---|
| Email | `#2E75B6` (blue) |
| Meeting | `#8B5CF6` (purple) |
| Call | `#16A34A` (green) |
| Note | `#E8913A` (orange) |

### Navigation (Q7–Q8)

**Q7. Section mapping?**
Answer: Reorganized from 7 sections to 6 top-bar items:
- Rights + Avails → combined as "Rights & Avails"
- Assets → moved under Content
- Releases → stays as own top-bar item
- Final top bar: Dashboard, Content (includes Assets), CRM, Rights & Avails, Releases, Screenings

**Q8. CRM sub-nav integration?**
Answer: Confirmed. Second bar below top bar with: Dashboard, Contacts, Accounts, Engagements.

### Components (Q9–Q14)

**Q9. Avatar color assignment?**
Answer: Deterministic — derived from contact's name via hash. No manual assignment.

**Q10. Badge shape?**
Answer: Pill (`border-radius: 999px`) across the board.

**Q11. Contact detail right panel?**
Answer: Tabbed. One page, two tabs:
- Tab 1: Engagement Timeline
- Tab 2: Data Quality

**Q12. Data quality scoring thresholds?**
Answer: Field-based tiers, not just percentages:
- Poor: Name + Company only (0–29%)
- Fair: Name + Company + Email or Phone (30–49%)
- Good: Name + Company + Title + Email + Phone + Tags (50–84%)
- Excellent: All of the above + Engagement History (85–100%)
- Numeric scores weighted by field importance (for sorting)

**Q13. Card/list toggle?**
Answer: List view is default. Toggle to card view available on list pages (lower priority than list view).

**Q14. Sidebar browser pattern?**
Answer: Section-specific, not universal. Content gets the title list sidebar. Other sections get their own layout.

## Token Files Updated

All answers have been recorded in:
- `tokens/colors.md` — Full palette with confirmed hex values
- `tokens/navigation.md` — Navigation structure and section mapping (new file)
- `tokens/components.md` — Component behavior decisions (new file)
- `tokens/bootstrap-overrides.md` — Confirmed SCSS overrides

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

## Files Reference

See detailed analysis in:
- `references/qa-session-001-figma-review.md` — Brand + Markaz Content designs
- `references/qa-session-001-crm-designs.md` — CRM designs (14 screens)
