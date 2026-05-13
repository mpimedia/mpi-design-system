# AGENTS.md

Instructions for all AI coding agents (Claude Code, Copilot, and others) working in this repository.

## Project Overview

MPI Design System is a Rails engine gem providing shared ViewComponents, design tokens, and Stimulus controllers for the MPI Media application ecosystem (Markaz, SFA, Garden, Harvest).

**Tech Stack:** Ruby 3.4+ / Rails 8.1+ / ViewComponent 3.0+ / Bootstrap 5.3 / Hotwire (Stimulus) / esbuild / Sass

## Dev Environment

```bash
bin/dev                    # Start development server (web, js, css)
bundle exec rspec          # Run all tests
bundle exec rubocop -a     # Lint and auto-correct
yarn build                 # Build JS
yarn build:css             # Build CSS
```

## Testing Instructions

```bash
bundle exec rspec                                          # All tests
bundle exec rspec spec/components/admin/badge/             # Directory
bundle exec rspec spec/components/admin/badge/component_spec.rb      # Single file
bundle exec rspec spec/components/admin/badge/component_spec.rb:42   # Single line
```

- RSpec with ViewComponent test helpers
- Capybara for rendered output assertions
- Dummy app at `spec/dummy/` for integration testing

## Linting

```bash
bundle exec rubocop        # Check all files
bundle exec rubocop -a     # Auto-correct
```

Uses **rubocop-rails-omakase**.

## Pre-Commit Requirements

**All of these must pass before committing:**

1. `bundle exec rubocop -a` — zero offenses
2. `bundle exec rspec` — zero failures

No exceptions.

## PR Instructions

- PR title: under 70 characters, descriptive
- PR body: Summary, Changes Made, Technical Approach, Testing, Checklist
- Link to issue: `Closes #NNN` or `Part of #NNN`
- Agent attribution required (see below)

## Review Guidelines

When reviewing code, check for:

### P0 — Must Fix
- Security vulnerabilities (XSS in component templates, missing escaping)
- Broken tests or tests that don't test what they claim
- Accessibility violations (missing ARIA attributes, poor contrast)

### P1 — Should Fix
- Pattern violations (components not following `Admin::Name::Component` convention)
- Missing tests for new components
- Incorrect Bootstrap class usage
- Missing responsive behavior

### P2 — Consider
- Naming improvements
- Code organization suggestions
- Additional component variants or states

## Multi-Agent Coordination

When multiple agents work on the same feature:

- **File ownership is exclusive** — no two agents modify the same file simultaneously
- **Shared interfaces must be defined upfront** — component APIs, Stimulus controller targets
- **Each agent runs pre-commit checks on its own scope** before committing
- **One agent handles integration** — merges streams, runs full test suite, creates PR

## Architecture

### Component Structure

```
app/components/admin/
├── badge/
│   ├── component.rb           # Ruby logic (inherits ApplicationComponent)
│   └── component.html.erb     # ERB template
├── data_table/
│   ├── component.rb
│   └── component.html.erb
└── ...
```

### Stimulus Controllers

Engine exports controllers via `app/javascript/mpi_design_system/`:

```js
import { registerMpiControllers } from "mpi_design_system"
registerMpiControllers(application)
```

> **Note:** The bare `"mpi_design_system"` import requires an esbuild alias in the consuming app's `esbuild.config.js`:
> ```js
> alias: { 'mpi_design_system': path.resolve(__dirname, 'path/to/mpi_design_system/app/javascript/mpi_design_system') }
> ```
> See this repo's `esbuild.config.js` for a working example.

### Design Tokens

SCSS tokens at `app/assets/stylesheets/mpi_design_system/_tokens.scss` override Bootstrap defaults before import.

### Engine Integration

Consuming apps add the gem and register controllers:

```ruby
# Gemfile
gem 'mpi_design_system', git: 'git@github.com:mpimedia/mpi-design-system.git'
```

```js
// application.js
import { registerMpiControllers } from "mpi_design_system"
registerMpiControllers(application)
```

## Agent Attribution (Required — No Exceptions)

Every AI agent **must** include attribution on all work:

- **Commits**: `Co-Authored-By: Agent Name <email>` trailer
- **PRs**: Agent name in description footer
- **Comments**: Attribution line (e.g., `— Claude Code (Opus 4.6)`)

If multiple agents contribute, include a `Co-Authored-By` line for each.

## Context7 MCP Query Strategy (Claude Code)

This section is for Claude Code agents with Context7 MCP configured.

- Always use Context7 MCP for library documentation before falling back to general knowledge
- Refer to `Gemfile` and `package.json` for exact dependency versions

### Core Libraries (Query in Priority Order)

1. `/websites/guides_rubyonrails_v8_0` — Rails framework
2. `/websites/ruby-lang_en` — Ruby language
3. `/websites/getbootstrap_5_3` — Bootstrap
4. `/viewcomponent/view_component` — ViewComponent
5. `/hotwired/stimulus-rails` — Stimulus JS
6. `/rspec/rspec-rails` — Testing
7. `/rubocop/rubocop` — Linting
