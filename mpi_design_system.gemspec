require_relative "lib/mpi_design_system/version"

Gem::Specification.new do |spec|
  spec.name        = "mpi_design_system"
  spec.version     = MpiDesignSystem::VERSION
  spec.authors     = ["Randy Burgess"]
  spec.email       = ["wrburgess@gmail.com"]
  spec.homepage    = "https://github.com/mpimedia/mpi-design-system"
  spec.summary     = "Shared ViewComponent library for MPI Media applications"
  spec.description = "Rails engine providing shared UI components, layouts, and design tokens for MPI Media's application suite (Markaz, SFA, Garden, Harvest, Markaz CRM)."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mpimedia/mpi-design-system"
  spec.metadata["changelog_uri"] = "https://github.com/mpimedia/mpi-design-system/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.4"

  spec.add_dependency "rails", ">= 8.1"
  spec.add_dependency "view_component", ">= 3.0"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "bootstrap", "~> 5.3"
  spec.add_dependency "sassc-rails"
end
