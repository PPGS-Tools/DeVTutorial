struct InertiaExtension end

function ParamExtension(::Type{InertiaExtension})

    function init_callbacks!(_, _)
        return false
    end

    trigger_level = :post_init

    function add_widgets!(fig, nr)
        inertia_sliders = SliderGrid(fig[nr, 1], 
            (label=L"$H_1$", range = 0.1:0.1:30, startvalue = 6), 
            (label=L"$H_2$", range = 0.1:0.1:30, startvalue = 6), 
            (label=L"$H_3$", range = 0.1:0.1:30, startvalue = 6)
        )
        return combine([s.value for s in inertia_sliders.sliders])
    end

    callbacks = [
        function set_inertia!(backend_state::BackendState, sliders::Vector)
            set_default!.(backend_state.nw[], vidxs(backend_state.nw[], :, INERTIA_SYMBOL), sliders)
        end
    ]

    return ParamExtension(init_callbacks!, trigger_level, add_widgets!, callbacks)
end