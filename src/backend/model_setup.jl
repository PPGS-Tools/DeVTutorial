const LOAD_SYMBOL = :generator₊load₊Pset
const LINE_LENGTH_SYMBOL = :pibranch₊l
const INERTIA_SYMBOL = :generator₊machine₊H
const VOLTAGE_SETPOINT = 1.04
const POWER_SETPOINT = 0.5

function initial_setup()
    mtkbuses = initial_bus_models()
    mtklines = initial_line_models()
    vertexfs = compile_bus_models(mtkbuses);
    edgefs = compile_line_models(mtklines);
    params = (vertexfs, edgefs)
    return params
end


function initial_bus_models()
    gen1p = (;X_ls=0.01460, X_d=0.1460, X′_d=0.0608, X″_d=0.06, X_q=0.1000, X′_q=0.0969, X″_q=0.06, T′_d0=8.96, T′_q0=0.310, H=6.364)
    gen2p = (;X_ls=0.01460, X_d=0.1460, X′_d=0.0608, X″_d=0.06, X_q=0.1000, X′_q=0.0969, X″_q=0.06, T′_d0=8.96, T′_q0=0.310, H=6.364)
    gen3p = (;X_ls=0.01460, X_d=0.1460, X′_d=0.0608, X″_d=0.06, X_q=0.1000, X′_q=0.0969, X″_q=0.06, T′_d0=8.96, T′_q0=0.310, H=6.364)

    mtkbus1 = GeneratorBus(; machine_p=gen1p)
    mtkbus2 = GeneratorBus(; machine_p=gen2p)
    mtkbus3 = GeneratorBus(; machine_p=gen3p)
    return [mtkbus1, mtkbus2, mtkbus3]
end


function compile_bus_models(mtkbus_vec)
    vertexfs = similar(mtkbus_vec, VertexModel)
    for (i, mtkbus) in enumerate(mtkbus_vec)
        vertexfs[i] = compile_bus(mtkbus; name=Symbol(:bus, i), vidx=i, pf=(i==2 ? pfSlack(V=VOLTAGE_SETPOINT) : pfPV(V=VOLTAGE_SETPOINT, P=0.0)))
    end
    return vertexfs
end


function initial_line_models()
    mtkline12 = piline(; R=0.0170, X=0.0920, B=0.1580)
    mtkline23 = piline(; R=0.0170, X=0.0920, B=0.1580)
    return [mtkline12, mtkline23]
end


function compile_line_models(mtkline_vec)
    edgefs = similar(mtkline_vec, EdgeModel)
    for (i, mtkline) in enumerate(mtkline_vec)
        edgefs[i] = compile_line(mtkline, name=Symbol(:l, i, i+1), src=i, dst=i+1)
    end
    return edgefs
end