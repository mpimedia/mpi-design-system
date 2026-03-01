# Design Tokens

Design tokens are the foundational values that define MPI's visual language. They ensure consistency across all five applications.

## Token Files

| File | Contents |
|---|---|
| [colors.md](colors.md) | Brand colors, semantic colors, neutral palette |
| [typography.md](typography.md) | Font families, type scale, heading sizes |
| [spacing.md](spacing.md) | Spacing scale, component spacing guidelines |
| [bootstrap-overrides.md](bootstrap-overrides.md) | MPI customizations to Bootstrap 5 defaults |

## How Tokens Are Used

1. **Designers** reference tokens when creating components in Claude sessions
2. **Developers** implement tokens as SCSS variables in Rails apps
3. **Reviewers** verify that new designs use established tokens (not arbitrary values)

## Adding New Tokens

If a design requires a value not covered by existing tokens:

1. Check if Bootstrap 5 already provides a suitable default
2. If a custom value is needed, propose it via PR to this directory
3. Document the token name, value, and intended usage
4. Update the relevant token file
