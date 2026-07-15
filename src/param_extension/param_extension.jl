struct ParamExtension
    init_callbacks!::Function
    trigger_level::Symbol
    add_widgets!::Function
    callbacks::Vector
end

combine(obs) = lift(obs...) do obs...
    collect(obs)
end

function add_editable_sliders!(fig, pos, num_sliders, label_format, range, startvalue, scale_output, unit_format; show_as_int = false)
    colors = Makie.wong_colors()
    subgrid = GridLayout(fig[pos, 1])
    dist_sliders = []
    for i = 1:num_sliders
        Label(subgrid[i, 1], label_format(i))
        slider = Makie.Slider(subgrid[i, 2], range=range, startvalue=startvalue,color_inactive=colors[i],color_active=:black,color_active_dimmed=colors[i])
        push!(dist_sliders, slider)
        tb = Textbox(subgrid[i, 3], stored_string=string(startvalue * scale_output), validator=Float64, width=50)
        on(tb.stored_string) do string
            set_close_to!(slider, parse(Float64, string) / scale_output)
        end
        if show_as_int
            on(slider.value) do slider
                Makie.set!(tb, string(split(string(slider * scale_output), ".")[1]))
            end
        else
            on(slider.value) do slider
                Makie.set!(tb, string(slider * scale_output))
            end
        end
        Label(subgrid[i, 4], unit_format(i))
    end
    colsize!(subgrid, 1, Relative(0.10))
    colsize!(subgrid, 2, Relative(0.75))
    colsize!(subgrid, 3, Relative(0.10))
    colsize!(subgrid, 4, Relative(0.05))
    return dist_sliders
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
