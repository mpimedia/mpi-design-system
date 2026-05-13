# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Project

MPI Design System is a Rails engine gem that provides shared ViewComponents, design tokens, and Stimulus controllers for all MPI Media applications (Markaz, SFA, Garden, Harvest). It defines the visual language and reusable UI components used across the ecosystem.

## Tech Stack

- Ruby 3.4+ / Rails 8.1+
- ViewComponent 3.0+
- Bootstrap 5.3 (tokens + classes)
- Hotwire (Stimulus controllers)
- Node / Yarn 4.12.0
- esbuild (JS) / Sass (CSS)
- RSpec + Capybara (testing)
- Lookbook (component previews)

## MPI Applications Using This Engine

- **Markaz** — Content management and distribution platform
- **SFA** — Video clip hosting and search
- **Garden** — Static site generator
- **Harvest** — Ecommerce platform

All apps share a common visual language defined by this design system.

## Setup

```bash
bundle install
yarn install
```

## Commands

```bash
# Development server (runs web, js, css)
bin/dev

# Tests
bundle exec rspec                              # All tests
bundle exec rspec spec/components/             # Directory
bundle exec rspec spec/components/admin/badge/component_spec.rb      # Single file
bundle exec rspec spec/components/admin/badge/component_spec.rb:42   # Single line

# Linting
bundle exec rubocop        # Check all files
bundle exec rubocop -a     # Auto-correct

# Assets
yarn build                  # JS (esbuild)
yarn build:css              # CSS (sass)

# Lookbook (component previews)
# Visit http://localhost:3000/lookbook after running bin/dev
```

## Required Workflow

**ALWAYS run linting and tests before committing or pushing.**

```bash
bundle exec rubocop -a
bundle exec rspec
```

Both must pass before any `git commit` or `git push`. No exceptions.

## Permissions and Autonomy

### Branch-Based Permissions

**On feature branches (any branch except `main`):**
- **FULL AUTONOMY GRANTED** — Proceed with all changes without asking "should I proceed" or similar permission questions
- Make commits, edit files, refactor code, and implement features directly
- Run tests and linting, fix issues, and commit fixes automatically
- Only ask questions for **requirement clarification** (what to build, not whether to proceed)

**On `main` branch:**
- Ask before making any changes
- Require explicit user approval for commits

Check the branch before starting work:
```bash
git branch --show-current
```

## Project Structure

```
app/
├── assets/
│   ├── config/manifest.js
│   ├── stylesheets/mpi_design_system/
│   │   ├── application.scss          # Main engine stylesheet
│   │   └── _tokens.scss              # Design token overrides
│   └── images/mpi_design_system/
├── components/admin/                  # ViewComponents (Admin::Name::Component)
│   ├── badge/
│   │   ├── component.rb
│   │   └── component.html.erb
│   └── ...
├── javascript/mpi_design_system/      # Engine JS exports
│   ├── index.js                       # Main export
│   └── controllers/
│       ├── index.js                   # registerMpiControllers(application)
│       └── tag_input_controller.js
├── helpers/
└── views/
lib/
├── mpi_design_system.rb
└── mpi_design_system/
    ├── engine.rb
    └── version.rb
spec/
├── components/                        # Component specs
│   ├── previews/                      # Lookbook previews
│   └── admin/
├── dummy/                             # Test Rails app
└── spec_helper.rb
```

## Component Conventions

- Components follow `Admin::Name::Component` pattern at `app/components/admin/`
- Each component has `component.rb` (Ruby logic) and `component.html.erb` (template)
- Use Bootstrap 5 classes for all styling — no custom CSS unless absolutely necessary
- Use SCSS design tokens from `app/assets/stylesheets/mpi_design_system/_tokens.scss`
- Interactive behavior uses Stimulus controllers in `app/javascript/mpi_design_system/controllers/`

### Component Catalog

Before creating a new component, check the existing catalog:

- `catalog/elements/` — Buttons, inputs, badges, icons, links (Atoms)
- `catalog/components/` — Cards, modals, navbars, tables, alerts (Molecules)
- `catalog/patterns/` — Forms, search bars, filters, data entry (Organisms)
- `catalog/layouts/` — Dashboards, detail pages, list views (Templates)

## Design Tokens

Reference these tokens when choosing values. Do not invent arbitrary colors, sizes, or spacing.

### Colors

- Use semantic color classes (`btn-primary`, `text-danger`, `bg-success`) rather than custom hex values
- Custom tokens are defined in `app/assets/stylesheets/mpi_design_system/_tokens.scss`
- Primary: `#2E75B6`, Navy: `#1B2A4A`, Accent: `#4EA8DE`
- See `tokens/colors.md` for full documentation

### Typography

- Use Bootstrap's heading classes (`h1`–`h6`) and text utilities (`fs-1`–`fs-6`)
- Use the default Bootstrap font stack

### Spacing

- Use Bootstrap's spacing utilities (`p-3`, `mb-4`, `gap-2`)
- Follow the spacing scale: 0, 0.25rem, 0.5rem, 1rem, 1.5rem, 3rem

## Technology Constraints

- **Use Bootstrap 5** — All MPI apps use Bootstrap 5
- **Use standard Bootstrap classes** — Prefer Bootstrap's built-in utilities over custom CSS
- **Use ViewComponents** — All UI components are `view_component` classes
- **Hotwire stack** — Turbo + Stimulus for all client-side behavior. No React/Vue/Angular
- **Produce HTML/CSS artifacts** — Valid HTML that maps directly to Rails ERB templates
- **Responsive by default** — Use Bootstrap's grid system and responsive utilities
- **Do not use Tailwind CSS** — MPI uses Bootstrap 5

## Accessibility Requirements

- WCAG 2.1 AA compliance minimum
- All interactive elements must be keyboard-accessible
- Include appropriate ARIA roles and labels
- Maintain 4.5:1 contrast ratio for normal text, 3:1 for large text
- Provide visible focus indicators

## Commit and PR Standards

**All commits and PRs must have verbose, detailed documentation.**

### Commit Message Format

```
Brief summary (50 chars or less)

Detailed explanation of changes:
- What was changed and why
- Technical approach taken
- Any architectural decisions made

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

### PR Description Format

```markdown
## Summary
Detailed overview of what this PR accomplishes and why it was needed.

## Changes Made
- Bullet point list of specific changes
- Include file paths and key modifications

## Technical Approach
- Design patterns used
- Why this approach was chosen

## Testing
- What was tested and how

## Checklist
- [ ] Tests pass
- [ ] Linting passes
```

## Agent Attribution (Required — No Exceptions)

Every AI agent **must** include attribution on every piece of work:

- **Commits**: `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
- **PRs**: Agent name in description footer
- **Comments**: Attribution line

## Claude Code Settings

Claude Code uses two settings files in `.claude/`:

| File | Checked In | Purpose |
|------|-----------|---------|
| `.claude/settings.json` | Yes | Shared team settings — minimal permissions, hooks (branch protection) |
| `.claude/settings.local.json` | No (gitignored) | Personal settings — full permissions, MCP server access, local preferences |

## Related Projects

See `.claude/projects.json` for the MPI Media ecosystem. Create `.claude/projects.local.json` (gitignored) with local paths for cross-repo operations.
