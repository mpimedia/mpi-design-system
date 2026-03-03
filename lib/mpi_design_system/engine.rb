module MpiDesignSystem
  class Engine < ::Rails::Engine
    isolate_namespace MpiDesignSystem

    initializer "mpi_design_system.view_component" do
      ActiveSupport.on_load(:view_component) do
        # ViewComponent autoloading is handled by the engine's autoload paths
      end
    end

    config.to_prepare do
      # Ensure Admin:: components are autoloaded from the engine
    end
  end
end
