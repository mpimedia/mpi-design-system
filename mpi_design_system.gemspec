require_relative "lib/mpi_design_system/version"

Gem::Specification.new do |spec|
  spec.name        = "mpi_design_system"
  spec.version     = MpiDesignSystem::VERSION
  spec.authors     = [ "Randy Burgess" ]
  spec.email       = [ "wrburgess@gmail.com" ]
  spec.homepage    = "https://github.com/mpimedia/mpi-design-system"
  spec.summary     = "Shared ViewComponent library for MPI Media applications"
  spec.description = "Rails engine providing shared UI components, layouts, and design tokens for MPI Media's application suite (Markaz, SFA, Garden, Harvest)."
  spec.license     = "LicenseRef-MPI-Proprietary"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mpimedia/mpi-design-system"
  spec.metadata["changelog_uri"] = "https://github.com/mpimedia/mpi-design-system/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.4"

  # Runtime dependencies are forced into every consuming app's bundle, so this
  # set is kept deliberately minimal (see .claude/rules/dependencies.md).
  # Bootstrap is intentionally NOT here: nothing in the engine loads the Ruby
  # `bootstrap` gem — consuming apps compile Bootstrap SCSS against their own npm
  # `bootstrap` package via a dart-sass `--load-path` (Issue #103, Work item 2).
  spec.add_dependency "rails", ">= 8.1"
  spec.add_dependency "view_component", ">= 3.0"
  spec.add_dependency "stimulus-rails"
end
