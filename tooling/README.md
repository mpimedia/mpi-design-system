# Tooling

Guides for the tools used in MPI's design workflow.

## Primary Design Tool: Claude + Bootstrap 5

Claude (via claude.ai or Claude Code) is the primary design tool. Claude generates HTML/CSS artifacts using Bootstrap 5 that are directly translatable to Rails views and ViewComponents.

### How It Works

1. Start a Claude session
2. Paste or attach the [`CLAUDE.md`](../CLAUDE.md) context file to anchor the conversation
3. Describe the component or layout you need
4. Claude generates an HTML artifact using Bootstrap 5 and the MPI design tokens
5. Iterate in the conversation until the design is right
6. Export as PDF or PNG for review

### Why This Works for MPI

- Claude-generated HTML maps 1:1 to Rails ERB templates
- Bootstrap 5 classes used in artifacts are the same classes used in production
- No translation layer between "design" and "code"
- The CLAUDE.md context file prevents drift across sessions

## Supporting Tools

### Figma

Use for:
- Collaborative visual exploration between humans
- Asset creation (icons, illustrations)
- Stakeholder presentations

Not recommended for:
- Source-of-truth component specs (use this repo instead)
- Claude's design input (Claude can't read Figma files)

### Adobe Creative Cloud

Use for:
- Photography and image editing
- Marketing asset creation
- Print materials

Not part of the component design workflow.

## Tool Setup

No special tooling is required to work with this design system. The catalog is plain Markdown, and the design workflow uses GitHub Issues and PRs.
