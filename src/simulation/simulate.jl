# This file holds simulation code adapted from amptool
# Its written so there is only one simulation function and one timestep function,
# model differences are/will be handled with different callbacks, initialisation and acceleration functions

@kwdef struct MetabolismBehaviorEnvironment{M,B,E,P}
    metabolism::M 
    behavior::B = NullBehavior()
    environment::E = ConstantEnvironment()
    par::P
end
function rebuild(mbe::MetabolismBehaviorEnvironment; 
    model=mbe.metabolism, behavior=mbe.behavior, environment=mbe.environment, par=mbe.par
)
    MetabolismBehaviorEnvironment(metabolism, behavior, environment, par)
end

@kwdef struct MetabolismEnvironment{M,E,P}
    metabolism::M 
    environment::E = ConstantEnvironment()
    par::P
end
function rebuild(mbe::MetabolismEnvironment; 
    model=mbe.metabolism, environment=mbe.environment, par=mbe.par
)
    MetabolismBehaviorEnvironment(metabolism, environment, par)
end

"""
    StateReconstructor(f, template)

Integrates with DifferentialEquations.jl to allow nested and types state
without fuss or the need for ComponentArrays.jl. 

StateReconstructor instead using Flatten.jl to reconstruct the template object
from an iterator, such as the `u` state from DiffEq.

"""
struct StateReconstructor{F,T,U}
    f::F
    template::T
    time_units::U
end
function (sr::StateReconstructor)(u::AbstractArray{T}, p, t) where T
    res = sr.f(Flatten.reconstruct(sr.template, u, T), p, t)
    converted = map(Flatten.flatten(res, Number), Flatten.flatten(sr.template, Number)) do r, t 
        convert(typeof(t), r * sr.time_units)
    end
    return SVector(Flatten.flatten(converted, T))
end

Base.values(sr::StateReconstructor) = Flatten.flatten(sr.template, AbstractFloat)
Base.collect(sr::StateReconstructor) = collect(values(sr))
Base.Array(sr::StateReconstructor) = collect(sr)

StaticArrays.SVector(sr::StateReconstructor) = SVector(values(sr))
StaticArrays.SArray(sr::StateReconstructor) = SVector(values(sr))

"""
    simulate(mbe::MetabolismBehaviorEnvironment)

Simulates life trajectory, returning an OrdinaryDiffEQ.jl output.

# Arguments

- `mbe`: a `ModelBehaviorEnvironment` object

# Keywords

- `solver` OrdinaryDiffEq solver, `Tsit5()` by default. 
- `abstol` absolute tolerance, 1e-9 by default 
- `reltol` relative tolerance, 1e-9 by default 
- `tspan` timespan tuple, taken from the range of environment data by default.

was get_indDyn_mod in amptool
"""
function simulate(mbe::MetabolismBehaviorEnvironment; 
    solver=Tsit5(), abstol=1e-9, reltol=1e-9, tspan=tspan(mbe.environment),
)
    (; metabolism, behavior, environment, par) = mbe
    # Reomove any ModelParameters Model or Param wrappers
    par = stripparams(par)
    # Add compound parameters to pars
    # TODO: more generic way to do this
    par = merge(par, compound_parameters(metabolism, par))

    mbe = MetabolismBehaviorEnvironment(metabolism, behavior, environment, par)
    # Initiale state
    state_structure = initialise_state(mbe)
    f = StateReconstructor(d_sim, state_structure, u"d")
    u0 = SVector(f)
    # Define the mode-specific callback function. This controls 
    # how the solver handles specific lifecycle events.
    callback = simulation_callback(mbe)
    # Define the ODE to solve with function, initial state, 
    # timespan and parameters
    problem = ODEProblem(f, u0, tspan, mbe)
    # solve the ODE, and return the solution object
    return solve(problem, solver; callback, abstol, reltol)
end

function initialise_state(mbe::MetabolismBehaviorEnvironment)
    metabolism = initialise_state(mbe.metabolism, mbe)
    behavior = initialise_state(mbe.behavior, mbe)
    environment = initialise_state(mbe.environment, mbe)
    return (; metabolism, behavior, environment)
end
function initialise_state(o::DEBOrganism, mbe::MetabolismBehaviorEnvironment)
    (; par) = mbe
    l_b, info = compute_length(Birth(), par)
    (; UE0) = initial_scaled_reserve(o.mode, par, l_b)
    E_0 = UE0 * par.p_Am # J, energy in egg

    return (; E=E_0, L=l_b * u"cm", E_H=0.0u"J", E_R=0.0u"J") # initial conditions at fertilization
end
function initialise_state(::NullBehavior, mbe::MetabolismBehaviorEnvironment)
    (;) 
end
function initialise_state(::AbstractBehavior, ::MetabolismBehaviorEnvironment)
    return NamedTuple()
end
function initialise_state(::AbstractEnvironment, ::MetabolismBehaviorEnvironment)
    return NamedTuple()
end

# Integrate environment, behavior and metabolism
function d_sim(s, mbe::MetabolismBehaviorEnvironment, t)
    environment = d_sim(s.environment, mbe.environment, mbe, t)
    behavior, inner_environment = d_sim(s.behavior, mbe.behavior, mbe, t)
    me = MetabolismEnvironment(mbe.metabolism, inner_environment, mbe.par)
    metabolism = d_sim(s.metabolism, mbe.metabolism, me, t)
    return (; metabolism, behavior, environment)
end
function d_sim(state, b::NullBehavior, mbe::MetabolismBehaviorEnvironment, t)
    # Select environmental parameters for the metabolism to experience
    # By default we just return the temperature correction and functional response
    state = (;)
    inner_environment = ConstantEnvironment(;
        tempcorrection = getattime(mbe.environment, :tempcorrection, t), # C, temperature at t
        functionalresponse = getattime(mbe.environment, :functionalresponse, t), # -, scaled functional response at t
    )
    return state, inner_environment
end
d_sim(state, b::AbstractEnvironment, mbe::MetabolismBehaviorEnvironment, t) = state

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
function d_sim(state, o::DEBOrganism, me::MetabolismEnvironment, t)
    (; metabolism, environment, par) = me
    (; p_Am, v, p_M, k_J, kap, E_Hb, E_Hp) = par
    (; E, L, E_H) = state
    TC = getattime(environment, :tempcorrection, t) # C, temperature at t
    f_t = getattime(environment, :functionalresponse, t) # -, scaled functional response at t

    # Add units. TODO automate this from the init

    s_M = acceleration_factor(metabolism.mode, par, L)
    pT_Am, vT, pT_M, kT_J = map(x -> x * TC, (p_Am, v, p_M, k_J)) # temp correction TODO: rates should already be grouped
    r = specific_growth_rate(metabolism.mode, merge(par, (; vT, pT_M, s_M)), state)

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
    return (E=dE, L=dL, E_H=dE_H, E_R=dE_R)
end

# TODO: move these somewhere general

"""
    specific_growth_rate(mode, par, state)

Calculate the specific growth rate `r`

# TODO: this should dispatch on a field of the model, not the mode
"""
function specific_growth_rate(mode::Mode, par, state)
    (; E, L, E_H) = state
    (; kap, kap_G, E_G, s_M, vT, pT_M) = par
    # TODO why is growth efficiency optional here
    kap_G_or_1 = (kap * E * s_M * vT < pT_M * L^4) ? kap_G : oneunit(kap_G) # section 4.1.5 comments to Kooy2010
    (E * s_M * vT / L - pT_M * L^3 / kap) / (E * s_M + kap_G_or_1 * E_G * L^3 / kap) # d^-1, specific growth rate
end
function specific_growth_rate(mode::Union{typeof(sbp()), typeof(abp())}, par, state)
    if hasreached(Puberty(), par, state.E_H) 
        # Afterpuberty adults in sbp/adp do not grow or shrink. So the growth rate is zero
        0.0u"d^-1"
    else
        # Otherwise call the standard model specific growth rate
        specific_growth_rate(std(), par, state)
    end
end

hasreached(::Birth, p, maturity) = maturity >= p.E_Hb
hasreached(::Puberty, p, maturity) = maturity >= p.E_Hp

# -, multiplication factor for v and {p_Am}
# TODO: do this without specifying L_s or L_b - just L and e.g. lifestages[Birth()].L
# Then it would be generalised to any lifestage.
acceleration_factor(::Accelerated{<:Isomorph,<:MaturityLevel}, p, L) = p.accelerating ? L / p.L_s : p.s_M
acceleration_factor(::Accelerated{<:Isomorph,<:Birth}, p, L) = p.accelerating ? L / p.L_b : p.s_M
acceleration_factor(::Mode, pars, L) = 1.0 # Non-accelerating modes

# Callbacks for metabolism, behavior and environment are combined
function simulation_callback(mbe::MetabolismBehaviorEnvironment)
    CallbackSet(
        simulation_callback(mbe.environment),
        simulation_callback(mbe.behavior),
        simulation_callback(mbe.metabolism),
    )
end
simulation_callback(o::AbstractEnvironment) = CallbackSet()
simulation_callback(o::AbstractBehavior) = CallbackSet()
simulation_callback(o::DEBOrganism) = simulation_callback(o.mode, o)
function simulation_callback(
    mode::Union{typeof(std()),typeof(sbp())} , o::DEBOrganism
)
    callbacks = map(callback_transitions(o)) do tr
        transition_callback(tr)
    end
    # Define a callback that simply forces accuracy around life-stage transitions
    return CallbackSet(callbacks...)
end

function callback_transitions(model)
    reduce((Birth(), Weaning(), Puberty(), Metamorphosis()); init=()) do acc, transition
        isnothing(get(life(model), transition, nothing)) ? acc : (acc..., transition)
    end
end

transition_callback(::AbstractTransition, model) = 
    ContinuousCallback(transition_event(model), transition_action(model))

transition_event(::Birth, model) = (ELHR, t, integrator) -> ustrip(u"J", i.p.par.E_Hb) - ELHR[3]
transition_event(::Puberty, model) = (ELHR, t, integrator) -> ustrip(u"J", i.p.par.E_Hp) - ELHR[3]
transition_event(::Metamorphosis, model) = (ELHR, t, i) -> ustrip(u"J", i.p.par.E_Hj) - ELHR[3]

# The default action is to do nothing
# This will still force the solver to exactly calculate the transitions time
transition_action(::AbstractTransition, model) = (integrator, i) -> (@show i; nothing) # action when event is found
