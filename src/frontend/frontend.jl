struct FrontendState
    fig::Figure
end

function FrontendState(backend_state::BackendState, extensions::Vector)
    activate_makie_frontend()
    fig = Figure(size = (2000, 900))
    plot_column = GridLayout(fig[1, 1])
    widget_column = GridLayout(fig[1, 2])
    draw_axes(plot_column, backend_state.sol)

    for (ctr, ext) in enumerate(extensions)
        register_param_extension!(widget_column, backend_state, ext, ctr)
    end

    draw_eigenvalue_axis(widget_column[length(extensions)+1, 1], backend_state.λ)

    widget_column.tellheight = false
    colsize!(fig.layout, 2, Auto(0.3))
    FrontendState(fig)
end

function activate_makie_frontend(;force_web=false)
    if force_web || "JUPYTERHUB_SERVICE_PREFIX" in keys(ENV)
        WGLMakie.activate!()
        userpath = ENV["JUPYTERHUB_SERVICE_PREFIX"]
        Page(listen_port=9091, proxy_url="https://hub.bwjupyter.de$(userpath)proxy/9091")
    else
        error("Failed to activate WGLMakie frontend")
        #GLMakie.activate!()
    end
end