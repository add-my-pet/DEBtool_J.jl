struct ModelParEnvironment{M,P,E}
    model::M
    par::P
    environment::E
end

rebuild(mpe::ModelParEnvironment; model=mpe.model, par=mpe.par, environment=mpe.environment) = 
    ModelParEnvironment(model, par, environment)

"""

Simulates life trajectory, returning an OrdinaryDiffEQ.jl output.

# Input

- `model`: a `DEBOrganism` model
- `par`: a `NamedTuple` of parameters
- `environment`: an `AbstractEnvironment` object. 

Output

at mean values of temperature and food. computed using the DEBtool functions

was get_indDyn_mod
"""
function simulate(model, par, environment; 
    solver=Tsit5(), abstol=1e-9, reltol=1e-9, tspan=tspan(environment),
)
    # Reomove any ModelParameters Model or Param wrappers
    par = stripparams(par)
    # Add compound parameters to pars
    # TODO: more generic way to do this
    par = merge(par, compound_parameters(model, par))
    # Initiale state
    mpe = ModelParEnvironment(model, par, environment)
    u = simulation_init(mpe)
    # Run simulation for the specific model mode
    return simulate(model.mode, mpe, u; solver, abstol, reltol, tspan)
end
# Model types mostly differe in their `callback` function,
# or how events occur and are handled during the lifecycle
function simulate(
    mode::Mode, mpe::ModelParEnvironment, u; solver, tspan, kw...
)
    # Define the mode-specific callback function. This controls 
    # how the solver handles specific lifecycle events.
    callback = simulation_callback(mode, mpe)
    # Define the ODE to solve with function, initial state, 
    # timespan and parameters
    problem = ODEProblem(d_sim, u, tspan, mpe)
    # solve the ODE, and return the solution object
    return solve(problem, solver; callback, kw...)
end
function simulate(
    mode::typeof(abj()), mpe::ModelParEnvironment, ELHR0; solver, tspan, kw...
)
    callback = ContinuousCallback(condition, terminate!)
    # 1st call from fertilization to birth
    L_b = NaN
    s_M = 1.0
    accelerating = false
    ode_par_1 = rebuild(mpe, par=merge(mpe.par, (; L_b, s_M, accelerating)))
    tspan_1 = (te, tspan[end])
    u_1 = ELHR0
    isterminal = @SVector[true, false, false]
    problem = ODEProblem(_d_ELHR, u_1, tspan_1, ode_par_1)
    sol_1 = solve(problem, solver; callback, kw...)

    # 2nd call from birth to metamorphosis
    u_2 = sol_1.u[end] .+ 1e-8
    L_b = sol_1.ye[2]
    s_M = NaN
    t_2 = sol.what
    accelerating = true
    ode_par_2 = merge(ode_par, (; par=merge(par, (; L_b, S_M, accelerating))))
    isterminal = @SVector[false, true, false]
    problem = ODEProblem(_d_ELHR, u_2, tspan_2, ode_par_2)
    sol_b = solve(problem, solver; callback, kw...)

    # 3nd call from metamorphosis to the end of simulation
    L_j = sol_2.ye[2]
    u_3 = sol_2.u[end] .+ 1e-8
    t_3 = sol.what
    isterminal = @SVector[false, false, false]
    s_M = L_j / L_b
    # s_M = L_j / L_s
    L_b = NaN
    accelerating = false
    ode_par_c = merge(ode_par, (; par= merge(par, (; L_b, s_M, accelerating))))
    tspan_c = (t_c, tspan[end])
    problem = ODEProblem(_d_ELHR, u_c, tspan_c, ode_par_c)
    sol_c = solve(problem, solver; callback, kw...)
    # TODO: join solves, or combine with changes as events
end
function simulate(
    mode::typeof(asj()), mpe::ModelParEnvironment, ELHR0; solver, kw...
)
    s_M = 1.0
    isterminal = [0, 1, 0, 0]
    # [t1, ELHR1, te, ye, ie] = ode45(dget_ELHR_asj, tspan, ELHR0, options, pars_asj, tTC, tf, NaN, s_M, isterminal);
    # if isempty(te)
    #     te[1] = NaN
    #     te[2] = NaN
    #     ye = NaN * ones(2, 4)
    #     @warn "birth is not reached"
    # elseif length(te) == 1
    #     te[2] = NaN
    #     ye[2, :] = NaN * ones(1, 4)
    #     @warn "start of accel is not reached"
    # end
    # a_b = te[1]
    # Ww_b = ye[1, 2]^3 + ye[1, 1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at birth
    # a_s = te[2]
    L_b = ye[1, 2]
    L_s = ye[2, 2]
    # Ww_s = ye[2, 2]^3 + ye[2, 1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at start of accel
    # 2nd call from start of acceleration to metamorphosis (end of acceleration)
    isterminal = [0, 0, 1, 0]
    # [t2, ELHR2, te, ye, ie] = ode45(dget_ELHR_asj, [te[2], tspan[end]], ye(2, :)+1e-8, options, pars_asj, tTC, tf, L_s, NaN, isterminal)
    # t2[1] = []
    ELHR2[1, :] = []
    # if isempty(te)
    #     te = NaN
    #     ye = NaN * ones(1,4)
    #     @warn "metamorphosis is not reached"
    # end
    # a_j = te
    # Ww_j = ye[2]^3 + ye(1) * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at metamorphosis
    # 3nd call from metamorphosis to the end of simulation
    L_j = ye[2]
    s_M = L_j / L_s
    isterminal = [0, 0, 0, 0]
    # [t3, ELHR3, te, ye, ie] = ode45(@dget_ELHR_asj, [te, tspan[end]], ye+1e-8, options, pars_asj, tTC, tf, NaN, s_M, isterminal);
    # t3[1] = []
    ELHR3[1, :] = []
    # if isempty(te)
    #     te = NaN
    #     ye[:] = NaN * ones(1, 4)
    #     @warn "puberty is not reached"
    # end
    # a_p = te
    L_p = ye[2]
    # Ww_p = ye[2]^3 + ye[1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at puberty
    # catenate matrices
    t = [t1; t2; t3]
    ELHR = [ELHR1; ELHR2; ELHR3]
end
function simulate(
    mode::typeof(abp()), mpe::ModelParEnvironment, ELHR0; solver, kw...
)
    # options = odeset('Events', @stage_events_abp, 'AbsTol', 1e-9, 'RelTol',1e-9);
    # 1st call from fertilization to birth
    s_M = 1.0
    isterminal = [1, 0]
    # [t1, ELHR1, te, ye, ie] = ode45(d_ELHR, tspan, ELHR0, options, pars_abp, tTC, tf, NaN, s_M, isterminal);
    # if isempty(te)
    #     te = NaN; ye = NaN * ones(1,4)
    #     @warn "birth is not reached"
    # end
    # a_b = te
    L_b = ye(2)
    # Ww_b = ye(2)^3 + ye(1) * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at birth
    # 2nd call from birth to the end of simulation
    isterminal = [0, 0]
    # [t2, ELHR2, te, ye, ie] = ode45(d_ELHR, (te, tspan[end]), ye+1e-8, options, pars_abp, tTC, tf, L_b, NaN, isterminal)
    # t2[1] = []
    # ELHR2[1, :] = []
    # if isempty(te)
    #     te = NaN; ye = NaN * ones(1, 4)
    #     @warn "puberty is not reached"
    # end
    # a_p = te
    L_p = ye[2]
    # Ww_p = ye[2]^3 + ye[1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at puberty
    # catenate matrices
    # t = [t1, t2]
    # TODO: remove start of each
    ELHR = [ELHR1, ELHR2]
end

function simulation_init((; model, par)::ModelParEnvironment{<:DEBOrganism})
    l_b, info = compute_length(Birth(), par)
    (; UE0) = initial_scaled_reserve(model.mode, par, l_b)
    E_0 = UE0 * par.p_Am # J, energy in egg
    # TODO explain why 1e-4
    return @SVector[ustrip(u"J", E_0), 1e-4, 0.0, 0.0] # initial conditions at fertilization
end

# d_sim
# Define changes in state variables
# t: time
# ELHR: 4-vector with state variables
#         E, J, reserve energy
#         L, cm, structural length
#         E_H, J, cumulated energy inversted into maturity (E_H in Kooijman 2010)
#         E_R, J, reproduction buffer (E_R in Kooijman 2010)
#
# Params
# p_Am   J/d.cm^2, surface-area-specific maximum assimilation rate
# v      cm/d, energy conductance
# p_M    J/d.cm^3, somatic maint
# k_J    1/d, maturity maint rate coeff
# kap    -, fraction allocated to growth + som maint
# kap_G  -, growth efficiency
# E_G    J/cm^3, volume-specific costs of structure
#
# dELHR: 4-vector with change in E, L, H, R
function d_sim(ELHR, mpe::ModelParEnvironment{<:DEBOrganism}, t)
    (; model, par, environment) = mpe
    (; p_Am, v, p_M, k_J, kap, E_Hb, E_Hp) = par

    E_, L_, E_H_ = ELHR
    # Add units
    E = E_ * u"J"
    L = L_ * u"cm"
    E_H = E_H_ * u"J"

    TC = getattime(environment, :tempcorrection, t) # C, temperature at t
    f_t = getattime(environment, :functionalresponse, t) # -, scaled functional response at t
    s_M = acceleration_factor(model.mode, par, L)
    pT_Am, vT, pT_M, kT_J = map(x -> x * TC, (p_Am, v, p_M, k_J)) # temp correction TODO: rates should already be grouped
    r = specific_growth_rate(model.mode, merge(par, (; vT, pT_M, s_M)), (E, L, E_H))

    # TODO explain all the equations
    # Assimilation scales with length squared. No assimilation before birth
    pA = (pT_Am * s_M * f_t * L^2) * hasreached(Birth(), par, E_H) # J/d, assimilation
    # Flux mobilised from reserved scales with the inverse of length 
    pC = E * (s_M * vT / L - r) # J/d, mobilized energy flux

    # generate derivatives
    # Change in reserve E is the difference between assimmilated mobilized energy
    dE = pA - pC # J/d, change in energy in reserve
    # Length L changes as the growth rate * the current length TODO: why / 3
    dL = r * L / 3 # cm/d, change in length
    # Maturitity H and reproduction R buffers receive (1 - κ) * mobilized flux, minus maturity maintenancy 
    # There is no investment in maturation after puberty 
    dE_H = ((1 - kap) * pC - kT_J * E_H) * !hasreached(Puberty(), par, E_H) # J/d, change in cumulated energy invested in maturation
    # And no investment in reproduction before puberty
    dE_R = ((1 - kap) * pC - kT_J * E_Hp) * hasreached(Puberty(), par, E_H) # J/d, change in reproduction buffer

    # Strip to days and pack as state variables
    # TODO: strip to the time units of `t` like ustrip("uJ" / units(t), x)
    return @SVector[ustrip(u"J/d", dE), ustrip(u"cm/d", dL), ustrip(u"J/d", dE_H), ustrip(u"J/d", dE_R)]
end

# TODO: this should dispatch on a field of the model, not the mode
function specific_growth_rate(mode::Union{typeof(sbp()), typeof(abp())}, par, ELH)
    E_H = ELH[3]
    if hasreached(Puberty(), par, E_H) 
        0.0u"d^-1" # adults do not grow or shrink
    else
        specific_growth_rate(std(), par, state)
    end
end
function specific_growth_rate(mode::Mode, par, (E, L, E_H))
    (; kap, kap_G, E_G, s_M, vT, pT_M) = par
    # TODO why is growth efficiency optional here
    kap_G_or_1 = (kap * E * s_M * vT < pT_M * L^4) ? kap_G : oneunit(kap_G) # section 4.1.5 comments to Kooy2010
    (E * s_M * vT / L - pT_M * L^3 / kap) / (E * s_M + kap_G_or_1 * E_G * L^3 / kap) # d^-1, specific growth rate
end

hasreached(::Birth, p, maturity) = maturity >= p.E_Hb
hasreached(::Puberty, p, maturity) = maturity >= p.E_Hp

# -, multiplication factor for v and {p_Am}
# TODO: do this without specifying L_s or L_b - just L and e.g. lifestages[Birth()].L
# Then it would be generalised to any lifestage.
acceleration_factor(::Accelerated{<:Isomorph,<:MaturityLevel}, p, L) = p.accelerating ? L / p.L_s : p.s_M
acceleration_factor(::Accelerated{<:Isomorph,<:Birth}, p, L) = p.accelerating ? L / p.L_b : p.s_M
acceleration_factor(::Mode, pars, L) = 1.0 # Non-accelerating modes

# Get all E_H variables to compare to E_H
all_E_H(::typeof(std()), p) = p.E_Hb, p.E_Hp
# all_E_H(::typeof(stx()), p) = p.E_Hb, p.E_Hx, p.E_Hp
all_E_H(::typeof(abj()), p) = p.E_Hb, p.E_Hj, p.E_Hp
all_E_H(::typeof(asj()), p) = p.E_Hb, p.E_Hs, p.E_Hj, p.E_Hp
all_E_H(::typeof(abp()), p) = p.E_Hb, p.E_Hp

simulation_callback(mpe::ModelParEnvironment) = 
    simulation_callback(mpe.model.mode, mpe)
function simulation_callback(
    mode::Union{typeof(std()),typeof(sbp())} , mpe::ModelParEnvironment
)
    @show callback_transitions(mpe.model)
    callbacks = map(callback_transitions(mpe.model)) do tr
        transition_callback(tr)
    end
    # Define a callback that simply forces accuracy around life-stage transitions
    x = CallbackSet(callbacks...)
    @show x
    x
end

function callback_transitions(model)
    reduce((Birth(), Weaning(), Puberty(), Metamorphosis()); init=()) do acc, transition
        isnothing(get(life(model), transition, nothing)) ? acc : (acc..., transition)
    end
end

transition_callback(::AbstractTransition, model) = 
    ContinuousCallback(transition_callback(model), transition_action(model))

transition_action(::AbstractTransition, model) = (integrator, i) -> nothing # action when event is found

transition_event(::Birth, model) = (ELHR, t, integrator) -> ustrip(u"J", i.p.par.E_Hb) - ELHR[3]
transition_event(::Puberty, model) = (ELHR, t, integrator) -> ustrip(u"J", i.p.par.E_Hp) - ELHR[3]
transition_event(::Metamorphosis, model) = (ELHR, t, i) -> ustrip(u"J", i.p.par.E_Hj) - ELHR[3]
