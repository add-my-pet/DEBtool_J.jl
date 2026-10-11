## iso221_interactive.jl
# Geometric Framework of Nutrition (GF) explorer using the iso221 DEB model.
# Two scenarios run simultaneously:
#   1. Constant balanced diet (row 1) — same as iso221_vs_std.jl scenario 1
#   2. Ontogenetic diet shift (row 2) — protein-rich food decreases while
#      non-protein food increases with age, following the GF paradigm of
#      Simpson & Raubenheimer.
#
# Sliders control the nutritional landscape and yield matrix; moving a slider
# re-runs both simulations and updates all eight panels.
#
# Usage:
#   cd("path/to/DEBtool_J.jl")
#   using Pkg; Pkg.activate(".")
#   using GLMakie
#   include("examples/iso221_interactive.jl")

using DEBtool_J
using Unitful
using GLMakie

# ── Fixed (non-interactive) parameters ───────────────────────────────────────
const _P0 = (;
    M_X1   = 1e-3u"mol",
    M_X2   = 1e-3u"mol",
    F_X1m  = 2.0u"dm^2/d/cm^2",
    F_X2m  = 3.0u"dm^2/d/cm^2",
    J_X1Am = 2.0e-3u"mol/d/cm^2",
    J_X2Am = 2.0e-3u"mol/d/cm^2",
    y_P1X1 = 0.15u"mol/mol",
    y_P2X2 = 0.15u"mol/mol",
    y_VE1  = 0.8u"mol/mol",
    y_VE2  = 0.8u"mol/mol",
    v      = 0.02u"cm/d",
    mu_E1  = 4e5u"J/mol",
    mu_E2  = 6e5u"J/mol",
    mu_V   = 5e5u"J/mol",
    j_E1M  = 0.09u"mol/d/mol",
    j_E2M  = 0.135u"mol/d/mol",     # 0.09 × (mu_E2/mu_E1) = 0.09 × 1.5
    J_E1T  = 0.0u"mol/d/cm^2",
    J_E2T  = 0.0u"mol/d/cm^2",
    MV     = 4e-3u"mol/cm^3",
    kap_E1 = 0.0,  kap_E2 = 0.0,
    kap_R1 = 0.95, kap_R2 = 0.95,
    rho1   = 0.01, del_V  = 0.8,
    E_Hb   = 1e1u"J",
    E_Hp   = 2e4u"J",
    k_J    = 0.002u"d^-1",
    k1_J   = 0.002u"d^-1",
    T_ref  = 293.0u"K",
    T_A    = 8000.0u"K",
    h_H    = 1e-5u"d^-1",
    h_a    = 2e-8u"d^-2",
    s_G    = 1e-4,
    n_CX1=1.0, n_HX1=1.8, n_OX1=0.5, n_NX1=0.2,
    n_CX2=1.0, n_HX2=1.8, n_OX2=0.5, n_NX2=0.2,
    n_CV =1.0, n_HV =1.8, n_OV =0.5, n_NV =0.2,
    n_CE1=1.0, n_HE1=1.61, n_OE1=0.33, n_NE1=0.28,
    n_CE2=1.0, n_HE2=2.0,  n_OE2=0.6,  n_NE2=0.0,
    n_CP1=1.0, n_HP1=1.8, n_OP1=0.5, n_NP1=0.2,
    n_CP2=1.0, n_HP2=1.8, n_OP2=0.6, n_NP2=0.0,
    n_CC=1.0, n_CH=0.0, n_CO=2.0, n_CN=0.0,
    n_HC=0.0, n_HH=2.0, n_HO=1.0, n_HN=0.0,
    n_OC=0.0, n_OH=0.0, n_OO=2.0, n_ON=0.0,
    n_NC=1.0, n_NH=4.0, n_NO=1.0, n_NN=2.0,
)

const _MODEL = iso221_animal(
    temperatureresponse = ArrheniusResponse(T_A=8000.0u"K", T_ref=293.0u"K")
)

# ── Simulation helpers ────────────────────────────────────────────────────────

function _build_par(; y_E1X1, y_E2X1, y_E1X2, y_E2X2, kap)
    merge(_P0, (;
        y_E1X1 = y_E1X1 * u"mol/mol",
        y_E2X1 = y_E2X1 * u"mol/mol",
        y_E1X2 = y_E1X2 * u"mol/mol",
        y_E2X2 = y_E2X2 * u"mol/mol",
        kap,
    ))
end

# Re-attach known units to bare sol.u floats; compute derived quantities in unit space.
# Units are stripped only at the Makie plotting boundary (in _run return values).
function _extract(sol, par)
    sv   = sol.u
    M_V  = [s[3] for s in sv] .* u"mol"
    M_E1 = [s[1] for s in sv] .* u"mol"
    M_E2 = [s[2] for s in sv] .* u"mol"
    E_H  = [s[4] for s in sv] .* u"J"
    M_R1 = [s[5] for s in sv] .* u"mol"
    M_R2 = [s[6] for s in sv] .* u"mol"
    L    = (M_V ./ par.MV) .^ (1/3)   # → cm
    m_E1 = M_E1 ./ M_V                 # → mol/mol (dimensionless)
    m_E2 = M_E2 ./ M_V
    return (; t=sol.t, L, m_E1, m_E2, E_H, M_R1, M_R2)
end

function _run(; X1, X2, gf_amp, gf_τ, y_E1X1, y_E2X1, y_E1X2, y_E2X2, kap)
    par = _build_par(; y_E1X1, y_E2X1, y_E1X2, y_E2X2, kap)
    sim = Simulator(; tspan=(0.0, 8000.0), saveat=range(0.0, 8000.0; length=400))

    # Scenario 1: constant balanced diet
    env1 = ConstantEnvironment(;
        tempcorrection = 1.0,
        food = (X1 = X1 * u"mol/dm^2", X2 = X2 * u"mol/dm^2"),
    )
    mbe1 = MetabolismBehaviorEnvironment(; metabolism=_MODEL, environment=env1, par)
    sol1 = try
        simulate(sim, mbe1)
    catch e
        @warn "constant-diet simulation failed" exception=e
        nothing
    end

    # Scenario 2: GF ontogenetic diet shift
    # X1 (protein-rich) starts high and decays; X2 (non-protein) starts low and rises.
    t_gf  = range(0.0, 8000.0; length=400)
    decay = exp.(.-collect(t_gf) ./ gf_τ)
    X1_gf = (gf_amp .* decay       .+ X1) .* u"mol/dm^2"
    X2_gf = (gf_amp .* (1 .- decay) .+ X2) .* u"mol/dm^2"
    env2  = Environment(;
        time          = collect(t_gf),
        food          = (X1 = X1_gf, X2 = X2_gf),
        tempcorrection = fill(1.0, length(t_gf)),
    )
    mbe2 = MetabolismBehaviorEnvironment(; metabolism=_MODEL, environment=env2, par)
    sol2 = try
        simulate(sim, mbe2)
    catch e
        @warn "GF simulation failed" exception=e
        nothing
    end

    d1 = isnothing(sol1) ? nothing : _extract(sol1, par)
    d2 = isnothing(sol2) ? nothing : _extract(sol2, par)
    return (; d1, d2, t_gf=collect(t_gf), X1_gf, X2_gf, E_Hb=par.E_Hb, E_Hp=par.E_Hp)
end

# ── Observable helpers (strip units only here, at the plotting boundary) ─────
_t(d)     = isnothing(d) ? Float64[] : d.t
_L(d)     = isnothing(d) ? Float64[] : ustrip.(u"cm",  d.L)
_mE1(d)   = isnothing(d) ? Float64[] : ustrip.(d.m_E1)
_mE2(d)   = isnothing(d) ? Float64[] : ustrip.(d.m_E2)
_EH(d)    = isnothing(d) ? Float64[] : ustrip.(u"J",   d.E_H)
_MR1(d)   = isnothing(d) ? Float64[] : ustrip.(u"mol", d.M_R1)
_MR2(d)   = isnothing(d) ? Float64[] : ustrip.(u"mol", d.M_R2)
_ratio(d) = isnothing(d) ? Float64[] : ustrip.(d.m_E1) ./ max.(ustrip.(d.m_E2), 1e-10)

# ── Figure and sliders ────────────────────────────────────────────────────────
fig = Figure(size=(1400, 900))

sg = SliderGrid(fig[3, 1:4],
    (label="X1  protein food (mol/dm²)",         range=0.1:0.1:10.0,   startvalue=2.0),
    (label="X2  non-protein food (mol/dm²)",      range=0.1:0.1:10.0,   startvalue=3.0),
    (label="GF amplitude (mol/dm²)",              range=0.0:0.5:8.0,    startvalue=4.0),
    (label="GF transition τ (d)",                 range=200.0:100.0:5000.0, startvalue=2000.0),
    (label="y_E1X1  protein food → reserve 1",   range=0.05:0.05:0.85, startvalue=0.45),
    (label="y_E2X1  protein food → reserve 2",   range=0.05:0.05:0.85, startvalue=0.35),
    (label="y_E1X2  non-prot food → reserve 1",  range=0.05:0.05:0.85, startvalue=0.35),
    (label="y_E2X2  non-prot food → reserve 2",  range=0.05:0.05:0.85, startvalue=0.45),
    (label="κ  somatic allocation fraction",      range=0.20:0.01:0.99, startvalue=0.80),
)
sl = sg.sliders

# ── Axes ─────────────────────────────────────────────────────────────────────
# Row 1: constant balanced diet (matching iso221_vs_std.jl _make_plots)
ax1 = Axis(fig[1,1]; xlabel="time (d)", ylabel="L (cm)",             title="Balanced diet: growth")
ax2 = Axis(fig[1,2]; xlabel="time (d)", ylabel="reserve density (mol/mol)", title="Balanced diet: reserves")
ax3 = Axis(fig[1,3]; xlabel="time (d)", ylabel="E_H (J)",            title="Maturity")
ax4 = Axis(fig[1,4]; xlabel="time (d)", ylabel="M_R (mol)",          title="Reproduction buffer")

# Row 2: GF ontogenetic diet shift
ax5 = Axis(fig[2,1]; xlabel="time (d)", ylabel="food (mol/dm²)",     title="GF: nutritional landscape")
ax6 = Axis(fig[2,2]; xlabel="time (d)", ylabel="L (cm)",             title="GF: growth")
ax7 = Axis(fig[2,3]; xlabel="time (d)", ylabel="reserve density (mol/mol)", title="GF: reserves")
ax8 = Axis(fig[2,4]; xlabel="time (d)", ylabel="m_E1 / m_E2",        title="GF: protein:non-protein ratio")

# ── Initial run ───────────────────────────────────────────────────────────────
r0 = _run(;
    X1=sl[1].value[], X2=sl[2].value[],
    gf_amp=sl[3].value[], gf_τ=sl[4].value[],
    y_E1X1=sl[5].value[], y_E2X1=sl[6].value[],
    y_E1X2=sl[7].value[], y_E2X2=sl[8].value[],
    kap=sl[9].value[],
)

# ── Observables ───────────────────────────────────────────────────────────────
# Row 1 (constant diet)
t1    = Observable(_t(r0.d1))
L1    = Observable(_L(r0.d1))
mE1_1 = Observable(_mE1(r0.d1));  mE2_1 = Observable(_mE2(r0.d1))
EH    = Observable(_EH(r0.d1))
MR1   = Observable(_MR1(r0.d1));  MR2   = Observable(_MR2(r0.d1))
Ehb   = Observable([ustrip(u"J", r0.E_Hb)])
Ehp   = Observable([ustrip(u"J", r0.E_Hp)])

# Row 2 (GF scenario)
t2    = Observable(_t(r0.d2))
L2    = Observable(_L(r0.d2))
mE1_2 = Observable(_mE1(r0.d2));  mE2_2 = Observable(_mE2(r0.d2))
ratio = Observable(_ratio(r0.d2))
t_gf_o  = Observable(r0.t_gf)
X1_gf_o = Observable(ustrip.(u"mol/dm^2", r0.X1_gf))
X2_gf_o = Observable(ustrip.(u"mol/dm^2", r0.X2_gf))

# ── Initial plots ─────────────────────────────────────────────────────────────
# Row 1
lines!(ax1, t1, L1; color=:green)

lines!(ax2, t1, mE1_1; color=:blue, label="m_E1 (protein)")
lines!(ax2, t1, mE2_1; color=:red,  label="m_E2 (non-prot.)")
axislegend(ax2; position=:rt)

lines!(ax3, t1, EH; color=:purple)
hlines!(ax3, Ehb; color=:gray,  linestyle=:dash, label="E_Hb")
hlines!(ax3, Ehp; color=:black, linestyle=:dot,  label="E_Hp")
axislegend(ax3; position=:lt)

lines!(ax4, t1, MR1; color=:blue, label="M_R1 (protein)")
lines!(ax4, t1, MR2; color=:red,  label="M_R2 (non-prot.)")
axislegend(ax4; position=:lt)

# Row 2
lines!(ax5, t_gf_o, X1_gf_o; color=:blue, label="X1 (protein-rich)")
lines!(ax5, t_gf_o, X2_gf_o; color=:red,  label="X2 (non-protein)")
axislegend(ax5; position=:ct)

lines!(ax6, t2, L2; color=:green, label="GF diet")
lines!(ax6, t1, L1; color=:green, linestyle=:dash, label="balanced diet")
axislegend(ax6; position=:rb)

lines!(ax7, t2, mE1_2; color=:blue, label="m_E1 (protein)")
lines!(ax7, t2, mE2_2; color=:red,  label="m_E2 (non-prot.)")
axislegend(ax7; position=:rt)

lines!(ax8, t2, ratio; color=:purple)
hlines!(ax8, [1.0]; color=:gray, linestyle=:dash)

# ── Reactive update ───────────────────────────────────────────────────────────
function _update!(r)
    t1[]    = _t(r.d1);   L1[]    = _L(r.d1)
    mE1_1[] = _mE1(r.d1); mE2_1[] = _mE2(r.d1)
    EH[]    = _EH(r.d1);  MR1[]   = _MR1(r.d1);  MR2[] = _MR2(r.d1)
    Ehb[]   = [ustrip(u"J", r.E_Hb)]
    Ehp[]   = [ustrip(u"J", r.E_Hp)]

    t2[]    = _t(r.d2);   L2[]    = _L(r.d2)
    mE1_2[] = _mE1(r.d2); mE2_2[] = _mE2(r.d2)
    ratio[] = _ratio(r.d2)

    t_gf_o[]  = r.t_gf
    X1_gf_o[] = ustrip.(u"mol/dm^2", r.X1_gf)
    X2_gf_o[] = ustrip.(u"mol/dm^2", r.X2_gf)
end

all_sliders = lift(
    sl[1].value, sl[2].value, sl[3].value, sl[4].value,
    sl[5].value, sl[6].value, sl[7].value, sl[8].value, sl[9].value
) do X1, X2, gf_amp, gf_τ, y_E1X1, y_E2X1, y_E1X2, y_E2X2, kap
    (; X1, X2, gf_amp, gf_τ, y_E1X1, y_E2X1, y_E1X2, y_E2X2, kap)
end

on(all_sliders) do kw
    r = try _run(; kw...) catch e; (@warn "update failed" exception=e; return) end
    _update!(r)
end

display(fig)
