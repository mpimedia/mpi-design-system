module MpiDesignSystem
  class Engine < ::Rails::Engine
    isolate_namespace MpiDesignSystem

    # No asset-pipeline initializer by design. The engine ships its component
    # JS and SCSS as *source*, delivered to each consuming app through that
    # app's own esbuild alias and dart-sass `--load-path` (see README for the
    # install contract). Pushing these dirs onto `config.assets.paths`
    # delivers nothing to the esbuild + dart-sass pipeline every MPI app uses and
    # only misleads consumers into thinking the assets "just work" once mounted.
    # (Issue #103, Work item 2.)
  end
end
