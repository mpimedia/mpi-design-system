# frozen_string_literal: true

require "spec_helper"

# Guards the release changelog. The gemspec's `changelog_uri` points at
# CHANGELOG.md, so the file must both exist and ship inside the gem (added to the
# `files` glob in PR4 of #103) — otherwise a consumer following the changelog
# link, or `gem` tooling, hits a 404 / missing file.
#
# #127 replaced a vacuous example (`expect(changelog).to include("0.2.0")`) that
# pinned a literal, long-superseded version. A changelog keeps history, so that
# assertion passed forever no matter what was being released — it could not fail,
# and a test that cannot fail is not coverage. What each example now catches:
#
# - "documents the current release under its own heading" catches a version bump
#   shipped without a matching CHANGELOG section. It is anchored to
#   `MpiDesignSystem::VERSION`, so it re-aims itself at every release instead of
#   rotting on a literal.
# - "when the release section is absent" is the decoy that proves the guard above
#   is not itself vacuous. It feeds a changelog that carries a historical release
#   section while mentioning the current version *only* as prose and as a link
#   reference — #127's exact shape — and shows the weak substring form accepting
#   it while the anchored form rejects it. Two things keep the decoy honest: the
#   positive `include` proves the version string really is in the fixture, so the
#   `not_to match` is an absence with something pinning the presence ("Two False
#   Greens" #2 in .claude/rules/testing.md); and the historical `## [0.0.1-decoy]`
#   heading proves the guard discriminates on the *version* rather than merely
#   demanding some release heading, which is False Green #1 in the same doc.
# - "defines a link reference for every bracketed heading" catches the broken
#   link-reference block #127 also repaired: only `[0.2.0]:` was defined, so six
#   bracketed headings rendered as literal text on GitHub and RubyDoc.
#
# Regex details, each load-bearing:
#
# - `Regexp.escape` on the version — the dots are regex wildcards otherwise, so
#   `0.6.0` would happily match `0X6Y0`.
# - The `^` anchor rejects the link-reference block at the bottom of the file.
#   Without it, `[0.6.0]: https://…` alone satisfies the guard — which is the
#   second way the old substring form was vacuous.
# - The `(?:[ \t]|$)` boundary — without it, `## [0.6.0]garbage` and
#   `## [0.6.0]-rc1` are accepted as the release heading.
# - `[ \t]+` and NOT `\s+` in `reference_definitions` — `\s` crosses newlines in
#   Ruby without /m, so a definition whose URL had been deleted (`[0.6.0]:`
#   followed by a blank line) would false-green by consuming the newline and
#   grabbing the next line's first character as its destination. Verified.
# - `^## \[([^\]]+)\]` deliberately does not capture the unbracketed `## 0.1.0`
#   heading; no tag was ever cut for 0.1.0, so it is correct for it to have no
#   link reference.
#
# Known limits, all accepted:
#
# 1. This is a lexical scan, not a Markdown parser. A fenced code block
#    containing `## [0.6.0]` would satisfy the release-heading guard.
# 2. The definition pattern requires column zero and exact case. Markdown also
#    permits up to three leading spaces and matches labels case-insensitively, so
#    an indented or differently-cased definition would false-red here. That is
#    deliberate style enforcement for a uniform reference block — if this spec
#    reddens on a definition that renders fine, this is why.
# 3. It validates label *coverage*, not URL correctness: a definition pointing at
#    the wrong compare range still passes.
RSpec.describe "CHANGELOG.md" do
  let(:root) { File.expand_path("../..", __dir__) }
  let(:changelog_path) { File.join(root, "CHANGELOG.md") }
  let(:changelog) { File.read(changelog_path) }

  let(:release_heading) { /^## \[#{Regexp.escape(MpiDesignSystem::VERSION)}\](?:[ \t]|$)/ }
  let(:bracketed_headings) { changelog.scan(/^## \[([^\]]+)\]/).flatten }
  let(:reference_definitions) { changelog.scan(/^\[([^\]]+)\]:[ \t]+\S/).flatten }

  let(:gemspec) do
    Gem::Specification.load(File.join(root, "mpi_design_system.gemspec"))
  end

  it "exists at the repo root" do
    expect(File).to exist(changelog_path)
  end

  it "documents the current release under its own heading" do
    expect(changelog).to match(release_heading)
  end

  context "when the release section is absent" do
    # Reproduces #127's exact shape: a changelog carrying a *historical* release
    # section while the current version appears only as prose and as a link
    # reference. The historical heading matters — without one the fixture would
    # only prove the guard wants a `## [...]` heading at all, which an
    # implementation matching *any* release heading would satisfy identically
    # (see "Two False Greens" #1 in .claude/rules/testing.md). `0.0.1-decoy` is
    # not a releasable version, so it can never collide with a future VERSION.
    #
    # The original assertion pinned the literal "0.2.0", so the substring form
    # below is a weak *dynamic* restatement of it, not the old code verbatim.
    let(:decoy) do
      <<~MARKDOWN
        # Changelog

        ## [Unreleased]

        - Preparing the #{MpiDesignSystem::VERSION} release; nothing is cut yet.

        ## [0.0.1-decoy] - 2020-01-01

        - A shipped release, but not the one VERSION currently names.

        [#{MpiDesignSystem::VERSION}]: https://example.test/compare/v0.0.1...v#{MpiDesignSystem::VERSION}
      MARKDOWN
    end

    it "is accepted by a weak substring check but rejected by the anchored guard" do
      expect(decoy).to include(MpiDesignSystem::VERSION)
      expect(decoy).not_to match(release_heading)
    end

    it "rejects it even though it does contain a release heading" do
      expect(decoy).to match(/^## \[0\.0\.1-decoy\] /)
      expect(decoy).not_to match(release_heading)
    end
  end

  it "defines a link reference for every bracketed heading" do
    expect(reference_definitions).to match_array(bracketed_headings)
  end

  it "is packaged in the gem's files so changelog_uri resolves" do
    expect(gemspec.files).to include("CHANGELOG.md")
  end
end
