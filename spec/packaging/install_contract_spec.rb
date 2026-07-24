# frozen_string_literal: true

require "spec_helper"

# Guards the install contract for consuming apps (PR4 of #103, Option A):
# README.md is the single, self-contained install home. README must carry the
# canonical wiring strings, and the in-source doc comments must point at README —
# not the interim "AGENTS.md" pointer used while PR3 (#114) landed. README.md
# ships in the gem; AGENTS.md does not, so a consumer can only read the install
# steps from README.
RSpec.describe "install contract docs" do
  let(:root) { File.expand_path("../..", __dir__) }

  def read(relative)
    File.read(File.join(root, relative))
  end

  describe "README.md" do
    let(:readme) { read("README.md") }

    it "documents the Stimulus registration entry point" do
      expect(readme).to include("registerMpiControllers")
    end

    it "documents the legacy @import token entry point" do
      expect(readme).to include('@import "mpi_design_system/tokens"')
    end

    it "documents the modern @use token-values entry point" do
      expect(readme).to include('@use "mpi_design_system/tokens_values"')
    end

    # The avatar partial is OPTIONAL (avatars fall back to the inline hex without it —
    # the #169 non-breaking contract), but the README must document it or a consumer has
    # no way to discover the theme-adaptive/re-brandable path. Pinned so it can't silently
    # drop; deliberately NOT asserted as mandatory wiring, which would misstate the contract.
    it "documents the optional avatar partial for theme-adaptive avatars" do
      expect(readme).to include('@import "mpi_design_system/avatar"')
      expect(readme).to match(/avatar.*optional|optional.*avatar/im)
    end

    it "resolves gem asset paths through Bundler" do
      expect(readme).to include("bundle show mpi_design_system")
    end
  end

  describe "in-source install pointers" do
    %w[
      lib/mpi_design_system/engine.rb
      app/assets/stylesheets/mpi_design_system/_tokens.scss
      app/assets/stylesheets/mpi_design_system/_tokens_values.scss
    ].each do |source_file|
      context "in #{source_file}" do
        let(:contents) { read(source_file) }

        it "points at README for the install contract" do
          expect(contents).to include("README")
        end

        it "no longer points at the interim AGENTS.md" do
          expect(contents).not_to include("AGENTS.md")
        end
      end
    end
  end
end
