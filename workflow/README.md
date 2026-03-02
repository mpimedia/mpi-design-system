# Design Workflow

How the MPI design system governs the lifecycle of design work.

## The Pipeline

```
Badie + Claude → Issue → Discussion → Decision → Plan → PR → Done
```

### How it works:

1. **Badie describes a need** to Claude in plain business language
2. **Claude creates an Issue** with structured requirements, context, and open questions
3. **Team discusses** in the issue — alternatives, feasibility, concerns
4. **Decision is recorded** in the issue once direction is chosen
5. **Plan is written** to the issue with enough detail for implementation
6. **Dev team implements** via PR, referencing the issue
7. **PR is merged** and the issue closes

## Guides

| Document | Purpose |
|---|---|
| [issue-lifecycle.md](issue-lifecycle.md) | Full issue lifecycle — stages, labels, conventions |
| [claude-project-instructions.md](claude-project-instructions.md) | Instructions for Badie's Claude Design Agent |
| [design-proposal.md](design-proposal.md) | How to write a design proposal |
| [review-checklist.md](review-checklist.md) | What reviewers evaluate during design review |

## Labels

| Label | Meaning |
|---|---|
| `proposal` | New design request |
| `revision` | Change to existing design |
| `needs-discussion` | Awaiting input from team |
| `decision-made` | Direction chosen, ready for planning |
| `plan-ready` | Implementation plan written, ready for dev |
| `implementing` | PR in progress |

## Project Board

All design work is tracked on the [MPI Design System project board](https://github.com/orgs/mpimedia/projects/14).

| Board Column | What's here |
|---|---|
| **Backlog** | Ideas not yet proposed as issues |
| **Proposal** | Issues created, discussion in progress |
| **In Design** | Decision made, design/plan being finalized |
| **In Review** | Design artifacts posted for stakeholder review |
| **Approved** | Plan ready, waiting for dev pickup |
| **Implementing** | PR in progress |
| **Done** | Merged and live |
