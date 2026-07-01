# GitHub Copilot Instructions for MPI Design System

**`AGENTS.md` at the repository root is the source of truth for all AI coding agents in this repo — read it first and follow it.**

Quick orientation:

- This is a Rails engine gem providing shared ViewComponents, design tokens, and Stimulus controllers for the MPI Media apps (Markaz, SFA, Garden, Harvest).
- Pre-commit requirements (no exceptions): `bundle exec rubocop -a` (zero offenses) and `bundle exec rspec` (zero failures).
- Never commit directly to `main` — create a feature branch first.
- Agent attribution is required on every commit, PR, and comment — see "Agent Attribution" in `AGENTS.md`.
- Review severity levels (P0/P1/P2) are summarized in `AGENTS.md` and expanded in `docs/standards/code-review.md`.

For lifecycle and process standards, see `docs/standards/`.
