# These methods dig down into the LifeStages object,
# and calculate the state variables at each transition - e.g. birth or puberty,
# for fixed temperatures and at-liberty feeding.
#
# They may also calculate males and females separately where specified.
#
# Reduce over all lifestages computing basic variables
# The output state of each transition is used as input state for the next
compute_transition_state(e::AbstractEstimator, o::DEBOrganism, pars) =
    compute_transition_state(e, life(o), pars)
function compute_transition_state(e::AbstractEstimator, life::Life, pars)
    init = (nothing => Init(),)
    # Reduce over all transitions, where each uses the state of the previous
    states = foldl(values(life); init) do transition_states, (lifestage, transition)
        prevstate = last(transition_states)
        transition_state = compute_transition_state(transition, e, pars, Transitions(Base.tail(transition_states)), prevstate)
        (transition_states..., transition_state)
    end
    # Remove the init state
    return Transitions(Base.tail(states)...)
end
# Handle Dimorphism: split the transition to male and female
compute_transition_state(d::Dimorphic, e::AbstractEstimator, pars, ts::Transitions, state) =
    Dimorphic(compute_transition_state(d.a, e, pars, ts[basetypeof(d.a)()], state), 
              compute_transition_state(d.b, e, pars, ts[basetypeof(d.b)()], state))
compute_transition_state(d::Dimorphic, e::AbstractEstimator, pars, ts::Transitions, state::Dimorphic) =
    Dimorphic(compute_transition_state(d.a, e, pars, ts[basetypeof(state.a)()], state.a), 
              compute_transition_state(d.b, e, pars, ts[basetypeof(state.b)()], state.b))
compute_transition_state(t::AbstractTransition, e::AbstractEstimator, pars, ts::Transitions, state::Dimorphic) =
    Dimorphic(compute_transition_state(t, e, pars, ts, state.a), compute_transition_state(e, t, pars, ts, state.b))
compute_transition_state(sex::Female, e::AbstractEstimator, pars, ts::Transitions, state) = 
    Female(compute_transition_state(sex.val, e, pars, ts, state))
function compute_transition_state(t::Male, e::AbstractEstimator, pars, ts::Transitions, state)
    pars_male = merge(pars, pars.male)
    return Male(compute_transition_state(t.val, e, pars_male, ts, state))
end
# This is the actual transition state code!
function compute_transition_state(at::Birth, e::AbstractEstimator, pars, ::Transitions, state)
    (; L_m, del_M, d_V, k_M, w, f) = pars

    (; τ, l, info) = compute_scaled_mean(Since(Conception()), at, pars, f)
    L = L_m * l                       # cm, structural length at birth at f
    Lw = L / del_M
    Ww = wet_weight(at, L, d_V, f, w)
    a = τ / k_M # TODO is this correct
    # TODO generalise for multiple temperatures
    Birth((; l, L, Lw, Ww, τ, a))
end
function compute_transition_state(at::Puberty, e::AbstractEstimator, pars, ::Transitions, state)
    (; L_m, del_M, d_V, k_M, w, l_T, g, f) = pars

    # Calculate necessary parameters
    ρ_B = 1 / (3 * (1 + f / g))
    l_i = f - l_T
    l_d = l_i - state.val.l

    l, info = compute_length(at, pars, state.val.l)
    τ = state.val.τ + log(l_d / (l_i - l)) / ρ_B

    # Check if τ is real and positive
    if !isreal(τ) || τ < zero(τ)
        info = false
    end

    t = (τ - state.val.τ) / k_M    # d, time since birth at puberty
    L = L_m * l                    # cm, structural length at puberty
    Lw = L / del_M                 # cm, plastron length at puberty
    Ww = wet_weight(at, L, d_V, f, w)
    a = τ / k_M # TODO is this correct
    return Puberty((; l, L, Lw, Ww, τ, t, a))
end
function compute_transition_state(at::Ultimate, e::AbstractEstimator, pars, trans::Transitions, state)
    (; f, l_T, L_m, del_M, d_V, w) = pars
    l = f - l_T                    # -, scaled ultimate length
    L = L_m * l                    # cm, ultimate structural length at f
    # TODO make these calculations optional based on data?. 
    Lw = L / del_M                 # cm, ultimate plastron length
    Ww = wet_weight(at, L, d_V, f, w)
    l_b = trans[Birth()].l
    a = compute_lifespan(e, pars, l_b)
    return Ultimate((; l, L, Lw, Ww, a))
end

wet_weight(::Union{Sex,AbstractTransition}, L, d_V, f, ω) =
    L^3 * d_V * (oneunit(f) + f * ω) # transition wet weight
