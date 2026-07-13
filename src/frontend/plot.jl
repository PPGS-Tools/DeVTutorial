"""
    draw_axes
"""
function draw_axes(fig, sol; firstindex=1)

    # Generator power
    ax = Axis(fig[firstindex, 1]; title="Generatorwirkleistung", xlabel="Zeit in s", ylabel="Leistung in MW")
    for i in 1:3
        lines!(ax, sol; idxs=@obsex(1000 * VIndex(i,:generator₊machine₊P)), label="Bus $i", color=Cycled(i))
    end
    ylims!(ax, (400.0, 600.0))
    xlims!(ax, (START_TIME, END_TIME))
    axislegend(ax)#["Region 1", "Region 2", "Region 3"]

    # # Voltage magnitude at all buses
    # ax = Axis(fig[firstindex+1, 1]; title="Voltage Magnitude", xlabel="Time [s]", ylabel="Voltage [pu]")
    # for i in 1:3
    #     lines!(ax, sol; idxs=VIndex(i,:busbar₊u_mag), label="Bus $i", color=Cycled(i))
    # end
    # ylims!(ax, (0.9, 1.1))
    # xlims!(ax, (START_TIME, END_TIME))
    # axislegend(ax)

    # Generator frequencies
    ax = Axis(fig[firstindex+1, 1]; title="Frequenz", xlabel="Zeit in s", ylabel="Frequenz in Hz")
    for i in 1:3
        lines!(ax, sol; idxs=VIndex(i,:generator₊meas₊f), label="Gen $i", color=Cycled(i))
    end
    ylims!(ax, (49.5, 50.5))
    xlims!(ax, (START_TIME, END_TIME))
    axislegend(ax)

    # Line flows
    ax = Axis(fig[firstindex+2, 1]; title="Austauschleistung", xlabel="Zeit in s", ylabel="Leistung in MW")
    for i in 1:2
        lines!(ax, sol; idxs=EIndex(i,:src₊P), label="Line $i", color=Cycled(i))
    end
    ylims!(ax, (-2, 2))
    xlims!(ax, (START_TIME, END_TIME))
    axislegend(ax)

end

function draw_eigenvalue_axis(fig, λ)
    ax = Axis(fig; title="Eigenwerte", xlabel=L"$Real(\lambda)$", ylabel=L"$Imag(\lambda)$")
    for i in 1:3
        scatter!(ax, λ)
    end
    ylims!(ax, (-2.5, 2.5))
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