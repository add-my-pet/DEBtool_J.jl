"""
These methods calculate the state variables at each transition, 
e.g. birth or puberty, for fixed temperatures and at-liberty feeding.

They may also calculate females and males separately when specified.
"""
compute_transition_state(e::AbstractEstimator, o::DEBAnimal, pars) =
    compute_transition_state(e, o, pars, lifecycle(o))
###############################################################################################################
# Fold over the whole lifecycle
# here each result is the input to the next life stage
function compute_transition_state(e::AbstractEstimator, o::DEBAnimal, pars, lifecycle::LifeCycle)
    # Set the initial transition state, with τ at zero.
    init = (Fertilisation((; state=init_scaled_state(o), τ=0.0)),)
    # Reduce over all transitions, where each uses the state of the previous
    states = foldl(values(lifecycle); init) do transition_states, (lifestage, transition)
        # Get the previous transition state
        prevstate = last(transition_states)
        # Calculate the next transition state
        transition_state = compute_transition_state(
            transition, e, o, pars, Transitions(Base.tail(transition_states)), prevstate
        )
        # Add the new state to the previous tuple
        (transition_states..., transition_state)
    end
    # Remove the init state my returning the tail of the tuple, in a Transitions object
    return Transitions(Base.tail(states)...)
end
###############################################################################################################
# Handle Dimorphism: split the transition to Female and Male
function compute_transition_state(
    d::Dimorphic, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state
)
    Dimorphic(
        compute_transition_state(d.a, e, o, pars, ts[basetypeof(d.a)()], state), 
        compute_transition_state(d.b, e, o, pars, ts[basetypeof(d.b)()], state),
    )
end
function compute_transition_state(
    d::Dimorphic, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state::Dimorphic
)
    Dimorphic(
        compute_transition_state(d.a, e, o, pars, ts[basetypeof(state.a)()], state.a), 
        compute_transition_state(d.b, e, o, pars, ts[basetypeof(state.b)()], state.b),
    )
end
function compute_transition_state(
    t::AbstractTransition, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state::Dimorphic
)
    Dimorphic(
        compute_transition_state(t, e, o, pars, ts, state.a), 
        compute_transition_state(e, t, o, pars, ts, state.b),
    )
end
###############################################################################################################
#  Unwrap Female transitions
compute_transition_state(sex::Female, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state) =
    Female(compute_transition_state(sex.val, e, o, pars, ts, state))
compute_transition_state(sex::Female, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state::Female) =
    Female(compute_transition_state(sex.val, e, o, pars, ts, state.val))
#  Unwrap Male transitions, and use male parameters
compute_transition_state(sex::Male, e::AbstractEstimator, o, pars, ts::Transitions, state) =
    Male(compute_transition_state(sex.val, e, o, merge(pars, pars.male), ts, state))
compute_transition_state(sex::Male, e::AbstractEstimator, o, pars, ts::Transitions, state::Male) =
    Male(compute_transition_state(sex.val, e, o, merge(pars, pars.male), ts, state.val))
###############################################################################################################
# This is the actual transition state code!
# Time from Fertilisation to Birth is calculated with scaled_age function.
function compute_transition_state(
    at::Birth, e::AbstractEstimator, o::DEBAnimal{<:Standard}, 
    pars, trans::Transitions, previous::AbstractTransition
)
    (; L_m, del_M, k_M, ω, f, v_Hb) = pars
    (; τ, l, info) = scaled_age(at, pars, f)
    derived = metrics(l, τ, τ, pars)
    # TODO calculate aging properly here
    state = (; v_H=v_Hb, e=1.0, l, aging=aging_init(o))
    # TODO: τ has two meanings, since fertilisations and conception
    Birth((; state, τ, derived))
end
function compute_transition_state(
    at::Puberty, e::AbstractEstimator, o::DEBAnimal{<:Standard},
    pars, trans::Transitions, previous::AbstractTransition
)
    (; L_m, del_M, k_M, ω, l_T, g, f) = pars
    birth = trans[Birth()]

    # TODO clean this up
    ρ_B = 1 / (3 * (1 + f / g))
    l_i = f - l_T
    l_d = l_i - birth.state.l

    l, info = compute_length(at, pars, birth.state.l)
    τ = previous.val.τ + log(l_d / (l_i - l)) / ρ_B

    return Puberty((; state=(; l), τ, derived=metrics(l, τ, birth.τ, pars)))
end
function compute_transition_state(
    at::Ultimate, e::AbstractEstimator, o::DEBAnimal, 
    pars, trans::Transitions, previous::AbstractTransition
)
    (; f, l_T, L_m, del_M, ω, h_a, k_M) = pars
    l_b = trans[Birth()].state.l
    τ_b = trans[Birth()].τ
    l = f - l_T                    # -, scaled ultimate length
    L = L_m * l                    # cm, ultimate structural length at f
    Lw = L / del_M                 # cm, ultimate plastron length
    Ww = wet_weight(L, f, ω)
    # TODO this merge is awful fix and explain scaling of h_a
    pars_tm = merge(pars, (; h_a=h_a / k_M^2)) 
    (; τ) = scaled_mean_age(Ultimate(), e, pars_tm, l_b) # -, scaled mean life span at T_ref
    a = τ / k_M
    t = (τ - τ_b) / k_M               # d, time since birth at puberty
    # @show (τ, t, a)
    return Ultimate((; state=(; l), τ, derived=(; l, L, Lw, Ww, t, a)))
end
###############################################################################################################
# ODE base transition state
function compute_transition_state(
    at::Birth, e::AbstractEstimator, o::DEBAnimal{<:StandardFoetalDiapause}, 
    pars, trans::Transitions, previous::AbstractTransition
)
    (; g, k, l_T, k_M, del_M, L_m, ω, f, v_Hb) = pars
    state = previous.val.state
    f_0b = 1.0 # embryo development is independent of nutritional state of the mother
    env = ConstantEnvironment(; food = f_0b)
    mbe = MetabolismBehaviorEnvironment(o, NullBehavior(), env, pars)
    # TODO give these numbers names
    tspan = (0.0, 1e10)
    callback = scaled_transition_callback(Birth(), o, state)
    solver = Tsit5()
    state_reconstructor = StateReconstructor(d_scaled, state, nothing)
    problem = ODEProblem(state_reconstructor, tspan, rebuild(at, mbe))

    # solve the ODE, and return the solution object
    sol = solve(problem, solver;
        save_everystep=false, save_start=false, save_end=false,
        # TODO make these config parameters? Why are they different to below?
        abstol=1e-8, reltol=1e-8,
        callback,
    )
    (; l, aging) = to_obj(state_reconstructor, sol[1])
    state = (; v_H=v_Hb, e=f_0b, l, aging)
    τ = sol.t[1]
    derived = metrics(l, τ, τ, pars)
    return Birth((; state, τ, derived))
end
function compute_transition_state(
    at::AbstractTransition, e::AbstractEstimator, o::DEBAnimal, 
    pars, trans::Transitions, previous#::AbstractTransition
)
    (; g, k, l_T, k_M, del_M, L_m, ω, f) = pars

    state = previous.val.state
    callback = scaled_transition_callback(at, o, state)
    state_reconstructor = StateReconstructor(d_scaled, state, nothing)
    tspan = (previous.val.τ, 1e20)
    env = ConstantEnvironment(; food=f)
    mbe = MetabolismBehaviorEnvironment(o, NullBehavior(), env, pars)
    problem = ODEProblem(state_reconstructor, tspan, rebuild(at, mbe))
    solver = Tsit5()
    sol = solve(problem, solver; 
        save_everystep=false, save_start=false, save_end=false,
        abstol=1e-9, reltol=1e-9,
        callback,
    )

    state = to_obj(state_reconstructor, sol[1])
    τ = sol.t[1]
    derived = metrics(state.l, τ, trans[Birth()].τ, pars)
    return rebuild(at, (; state, τ, derived))
end

function metrics(l, τ, τ_b, pars)
    (; f, L_m, del_M, k_M, ω) = pars
    t = (τ - τ_b) / k_M               # d, time since birth at puberty
    L = L_m * l                       # cm, structural length at puberty
    Lw = L / del_M                    # cm, plastron length at puberty
    Ww = wet_weight(L, f, ω)
    a = τ / k_M # TODO is this correct
    return (; t, l, L, Lw, Ww, τ, a)
end

wet_weight(L, f, ω) = L^3 * (oneunit(f) + f * ω) # transition wet weight


# TODO this is all kind of pointless, why not just one ODE
# function compute_transition_state(e::AbstractEstimator, o::DEBAnimal{<:Holometabolous{NoFeeding}}, pars::NamedTuple)
#     (;
#      g,      # -, energy investment ratio
#      k,      # -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
#      v_Hb,   # -, v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}: birth (embryo-larva transition)
#      v_He,   # -, v_H^e = U_H^e g^2 kM^3/ (1 - kap) v^2; U_H^e = E_H^e/ {p_Am}: emergence (pupa-imago transition)
#      s_j,    # -, [E_R^j]/ [E_R^ref] scaled reprod buffer density at pupation
#      kap,    # -, allocation fraction to soma of pupa
#      kap_V,  # -, conversion efficiency from larval reserve to larval structure, back to imago reserve
#      f,
#     )
#     #  [E_R^ref] = (1 - kap) [E_m] g (k_E + k_M)/ (k_E - g k_M) is max reprod buffer density

#     # from birth to pupation
#     [tau_b, l_b, info] = get_tb([g k v_Hb], f)  # scaled age and length at birth
#     rho_j = (f / l_b - 1) / (f / g + 1)          # scaled specific growth rate of larva
#     v_Rj = s_j * (1 + l_b / g) / (1 - l_b)       # scaled reprod buffer density at pupation

#     p = (; f, g, l_b, k, v_Hb, v_Rj, rho_j
#     tau_j = nmfzero(fnget_tj_hex, 1, p)     # scaled time since birth at pupation
#     l_j = l_b * exp(tau_j * rho_j / 3)          # scaled length at pubation
#     tau_j = tau_b + tau_j                       # -, scaled age at pupation
#     sM = l_j / l_b                              # -, acceleration factor

#     # from pupation to emergence; 
#     # instantaneous conversion from larval structure to pupal reserve
#     u_Ej = l_j^3 * (kap * kap_V + f / g)        # -, scaled reserve at pupation

#     # options = odeset("Events", emergence, 'NonNegative',[1; 1; 1]);
#     [t luEvH tau_e luEvH_e] = ode45(dget_tj_hex, [0, 300], [0, u_Ej, 0], options, sM, g, k, v_He)
#     tau_e = tau_j + tau_e; # -, scaled age at emergence 
#     l_e = luEvH[end, 1];    # -, scaled length at emergence
#     u_Ee = luEvH[end, 2];   # -, scaled reserve at emergence
# end

# # subfunctions

# function fnget_tj_hex(tau_j, par)
#     (; f, g, l_b, k, v_Hb, v_Rj, rho_j) = par
#     ert = exp(-tau_j * rho_j)
#     return v_Rj - f / g * (g + l_b) / (f - l_b) * (1 - ert) + tau_j * k * v_Hb * ert / l_b^3
# end

# function [value,isterminal,direction] = emergence(u, t, par)
#     value = v_He - luEvH(3)
#     isterminal = 1
#     direction = 0
# end

# function dget_tj_hex(u, t, par)
#     (; l, u_E, v_H) = u
#     l2 = l * l
#     l3 = l * l2
#     l4 = l * l3
#     u_E = max(1e-6, u_E)

#     dl = (g * sM * u_E - l4) / (u_E + l3) / 3
#     du_E = -u_E * l2 * (g * sM + l) / (u_E + l3)
#     dv_H = -du_E - k * v_H

#     (; dl, du_E, dv_H)
# end

