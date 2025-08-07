# These methods dig down into the LifeStages object,
# and calculate the state variables at each transition - e.g. birth or puberty,
# for fixed temperatures and at-liberty feeding.
#
# They may also calculate males and females separately where specified.
#
# Reduce over all lifestages computing basic variables
# The output state of each transition is used as input state for the next
compute_transition_state(e::AbstractEstimator, o::DEBAnimal{<:Standard}, pars) =
    compute_transition_state(e, lifecycle(o), pars)
function compute_transition_state(e::AbstractEstimator, lifecycle::LifeCycle, pars)
    init = (nothing => Conception(),)
    # Reduce over all transitions, where each uses the state of the previous
    states = foldl(values(lifecycle); init) do transition_states, (lifestage, transition)
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
function compute_transition_state(at::Birth, e::AbstractEstimator, pars, ::Transitions, previous)
    (; L_m, del_M, k_M, ω, f) = pars

    (; τ, l, info) = scaled_age(at, pars, f)
    L = L_m * l                       # cm, structural length at birth at f
    Lw = L / del_M
    Ww = wet_weight(at, L, f, ω)
    a = τ / k_M # TODO is this correct
    Birth((; l, L, Lw, Ww, τ, a))
end
function compute_transition_state(at::Weaning, e::AbstractEstimator, pars, ::Transitions, previous)
    (; L_m, del_M, k_M, ω, f) = pars

    L = L_m * l                       # cm, structural length at birth at f
    Lw = L / del_M
    Ww = wet_weight(at, L, f, ω)
    a = τ / k_M # TODO is this correct
    Weaning((; l, L, Lw, Ww, τ, a))
end
function compute_transition_state(at::Puberty, e::AbstractEstimator, pars, ::Transitions, previous)
    (; L_m, del_M, k_M, ω, l_T, g, f) = pars

    # TODO lean this up
    ρ_B = 1 / (3 * (1 + f / g))
    l_i = f - l_T
    l_d = l_i - previous.val.l

    l, info = compute_length(at, pars, previous.val.l)
    τ = previous.val.τ + log(l_d / (l_i - l)) / ρ_B

    # Check if τ is real and positive
    if !isreal(τ) || τ < zero(τ)
        info = false
    end

    t = (τ - previous.val.τ) / k_M    # d, time since birth at puberty
    L = L_m * l                       # cm, structural length at puberty
    Lw = L / del_M                    # cm, plastron length at puberty
    Ww = wet_weight(at, L, f, ω)
    a = τ / k_M # TODO is this correct
    return Puberty((; l, L, Lw, Ww, τ, t, a))
end
function compute_transition_state(at::Ultimate, e::AbstractEstimator, pars, trans::Transitions, previous)
    (; f, l_T, L_m, del_M, ω) = pars
    l = f - l_T                    # -, scaled ultimate length
    L = L_m * l                    # cm, ultimate structural length at f
    # TODO make these calculations optional based on data?. 
    Lw = L / del_M                 # cm, ultimate plastron length
    Ww = wet_weight(at, L, f, ω)
    l_b = trans[Birth()].l
    a = compute_lifespan(e, pars, l_b)
    return Ultimate((; l, L, Lw, Ww, a))
end

wet_weight(::Union{Sex,AbstractTransition}, L, f, ω) = begin
    L^3 * (oneunit(f) + f * ω) # transition wet weight
end


# Just use an ode for the whole thing
function compute_transition_state(e::AbstractEstimator, o::DEBAnimal{<:StandardFoetalDiapause}, pars::NamedTuple)
    (;  g,    # -, energy investment ratio
        k,    # -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
        l_T,  # -, scaled heating length
        v_Hb, # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
        v_Hx, # v_H^x = U_H^x g^2 kM^3/ (1 - kap) v^2; U_B^x = M_H^x/ {J_EAm}
        v_Hp, # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
        s_F,
        k_M,
        del_M,
        L_m,
        ω,
        f,
    ) = pars
    state_template = (v_H=1e-20, l=1e-20)
    # u0 = SVector(f)
    # Define the mode-specific callback function. This controls
    # how the solver handles specific lifecycle events.

    f_0b = 1.0 # embryo development is independent of nutritional state of the mother

    embryo_env = ConstantEnvironment(;
        functionalresponse = f_0b, # getattime(mbe.environment, :functionalresponse, t),
    )
    embryo_mbe = MetabolismBehaviorEnvironment(o, NullBehavior(), embryo_env, pars)
    tspan = (0.0, 1e10)
    birth_action(integrator) = terminate!(integrator)
    birth_event = v_transition_event(Birth(), o, state_template)
    birth_callback = ContinuousCallback(birth_event, birth_action)
    solver = Tsit5()
    sr = StateReconstructor(dget_length_birth, state_template, nothing)
    state_init = SVector(sr)

    # Define the ODE to solve with function, initial state,
    # timespan and parameters
    problem = ODEProblem(sr, state_init, tspan, embryo_mbe)

    # solve the ODE, and return the solution object
    sol = solve(problem, solver;
        save_everystep=false, save_start=false, save_end=false,
        callback=ContinuousCallback(birth_event, birth_action),
        abstol=1e-8,
        reltol=1e-8,
    )
    τ_b = sol.t[1]
    l_b = to_obj(sr, sol[1]).l
    # [~, ~, τ_b, vl_b] = ode45(@dget_lb, [0, 1e10], [1e-20, 1e-20], options, f_0b, s_F, g, k, v_Hb)

    # juvenile & adult

    # l_b = vl_b[1, 2];
    state_b = (; v_H=v_Hb, e=f_0b, l=l_b)
    sr = StateReconstructor(dget_length_weaning_puberty, state_b, nothing)
    state_init = SVector(sr)
    τ = 1e20 
    tspan = (-1e-10, τ)
    # options = odeset('Events', event_xp, abstol=1e-9, reltol=1e-9)
    # [τ, vel, τ_xp, vel_xp] = ode45(dget_lx, [-1e-10, τ], vel_b, options, info_τ, f, g, k, l_T, v_Hx, v_Hp);
    weaning_action(integrator) = nothing
    puberty_action(integrator) = terminate!(integrator)
    weaning_event = v_transition_event(Weaning(), o, state_b)
    puberty_event = v_transition_event(Puberty(), o, state_b)
    callback = CallbackSet(
        ContinuousCallback(weaning_event, weaning_action),
        ContinuousCallback(puberty_event, puberty_action),
    )
    weaning_puberty_mbe = MetabolismBehaviorEnvironment(o, NullBehavior(), embryo_env, pars)
    problem = ODEProblem(sr, state_init, tspan, weaning_puberty_mbe)
    sol = solve(problem, solver; 
        save_everystep=false, save_start=false, save_end=false,
        callback, 
        abstol=1e-9, reltol=1e-9
    )

    # if isempty(τ_xp)
    #     τ_x = []; τ_p = []; l_x = []; l_p = [];
    # elseif length(τ_xp) == 1
    #     τ_x = τ_b + τ_xp[1]
    #     τ_p = []
    #     l_x = vel_xp[1, 3]
    #     l_p = []
    # else
    #     τ_x = τ_b + τ_xp[1]
    #     τ_p = τ_b + τ_xp[2]
    #     l_x = vel_xp[1, 3]
    #     l_p = vel_xp[2, 3]
    # end

    # tvel = [τ, vel]
    # tvel[1, :] = []
    # info = 1

    # if any(!isreal, (τ_b, τ_x, τ_p)) || any(<(zero(τ_b)), (τ_b, τ_x, τ_p)) # tb, tx and tp must be real and positive
    #     info = 0
    # end
    l_x = to_obj(sr, sol[1]).l
    l_p = to_obj(sr, sol[2]).l
    τ_x = sol.t[1]
    τ_p = sol.t[2]
    τ = (τ_b, τ_x, τ_p)
    l = (l_b, l_x, l_p)
    transitions = (Birth(), Weaning(), Puberty())
    transition_state = map(transitions, τ, l) do at, τ, l
        t = (τ - τ_b) / k_M             # d, time since birth at puberty
        L = L_m * l                       # cm, structural length at puberty
        Lw = L / del_M                    # cm, plastron length at puberty
        Ww = wet_weight(at, L, f, ω)
        a = τ / k_M # TODO is this correct
        rebuild(at, (; t, l, L, Lw, Ww, τ, a))
    end
    ultimate = compute_transition_state(Ultimate(), e, pars, Transitions(transition_state), last(transition_state))
    return Transitions((transition_state..., ultimate))
end


function dget_length_birth(u, mbe, τ) # τ: scaled time since start development
    (; v_H, l) = u
    (; s_F, g, k, v_Hb, f) = mbe.par
    f = getattime(mbe.environment, :functionalresponse, τ)

    l_i = s_F * f # -, scaled ultimate length
    f = s_F * f  # -, scaled functional response

    dl = (g / 3) * (l_i - l) / (f + g)  # d/d τ l
    dv_H = 3 * l^2 * dl + l^3 - k * v_H # d/d τ v_H
    return (; v_H=dv_H, l=dl)
end

function dget_length_weaning_puberty(u, mbe, τ)
    (; s_F, g, k, v_Hb, l_T, #= tf, =#) = mbe.par
    # τ: scaled time since birth
    (; v_H, e, l) = u
    f = getattime(mbe.environment, :functionalresponse, τ)

    # if size(tf, 1) == 1 && size(tf,2)==1 # f constant in period bi
        # f = tf[1];
        # e = f
    # elseif size(tf,1)==1 && size(tf,2)==2 # f constant in periods bx and xi
        # if v_H < v_Hx; f = tf(1); else f = tf(2); end; e = f;
    # else # f is varying
        # f = spline1(τ,tf);
    # end

    ρ = g * (e / l - 1 - l_T / l) / (e + g); # -, spec growth rate

    de = (f - e) * g / l; # d/d τ e
    dl = l * ρ / 3; # -, d/d τ l
    dv_H = e * l^2 * (l + g) / (e + g) - k * v_H; # -, d/d τ v_H

    return (; v_H=dv_H, e=de, l=dl)
end


v_transition_event(::Birth, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.par.v_Hb - u.v_H
end
v_transition_event(::Puberty, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.par.v_Hp - u.v_H
end
v_transition_event(::Metamorphosis, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.par.v_Hj - u.v_H
end
v_transition_event(::Weaning, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.par.v_Hx - u.v_H
end
