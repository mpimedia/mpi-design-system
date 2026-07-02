# frozen_string_literal: true

require "spec_helper"

# Guards Work item 2 of #103: the engine delivers component JS/SCSS as *source*
# consumed by each host app's esbuild alias + dart-sass `--load-path`, NOT via
# the Rails asset pipeline. A `config.assets.paths` initializer delivers nothing
# to the esbuild/dart-sass pipeline every MPI app uses and only misleads
# consumers, so it must not exist. These examples fail if it is re-introduced.
RSpec.describe MpiDesignSystem::Engine do
  describe "asset-delivery contract" do
    it "registers no config.assets.paths initializer" do
      initializer_names = described_class.initializers.map(&:name)

      expect(initializer_names).not_to include("mpi_design_system.assets")
    end

    it "does not push the engine's JS source dir onto the host asset paths" do
      # `app/javascript` holds esbuild-bundled *source* — it must never be on the
      # Propshaft path (that was the misleading part of the removed initializer).
      # `app/assets/stylesheets` is deliberately NOT asserted here: Rails'
      # built-in `Rails::Engine` `append_assets_path` initializer adds every
      # engine's `app/assets/*` by default, and that standard contribution is
      # harmless (Propshaft serves static files; it does not compile the .scss).
      asset_paths = Rails.application.config.assets.paths.map(&:to_s)

      expect(asset_paths).not_to include(described_class.root.join("app/javascript").to_s)
    end
  end
end
