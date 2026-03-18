## iso221_vs_std.jl
# Example simulation comparing the iso221 (2-reserve) model against the standard
# (1-reserve) DEB model.
#
# Runs two scenarios:
#   1. Constant balanced diet: iso221 vs std with equivalent parameters
#   2. Geometric Framework scenario: varying food ratio X1:X2 over the lifecycle,
#      showing ontogenetic dietary preference shifts
#
# Usage:
#   cd("path/to/DEBtool_J.jl")
#   using Pkg; Pkg.activate(".")
#   include("examples/iso221_vs_std.jl")
#
# Requires GLMakie (or another Makie backend):
#   Pkg.add("GLMakie")
#   using GLMakie

using DEBtool_J
using Unitful
using ModelParameters

# -------------------------------------------------------------------------
# iso221 Parameters (from MATLAB mydata_iso_221.m, Kooijman 2011/2023)
# -------------------------------------------------------------------------
p_iso221_raw = (;
    M_X1   = Const(1e-3,  units=u"mol",        label="food particle size 1"),
    M_X2   = Const(1e-3,  units=u"mol",        label="food particle size 2"),
    F_X1m  = Const(2.0,   units=u"dm^2/d/cm^2",         label="searching rate food 1"),
    F_X2m  = Const(3.0,   units=u"dm^2/d/cm^2",         label="searching rate food 2"),
    J_X1Am = Param(2.0e-3, units=u"mol/d/cm^2", label="max ingestion rate food 1"),
    J_X2Am = Param(2.0e-3, units=u"mol/d/cm^2", label="max ingestion rate food 2"),
    y_E1X1 = Param(0.45,  units=u"mol/mol",        label="yield E1 on X1"),
    y_E2X1 = Param(0.35,  units=u"mol/mol",        label="yield E2 on X1"),
    y_E1X2 = Param(0.35,  units=u"mol/mol",        label="yield E1 on X2"),
    y_E2X2 = Param(0.45,  units=u"mol/mol",        label="yield E2 on X2"),
    y_P1X1 = Const(0.15,  units=u"mol/mol",        label="faecal yield P1 on X1"),
    y_P2X2 = Const(0.15,  units=u"mol/mol",        label="faecal yield P2 on X2"),
    y_VE1  = Param(0.8,   units=u"mol/mol",        label="yield V on E1"),
    y_VE2  = Param(0.8,   units=u"mol/mol",        label="yield V on E2"),
    v      = Param(0.02,  units=u"cm/d",        label="energy conductance"),
    kap    = Param(0.8,   units=nothing,        label="allocation fraction to soma"),
    mu_E1  = Const(4e5,   units=u"J/mol",       label="chemical potential E1"),
    mu_E2  = Const(6e5,   units=u"J/mol",       label="chemical potential E2"),
    mu_V   = Const(5e5,   units=u"J/mol",       label="chemical potential V"),
    j_E1M  = Param(0.09,  units=u"mol/d/mol",        label="spec somatic maint E1"),
    j_E2M  = Param(0.09 * 6e5 / 4e5, units=u"mol/d/mol", label="spec somatic maint E2"),
    J_E1T  = Const(0.0,   units=u"mol/d/cm^2",  label="surface-linked maint E1"),
    J_E2T  = Const(0.0,   units=u"mol/d/cm^2",  label="surface-linked maint E2"),
    MV     = Param(4e-3,  units=u"mol/cm^3",    label="volume-specific structure density"),
    kap_E1 = Const(0.0,   units=nothing,        label="rejected flux return fraction E1"),
    kap_E2 = Const(0.0,   units=nothing,        label="rejected flux return fraction E2"),
    kap_R1 = Const(0.95,  units=nothing,        label="reproduction efficiency E1"),
    kap_R2 = Const(0.95,  units=nothing,        label="reproduction efficiency E2"),
    rho1   = Const(0.01,  units=nothing,        label="maintenance preference for E1"),
    del_V  = Const(0.8,   units=nothing,        label="shrinking threshold"),
    E_Hb   = Param(1e1,   units=u"J",           label="maturity at birth"),
    E_Hp   = Param(2e4,   units=u"J",           label="maturity at puberty"),
    k_J    = Const(0.002, units=u"d^-1",        label="maturity maintenance rate"),
    k1_J   = Const(0.002, units=u"d^-1",        label="rejuvenation rate"),
    T_ref  = 293.0u"K",
    T_A    = Const(8000.0, units=u"K",          label="Arrhenius temperature"),
    h_H    = Const(1e-5,  units=u"d^-1",        label="hazard from rejuvenation"),
    h_a    = Const(2e-8,  units=u"d^-2",        label="Weibull aging acceleration"),
    s_G    = Const(1e-4,  units=nothing,        label="Gompertz stress coefficient"),
    n_CX1 = Const(1.0, units=nothing, label="C index X1"), n_HX1 = Const(1.8, units=nothing, label="H index X1"),
    n_OX1 = Const(0.5, units=nothing, label="O index X1"), n_NX1 = Const(0.2, units=nothing, label="N index X1"),
    n_CX2 = Const(1.0, units=nothing, label="C index X2"), n_HX2 = Const(1.8, units=nothing, label="H index X2"),
    n_OX2 = Const(0.5, units=nothing, label="O index X2"), n_NX2 = Const(0.2, units=nothing, label="N index X2"),
    n_CV  = Const(1.0, units=nothing, label="C index V"),  n_HV  = Const(1.8, units=nothing, label="H index V"),
    n_OV  = Const(0.5, units=nothing, label="O index V"),  n_NV  = Const(0.2, units=nothing, label="N index V"),
    n_CE1 = Const(1.0, units=nothing, label="C index E1"), n_HE1 = Const(1.61, units=nothing, label="H index E1"),
    n_OE1 = Const(0.33, units=nothing, label="O index E1"), n_NE1 = Const(0.28, units=nothing, label="N index E1"),
    n_CE2 = Const(1.0, units=nothing, label="C index E2"), n_HE2 = Const(2.0, units=nothing, label="H index E2"),
    n_OE2 = Const(0.6, units=nothing, label="O index E2"),  n_NE2 = Const(0.0, units=nothing, label="N index E2"),
    n_CP1 = Const(1.0, units=nothing, label="C index P1"), n_HP1 = Const(1.8, units=nothing, label="H index P1"),
    n_OP1 = Const(0.5, units=nothing, label="O index P1"), n_NP1 = Const(0.2, units=nothing, label="N index P1"),
    n_CP2 = Const(1.0, units=nothing, label="C index P2"), n_HP2 = Const(1.8, units=nothing, label="H index P2"),
    n_OP2 = Const(0.6, units=nothing, label="O index P2"), n_NP2 = Const(0.0, units=nothing, label="N index P2"),
    n_CC = Const(1.0, units=nothing, label=""), n_CH = Const(0.0, units=nothing, label=""),
    n_CO = Const(2.0, units=nothing, label=""), n_CN = Const(0.0, units=nothing, label=""),
    n_HC = Const(0.0, units=nothing, label=""), n_HH = Const(2.0, units=nothing, label=""),
    n_HO = Const(1.0, units=nothing, label=""), n_HN = Const(0.0, units=nothing, label=""),
    n_OC = Const(0.0, units=nothing, label=""), n_OH = Const(0.0, units=nothing, label=""),
    n_OO = Const(2.0, units=nothing, label=""), n_ON = Const(0.0, units=nothing, label=""),
    n_NC = Const(1.0, units=nothing, label=""), n_NH = Const(4.0, units=nothing, label=""),
    n_NO = Const(1.0, units=nothing, label=""), n_NN = Const(2.0, units=nothing, label=""),
)

# Strip Param/Const wrappers → raw values with Unitful units attached
p_iso221 = ModelParameters.stripparams(p_iso221_raw)

# -------------------------------------------------------------------------
# Build iso221 animal and compute compound parameters
# -------------------------------------------------------------------------
model_iso221 = iso221_animal(
    temperatureresponse = ArrheniusResponse(T_A=p_iso221.T_A, T_ref=p_iso221.T_ref)
)
p_iso221_full = merge(p_iso221, compound_parameters(model_iso221, p_iso221))

println("iso221 compound parameters:")
println("  L_m = $(p_iso221_full.L_m)")
println("  m_E1m = $(p_iso221_full.m_E1m)")
println("  m_E2m = $(p_iso221_full.m_E2m)")

# -------------------------------------------------------------------------
# Scenario 1: Constant balanced diet
# Both food types present at equal density
# -------------------------------------------------------------------------
println("\nRunning Scenario 1: constant balanced diet...")

env_balanced = ConstantEnvironment(;
    tempcorrection = 1.0,  # at T_ref
    food = (X1 = 2.0u"mol/dm^2", X2 = 3.0u"mol/dm^2"),
)

mbe_iso221 = MetabolismBehaviorEnvironment(;
    metabolism = model_iso221,
    environment = env_balanced,
    par = p_iso221_full,
)

sim_iso221 = Simulator(; tspan=(0.0, 8000.0), saveat=range(0.0, 8000.0; length=500))

sol_iso221 = try
    simulate(sim_iso221, mbe_iso221)
catch e
    println("Simulation error: $e")
    nothing
end

if !isnothing(sol_iso221)
    t_vals = sol_iso221.t
    println("  Simulation successful: $(length(t_vals)) time points, t_end = $(last(t_vals)) d")

    # Extract state variables — sol.u contains SVector{9,Float64} (bare floats)
    # State order: 1=M_E1, 2=M_E2, 3=M_V, 4=E_H, 5=M_R1, 6=M_R2, 7=q, 8=h, 9=S
    M_E1_vals = [u[1] for u in sol_iso221.u]   # mol
    M_E2_vals = [u[2] for u in sol_iso221.u]   # mol
    M_V_vals  = [u[3] for u in sol_iso221.u]   # mol
    E_H_vals  = [u[4] for u in sol_iso221.u]   # J
    M_R1_vals = [u[5] for u in sol_iso221.u]   # mol
    M_R2_vals = [u[6] for u in sol_iso221.u]   # mol
    MV_bare = ustrip(p_iso221_full.MV)          # mol/cm^3
    L_vals    = (M_V_vals ./ MV_bare) .^ (1/3) # cm
    m_E1_vals = M_E1_vals ./ M_V_vals          # mol/mol
    m_E2_vals = M_E2_vals ./ M_V_vals

    println("  L at end: $(last(L_vals)) cm")
    println("  E_H at end: $(last(E_H_vals)) J")

    # -----------------------------------------------------------------------
    # Scenario 2: Geometric Framework — varying food ratio
    # Young prefer protein-rich (X1) food; adults shift to non-protein (X2)
    # -----------------------------------------------------------------------
    println("\nRunning Scenario 2: Geometric Framework (varying food ratio)...")
    # Gradually shift from X1-dominant to X2-dominant diet over 4000 d
    t_gf = range(0.0, 8000.0; length=500)
    # High X1 early, high X2 late
    X1_gf = (4.0 .* exp.(-t_gf ./ 2000) .+ 0.5) .* u"mol/dm^2"
    X2_gf = (4.0 .* (1 .- exp.(-t_gf ./ 2000)) .+ 0.5) .* u"mol/dm^2"

    env_gf = Environment(;
        time = collect(t_gf),
        food = (X1 = X1_gf, X2 = X2_gf),
        tempcorrection = fill(1.0, length(t_gf)),  # constant T = T_ref
    )

    mbe_gf = MetabolismBehaviorEnvironment(;
        metabolism = model_iso221,
        environment = env_gf,
        par = p_iso221_full,
    )
    sim_gf = Simulator(; tspan=(0.0, 8000.0), saveat=range(0.0, 8000.0; length=500))
    sol_gf = try
        simulate(sim_gf, mbe_gf)
    catch e
        println("GF simulation error: $e")
        nothing
    end

    # -----------------------------------------------------------------------
    # Plotting (requires a Makie backend to be loaded before this script)
    # -----------------------------------------------------------------------
    try
        # Check if Makie is available
        fig_available = @isdefined(Figure)
        if fig_available
            _make_plots(t_vals, L_vals, m_E1_vals, m_E2_vals, E_H_vals,
                        M_R1_vals, M_R2_vals, sol_gf, p_iso221_full, t_gf, X1_gf, X2_gf)
        else
            println("\nLoad a Makie backend (e.g. `using GLMakie`) before running this script for plots.")
        end
    catch e
        println("Plotting skipped: $e")
    end
else
    println("Cannot continue — simulation failed.")
end

# -------------------------------------------------------------------------
# Plotting function (called if Makie is loaded)
# -------------------------------------------------------------------------
function _make_plots(t, L, m_E1, m_E2, E_H, M_R1, M_R2, sol_gf, p, t_gf, X1_gf, X2_gf)
    fig = Figure(size=(1200, 800))

    # Row 1: Scenario 1 — balanced diet
    ax1 = Axis(fig[1,1]; xlabel="time since birth (d)", ylabel="structural length (cm)", title="Balanced diet")
    lines!(ax1, t, L; color=:green, label="iso221")

    ax2 = Axis(fig[1,2]; xlabel="time since birth (d)", ylabel="reserve density (mol/mol)", title="Reserve densities")
    lines!(ax2, t, m_E1; color=:blue, label="protein (E1)")
    lines!(ax2, t, m_E2; color=:red, label="non-protein (E2)")
    axislegend(ax2; position=:rt)

    ax3 = Axis(fig[1,3]; xlabel="time since birth (d)", ylabel="maturity (J)", title="Maturity")
    lines!(ax3, t, E_H; color=:purple)
    hlines!(ax3, [ustrip(p.E_Hb), ustrip(p.E_Hp)]; color=:gray, linestyle=:dash, label=["E_Hb","E_Hp"])

    ax4 = Axis(fig[1,4]; xlabel="time since birth (d)", ylabel="cumul. reprod buffer (mol)", title="Reproduction buffer")
    lines!(ax4, t, M_R1; color=:blue, label="reserve 1 (protein)")
    lines!(ax4, t, M_R2; color=:red, label="reserve 2 (non-protein)")
    axislegend(ax4; position=:lt)

    # Row 2: Scenario 2 — Geometric Framework
    if !isnothing(sol_gf)
        t_gf_sol = sol_gf.t
        M_V_gf  = [u[3] for u in sol_gf.u]
        MV_bare = ustrip(p.MV)
        L_gf    = (M_V_gf ./ MV_bare) .^ (1/3)
        M_E1_gf = [u[1] for u in sol_gf.u]
        M_E2_gf = [u[2] for u in sol_gf.u]
        m_E1_gf = M_E1_gf ./ M_V_gf
        m_E2_gf = M_E2_gf ./ M_V_gf

        ax5 = Axis(fig[2,1]; xlabel="time (d)", ylabel="food density (mol/dm²)", title="GF: food scenario")
        lines!(ax5, collect(t_gf), ustrip.(X1_gf); color=:blue, label="X1 (protein-rich)")
        lines!(ax5, collect(t_gf), ustrip.(X2_gf); color=:red, label="non-protein-rich X2")
        axislegend(ax5; position=:ct)

        ax6 = Axis(fig[2,2]; xlabel="time (d)", ylabel="structural length (cm)", title="GF: growth")
        lines!(ax6, t_gf_sol, L_gf; color=:green, label="iso221 GF")
        lines!(ax6, t, L; color=:green, linestyle=:dash, label="balanced")
        axislegend(ax6; position=:rb)

        ax7 = Axis(fig[2,3]; xlabel="time (d)", ylabel="reserve density (mol/mol)", title="GF: reserve densities")
        lines!(ax7, t_gf_sol, m_E1_gf; color=:blue, label="protein (E1)")
        lines!(ax7, t_gf_sol, m_E2_gf; color=:red, label="non-protein (E2)")
        axislegend(ax7; position=:rt)

        # Preference ratio: m_E1/m_E2 — higher means more protein-rich reserves
        ax8 = Axis(fig[2,4]; xlabel="time (d)", ylabel="reserve ratio m_E1/m_E2", title="GF: dietary preference proxy")
        lines!(ax8, t_gf_sol, m_E1_gf ./ max.(m_E2_gf, 1e-10); color=:purple)
        hlines!(ax8, [1.0]; color=:gray, linestyle=:dash)
    end

    mkpath("examples/output")
    save("examples/output/iso221_vs_std.png", fig)
    println("\nPlot saved to examples/output/iso221_vs_std.png")
    display(fig)
    return fig
end

println("\nDone. To produce plots, load a Makie backend first:")
println("  using GLMakie")
println("  include(\"examples/iso221_vs_std.jl\")")
