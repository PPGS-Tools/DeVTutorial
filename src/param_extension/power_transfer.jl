struct PowerTransferExtension end

function ParamExtension(::Type{PowerTransferExtension})

    function init_callbacks!(_, _)
        return false
    end

    trigger_level = :pre_init

    function add_widgets!(fig, nr)
        function _label_format(x)
            L"P_{\mathrm{A},(%$(x)-%$(x+2))}"
        end

        function _unit_format(x)
            L"\mathrm{MW}"
        end

        transfer_sliders = add_editable_sliders!(fig, nr, 1, _label_format, -1:0.1:1, 0, 500, _unit_format; show_as_int = true)
        return combine([s.value for s in transfer_sliders])
    end

    callbacks = [
        function set_power_transfer!(backend_state::BackendState, sliders::Vector)
            set_default!(backend_state.nw[], VIndex(1, LOAD_SYMBOL), sliders[1]-POWER_SETPOINT)
            set_default!(backend_state.nw[], VIndex(3, LOAD_SYMBOL), -sliders[1]-POWER_SETPOINT)
            set_pfmodel!(backend_state.nw[], VIndex(1), pfPV(V=VOLTAGE_SETPOINT, P=sliders[1]))
            set_pfmodel!(backend_state.nw[], VIndex(3), pfPV(V=VOLTAGE_SETPOINT, P=-sliders[1]))
        end
    ]

    return ParamExtension(init_callbacks!, trigger_level, add_widgets!, callbacks)
end

