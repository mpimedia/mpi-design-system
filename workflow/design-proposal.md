# Writing a Design Proposal

A design proposal is the starting point for any new component, pattern, or design change. It captures the need and provides enough context for the designer to begin work.

## When to Write a Proposal

- A new UI component is needed that doesn't exist in the catalog
- An existing component needs a new variant or significant change
- A recurring UI pattern should be standardized
- A layout template would benefit multiple apps

## Proposal Template

Use the **Design Proposal** issue template in this repo. It covers:

### Required Information

- **Component name** — What to call it (plain language)
- **Description** — What it does, in one or two sentences
- **Which app(s) need it** — Optimus, Avails, SFA, Garden, Harvest, or all
- **User context** — What is the user trying to accomplish when they encounter this component?

### Helpful to Include

- **Existing examples** — Screenshots, URLs, or references to similar components in other products
- **Rough requirements** — States (hover, disabled, loading), variants (sizes, colors), responsiveness
- **Constraints** — Accessibility needs, performance considerations, mobile requirements
- **Priority** — How urgently is this needed?

## What Happens Next

1. The issue is added to the [project board](https://github.com/orgs/mpimedia/projects/14) in the **Proposal** column
2. A designer picks it up and moves it to **In Design**
3. The designer works with Claude to create the design, referencing the CLAUDE.md context file
4. Artifacts (HTML previews, PNGs, PDFs) are posted back to the issue
5. The issue moves to **In Review** for stakeholder feedback
