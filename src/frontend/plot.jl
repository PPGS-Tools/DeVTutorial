"""
    draw_axes
"""
function draw_axes(fig, sol, colors; firstindex=1)
    linestyles = [:solid, :dash, :dot]
    # Generator power
    ax1 = Axis(fig[firstindex, 1]; title=L"\textbf{Generatorwirkleistung}", xlabel=L"\text{Zeit}\,/\,\mathrm{s}", ylabel=L"\text{Leistung}\,/\,\mathrm{MW}")
    for i in 1:3
        lines!(ax1, sol; idxs=@obsex(1000 * VIndex(i,:generator₊machine₊P)), label="Bus $i", color=colors[i], linestyle=linestyles[i])
    end
    ylims!(ax1, (400.0, 600.0))
    #xlims!(ax1, (START_TIME, END_TIME))
    axislegend(ax1)#["Region 1", "Region 2", "Region 3"]

    # # Voltage magnitude at all buses
    # ax2 = Axis(fig[firstindex+1, 1]; title=L"\textbf{Spannung}", xlabel=L"\text{Zeit}\,/\,\mathrm{s}", ylabel=L"\text{Zeit}\,/\,\mathrm{p.u.}")
    # for i in 1:3
    #     lines!(ax2, sol; idxs=VIndex(i,:busbar₊u_mag), label="Bus $i", color=colors[i], linestyle=linestyles[i])
    # end
    # ylims!(ax2, (0.9, 1.1))
    # xlims!(ax2, (START_TIME, END_TIME))
    # axislegend(ax2)

    # Generator frequencies
    ax3 = Axis(fig[firstindex+1, 1]; title=L"\textbf{Frequenz}", xlabel=L"\text{Zeit}\,/\,\mathrm{s}", ylabel=L"\text{Frequenz}\,/\,\mathrm{Hz}")
    for i in 1:3
        lines!(ax3, sol; idxs=VIndex(i,:generator₊meas₊f), label="Gen $i", color=colors[i], linestyle=linestyles[i])
    end
    ylims!(ax3, (49.5, 50.5))
    #xlims!(ax3, (START_TIME, END_TIME))
    axislegend(ax3)

    # Line flows
    ax4 = Axis(fig[firstindex+2, 1]; title=L"\textbf{Austauschleistung}", xlabel=L"\text{Zeit}\,/\,\mathrm{s}", ylabel=L"\text{Leistung}\,/\,\mathrm{MW}")
    for i in 1:2
        lines!(ax4, sol; idxs=@obsex(500 * EIndex(i,:src₊P)), label="Line $i", color=colors[i], linestyle=linestyles[i])
    end
    ylims!(ax4, (-100, 100))
    axislegend(ax4)

    axlist = [ax1, ax3, ax4]
    xlims!.(axlist, Ref((START_TIME, END_TIME)))
    linkxaxes!(axlist)
    #set_theme!(Theme(palette = [color = colors]))

end

function draw_eigenvalue_axis(fig, λ)
    ax = Axis(fig; title=L"\textbf{Eigenwerte}", xlabel=L"$\Re(\lambda)$", ylabel=L"$\Im(\lambda)$")
    for i in 1:3
        scatter!(ax, λ)
    end
    ylims!(ax, (-20, 20))
    xlims!(ax, (-4.5, 0.5))
end

"""
    plot_static
"""
function plot_static(sol::ODESolution; file="solution_plot.png")
    # Plotting
    fig = Figure(size=(600,800));
    DrawAxes(fig, sol)
    save(file, fig)
end


"""
    plot_static
"""
function plot_static(prob::ODEProblem; file="solution_plot.png")
    sol = solve(prob, Rodas5P())
    plot_static(sol; file=file)
end