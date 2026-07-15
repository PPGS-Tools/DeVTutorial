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
        function _label_format(n)
            L"$\Delta P_{\mathrm{Z},%$(n)}$"
        end

        function _unit_format(x)
            L"$\mathrm{MW}$"
        end
        
        dist_sliders = add_editable_sliders!(fig, nr, 3, _label_format, -0.2:0.002:0.2, 0, 500, _unit_format; show_as_int=true)
        return combine([s.value for s in dist_sliders])
    end

    callbacks = [
        function dist(backend_state::BackendState, sliders::Vector)
            _set_load_callbacks!(backend_state.vertexfs, sliders)
        end
    ]

    return ParamExtension(init_callbacks!, trigger_level, add_widgets!, callbacks)
end