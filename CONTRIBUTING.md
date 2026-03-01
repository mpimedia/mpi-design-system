# Contributing to the MPI Design System

## Design Workflow

Every component follows a structured path from idea to implementation:

```
Propose → Design → Review → Approve → Implement → Done
```

### 1. Propose

Open an issue in this repo using the **Design Proposal** template. Include:

- What the component or pattern is
- Which app(s) need it
- Any existing examples or inspiration
- Rough requirements (states, variants, responsiveness)

The issue moves to **Proposal** on the project board.

### 2. Design

Badie (or another designer) works with Claude to create the design:

1. Start a Claude session and load the [`CLAUDE.md`](CLAUDE.md) context file
2. Claude generates HTML/CSS artifacts using Bootstrap 5 within the design language
3. Iterate on the design within the conversation
4. Export final artifacts as PDF/PNG
5. Post the artifacts and a draft component spec to the issue

The issue moves to **In Design** while active work is happening.

### 3. Review

Once the design is posted:

1. The issue moves to **In Review**
2. Stakeholders review against the [review checklist](workflow/review-checklist.md)
3. Feedback is posted as issue comments
4. Designer iterates if changes are requested (issue moves back to **In Design**)

### 4. Approve

When stakeholders sign off:

1. The component spec is submitted as a PR to this repo
2. The spec goes in the appropriate catalog directory (`elements/`, `components/`, `patterns/`, or `layouts/`)
3. Visual references go in `references/`
4. PR is reviewed and merged
5. Issue moves to **Approved**

### 5. Implement

A developer builds the approved design:

1. Create a ViewComponent in the target Rails app
2. Follow the Bootstrap 5 classes and markup from the spec
3. Reference design tokens for customizations
4. Issue moves to **Implementing**

### 6. Done

Once implemented, merged, and live, the issue moves to **Done**.

## Component Spec Format

Every component spec in the catalog follows this template:

```markdown
# Component Name

**Category:** Elements | Components | Patterns | Layouts
**Status:** Draft | In Review | Approved | Deprecated
**Bootstrap mapping:** [relevant Bootstrap component]
**Atomic equivalent:** Atom | Molecule | Organism | Template

## Description

What this component is and when to use it.

## When to Use

- Scenario 1
- Scenario 2

## When NOT to Use

- Use [alternative] instead when...

## Variants

### Default
Description and visual reference.

### Variant Name
Description and visual reference.

## States

- Default
- Hover
- Active
- Disabled
- Loading (if applicable)

## Design Tokens

| Token | Value | Usage |
|---|---|---|
| Color | `$mpi-primary` | Background |
| Spacing | `$spacer-3` | Padding |

## Bootstrap 5 Classes

```html
<button class="btn btn-primary btn-lg">Label</button>
```

## ERB / ViewComponent Example

```erb
<%= render ButtonComponent.new(variant: :primary, size: :lg) do %>
  Label
<% end %>
```

## Stimulus Behaviors

If applicable, document JavaScript behaviors.

## Accessibility

- ARIA roles and attributes
- Keyboard navigation
- Screen reader behavior

## Visual Reference

![Component Name](../references/component-name.png)
```

## Branch Naming

Follow the org convention:

- `feature/add-button-spec` — New component spec
- `fix/update-card-variants` — Fix or update existing spec
- `docs/improve-token-docs` — Documentation improvements

## Commit Messages

Follow org standards. Include AI attribution:

```
feat(catalog): add button component spec

- Define primary, secondary, outline variants
- Document hover, active, disabled states
- Include Bootstrap 5 class mapping and ERB example
- Add accessibility notes for keyboard navigation

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
