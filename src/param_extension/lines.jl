struct LineExtension end

function ParamExtension(::Type{LineExtension})

    function _val_format(x)
        L"$%$(round(Int, x * 100))\,\mathrm{km}$"
    end

    function init_callbacks!(_, _)
        return false
    end

    trigger_level = :pre_init

    function add_widgets!(fig, nr)
        function _label_format(x)
            L"l_{%$(x)-%$(x+1)}"
        end

        function _unit_format(x)
            L"\mathrm{km}"
        end

        line_sliders = add_editable_sliders!(fig, nr, 2, _label_format, 0.1:0.1:10, 1, 100, _unit_format; show_as_int = true)
        return combine([s.value for s in line_sliders])
    end

    callbacks = [
        function set_line_length!(backend_state::BackendState, sliders::Vector)
            set_default!.(backend_state.nw[], eidxs(backend_state.nw[], :, LINE_LENGTH_SYMBOL), sliders)
        end
    ]

    return ParamExtension(init_callbacks!, trigger_level, add_widgets!, callbacks)
end