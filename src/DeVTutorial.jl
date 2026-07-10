module DeVTutorial

using PowerDynamics
using PowerDynamics.Library
using ModelingToolkit
using NetworkDynamics
using Graphs
using OrdinaryDiffEqRosenbrock
using OrdinaryDiffEqNonlinearSolve
using GLMakie
using WGLMakie # Interactive Plot
using Bonito

const START_TIME = 0.0
const DISTURBANCE_TIME = 1.0
const END_TIME = 15.0

const ODE_SOLVER = Rodas5P(autodiff=true)

include("backend/backend.jl")
include("backend/model_components.jl")
include("backend/model_setup.jl")

include("frontend/frontend.jl")
include("frontend/plot.jl")

include("param_extension/param_extension.jl")
include("param_extension/disturbance.jl")
include("param_extension/inertia.jl")
include("param_extension/lines.jl")
include("param_extension/power_transfer.jl")

include("app.jl")

const EXTENSION_REGISTRY = [
        DisturbanceExtension,
        InertiaExtension,
        LineExtension,
        PowerTransferExtension
    ]

export app

end # module DeVCode
