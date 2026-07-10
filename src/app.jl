function app()
    extensions = [ParamExtension(ext) for ext in EXTENSION_REGISTRY]
    backend_state = BackendState(initial_setup, extensions)
    frontend_state = FrontendState(backend_state, extensions)
    frontend_state.fig
end