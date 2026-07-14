# frozen_string_literal: true

require "spec_helper"

# Guards the released version constant. PR4 of #103 cut v0.2.0 (first adoption-ready
# release); v0.3.0 (#121) tokenizes Admin::EmptyState. This spec fails if the constant
# regresses, keeping lib/mpi_design_system/version.rb in lockstep with CHANGELOG.md and
# the git tag.
RSpec.describe "MpiDesignSystem::VERSION" do
  it "is 0.3.0" do
    expect(MpiDesignSystem::VERSION).to eq("0.3.0")
  end
end
