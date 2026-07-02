# frozen_string_literal: true

require "spec_helper"

# Guards .claude/rules/dependencies.md: the gemspec's runtime dependencies are
# forced into every consuming app's bundle, so the set is kept deliberately
# minimal. `bootstrap` was removed in #103 (Work item 2) because nothing in the
# engine loads the Ruby gem — SCSS resolves Bootstrap against the app's npm
# package via a dart-sass `--load-path`. This spec fails if it (or any other
# runtime dependency) creeps back into the gemspec.
RSpec.describe "mpi_design_system.gemspec" do
  let(:gemspec) do
    path = File.expand_path("../../mpi_design_system.gemspec", __dir__)
    Gem::Specification.load(path)
  end

  let(:runtime_dependencies) do
    gemspec.dependencies.select { |dep| dep.type == :runtime }.map(&:name)
  end

  it "declares exactly the intended runtime dependencies" do
    expect(runtime_dependencies).to contain_exactly("rails", "view_component", "stimulus-rails")
  end

  it "does not force Bootstrap into consuming apps' bundles" do
    expect(runtime_dependencies).not_to include("bootstrap")
  end

  it "requires Ruby >= 3.4" do
    expect(gemspec.required_ruby_version.to_s).to include("3.4")
  end
end
