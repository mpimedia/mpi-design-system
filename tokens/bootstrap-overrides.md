# Bootstrap 5 Overrides

MPI-specific customizations to Bootstrap 5 defaults.

> **Status:** Draft — to be populated as the design system matures.

## How Overrides Work

Each MPI Rails app uses Bootstrap 5 via the `bootstrap` gem. Customizations are applied by overriding Bootstrap SCSS variables **before** importing Bootstrap:

```scss
// app/assets/stylesheets/application.scss

// 1. MPI overrides (import from design system tokens)
@import "mpi_overrides";

// 2. Bootstrap
@import "bootstrap";

// 3. App-specific styles
@import "custom";
```

## Current Overrides

### Colors

See [colors.md](colors.md) for the full palette. Key overrides:

```scss
$primary: $mpi-primary;
$secondary: $mpi-secondary;
// Additional overrides TBD
```

### Typography

See [typography.md](typography.md). Key overrides:

```scss
$font-family-base: $mpi-font-primary;
// Additional overrides TBD
```

### Components

Document component-specific overrides here as they are established:

```scss
// Example: card customizations
// $card-border-radius: 0.5rem;
// $card-spacer-y: 1.25rem;
```

## Shared Override File

Eventually, a shared SCSS partial (`_mpi_overrides.scss`) should be maintained in this repo and distributed to each app. For now, each app maintains its own overrides file, using the tokens documented here as the reference.
