# MPI Design System

A shared design language and component catalog for MPI Media applications.

## What This Is

This repo is the **single source of truth** for MPI's visual design language. It contains:

- **Design tokens** — Colors, typography, spacing, and Bootstrap 5 customizations
- **Component catalog** — Specs for every UI building block used across MPI apps
- **Workflow documentation** — How to propose, design, review, and approve components
- **Visual references** — Approved renders (PNGs, PDFs) stored alongside their specs
- **CLAUDE.md** — A context file that anchors AI design sessions to the shared design language

This is a **documentation and specification repo**, not a code library. Implementation happens in each app's codebase using ViewComponents and Bootstrap 5.

## Applications

The design system serves these MPI Media applications:

| App | Purpose |
|---|---|
| **Optimus** | Rails application template and pattern source |
| **Avails** | Central data repository |
| **SFA** | Video clip hosting and search |
| **Garden** | Static site generator |
| **Harvest** | Ecommerce platform |

## Repo Structure

```
mpi-design-system/
├── CLAUDE.md                    # Context file for Claude design sessions
├── CONTRIBUTING.md              # How to propose, review, approve designs
│
├── tokens/                      # Design tokens
│   ├── colors.md
│   ├── typography.md
│   ├── spacing.md
│   └── bootstrap-overrides.md
│
├── catalog/                     # Component catalog
│   ├── elements/                # Buttons, inputs, badges, icons, links
│   ├── components/              # Cards, modals, navbars, tables, alerts
│   ├── patterns/                # Forms, search, filters, data entry
│   └── layouts/                 # Dashboards, detail pages, list views
│
├── workflow/                    # Design governance
│   ├── design-proposal.md
│   └── review-checklist.md
│
├── references/                  # Approved visual references (PNGs, PDFs)
│
└── tooling/                     # Tool guides and recommendations
```

## Taxonomy

Components are organized using **plain language categories** with cross-references to Atomic Design and Bootstrap 5 terminology:

| Category | What it contains | Atomic equivalent |
|---|---|---|
| **Elements** | Smallest building blocks — buttons, inputs, badges, icons, links | Atoms |
| **Components** | Self-contained UI units — cards, modals, navbars, tables, alerts | Molecules |
| **Patterns** | Recurring multi-component arrangements — forms, search, filters | Organisms |
| **Layouts** | Full page structures — dashboards, detail pages, list views | Templates/Pages |

## Quick Start

### For Designers (Badie + Claude)

1. Open a Claude session (claude.ai or Claude Code)
2. Paste or attach the contents of [`CLAUDE.md`](CLAUDE.md) at the start of the conversation
3. Claude will design within the established design language
4. Export artifacts as PDF/PNG and attach to the relevant GitHub issue

### For Developers

1. Find the approved component spec in [`catalog/`](catalog/)
2. Implement as a ViewComponent in the target Rails app
3. Follow the Bootstrap 5 classes and markup documented in the spec
4. Reference the design tokens in [`tokens/`](tokens/) for customizations

### For Reviewers

1. Check the [GitHub Project board](https://github.com/orgs/mpimedia/projects/14) for items in "In Review"
2. Review the design against the [`workflow/review-checklist.md`](workflow/review-checklist.md)
3. Comment on the issue with approval or requested changes

## Design Workflow

```
Propose → Design → Review → Approve → Implement → Done
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full process.

## Project Board

Track design system progress on the [MPI Design System project board](https://github.com/orgs/mpimedia/projects/14).

## Related Repositories

- [mpi-application-standards](https://github.com/mpimedia/mpi-application-standards) — Shared Claude Code and development standards
- [mpi-application-workflows](https://github.com/mpimedia/mpi-application-workflows) — Reusable GitHub Actions workflows
- [.github](https://github.com/mpimedia/.github) — Organization-wide templates and defaults
