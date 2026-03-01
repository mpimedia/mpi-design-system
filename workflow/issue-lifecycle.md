# Issue Lifecycle

Every design system issue follows this lifecycle, tracked by labels and board columns.

## Stages

### 1. Proposal (`proposal` + `needs-discussion`)

**Who:** Badie + Claude Design Agent
**Board column:** Proposal

An issue is created capturing a business need. It includes context, users, requirements, data, and open questions.

At this stage the issue is a conversation starter, not a final spec. It explicitly flags what needs dev team input.

### 2. Discussion (`needs-discussion`)

**Who:** Everyone — Badie, dev team, agents
**Board column:** Proposal (stays here during discussion)

This is where the issue gets refined. Participants contribute:

| Contributor | What they bring |
|---|---|
| **Badie / Design Agent** | Business context, user workflows, data requirements, priorities |
| **Dev team / Dev agents** | Technical feasibility, implementation concerns, effort estimates, existing patterns to reuse |
| **Anyone** | Alternative approaches, edge cases, accessibility concerns, warnings about scope |

#### Discussion conventions:

- **Present alternatives as trade-offs**, not just technical options. Frame them in terms of what the user experiences, how long it takes, and what it costs in complexity.
- **Flag warnings early.** If something is technically risky, expensive, or conflicts with existing patterns, say so now — not after a plan is written.
- **Ask clarifying questions** as issue comments, not in side channels. Keep the full conversation in the issue.
- **Attribution:** AI-authored comments should end with an attribution line (e.g., *Comment by Badie via Claude Design Agent* or *Comment by dev team via Claude Code*).

### 3. Decision (`decision-made`)

**Who:** Whoever has authority (usually Badie for design direction, dev lead for technical approach)
**Board column:** In Design

When discussion converges, a decision comment is added to the issue:

```markdown
## Decision

[What was decided and why.]

### What was considered:
- **Option A:** [description] — [why chosen or rejected]
- **Option B:** [description] — [why chosen or rejected]

### Key factors:
- [What mattered most]
```

The `needs-discussion` label is removed and `decision-made` is added.

### 4. Plan (`plan-ready`)

**Who:** Badie + Claude Design Agent (for design specs), Dev team (for technical review)
**Board column:** Approved

An implementation plan is written as a comment on the issue. This is the handoff document — it must contain enough detail for a developer or dev agent to implement via PR without going back to Badie.

```markdown
## Implementation Plan

### What to build
[Concrete description.]

### Specifications
- [UI elements and their behavior]
- [States: default, hover, active, disabled, loading, empty, error]
- [Responsive behavior]
- [Data displayed and where it comes from]
- [User actions and what they trigger]

### Bootstrap 5 Guidance
[Relevant Bootstrap components.]

### Accessibility
[Key requirements for this design.]

### Acceptance Criteria
- [ ] [Testable criterion]
- [ ] [Testable criterion]
- [ ] [Testable criterion]

### Out of Scope
[What this does NOT include.]
```

The `decision-made` label is removed and `plan-ready` is added.

### 5. Implementation (`implementing`)

**Who:** Dev team / Dev agents
**Board column:** Implementing

A developer or dev agent picks up the plan-ready issue and:

1. Creates a feature branch
2. Implements the design as a component spec in the catalog (and/or as a ViewComponent in the target app)
3. Opens a PR referencing the issue (`Closes #123`)
4. The PR is reviewed and merged

The `plan-ready` label is removed and `implementing` is added.

### 6. Done

**Who:** Reviewer who merges the PR
**Board column:** Done

The PR is merged, the issue is closed, and the component is live.

## Labels Summary

| Label | Meaning | Added by |
|---|---|---|
| `proposal` | New design request | Creator (on issue creation) |
| `revision` | Change to existing design | Creator (on issue creation) |
| `needs-discussion` | Awaiting input from team | Creator (on issue creation) |
| `decision-made` | Direction chosen, ready for planning | Decision maker |
| `plan-ready` | Implementation plan written, ready for dev | Plan author |
| `implementing` | PR in progress | Developer |

## Board Column Mapping

| Board Column | Labels Present |
|---|---|
| Proposal | `proposal` + `needs-discussion` |
| In Design | `decision-made` (actively being designed/planned) |
| In Review | Design artifacts posted, awaiting review |
| Approved | `plan-ready` |
| Implementing | `implementing` |
| Done | Issue closed |
