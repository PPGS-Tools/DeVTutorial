struct BackendState
    nw::Observable
    u0::Observable
    sol::Observable
    λ::Observable
    vertexfs::Vector
    edgefs::Vector
end

function BackendState(setup_function::Function, extensions::Vector)
    vertexfs, edgefs = setup_function()
    nw = Observable(Network(vertexfs, edgefs; warn_order=false))

    for ext in extensions
        ext.init_callbacks!(vertexfs, edgefs)
    end

    # :pre_init
    u0 = lift(nw) do nw
        println("Initializing")
        initialize_from_pf!(nw)
        NWState(nw)
    end

    # :post_init
    sol = lift(u0) do u0
        prob = ODEProblem(nw[], u0, (START_TIME, END_TIME))
        solve(prob, ODE_SOLVER; p=pflat(NWParameter(nw[])))
    end

    λ = lift(u0) do u0
        [(real(λ), imag(λ)) for λ in jacobian_eigenvals(NWState(nw[]))]
    end

    return BackendState(nw, u0, sol, λ, vertexfs, edgefs)

end
