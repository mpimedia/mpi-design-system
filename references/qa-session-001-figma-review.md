# Q&A Session 001 — Figma Design Review

> **Date:** 2026-03-02
> **Files reviewed:**
> - Brand Identity: `figma.com/design/yJK8mEtKj1CmAGagCoTuE9/Brand_01_Logo_Lockups`
> - Markaz App: `figma.com/design/ldgy5eCURURkP9a051g2iZ/01_Metadata`
> **Status:** Draft — pending confirmation from Badie on exact values

## Decisions Confirmed This Session

1. **Brand identity is stable** — extract tokens now
2. **Markaz layout is canonical** — all MPI apps will follow this pattern
3. **Two-level navigation confirmed** — top bar shows main sections (always visible), second level shows section-specific links
4. **Colors V1 confirmed** — green `#22A06B`, amber `#D4772C` (from Issue #5)

## Colors — Draft Extraction

Values below are approximate (eyedropped from rasterized Figma screenshots). Must be confirmed with Badie before finalizing.

### Brand Colors

| Token | Draft Value | Source | Notes |
|---|---|---|---|
| `$mpi-brand-navy` | ~`#1E2A4A` | Brand file, dark backgrounds | Deep navy used in logo lockups |
| `$mpi-brand-blue-accent` | ~`#4A90D9` | Brand file, diamond accent | Brighter blue at center of X mark |
| `$mpi-brand-cream` | ~`#FAF8F5` | Brand file, page background | Off-white brand canvas |

### App Colors (from Markaz screen)

| Token | Draft Value | Source | Notes |
|---|---|---|---|
| `$mpi-primary` | ~`#2563EB` | Active nav item, primary button | Blue used for "Edit Metadata" button and "Content" active tab |
| `$mpi-success` | `#22A06B` | Confirmed Issue #5 | Green progress rings, "Active" badges, green dot indicators |
| `$mpi-warning` | `#D4772C` | Confirmed Issue #5 | Amber percentages (68%), orange badges |
| `$mpi-danger` | ~`#DC3545` | Low-completion items (38%) | Red percentage indicators — may be Bootstrap default |
| `$mpi-info` | ~`#3B82F6` | "IMDB" badges, metadata badges | Blue informational badges |

### Neutral Colors

| Token | Draft Value | Source | Notes |
|---|---|---|---|
| `$mpi-text` | ~`#1A1A2E` | Primary headings, body text | Near-black |
| `$mpi-text-muted` | ~`#6C757D` | Secondary text, section labels | Medium gray — may match Bootstrap `text-muted` |
| `$mpi-border` | ~`#DEE2E6` | Card borders, dividers | Light gray — may match Bootstrap default |
| `$mpi-background` | ~`#F5F7FA` | Page background behind cards | Very light gray |
| `$mpi-surface` | `#FFFFFF` | Cards, panels, top bar | White |

### Badge Colors (observed in Markaz design)

| Usage | Color | Background |
|---|---|---|
| "Active" badge | White text | Green (`#22A06B`) |
| "Marketing" badge | White text | Teal/green |
| "Original" badge | Dark text | Light gray |
| "Delivery" badge | White text | Orange/coral |
| "Feature Film" badge | White text | Blue |
| "Dark Sky Films" badge | White text | Dark blue/navy |
| "IMDB" badge | White text | Gold/amber |

> **Open question:** Are badge colors semantic (always green = active, orange = delivery) or brand-specific (Dark Sky = dark blue)?

## Typography — Draft Extraction

### Confirmed

- **Font family:** Bootstrap default system font stack (not DM Sans) — confirmed Issue #5
- **Heading font:** Appears to be same as body (system font stack)

### Observed from Markaz Design

| Element | Approx. Size | Weight | Style | Notes |
|---|---|---|---|---|
| Page title ("The Harvest") | ~28-32px | Bold (700) | Normal | Largest text on page |
| Tagline ("Some roots run deeper...") | ~16px | Normal (400) | Italic | Subtitle under title |
| Section labels ("SYNOPSIS", "CREDITS & DETAILS") | ~11-12px | Bold (600-700) | Uppercase, letter-spaced | All-caps micro headers |
| Tab labels ("Metadata", "Archive Files") | ~14px | Normal/Medium | Normal | With count badges |
| Top nav items ("Dashboard", "Content") | ~14px | Normal (400) | Normal | Active item is blue + underline |
| Body text (synopsis text) | ~14px | Normal (400) | Normal | Standard paragraph text |
| Card labels ("DIRECTOR", "WRITER") | ~11-12px | Bold (600) | Uppercase | Small label above value |
| Card values ("Sarah Chen") | ~14-16px | Normal (400) | Normal | |
| Sidebar title items ("The Harvest") | ~14px | Bold (600) | Normal | |
| Sidebar metadata ("2024 DARK SKY") | ~12px | Normal (400) | Normal | Muted color |

### Bootstrap Mapping (tentative)

| Design Element | Bootstrap Class |
|---|---|
| Page title | `h3` or `h4` (not `h1` — this is within content area) |
| Section labels | Custom: `text-uppercase fw-bold fs-6 letter-spacing` |
| Tab bar | Bootstrap `nav-tabs` |
| Body text | Default `p` / `fs-6` |
| Card labels | `text-uppercase fw-bold small` |

## Navigation — Two-Level Pattern

### Level 1: Top Bar (always visible)

```
[X MARKAZ]  Dashboard  Content  CRM  Avails  Screenings    [Search...]  [Avatar]
```

- White background, full-width
- Brand mark (X + MARKAZ) on left
- Section nav items center-left
- Active section: blue text + blue underline
- Global search bar on right
- User avatar (initials) far right

**Open question:** The Figma shows 5 sections (Dashboard, Content, CRM, Avails, Screenings) but Markaz has 7 sections (Rights, CRM, Content, Websites, Assets, Releases, Screenings). How do the missing sections map?

Possible mapping:
- "Avails" = Rights section?
- Websites, Assets, Releases may be sub-items within Content?
- Or the topbar items will differ per-app?

### Level 2: Section-Specific Nav

Within "Content" section, the second level appears as:
- **Left sidebar:** Title browser with search, filters, and scrollable list
- **Content tabs:** Metadata, Archive Files, Delivery Tracking, Press, Awards, Rights & Avails

> This may be Content-specific. CRM's second level would have its own links.

## Components Identified

### Shared (Design System level)

| Component | Current Equivalent | Description |
|---|---|---|
| **NavBar** | `Admin::NavBar` | White top bar with brand, section nav, search, avatar |
| **NavItem** | `Admin::NavItem` | Top nav link with active state (blue + underline) |
| **SidebarBrowser** | _New_ | Left sidebar with search, filters, scrollable item list |
| **FilterChip** | _New_ | Small toggle chips (All, MPI, Dark Sky, WP) |
| **Badge** | Bootstrap `badge` | Colored labels (Active, Marketing, IMDB, etc.) |
| **ProgressCircle** | _New_ | Circular progress indicator with percentage |
| **StatCard** | _New_ | Circular stat + label + subtitle (e.g., "12 Awards") |
| **TabBar** | Bootstrap `nav-tabs` | Content section tabs with counts |
| **DetailCard** | _New_ | Label + value card (Credits & Details section) |
| **KeyValueTable** | `Admin::TableForShow` | Two-column key-value table (Technical Specifications) |
| **VersionedContent** | _New_ | Content block with version selector (Synopsis, Tagline) |
| **ActionButton** | `Admin::ActionButton` | Primary + outline button pair |
| **TitleHero** | _New_ | Poster + title + tagline + metadata + actions header |
| **PageContainer** | `Admin::PageContainer` | Main content wrapper |

### Markaz-Specific

| Component | Description |
|---|---|
| **TitleListItem** | Sidebar item: poster thumb, title, year, label, ID, completion % |
| **MetadataBadgeRow** | Row of metadata badges (studio, ID, format, year, IMDB) |
| **SynopsisVersion** | Single synopsis version with status dot + badges + text |

## Layout Pattern

```
+-------------------------------------------------------+
| NavBar (Level 1)                                       |
+----------+--------------------------------------------+
| Sidebar  | Hero Section                               |
| Browser  |   [Poster] Title / Tagline / Badges / CTAs |
|          +--------------------------------------------+
|          | Stats Row (progress circles + counts)       |
|          +--------------------------------------------+
|          | TabBar (Level 2 content nav)                |
|          +--------------------------------------------+
|          | Tab Content                                 |
|          |   Section > Cards/Tables/Versioned Content  |
+----------+--------------------------------------------+
```

## Open Questions for Badie

1. **Exact hex values** for all colors — the draft values above are approximate
2. **Navigation mapping** — how do 7 Markaz sections map to the 5 topbar items shown?
3. **Badge color system** — are badge colors semantic (status-based) or categorical (per-label)?
4. **Brand navy vs app primary** — is the logo navy (`~#1E2A4A`) the same as or different from the app primary blue (`~#2563EB`)?
5. **Sidebar pattern** — does every app section have a sidebar browser, or just Content?
6. **Progress circles** — are these a standard component, or Content-specific?
7. **Typography fine-tuning** — exact font sizes, weights, line-heights
