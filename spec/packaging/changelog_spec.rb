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
#   is not itself vacuous. Its fixture reproduces #127's exact shape — a historical
#   release section present while the current version appears only as prose and as
#   a link reference — so it pins *version discrimination*: a guard matching any
#   release heading passes the real file but fails here.
# - "with a heading that only resembles the release heading" pins the remaining
#   three elements of the pattern, which a fixture with no release section cannot
#   reach: drop `Regexp.escape`, the `(?:[ \t]|$)` boundary, or the `^` anchor and
#   one of its examples reddens. Each element the comment below calls load-bearing
#   has an example that fails when it is removed — that is the whole point of #127.
# - "defines a link reference for every bracketed heading" catches the broken
#   link-reference block #127 also repaired: only `[0.2.0]:` was defined, so six
#   bracketed headings rendered as literal text on GitHub and RubyDoc.
#
# Regex details, each load-bearing:
#
# - `Regexp.escape` on the version — the dots are regex wildcards otherwise, so
#   `0.6.0` would happily match `0X6Y0`.
# - The `^` anchor rejects a *mid-line* or indented mention (`see ## [0.6.0] …`).
#   Note it is the literal `## ` prefix, not the anchor, that rejects the
#   link-reference block at the bottom of the file.
# - The `(?:[ \t]|$)` boundary — without it, `## [0.6.0]garbage` and
#   `## [0.6.0]-rc1` are accepted as the release heading.
# - `[ \t]+` and NOT `\s+` in `reference_definitions` — `\s` crosses newlines in
#   Ruby without /m, so a definition whose URL had been deleted (`[0.6.0]:`
#   followed by a blank line) would false-green by consuming the newline and
#   grabbing the next line's first character as its destination.
# - `^## \[([^\]]+)\]` deliberately does not capture the unbracketed `## 0.1.0`
#   heading; no tag was ever cut for 0.1.0, so it is correct for it to have no
#   link reference.
#
# Known limits, all accepted:
#
# 1. This is a lexical scan, not a Markdown parser, so fenced code blocks are
#    invisible to it and can fail in *either* direction. A fenced `## [0.6.0]`
#    satisfies the release guard though it renders as code, not a heading. A fenced
#    column-zero `[x]: url` registers as a definition — which false-*reds* the
#    link-reference example when `x` has no heading, and false-*greens* it when it
#    stands in for a real definition that was deleted. Keep reference syntax
#    inline-quoted mid-line, as this file's prose already does.
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
  let(:definition_pattern) { /^\[([^\]]+)\]:[ \t]+\S/ }
  let(:reference_definitions) { changelog.scan(definition_pattern).flatten }

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
    # (see "Two False Greens" #1 in .claude/rules/testing.md). `0.0.1-decoy` is a
    # syntactically valid version (RubyGems reads it as 0.0.1.pre.decoy) but sorts
    # below everything shipped, so colliding with VERSION would take a regression.
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

  # The decoy above proves the guard discriminates on the version. These pin the
  # three remaining load-bearing elements, which a fixture missing the release
  # section cannot exercise: drop `Regexp.escape` and the wildcard heading matches,
  # drop the `(?:[ \t]|$)` boundary and the longer-token headings match, drop the
  # `^` anchor and the mid-line and indented mentions match.
  context "with a heading that only resembles the release heading" do
    let(:wildcard_version) { MpiDesignSystem::VERSION.gsub(".", "X") }

    it "rejects a heading matched only by treating the version's dots as wildcards" do
      expect("## [#{wildcard_version}] - 2026-01-01\n").not_to match(release_heading)
    end

    it "rejects a heading whose version is a prefix of a longer token" do
      expect("## [#{MpiDesignSystem::VERSION}]-rc1 - 2026-01-01\n").not_to match(release_heading)
      expect("## [#{MpiDesignSystem::VERSION}]garbage\n").not_to match(release_heading)
    end

    it "rejects a mid-line or indented mention" do
      expect("see ## [#{MpiDesignSystem::VERSION}] in history\n").not_to match(release_heading)
      expect("  ## [#{MpiDesignSystem::VERSION}] - 2026-01-01\n").not_to match(release_heading)
    end

    it "still accepts the real heading forms" do
      expect("## [#{MpiDesignSystem::VERSION}] - 2026-01-01\n").to match(release_heading)
      expect("## [#{MpiDesignSystem::VERSION}]\n").to match(release_heading)
    end
  end

  it "defines a link reference for every bracketed heading" do
    # Pin the headings first: `match_array` alone is satisfied by [] == [], so on a
    # changelog with no bracketed headings and no reference block it would pass
    # green. Without this line the example leans on its sibling above to reject
    # that file — an implicit cross-example dependency, and False Green #2.
    expect(bracketed_headings).to include("Unreleased", MpiDesignSystem::VERSION)

    expect(reference_definitions).to match_array(bracketed_headings)
  end

  # Pins the `[ \t]+` strictness. Under `\s+` the malformed fixture below yields a
  # phantom definition — `\s` crosses the blank line and takes the comment's `<` as
  # the destination — so the example above would keep passing while a definition
  # with no URL sat in the file. The well-formed half is what stops this from
  # passing on a pattern that simply matches nothing.
  context "with a link reference whose destination was deleted" do
    let(:well_formed) { "[#{MpiDesignSystem::VERSION}]: https://example.test/v1\n" }
    let(:malformed) { "[#{MpiDesignSystem::VERSION}]:\n\n<!-- destination removed -->\n" }

    it "counts the well-formed definition but not the destination-less one" do
      expect(well_formed.scan(definition_pattern).flatten).to eq([ MpiDesignSystem::VERSION ])
      expect(malformed.scan(definition_pattern).flatten).to be_empty
    end
  end

  it "is packaged in the gem's files so changelog_uri resolves" do
    expect(gemspec.files).to include("CHANGELOG.md")
  end
end
