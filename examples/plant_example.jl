## plant_example.jl
# Example simulation of the Plant DEB model.
#
# Two-organ (shoot + root), 2-reserve (C, N) isomorph plant.
# Based on DynamicEnergyBudgets.jl (BiophysicalEcology) and
# DEBplant isomorph.jl (rafaqz/DEBplant).
#
# State variables (6):
#   Shoot: V_S (structure), C_S (C-reserve), N_S (N-reserve)
#   Root:  V_R (structure), C_R (C-reserve), N_R (N-reserve)
#
# Lifecycle:
#   Embryo → Birth  (fires at t=0: V_R = M_VRb)
#   Juvenile → Puberty  (V_S reaches M_VSp = 10 mol)
#   Adult → Ultimate
#
# Usage:
#   cd("path/to/DEBtool_J.jl")
#   using Pkg; Pkg.activate(".")
#   include("examples/plant_example.jl")

using DEBtool_J
using Unitful
using ModelParameters

# -------------------------------------------------------------------------
# Parameters
# Core values from DEBplant isomorph.jl (rafaqz/DEBplant)
# -------------------------------------------------------------------------
p_plant_raw = (;
    # ---- Core DEB (from DEBplant isomorph.jl DEBCore) ----
    k       = Const(0.6,       units=u"d^-1",           label="reserve turnover rate"),
    j_E_mai = Param(0.01520,   units=u"d^-1",           label="specific somatic maintenance rate"),
    y_V_E   = Param(0.7,       units=u"mol/mol",        label="yield of structure on reserve"),
    y_E_C   = Param(0.5,       units=u"mol/mol",        label="yield of general reserve from C-reserve"),
    y_E_N   = Param(30.0,      units=u"mol/mol",        label="yield of general reserve from N-reserve"),
    κsoma   = Const(1.0,       units=nothing,           label="fraction of mobilised reserve to soma"),
    w_V     = Const(25.0,      units=u"g/mol",          label="molar mass of structure"),
    SLA     = Const(24.0,      units=u"m^2/kg",         label="specific leaf area"),

    # ---- Shoot photosynthesis (KooijmanSLAPhotosynthesis) ----
    # Parameter values from DEBplant isomorph.jl
    j_L_Amax    = Param(100.01,  units=u"μmol/(m^2*s)",  label="max specific light uptake"),
    J_L_K       = Const(2000.0,  units=u"μmol/(m^2*s)",  label="light half-saturation flux"),
    j_C_Amax    = Param(20.0,    units=u"μmol/(m^2*s)",  label="max specific CO2 uptake"),
    K_C         = Const(2.232e-6, units=u"mol/L",         label="CO2 half-saturation concentration"),
    j_O_Amax    = Const(0.1,     units=u"μmol/(m^2*s)",  label="max specific O2 uptake"),
    K_O         = Const(9.375e-5, units=u"mol/L",         label="O2 half-saturation concentration"),
    k_C_binding = Const(10000.0, units=u"μmol/(mol*s)",  label="CO2 competitive binding rate"),
    k_O_binding = Const(10000.0, units=u"μmol/(mol*s)",  label="O2 competitive binding rate"),

    # ---- Root N-uptake (KooijmanNH4_NO3Assim) ----
    # Parameterised to match ConstantNAssim n_uptake ≈ 0.2 μmol/(mol·s) at saturation:
    #   j_NH_Amax + ρNO * j_NO_Amax = 0.14 + 0.35 * 0.17 ≈ 0.20 μmol/(mol·s)
    j_NH_Amax = Param(0.14,  units=u"μmol/(mol*s)", label="max specific NH4 uptake rate"),
    K_NH      = Const(1e-5,  units=u"mol/L",         label="NH4 half-saturation concentration"),
    j_NO_Amax = Const(0.17,  units=u"μmol/(mol*s)", label="max specific NO3 uptake rate"),
    K_NO      = Const(1e-5,  units=u"mol/L",         label="NO3 half-saturation concentration"),
    K_H       = Const(1.0,   units=u"mol/L",         label="water half-saturation concentration"),
    ρNO       = Const(0.35,  units=nothing,           label="NO3 preference weight"),

    # ---- Life-stage / allometric scaling ----
    M_VSd = Const(1.0,  units=u"mol", label="reference shoot structure mass (scaling)"),
    M_VRd = Const(1.0,  units=u"mol", label="reference root structure mass (scaling)"),
    M_VSb = Const(0.5,  units=u"mol", label="shoot structure at germination"),
    M_VRb = Const(0.3,  units=u"mol", label="root structure at germination (Birth threshold)"),
    M_VSp = Const(10.0, units=u"mol", label="shoot structure at puberty (Puberty threshold)"),

    # ---- Reference conditions for seed initialisation (used in compound_parameters) ----
    # At these conditions, compound_parameters computes equilibrium reserve densities.
    J_L_ref  = Const(400.0,  units=u"μmol/(m^2*s)", label="reference photon flux"),
    X_C_ref  = Const(1e-4,   units=u"mol/L",         label="reference CO2 concentration"),
    X_O_ref  = Const(2.5e-4, units=u"mol/L",         label="reference O2 concentration"),
    X_NH_ref = Const(1e-3,   units=u"mol/L",         label="reference NH4 concentration"),
    X_NO_ref = Const(1e-3,   units=u"mol/L",         label="reference NO3 concentration"),
    X_H_ref  = Const(1.0,    units=u"mol/L",         label="reference water concentration"),

    # ---- Temperature (Arrhenius, 1-parameter) ----
    T_ref = 293.0u"K",
    T_A   = Const(8000.0, units=u"K", label="Arrhenius temperature"),
)

# -------------------------------------------------------------------------
# Model, behavior, environment
# -------------------------------------------------------------------------
model_plant = plant_model(temperatureresponse=ArrheniusResponse(stripparams(p_plant_raw)))

# Constant environment: well-lit, CO2-rich, nutrient-rich, well-watered
# Simulate for 200 days (birth fires at t=0, puberty reached ~30-60 d)
tspan_plant = (0.0, 200.0)
n_pts = 201
t_vec = collect(range(0.0, 200.0; length=n_pts))

env_plant = Environment(;
    time = t_vec,
    food = (
        J_L  = fill(400.0u"μmol/(m^2*s)", n_pts),   # bright daylight
        X_C  = fill(1e-4u"mol/L",         n_pts),   # CO2 (saturating vs K_C = 2.23e-6 mol/L)
        X_O  = fill(2.5e-4u"mol/L",       n_pts),   # dissolved O2
        X_NH = fill(1e-3u"mol/L",         n_pts),   # ammonia (saturating vs K_NH = 1e-5 mol/L)
        X_NO = fill(1e-3u"mol/L",         n_pts),   # nitrate
        X_H  = fill(1.0u"mol/L",          n_pts),   # water (high = well-watered)
    ),
    tempcorrection = fill(1.0, n_pts),  # constant T = T_ref → TC = 1
)

mbe_plant = MetabolismBehaviorEnvironment(; metabolism=model_plant, environment=env_plant, par=p_plant_raw)
sim_plant  = Simulator(; tspan=tspan_plant)

# -------------------------------------------------------------------------
# Run simulation
# -------------------------------------------------------------------------
println("Running plant simulation (200 days)...")
sol_plant = try
    simulate(sim_plant, mbe_plant)
catch e
    println("Simulation error: $e")
    rethrow(e)
end
println("Done. retcode = $(sol_plant.retcode)")

# -------------------------------------------------------------------------
# Extract and display results
# -------------------------------------------------------------------------
# sol_plant.u contains SVectors; index order is [V_S, C_S, N_S, V_R, C_R, N_R]
t_out = sol_plant.t

V_S = [u[1] for u in sol_plant.u]   # shoot structure (mol)
C_S = [u[2] for u in sol_plant.u]   # shoot C-reserve (mol)
N_S = [u[3] for u in sol_plant.u]   # shoot N-reserve (mol)
V_R = [u[4] for u in sol_plant.u]   # root structure (mol)
C_R = [u[5] for u in sol_plant.u]   # root C-reserve (mol)
N_R = [u[6] for u in sol_plant.u]   # root N-reserve (mol)

# Reserve densities
m_CS = C_S ./ V_S    # shoot C-reserve density (mol/mol)
m_NS = N_S ./ V_S    # shoot N-reserve density
m_CR = C_R ./ V_R    # root C-reserve density
m_NR = N_R ./ V_R    # root N-reserve density

println("\nFinal state at t = $(round(t_out[end]; digits=1)) d:")
println("  V_S = $(round(V_S[end]; digits=3)) mol  (shoot structure)")
println("  V_R = $(round(V_R[end]; digits=3)) mol  (root structure)")
println("  m_CS = $(round(m_CS[end]; digits=4))  (shoot C-reserve density)")
println("  m_NS = $(round(m_NS[end]; digits=6))  (shoot N-reserve density)")

# -------------------------------------------------------------------------
# Optional plotting (requires GLMakie or CairoMakie)
# -------------------------------------------------------------------------
# Uncomment after: using GLMakie  (or CairoMakie)
#
fig = Figure(size=(900, 600))
ax1 = Axis(fig[1,1]; xlabel="Time (d)", ylabel="Structure (mol)", title="Shoot and Root Structure")
lines!(ax1, t_out, V_S; label="V_S (shoot)", color=:green)
lines!(ax1, t_out, V_R; label="V_R (root)",  color=:brown)
axislegend(ax1)

ax2 = Axis(fig[1,2]; xlabel="Time (d)", ylabel="Reserve density (mol/mol)", title="C-reserve Density")
lines!(ax2, t_out, m_CS; label="m_CS (shoot)", color=:green)
lines!(ax2, t_out, m_CR; label="m_CR (root)",  color=:brown)
axislegend(ax2)

ax3 = Axis(fig[2,1]; xlabel="Time (d)", ylabel="Reserve density (mol/mol)", title="N-reserve Density")
lines!(ax3, t_out, m_NS; label="m_NS (shoot)", color=:green)
lines!(ax3, t_out, m_NR; label="m_NR (root)",  color=:brown)
axislegend(ax3)

ax4 = Axis(fig[2,2]; xlabel="V_R (mol)", ylabel="V_S (mol)", title="Shoot vs Root")
lines!(ax4, V_R, V_S; color=:darkgreen)

display(fig)
