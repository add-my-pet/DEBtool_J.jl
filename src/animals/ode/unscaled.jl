
function initialise_state(mbe::MetabolismBehaviorEnvironment)
    metabolism = initialise_state(mbe.metabolism, mbe)
    behavior = initialise_state(mbe.behavior, mbe)
    environment = initialise_state(mbe.environment, mbe)
    return (; metabolism, behavior, environment)
end
function initialise_state(o::DEBAnimal, mbe::MetabolismBehaviorEnvironment)
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
function d_sim(state, tr::AbstractTransition, t)
    mbe = tr.val
    (; metabolism, behavior, environment) = mbe
    # Transition does not influence the environment
    environment = d_sim(state.environment, environment, t)
    # Transition and environment both influence behavior
    behavior, inner_environment = d_sim(state.behavior, rebuild(tr, nothing), behavior, mbe, t)
    # Metabolism respondse to post-behavioral experience of the environment
    me = MetabolismEnvironment(metabolism, inner_environment, mbe.par)
    metabolism = d_sim(state.metabolism, rebuild(tr, nothing), metabolism, me, t)
    return (; metabolism, behavior, environment)
end
function d_sim(state, tr::AbstractTransition, b::NullBehavior, mbe, t)
    # Select environmental parameters for the metabolism to experience
    # By default we just return the temperature correction and functional response
    state = (;)
    tempcorrection = getattime(mbe.environment, :tempcorrection, t) # c, temperature at t
    food = getattime(mbe.environment, :food, t) # -, scaled functional response at t
    inner_environment = ConstantEnvironment(; tempcorrection, food)
    return state, inner_environment
end
d_sim(state, b::AbstractEnvironment, t) = state

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
# κ    -, fraction allocated to growth + som maint
# κ_G  -, growth efficiency
# E_G    J/cm^3, volume-specific costs of structure
#
# dELHR: 4-vector with change in E, L, H, R
function d_sim(state, tr::AbstractTransition, metabolism::DEBAnimal, me, t)
    (; environment, par) = me
    (; p_Am, v, p_M, k_J, κ, E_Hb, E_Hp) = par
    (; E, L, E_H) = state
    TC = getattime(environment, :tempcorrection, t) # C, temperature at t
    f_t = getattime(environment, :food, t) # -, scaled functional response at t

    # Add units. TODO automate this from the init
    s_M = acceleration_factor(metabolism.mode, par, L)
    pT_Am, vT, pT_M, kT_J = map(x -> x * TC, (p_Am, v, p_M, k_J)) # temp correction TODO: rates should already be grouped
    r = specific_growth_rate(metabolism.mode, merge(par, (; vT, pT_M, s_M)), state)

    # TODO explain all the equations
    # Assimilation scales with length squared. No assimilation before birth
    pA = (pT_Am * s_M * f_t * L^2) * hasreached(Birth(), tr, metabolism) # J/d, assimilation
    # Flux mobilised from reserved scales with the inverse of length 
    pC = E * (s_M * vT / L - r) # J/d, mobilized energy flux

    # generate derivatives
    # Change in reserve E is the difference between assimmilated mobilized energy
    dE = pA - pC # J/d, change in energy in reserve
    # Length L changes as the growth rate * the current length TODO: why / 3
    dL = r * L / 3 # cm/d, change in length
    # Maturitity H and reproduction R buffers receive (1 - κ) * mobilized flux, minus maturity maintenancy 
    # There is no investment in maturation after puberty 
    dE_H = ((1 - κ) * pC - kT_J * E_H) * !hasreached(Puberty(), tr, metabolism) # J/d, change in cumulated energy invested in maturation
    # And no investment in reproduction before puberty
    dE_R = ((1 - κ) * pC - kT_J * E_Hp) * hasreached(Puberty(), tr, metabolism) # J/d, change in reproduction buffer

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
    (; κ, κ_G, E_G, s_M, vT, pT_M) = par
    # TODO why is growth efficiency optional here
    κ_G_or_1 = (κ * E * s_M * vT < pT_M * L^4) ? κ_G : oneunit(κ_G) # section 4.1.5 comments to Kooy2010
    (E * s_M * vT / L - pT_M * L^3 / κ) / (E * s_M + κ_G_or_1 * E_G * L^3 / κ) # d^-1, specific growth rate
end
function specific_growth_rate(mode::Union{typeof(sbp()),typeof(abp())}, par, state)
    if hasreached(Puberty(), par, state.E_H) 
        # After puberty adults in sbp/adp do not grow or shrink. So the growth rate is zero
        0.0u"d^-1"
    else
        # Otherwise call the standard model specific growth rate
        specific_growth_rate(std(), par, state)
    end
end

# TODO: generalise this order so we can use > or <= etc ?
function hasreached(target::AbstractTransition, query::AbstractTransition, animal)::Bool
    # Look through all the transitions, to see if target or query comes first
    res = reduce(values(transitions(animal)); init=nothing) do result, t
        t = unwrap(target, Female())
        if result isa Bool 
            result 
        else
            if t isa basetypeof(target)
                false # We found the target before the query, so it must come afterwards (or be the same)
            else
                if t isa basetypeof(query)
                    true
                else
                    nothing
                end
            end
        end
    end
    if isnothing(res)
        error("Neigther target $(nameof(basetypeof(target))) or query $(nameof(basetypeof(query))) were found in this lifecycle")
    else
        return res::Bool
    end
end

# -, multiplication factor for v and {p_Am}
# TODO: do this without specifying L_s or L_b - just L and e.g. lifestages[Birth()].L
# Then it would be generalised to any lifestage.
acceleration_factor(::Accelerated{<:Isomorph,<:MaturityLevel}, p, L) = p.accelerating ? L / p.L_s : p.s_M
acceleration_factor(::Accelerated{<:Isomorph,<:Birth}, p, L) = p.accelerating ? L / p.L_b : p.s_M
acceleration_factor(::Mode, pars, L) = 1.0 # Non-accelerating modes


# Callbacks for metabolism, behavior and environment are combined
function event_callback(tr::AbstractTransition, mbe::MetabolismBehaviorEnvironment, template)
    CallbackSet(
        event_callback(tr, mbe.environment, template),
        event_callback(tr, mbe.behavior, template),
        event_callback(tr, mbe.metabolism, template),
    )
end
event_callback(::AbstractTransition, o::AbstractEnvironment, template) = CallbackSet()
event_callback(::AbstractTransition, o::AbstractBehavior, template) = CallbackSet()
event_callback(tr::AbstractTransition, o::DEBAnimal, template) = transition_callback(tr, o, template)

transition_callback(tr::AbstractTransition, model, template) = 
    ContinuousCallback(transition_event(tr, model, template), terminate!)

transition_event(::Birth, model, template) = CallbackReconstructor(template) do u, t, i
    ustrip(i.p.val.par.E_Hb - u.metabolism.E_H)
end
transition_event(::Puberty, model, template) = CallbackReconstructor(template) do u, t, i
    ustrip(i.p.val.par.E_Hp - u.metabolism.E_H)
end
transition_event(::Metamorphosis, model, template) = CallbackReconstructor(template) do u, t, i
    ustrip(i.p.val.par.E_Hj - u.metabolism.E_H)
end
transition_event(::Weaning, model, template) = CallbackReconstructor(template) do u, t, i
    ustrip(i.p.val.par.E_Hx - u.metabolism.E_H)
end
transition_event(::Ultimate, model, template) = CallbackReconstructor(template) do u, t, i
    1.0 # Just run forever
end
