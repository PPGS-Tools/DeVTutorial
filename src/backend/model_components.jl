using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as Dt
using ModelingToolkitStandardLibrary.Blocks: RealInput

@mtkmodel measurement_bus_frequency begin
    @parameters begin
        f_b=50, [description="Base frequency"]
    end
    @components begin
        ωin = RealInput()
    end
    @variables begin
        f(t), [description="Frequency [Hz]"]
    end
    @equations begin
        f ~ ωin.u * f_b
    end
end

function GeneratorBus(; machine_p=(;), avr_p=(;), gov_p=(;), load_p=(;))
    @named machine = SauerPaiMachine(;
        vf_input=true,
        τ_m_input=true,
        S_b=100,
        V_b=1,
        ω_b=2π*50,
        R_s=0.000125,
        T″_d0=0.01,
        T″_q0=0.01,
        machine_p... # unpack machine parameters
    )
    @named avr = AVRTypeI(; vr_min=-5, vr_max=5,
        Ka=20, Ta=0.2,
        Kf=0.063, Tf=0.35,
        Ke=1, Te=0.314,
        E1=3.3, Se1=0.6602, E2=4.5, Se2=4.2662,
        tmeas_lag=false,
        avr_p... # unpack AVR parameters
    )
    @named gov = TGOV1(; R=0.05, T1=0.05, T2=2.1, T3=7.0, DT=0, V_max=5, V_min=-5,
        gov_p... # unpack governor parameters
    )

    @named load = PQLoad(; Pset=-POWER_SETPOINT, Qset=0.0, load_p...)

    @named meas = measurement_bus_frequency(; f_b=50)

    connect(machine.ωout, meas.ωin)
    injector = CompositeInjector([machine, avr, gov, load, meas]; name=:generator)

    mtkbus = MTKBus(injector)
end

function piline(; R, X, B)
    @named pibranch = PiLineLength(;R, X, B_src=B/2, B_dst=B/2, G_src=0, G_dst=0, l=1)
    MTKLine(pibranch)
end


@mtkmodel PiLineLength begin
    @parameters begin
        R=0, [description="Resistance of branch in pu"]
        X=0.1, [description="Reactance of branch in pu"]
        G_src=0, [description="Conductance of src shunt"]
        B_src=0, [description="Susceptance of src shunt"]
        G_dst=0, [description="Conductance of dst shunt"]
        B_dst=0, [description="Susceptance of dst shunt"]
        r_src=1, [description="src end transformation ratio"]
        r_dst=1, [description="dst end transformation ratio"]
        active=1, [description="Line active or at fault"]
        l=1, [description="Line length"]
    end
    @components begin
        src = Terminal()
        dst = Terminal()
    end
    begin
        Z = (R + im*X) * l
        Ysrc = (G_src + im*B_src) * l
        Ydst = (G_dst + im*B_dst) * l
        Vsrc = src.u_r + im*src.u_i
        Vdst = dst.u_r + im*dst.u_i
        V₁ = r_src * Vsrc
        V₂ = r_dst * Vdst
        i₁ = Ysrc * V₁
        i₂ = Ydst * V₂
        iₘ = 1/Z * (V₁ - V₂)
        isrc = (-iₘ - i₁)*r_src
        idst = ( iₘ - i₂)*r_dst
    end
    @equations begin
        src.i_r ~ active * simplify(real(isrc))
        src.i_i ~ active * simplify(imag(isrc))
        dst.i_r ~ active * simplify(real(idst))
        dst.i_i ~ active * simplify(imag(idst))
    end
end
