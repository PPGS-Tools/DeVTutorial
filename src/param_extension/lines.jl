struct LineExtension end

function ParamExtension(::Type{LineExtension})

    function init_callbacks!(_, _)
        return false
    end

    trigger_level = :pre_init

    function add_widgets!(fig, nr)
        line_sliders = SliderGrid(fig[nr, 1],
            (label=L"d_1", range = 0.1:0.1:10, startvalue = 1),
            (label=L"d_2", range = 0.1:0.1:10, startvalue = 1)
        )
        return combine([s.value for s in line_sliders.sliders])
    end

    callbacks = [
        function set_line_length!(backend_state::BackendState, sliders::Vector)
            set_default!.(backend_state.nw[], eidxs(backend_state.nw[], :, LINE_LENGTH_SYMBOL), sliders)
        end
    ]

    return ParamExtension(init_callbacks!, trigger_level, add_widgets!, callbacks)
end