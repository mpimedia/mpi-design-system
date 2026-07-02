# frozen_string_literal: true

require "spec_helper"

# Guards the release changelog. The gemspec's `changelog_uri` points at
# CHANGELOG.md, so the file must both exist and ship inside the gem (added to the
# `files` glob in PR4 of #103) — otherwise a consumer following the changelog
# link, or `gem` tooling, hits a 404 / missing file.
RSpec.describe "CHANGELOG.md" do
  let(:root) { File.expand_path("../..", __dir__) }
  let(:changelog_path) { File.join(root, "CHANGELOG.md") }
  let(:changelog) { File.read(changelog_path) }

  let(:gemspec) do
    Gem::Specification.load(File.join(root, "mpi_design_system.gemspec"))
  end

  it "exists at the repo root" do
    expect(File).to exist(changelog_path)
  end

  it "documents the 0.2.0 release" do
    expect(changelog).to include("0.2.0")
  end

  it "is packaged in the gem's files so changelog_uri resolves" do
    expect(gemspec.files).to include("CHANGELOG.md")
  end
end
