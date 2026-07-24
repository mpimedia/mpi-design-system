# frozen_string_literal: true

require "spec_helper"

# Guards the released version constant. PR4 of #103 cut v0.2.0 (first adoption-ready
# release); v0.3.0 (#121) tokenizes Admin::EmptyState; v0.4.0 (#124) tokenizes
# Admin::BreadcrumbNav; v0.4.1 (#128) fixes Admin::Badge filled contrast; v0.5.0 adds
# opt-in Admin::Pagination link windowing (harvest#769); v0.6.0 (#134) adds the
# slot/block-based Admin::TableForIndex with batch selection + Ransack-free sortable
# headers (harvest#692); v0.7.0 (#148) releases Admin::ActionButton's classes_append: /
# verb-gated role: / :info color (#136), AA foreground derivation for the inline-styled
# components (#130), and the changelog release guard (#127); v0.8.0 (#149) makes
# Admin::Pagination theme-adaptive — the Track 2 pilot conversion (epic #147);
# v0.9.0 releases the NavBar/AppShell theme-adaptive conversion (#154, phase 6) and the
# StatCard/AvatarStack/ActiveFilterBar small conversions (#150, phase 2); v0.10.0 batches
# the FilterChipBar/DataTable/TagChip semantic conversion (#151, phase 3) and the FilterPanel
# theme-adaptive conversion (#152, phase 4 — the AvatarCircle half is split to #169); v0.11.0
# (#153) makes Admin::Dashboard theme-adaptive — the largest inline-hex surface (Track 2 phase 5;
# the caller-supplied Contacts-by-Group chart palette is split to #172); v0.12.0 promotes
# AvatarCircle's name-hash identity palette to theme-adaptive runtime `--mds-avatar-*` tokens
# (#169, split from #152 — the engine's first hand-authored dark palette) and records the #172
# chart-palette caller-owned decision. This spec fails if the constant regresses, keeping
# lib/mpi_design_system/version.rb in lockstep with CHANGELOG.md and the git tag.
RSpec.describe "MpiDesignSystem::VERSION" do
  it "is 0.12.0" do
    expect(MpiDesignSystem::VERSION).to eq("0.12.0")
  end
end
