# MPI Design System

A mountable **Rails engine gem** that ships the shared ViewComponents, design tokens, and
Stimulus controllers for every MPI Media application.

## What This Is

`mpi_design_system` is the single source of truth for MPI's visual language, delivered as
installable code — not just documentation. It provides:

- **ViewComponents** — 33 shared UI components under the `MpiDesignSystem::Admin::` namespace
  (badges, cards, tables, layouts, CRM panels, and more)
- **Design tokens** — Brand colors, semantic palette, and Bootstrap 5 overrides as SCSS
- **Stimulus controllers** — Hotwire behavior (e.g. `mpi--tag-input`), registered in one call
- **Component catalog** — Specs for every UI building block (`catalog/`)
- **Token & workflow docs** — `tokens/*.md`, `CONTRIBUTING.md`, and `CLAUDE.md` for design sessions

The engine ships its component **JS and SCSS as source**. There is no Rails asset-pipeline
initializer — a consuming app wires the assets into its own esbuild + dart-sass build (see
[Installation](#installation)). This mirrors the pipeline every MPI app already uses
(`jsbundling-rails` + `cssbundling-rails` + Propshaft).

## Applications

The design system serves these MPI Media applications:

| App | Purpose |
|---|---|
| **Markaz** | Content management and distribution platform |
| **SFA** | Video clip hosting and search |
| **Garden** | Static site generator |
| **Harvest** | Ecommerce platform |

## Installation

Installing the engine is three steps: add the gem, wire the JS, and wire the SCSS. Every
path below resolves through Bundler with `bundle show mpi_design_system`, so nothing depends
on where Bundler unpacks the gem.

### 1. Add the gem

```ruby
# Gemfile
gem "mpi_design_system", git: "git@github.com:mpimedia/mpi-design-system.git", tag: "v0.8.0"
```

Pin to a release tag (`tag: "v0.8.0"`) so upgrades are deliberate. Then:

```bash
bundle install
```

### 2. Wire the JavaScript (esbuild)

The engine exports its Stimulus controllers under the bare specifier `mpi_design_system`.
Alias that specifier to the gem's JS source in your app's esbuild config, resolving the gem
path at build time via `bundle show`:

```js
// esbuild.config.js
const path = require("path");
const { execSync } = require("child_process");

const gemPath = execSync("bundle show mpi_design_system").toString().trim();

require("esbuild").build({
  // ...your existing options...
  alias: {
    mpi_design_system: path.join(gemPath, "app/javascript/mpi_design_system"),
  },
});
```

Then register every engine controller in one call from your Stimulus entrypoint:

```js
// app/javascript/application.js
import { Application } from "@hotwired/stimulus";
import { registerMpiControllers } from "mpi_design_system";

const application = Application.start();
registerMpiControllers(application);
```

### 3. Wire the SCSS (dart-sass)

Add the gem's stylesheets directory to your dart-sass `--load-path`, again resolved via
`bundle show`:

```bash
sass app/assets/stylesheets/application.scss:app/assets/builds/application.css \
  --load-path=node_modules \
  --load-path=$(bundle show mpi_design_system)/app/assets/stylesheets
```

Then import the MPI tokens in `application.scss` using **one** of the two entry points:

- **Legacy `@import` pipeline** — import `tokens` before Bootstrap; it maps the MPI palette
  onto Bootstrap's variables:

  ```scss
  @import "mpi_design_system/tokens";
  @import "bootstrap/scss/bootstrap";
  ```

- **Modern Sass-module pipeline** — `@use` the dependency-free values module and feed the
  palette into your own Bootstrap config, so the engine's Bootstrap is not double-compiled
  against your app's `bootstrap@5.3.x`:

  ```scss
  @use "mpi_design_system/tokens_values" as mpi;
  $primary: mpi.$mpi-primary;
  $success: mpi.$mpi-success;
  $warning: mpi.$mpi-warning;
  $info: mpi.$mpi-info;
  $body-color: mpi.$mpi-text;
  @import "bootstrap/scss/bootstrap";
  ```

  Map every token you rely on — Bootstrap keeps its own default for any you skip. In
  particular, an unmapped `$info` leaves Bootstrap's cyan (`#0DCAF0`) on `btn-info` /
  `text-bg-info`, which is outside the MPI palette.

### 4. Use a component

```erb
<%= render MpiDesignSystem::Admin::Badge::Component.new(label: "New", color: :success) %>
```

## Repo Structure

```
mpi-design-system/
├── app/
│   ├── components/mpi_design_system/admin/   # ViewComponents (MpiDesignSystem::Admin::Name::Component)
│   ├── javascript/mpi_design_system/         # Engine JS + Stimulus controllers
│   └── assets/stylesheets/mpi_design_system/ # SCSS tokens (_tokens.scss, _tokens_values.scss)
├── lib/mpi_design_system/                    # Engine, version
├── spec/                                     # RSpec specs, Lookbook previews, dummy app
│
├── CHANGELOG.md                 # Release history (Keep a Changelog)
├── CONTRIBUTING.md              # How to propose, review, approve designs
├── CLAUDE.md                    # Context file for Claude design sessions
│
├── tokens/                      # Design token documentation
│   ├── colors.md
│   ├── typography.md
│   ├── spacing.md
│   └── bootstrap-overrides.md
│
├── catalog/                     # Component catalog specs
│   ├── elements/                # Buttons, inputs, badges, icons, links
│   ├── components/              # Cards, modals, navbars, tables, alerts
│   ├── patterns/                # Forms, search, filters, data entry
│   └── layouts/                 # Dashboards, detail pages, list views
│
└── references/                  # Approved visual references (PNGs, PDFs)
```

## Component Taxonomy

Components are organized using **plain language categories** with cross-references to
Atomic Design and Bootstrap 5 terminology:

| Category | What it contains | Atomic equivalent |
|---|---|---|
| **Elements** | Smallest building blocks — buttons, inputs, badges, icons, links | Atoms |
| **Components** | Self-contained UI units — cards, modals, navbars, tables, alerts | Molecules |
| **Patterns** | Recurring multi-component arrangements — forms, search, filters | Organisms |
| **Layouts** | Full page structures — dashboards, detail pages, list views | Templates/Pages |

## Development

```bash
bundle install
yarn install

bin/dev                    # Dev server (web, js, css) + Lookbook at /lookbook
bundle exec rspec          # Run the spec suite
bundle exec rubocop -a     # Lint and auto-correct
```

Reference the design tokens documented in [`tokens/`](tokens/) and the component specs in
[`catalog/`](catalog/) before adding or changing a component. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the full propose → design → review → approve →
implement workflow, and [`CHANGELOG.md`](CHANGELOG.md) for release history.

## Project Board

Track design system progress on the
[MPI Design System project board](https://github.com/orgs/mpimedia/projects/15).

## Related Repositories

- [mpi-application-standards](https://github.com/mpimedia/mpi-application-standards) — Shared Claude Code and development standards
- [mpi-application-workflows](https://github.com/mpimedia/mpi-application-workflows) — Reusable GitHub Actions workflows
- [.github](https://github.com/mpimedia/.github) — Organization-wide templates and defaults
