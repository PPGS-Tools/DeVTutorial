struct ParamExtension
    init_callbacks!::Function
    trigger_level::Symbol
    add_widgets!::Function
    callbacks::Vector
end

combine(obs) = lift(obs...) do obs...
    collect(obs)
end

function register_param_extension!(widget_column, backend_state::BackendState, ext::ParamExtension, ctr)
    widgets = ext.add_widgets!(widget_column, ctr)

    on(widgets) do widgets
        for cb in ext.callbacks
            cb(backend_state, widgets)
        end
    end

    if ext.trigger_level === :pre_init
        on(widgets) do _
            notify(backend_state.nw)
        end
    elseif ext.trigger_level === :post_init
        on(widgets) do _
            notify(backend_state.u0)
        end
    end
end
