struct InertiaExtension end

function ParamExtension(::Type{InertiaExtension})

    function init_callbacks!(_, _)
        return false
    end

    trigger_level = :post_init

    function add_widgets!(fig, nr)
        function _label_format(x)
            L"$T_{\mathrm{A},%$(x)}$"
        end

        function _unit_format(x)
            L"$\mathrm{s}$"
        end

        inertia_sliders = add_editable_sliders!(fig, nr, 3, _label_format, 0.005:0.005:12, 6.0, 2, _unit_format)
        return combine([s.value for s in inertia_sliders])
    end

    callbacks = [
        function set_inertia!(backend_state::BackendState, sliders::Vector)
            set_default!.(backend_state.nw[], vidxs(backend_state.nw[], :, INERTIA_SYMBOL), sliders)
        end
    ]

    return ParamExtension(init_callbacks!, trigger_level, add_widgets!, callbacks)
end