struct PowerTransferExtension end

function ParamExtension(::Type{PowerTransferExtension})

    function init_callbacks!(_, _)
        return false
    end

    trigger_level = :pre_init

    function add_widgets!(fig, nr)
        transfer_sliders = SliderGrid(fig[nr, 1],
            (label=L"P_\mathrm{A}", range = -1:0.1:1, startvalue = 0.0)
        )
        return combine([s.value for s in transfer_sliders.sliders])
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

