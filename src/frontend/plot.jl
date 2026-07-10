"""
    draw_axes
"""
function draw_axes(fig, sol; firstindex=1)

    # Generator power
    ax = Axis(fig[firstindex, 1]; title="Generator Power", xlabel="Time [s]", ylabel="Power [pu]")
    for i in 1:3
        lines!(ax, sol; idxs=VIndex(i,:generator₊machine₊P), label="Bus $i", color=Cycled(i))
    end
    ylims!(ax, (-1.0, 2.0))
    xlims!(ax, (START_TIME, END_TIME))
    axislegend(ax)

    # Voltage magnitude at all buses
    ax = Axis(fig[firstindex+1, 1]; title="Voltage Magnitude", xlabel="Time [s]", ylabel="Voltage [pu]")
    for i in 1:3
        lines!(ax, sol; idxs=VIndex(i,:busbar₊u_mag), label="Bus $i", color=Cycled(i))
    end
    ylims!(ax, (0.9, 1.1))
    xlims!(ax, (START_TIME, END_TIME))
    axislegend(ax)

    # Generator frequencies
    ax = Axis(fig[firstindex+2, 1]; title="Generator Frequency", xlabel="Time [s]", ylabel="Frequency [Hz]")
    for i in 1:3
        lines!(ax, sol; idxs=VIndex(i,:generator₊meas₊f), label="Gen $i", color=Cycled(i))
    end
    ylims!(ax, (49.5, 50.5))
    xlims!(ax, (START_TIME, END_TIME))
    axislegend(ax)

    # Line flows
    ax = Axis(fig[firstindex+3, 1]; title="Powerflow", xlabel="Time [s]", ylabel="Power [MW]")
    for i in 1:2
        lines!(ax, sol; idxs=EIndex(i,:src₊P), label="Line $i", color=Cycled(i))
    end
    ylims!(ax, (-2, 2))
    xlims!(ax, (START_TIME, END_TIME))
    axislegend(ax)

end

function draw_eigenvalue_axis(fig, λ)
    ax = Axis(fig; title="Eigenvalues", xlabel=L"$Real(\lambda)$", ylabel=L"$Imag(\lambda)$")
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