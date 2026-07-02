# Dependency Rules

Applies to: `mpi_design_system.gemspec`, `Gemfile`, `package.json`, `yarn.lock`, `.yarnrc.yml`

## This Repo Is a Gem — Runtime Dependencies Propagate

- Runtime dependencies live in `mpi_design_system.gemspec` and are forced into the bundle
  of **every consuming app** (Markaz, SFA, Garden, Harvest). The current runtime set is
  deliberately tiny: `rails >= 8.1`, `view_component >= 3.0`, `stimulus-rails`,
  `bootstrap ~> 5.3`, with `required_ruby_version >= 3.4`
- Adding or tightening a gemspec dependency is an ecosystem-wide decision — it constrains
  every consumer's resolution. Keep constraints as loose as safely possible, and never add
  a runtime dependency for something only used in development or test
- Development/test-only gems (puma, propshaft, jsbundling-rails, cssbundling-rails,
  lookbook, foreman, rspec-rails, capybara, rubocop-rails-omakase) belong in the
  `Gemfile`, never in the gemspec

## Lockfiles

- `Gemfile.lock` is **deliberately gitignored** — engines don't commit lockfiles, so the
  engine resolves fresh within its constraints the same way it will inside each consuming
  app. Do not commit it and do not "fix" its absence
- `yarn.lock` **is** committed, and `package.json` pins JS dependencies to exact versions.
  CI installs with `yarn install --immutable`, so a `package.json` change without a
  matching lockfile update fails the build

## Release-Age Cooldown (Supply-Chain Guardrail)

MPI treats freshly published releases as elevated supply-chain risk — a compromised
release is most dangerous in its first days.

- Unlike the MPI app repos, this engine does **not** currently configure resolver-level
  gates (no `cooldown:` in the `Gemfile`, no `npmMinimalAgeGate` in `.yarnrc.yml`), so
  the cooldown is applied at **review time** instead
- When authoring or reviewing a version bump, check the release date; prefer releases at
  least a week old. Adopting a younger release requires a stated reason in the PR — a
  security advisory is the standard one, noted with its CVE/advisory ID
- If resolver-level gates are added later, mirror the app-repo convention rather than
  inventing a new one

## Dependabot and Actions Pinning

- Dependabot PRs (npm and GitHub Actions bumps arrive regularly) go through `/dep-review`
  (`.claude/commands/dep-review.md`): identify the dependency and version delta, check the
  changelog for breaking changes, assess usage in the engine, and run the full suite
  against the PR branch before recommending merge
- GitHub Actions in `.github/workflows/ci.yml` are pinned to full commit SHAs with a
  trailing `# vN` comment so Dependabot can still bump them — keep any new action
  SHA-pinned the same way

## Anti-Patterns

- Never add a runtime dependency to the gemspec that consumers don't strictly need
- Never move a dev/test gem from the `Gemfile` into the gemspec to "fix" a load error
- Never commit `Gemfile.lock`
- Never merge a dependency PR without `/dep-review` and green CI
- Never replace a SHA-pinned action with a floating tag
