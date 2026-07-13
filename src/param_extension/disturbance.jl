struct DisturbanceExtension end

function ParamExtension(::Type{DisturbanceExtension})

    function _set_load_callbacks!(vertexfs::Vector, magnitudes::Vector)
        get_event(mag) = ComponentAffect([], [LOAD_SYMBOL]) do u, p, ctx
            p[LOAD_SYMBOL] -= mag
        end
        cb = [PresetTimeComponentCallback([DISTURBANCE_TIME], get_event(mag)) for mag in magnitudes]
        set_callback!.(vertexfs, cb)
    end

    function init_callbacks!(vertexfs::Vector, _)
        _set_load_callbacks!(vertexfs, zeros(size(vertexfs)))
    end

    trigger_level = :post_init

    function add_widgets!(fig, nr)
        dist_sliders = SliderGrid(fig[nr, 1], 
            (label=L"$\frac{\Delta P_{\mathrm{Z},1}}{500 \mathrm{MW}}$", range = -1:0.01:1, startvalue = 0), 
            (label=L"$\frac{\Delta P_{\mathrm{Z},2}}{500 \mathrm{MW}}$", range = -1:0.01:1, startvalue = 0), 
            (label=L"$\frac{\Delta P_{\mathrm{Z},3}}{500 \mathrm{MW}}$", range = -1:0.01:1, startvalue = 0)
        )
        return combine([s.value for s in dist_sliders.sliders])
    end

    callbacks = [
        function dist(backend_state::BackendState, sliders::Vector)
            _set_load_callbacks!(backend_state.vertexfs, sliders)
        end
    ]

    return ParamExtension(init_callbacks!, trigger_level, add_widgets!, callbacks)
end