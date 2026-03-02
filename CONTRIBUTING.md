# Contributing to the MPI Design System

## Design Workflow

Every design follows a structured path from idea to implementation:

```
Badie + Claude → Issue → Discussion → Decision → Plan → PR → Done
```

For the full lifecycle details, labels, and conventions, see [`workflow/issue-lifecycle.md`](workflow/issue-lifecycle.md).

### Quick Overview

1. **Propose** — Badie describes a need to Claude. Claude creates an issue with business context, requirements, and open questions.
2. **Discuss** — Dev team and Badie discuss in the issue: alternatives, feasibility, concerns.
3. **Decide** — A direction is chosen and recorded in the issue.
4. **Plan** — An implementation plan is written to the issue with enough detail for a developer to build it.
5. **Implement** — Dev team picks up the plan, creates a PR.
6. **Done** — PR is merged, issue closes.

### For Badie

See [`workflow/claude-project-instructions.md`](workflow/claude-project-instructions.md) for how to set up your Claude Design Agent and the full workflow.

### For Developers

Pick up issues labeled `plan-ready` on the [project board](https://github.com/orgs/mpimedia/projects/14). The implementation plan in the issue has everything you need. Create a feature branch, implement, and open a PR referencing the issue.

## Component Spec Format

Every component spec in the catalog follows this template:

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
