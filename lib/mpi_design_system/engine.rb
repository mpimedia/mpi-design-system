module MpiDesignSystem
  class Engine < ::Rails::Engine
    isolate_namespace MpiDesignSystem

    initializer "mpi_design_system.assets" do |app|
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.paths << root.join("app/assets/stylesheets")
    end
  end
end
