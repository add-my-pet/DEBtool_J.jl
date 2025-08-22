"""
These methods calculate the state variables at each transition, 
e.g. birth or puberty, for fixed temperatures and at-liberty feeding.

They may also calculate females and males separately when specified.
"""
compute_transition_state(e::AbstractEstimator, o::DEBAnimal, pars) =
    compute_transition_state(e, o, pars, lifecycle(o))
function compute_transition_state(e::AbstractEstimator, o::DEBAnimal, pars, lifecycle::LifeCycle)
    init = (nothing => Conception(),)
    # Reduce over all transitions, where each uses the state of the previous
    states = foldl(values(lifecycle); init) do transition_states, (lifestage, transition)
        prevstate = last(transition_states)
        transition_state = compute_transition_state(transition, e, o, pars, Transitions(Base.tail(transition_states)), prevstate)
        (transition_states..., transition_state)
    end
    # Remove the init state
    return Transitions(Base.tail(states)...)
end
# Handle Dimorphism: split the transition to male and female
compute_transition_state(d::Dimorphic, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state) =
    Dimorphic(compute_transition_state(d.a, e, o, pars, ts[basetypeof(d.a)()], state), 
              compute_transition_state(d.b, e, o, pars, ts[basetypeof(d.b)()], state))
compute_transition_state(d::Dimorphic, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state::Dimorphic) =
    Dimorphic(compute_transition_state(d.a, e, o, pars, ts[basetypeof(state.a)()], state.a), 
              compute_transition_state(d.b, e, o, pars, ts[basetypeof(state.b)()], state.b))
compute_transition_state(t::AbstractTransition, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state::Dimorphic) =
    Dimorphic(compute_transition_state(t, e, o, pars, ts, state.a), compute_transition_state(e, t, o, pars, ts, state.b))
compute_transition_state(sex::Female, e::AbstractEstimator, o::DEBAnimal, pars, ts::Transitions, state) = 
    Female(compute_transition_state(sex.val, e, o, pars, ts, state))
function compute_transition_state(t::Male, e::AbstractEstimator, o, pars, ts::Transitions, state)
    pars_male = merge(pars, pars.male)
    return Male(compute_transition_state(t.val, e, o, pars_male, ts, state))
end
# This is the actual transition state code!
function compute_transition_state(at::Birth, e::AbstractEstimator, o::DEBAnimal{<:Standard}, pars, trans::Transitions, previous)
    (; L_m, del_M, k_M, ω, f) = pars
    (; τ, l, info) = scaled_age(at, pars, f)
    m = metrics(l, τ, τ, pars)
    Birth(m)
end
# function compute_transition_state(at::Weaning, e::AbstractEstimator, o::DEBAnimal{<:Standard}, pars, trans::Transitions, previous)
#     (; L_m, del_M, k_M, ω, f) = pars
#     return Weaning(metrics(l, τ, trans[Birth()].τ, pars))
# end
function compute_transition_state(at::Puberty, e::AbstractEstimator, o::DEBAnimal{<:Standard}, pars, trans::Transitions, previous::AbstractTransition)
    (; L_m, del_M, k_M, ω, l_T, g, f) = pars
    birth = trans[Birth()]

    # TODO clean this up
    ρ_B = 1 / (3 * (1 + f / g))
    l_i = f - l_T
    l_d = l_i - birth.l

    l, info = compute_length(at, pars, birth.l)
    τ = previous.val.τ + log(l_d / (l_i - l)) / ρ_B

    # Check if τ is real and positive
    if !isreal(τ) || τ < zero(τ)
        info = false
    end

    return Puberty(metrics(l, τ, birth.τ, pars))
end
function compute_transition_state(at::Ultimate, e::AbstractEstimator, o::DEBAnimal{<:Standard}, pars, trans::Transitions, previous)
    (; f, l_T, L_m, del_M, ω) = pars
    l = f - l_T                    # -, scaled ultimate length
    L = L_m * l                    # cm, ultimate structural length at f
    # TODO make these calculations optional based on data?. 
    Lw = L / del_M                 # cm, ultimate plastron length
    Ww = wet_weight(L, f, ω)
    (; a, τ) = compute_lifespan(e, pars, trans[Birth()].l)
    return Ultimate((; l, L, Lw, Ww, τ, a))
end

function compute_lifespan(e::AbstractEstimator, pars, l_b)
    (; h_a, k_M) = pars
    # TODO this merge is awful fix and explain scaling of h_a
    pars_tm = merge(pars, (; h_a=h_a / k_M^2)) 
    (; τ) = scaled_mean_age(Ultimate(), e, pars_tm, l_b) # -, scaled mean life span at T_ref
    a = τ / k_M
    return (; a, τ)
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


# Just use an ode for the whole thing
function compute_transition_state(at::Birth, e::AbstractEstimator, o::DEBAnimal{<:StandardFoetalDiapause}, pars, trans::Transitions, previous)
    (; g, k, l_T, k_M, del_M, L_m, ω, f) = pars
    # TODO give these numbers names
    state = (v_H=1e-20, l=1e-20)

    # Define the mode-specific callback function. This controls
    # how the solver handles specific lifecycle events.

    f_0b = 1.0 # embryo development is independent of nutritional state of the mother

    env = ConstantEnvironment(; functionalresponse = f_0b)
    mbe = MetabolismBehaviorEnvironment(o, NullBehavior(), env, pars)
    # TODO give these numbers names
    tspan = (0.0, 1e10)
    callback = scaled_transition_callback(Birth(), o, state)
    solver = Tsit5()
    state_reconstructor = StateReconstructor(dget_length_birth, state, nothing)

    # Define the ODE to solve with function, initial state,
    # timespan and parameters
    problem = ODEProblem(state_reconstructor, tspan, rebuilt(at, mbe))

    # solve the ODE, and return the solution object
    sol = solve(problem, solver;
        save_everystep=false, save_start=false, save_end=false,
        # TODO make these config parameters? Why are they different to below?
        abstol=1e-8, reltol=1e-8,
        callback,
    )
    τ = sol.t[1]
    l = to_obj(state_reconstructor, sol[1]).l
    return Birth((; v_H=v_Hb, e=f_0b, metrics(l, τ, τ, pars)...))
end

function compute_transition_state(at::AbstractTransition, e::AbstractEstimator, o::DEBAnimal, pars, trans::Transitions, previous)
    (; g, k, l_T, k_M, del_M, L_m, ω, f) = pars

    state = previous[(:v_H, :e, :l)]
    callback = scaled_transition_callback(at, o, state)
    state_reconstructor = StateReconstructor(d_scaled, state, nothing)
    tspan = (previous.val.τ, 1e20)
    env = ConstantEnvironment(; functionalresponse=f)
    mbe = MetabolismBehaviorEnvironment(o, NullBehavior(), env, pars)
    problem = ODEProblem(state_reconstructor, tspan, rebuild(at, mbe))
    solver = Tsit5()
    sol = solve(problem, solver; 
        save_everystep=false, save_start=false, save_end=true,
        abstol=1e-9, reltol=1e-9,
        callback,
    )

    τ = sol.t[1]
    (; v_H, e, l) = to_obj(sr, sol[1])

    return rebuild(at, (; v_H, e, metrics(l, τ, trans[Birth()].τ, pars)...))
end

function dget_length_birth(u, mbe, τ) # τ: scaled time since start development
    (; v_H, l) = u
    (; s_F, g, k, v_Hb, f) = mbe.par
    f = getattime(mbe.environment, :functionalresponse, τ)

    l_i = s_F * f # -, scaled ultimate length
    f = s_F * f   # -, scaled functional response

    dl = (g / 3) * (l_i - l) / (f + g)  # d/d τ l
    dv_H = 3 * l^2 * dl + l^3 - k * v_H # d/d τ v_H
    return (; v_H=dv_H, l=dl)
end

function dget_length_weaning_puberty(u, mbe, τ)
    (; s_F, g, k, v_Hb, l_T) = mbe.par
    (; v_H, e, l) = u

    f = getattime(mbe.environment, :functionalresponse, τ)

    ρ = g * (e / l - 1 - l_T / l) / (e + g); # -, spec growth rate

    de = (f - e) * g / l; # d/d τ e
    dl = l * ρ / 3; # -, d/d τ l
    dv_H = e * l^2 * (l + g) / (e + g) - k * v_H; # -, d/d τ v_H

    return (; v_H=dv_H, e=de, l=dl)
end

# Events - based on v_H
v_H_transition_event(::Birth, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.par.v_Hb - u.v_H
end
v_H_transition_event(::Puberty, model, template) = CallbackReconstructor(template) do u, t, i
    println(u)
    println(t)
    println()
    i.p.par.v_Hp - u.v_H
end
v_H_transition_event(::Metamorphosis, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.par.v_Hj - u.v_H
end
v_H_transition_event(::Weaning, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.par.v_Hx - u.v_H
end
scaled_transition_event(::Ultimate, model, template) = CallbackReconstructor(template) do u, t, i
    state_below_zero_means_death = (u.v_H, u.e, u.l, u.aging...)
    any(map(x -> x <= zero(x), state_below_zero_means_death))
end

d_scaled_aging(state, mbe, τ) = d_scaled_aging(state.aging, state, mbe, τ)
d_scaled_aging(::Nothing, state, mbe, τ) = nothing
# function d_scaled_aging(aging, state, mbe, τ)
#     (; g, k, v_Hb, h_a, s_G, k_M) = mbe.par
#     h_a = h_a / k_M^2 # scale
#     h_B = haskey(mbe.par, :h_B) ? mbe.par.h_B : 0.0 
#     ρ_N = haskey(mbe.par, :ρ_N) ? mbe.par.ρ_Nh_B : 0.0 
#     (; e, l, v_H) = state
#     (; q, h, S) = aging
#     q = max(zero(q), q)
#     h = max(zero(h), h)

#     e = g * e / l^3
#     ρ = (e / l - 1) / (1 + e / g)
#     dq = g * e * (q * s_G + h_a / l^3) * (g / l - ρ) - ρ * q
#     dh = q - ρ * h
#     dS = -(h + h_B) * S

#     dl0 = S * exp(-ρ_N * τ)                       

#     return (; q=dq, h=dh, S=dS, l0=dl0)
# end

"""

# State variables

- 'q':   -, scaled aging acceleration
- 'h_A': -, scaled hazard rate due to aging
- 'S':   -, survival prob
- 't':   -, scaled cumulative survival

- 'τ': scaled time since birth
"""
function d_scaled_aging(aging, state, at::AbstractTransition, τ)
    par = at.val.par
    thinning = false # TODO 
    (; f, g, s_G, h_a, k_M) = par
    h_a = h_a / k_M^2 # scale
    h_B = haskey(par, :h_B) ? par.h_B : 0.0 
    (; q, h_A, S, t) = aging   
    l = state.l
  
    rho_B = 1/ 3/ (1 + f/ g)g 
    r = 3 * rho_B * (f/ l - 1)g

    dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q
    dh_A = q - r * h_A
    h_X = thinning * r * 2 / 3
    h = h_A + h_B + h_X
    dS = -h * S
    dt = S

    return (; q=dq, h_A=dh_A, S=dS, t=dt) 
end

aging_init(o) = (; q=0.0, h_A=0.0, S=1.0, t=0.0)


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

