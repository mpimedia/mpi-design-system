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

## Release

The gem is released by cutting a **git tag** — there is no RubyGems publish. Consuming apps
resolve the gem from GitHub and pin to a tag (see the README install snippet), so **the tag is
the only release artifact**. Versions follow [SemVer](https://semver.org/) with a **pre-1.0
caveat: minor bumps may include breaking changes** (as stated at the top of `CHANGELOG.md`). Cut
**one release per shipped unit** — typically the feature or fix PR you just merged. History has
varied (`v0.7.0` batched three runtime changes; `v0.8.0` folded its release commit into the
feature PR), and a documentation-only change — like this very section — may ride the next runtime
release rather than getting its own, since `CONTRIBUTING.md` is not shipped in the gem.

### What a release changes

A release is a single `chore(release): vX.Y.Z — <summary>` commit touching exactly **four** files.
The `.gemspec` needs no edit — it reads the `VERSION` constant.

- **`lib/mpi_design_system/version.rb`** — bump `VERSION`.
- **`spec/packaging/version_spec.rb`** — update the `expect(...).to eq("X.Y.Z")` (the only
  asserted literal), the `it "is X.Y.Z"` example description (cosmetic — RSpec never compares it
  to `VERSION`, so a stale one ships green; keep it honest anyway), and a one-line clause on the
  release-lineage comment (also not asserted — house convention).
- **`README.md`** — bump the `tag: "vX.Y.Z"` pin in **both** the Gemfile install example and the
  explanatory line beneath it.
- **`CHANGELOG.md`** — the four edits below.

### The four CHANGELOG edits

`spec/packaging/changelog_spec.rb` enforces that every `## [x]` heading has a matching `[x]:` link
definition and vice versa (an exact multiset), that `## [Unreleased]` is always present with its
own definition, and that the current `VERSION` has its own `## [VERSION]` heading. Cutting
`vX.Y.Z` (previous tag `vP.Q.R`) therefore means all four of:

```markdown
## [Unreleased]                       ← 2. keep this heading (leaving it empty is fine)

## [X.Y.Z] - YYYY-MM-DD               ← 1. add, dated; POPULATE from the shipped unit's changes

... (existing dated sections) ...

[Unreleased]: https://github.com/mpimedia/mpi-design-system/compare/vX.Y.Z...HEAD   ← 4. re-aim
[X.Y.Z]: https://github.com/mpimedia/mpi-design-system/compare/vP.Q.R...vX.Y.Z      ← 3. add
```

**The spec checks label _coverage_, not correctness.** It will not catch a wrong compare-URL
range, a wrong date, or an **empty** `## [X.Y.Z]` section — so populate the entry from the commits
since the previous tag, and eyeball the URLs and date yourself. For the date, use the day you
author the release commit (the merge day in a normal same-day flow); if the PR lingers past
midnight, amend the date before tagging.

### Cutting the release

1. **Branch from fresh `main`** so the shipped unit's `[Unreleased]` notes are present:
   ```bash
   git fetch origin
   git switch -c release/vX.Y.Z origin/main
   ```
2. Make the four-file `chore(release): vX.Y.Z — <summary>` commit, then run both required checks —
   the packaging specs must pass on the new version:
   ```bash
   bundle exec rubocop -a
   bundle exec rspec
   ```
3. Open the release PR and **wait for CI to pass on it**.

### Tagging (the fragile part — gate it on CI)

CI runs on branch pushes but **not on tag pushes** (`.github/workflows/ci.yml` has no `tags:`
filter, and `main` has no branch protection), so **a pushed tag runs no CI of its own**. Gate the
tag on the merge commit's checks already being green. Every command below is verified against its
failure case; see `.claude/rules/testing.md` §"A check written in documentation is still a check"
for why they are shaped this way — and run any change to them against its failure case before you
commit it.

After the PR merges:

```bash
git fetch origin   # gh returns a SHA from GitHub; fetch puts that commit object in your local repo

PR=NNN   # the merged release PR's number
MERGE_SHA=$(gh pr view "$PR" --json mergeCommit --jq .mergeCommit.oid)
[ -n "$MERGE_SHA" ] || { echo "ABORT: no merge commit (PR not merged?)"; exit 1; }

# Gate: every check on the MERGE COMMIT must be green. check-runs gives per-job conclusions, so a
# skipped job cannot hide behind a workflow-level roll-up. `--paginate` so a non-success beyond the
# first 30 checks is not missed; `.conclusion // "pending"` maps a still-running check (null
# conclusion, which gh would otherwise emit as a blank line that command substitution silently
# trims) to a non-success token. The `|| exit` catches a mid-pagination gh failure that would
# otherwise leave a partial, falsely-green list. Fails closed on empty, pending, or non-success.
CONCLUSIONS=$(gh api --paginate "repos/mpimedia/mpi-design-system/commits/$MERGE_SHA/check-runs" \
  --jq '.check_runs[] | .conclusion // "pending"') \
  || { echo "ABORT: could not read CI checks for $MERGE_SHA"; exit 1; }
[ -n "$CONCLUSIONS" ] || { echo "ABORT: no CI checks for $MERGE_SHA"; exit 1; }
[ "$(printf '%s\n' "$CONCLUSIONS" | sort -u)" = "success" ] \
  || { echo "ABORT: CI not all green -> $CONCLUSIONS"; exit 1; }

# Assert the version at that commit is exactly the one you're tagging (substitute X.Y.Z). Capture
# git show separately so its own failure aborts; BRACE the variable — a bare "$MERGE_SHA:lib/..."
# triggers zsh's :l modifier and mangles the path. Match the whole line as a fixed string
# (grep -qxF) so a comment, an `OLD_VERSION =`, or the "." wildcard can't false-match.
VERSION_RB=$(git show "${MERGE_SHA}:lib/mpi_design_system/version.rb") \
  || { echo "ABORT: cannot read version.rb at $MERGE_SHA"; exit 1; }
printf '%s\n' "$VERSION_RB" | grep -qxF '  VERSION = "X.Y.Z"' \
  || { echo "ABORT: version.rb at $MERGE_SHA is not X.Y.Z"; exit 1; }

# Lightweight tag on the merge commit, then push it — chained so a failed tag (e.g. one that
# already exists at the wrong commit) never reaches the push.
git tag "vX.Y.Z" "$MERGE_SHA" && git push origin "vX.Y.Z"
```

- Resolve `$MERGE_SHA` from the PR's own `mergeCommit`, **not** `git rev-parse origin/main` — `main`
  is mutable and may have already advanced to another PR's work.
- Tag the explicit SHA. Do **not** `git checkout main` — `main` is checked out in the parent
  worktree, so the checkout fails from inside a worktree.
- Never run `rake release` — it invokes Bundler's RubyGems push task, and this gem is not
  published to RubyGems.

### Notify consumers

The tag is live, but no consumer moves until its pin is bumped. Tell each consuming app (Markaz,
SFA, Garden, Harvest) to bump the `tag: "vX.Y.Z"` pin in its Gemfile (syntax is in this repo's
README install section). Harvest's own bump procedure lives in its `.claude/rules/backend.md`
("Git-Sourced Gem Pins").
