# Design Tokens

Design tokens are the foundational values that define MPI's visual language. They ensure consistency across all five applications.

## Current Status

Core token values are **confirmed** as of 2026-03-02 (Q&A Session 001). Colors, navigation structure, and key component decisions are finalized. Typography and spacing remain at Bootstrap defaults.

## Process

1. Badie provides designs (Figma, HTML artifacts, screenshots, PDFs)
2. AC + HC conduct a Q&A session to decompose the designs
3. Colors, typography, spacing, and component overrides are extracted
4. Values are recorded in these token files as the canonical source
5. A shared `_mpi_overrides.scss` partial is generated from the tokens
6. Apps adopt the shared partial via the design system gem

## Token Files

| File | Contents | Status |
|---|---|---|
| [colors.md](colors.md) | Brand colors, semantic colors, tag/engagement palettes | **Confirmed** |
| [typography.md](typography.md) | Font families, type scale, heading sizes | Baseline (Bootstrap defaults) |
| [spacing.md](spacing.md) | Spacing scale, component spacing guidelines | Baseline (Bootstrap defaults) |
| [navigation.md](navigation.md) | App navigation structure, section mapping | **Confirmed** |
| [components.md](components.md) | Component behavior decisions (avatars, badges, etc.) | **Confirmed** |
| [bootstrap-overrides.md](bootstrap-overrides.md) | MPI customizations to Bootstrap 5 defaults | In progress |

## Adding New Tokens

If a design requires a value not covered by existing tokens:

1. Check if Bootstrap 5 already provides a suitable default
2. If a custom value is needed, propose it via PR to this directory
3. Document the token name, value, and intended usage
4. Every override must trace back to an approved design decision
