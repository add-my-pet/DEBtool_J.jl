# These methods dig down into the LifeStages object,
# and calculate the state variables at each transition - e.g. birth or puberty,
# for fixed temperatures and at-liberty feeding.
#
# They may also calculate males and females separately where specified.
#
# Reduce over all lifestages computing basic variables
# The output state of each transition is used as input state for the next
compute_transition_state(e::AbstractEstimator, o::DEBOrganism{<:Standard}, pars) =
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
    (; L_m, del_M, d_V, k_M, ω, f) = pars

    (; τ, l, info) = scaled_age(at, pars, f)
    L = L_m * l                       # cm, structural length at birth at f
    Lw = L / del_M
    Ww = wet_weight(at, L, d_V, f, ω)
    a = τ / k_M # TODO is this correct
    Birth((; l, L, Lw, Ww, τ, a))
end
function compute_transition_state(at::Weaning, e::AbstractEstimator, pars, ::Transitions, previous)
    (; L_m, del_M, d_V, k_M, ω, f) = pars

    L = L_m * l                       # cm, structural length at birth at f
    Lw = L / del_M
    Ww = wet_weight(at, L, d_V, f, ω)
    a = τ / k_M # TODO is this correct
    Weaning((; l, L, Lw, Ww, τ, a))
end
function compute_transition_state(at::Puberty, e::AbstractEstimator, pars, ::Transitions, previous)
    (; L_m, del_M, d_V, k_M, ω, l_T, g, f) = pars

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
    Ww = wet_weight(at, L, d_V, f, ω)
    a = τ / k_M # TODO is this correct
    return Puberty((; l, L, Lw, Ww, τ, t, a))
end
function compute_transition_state(at::Ultimate, e::AbstractEstimator, pars, trans::Transitions, previous)
    (; f, l_T, L_m, del_M, d_V, ω) = pars
    l = f - l_T                    # -, scaled ultimate length
    L = L_m * l                    # cm, ultimate structural length at f
    # TODO make these calculations optional based on data?. 
    Lw = L / del_M                 # cm, ultimate plastron length
    Ww = wet_weight(at, L, d_V, f, ω)
    l_b = trans[Birth()].l
    a = compute_lifespan(e, pars, l_b)
    return Ultimate((; l, L, Lw, Ww, a))
end

wet_weight(::Union{Sex,AbstractTransition}, L, d_V, f, ω) =
    L^3 * d_V * (oneunit(f) + f * ω) # transition wet weight


# Just use an ode for the whole thing
function compute_transition_state(e::AbstractEstimator, o::DEBOrganism{<:StandardFoetal}, pars)
    # created 2019/02/04 by Bas Kooijman, modified 2023/08/26

    ## Syntax
    # varargout = <../get_tx.m *get_tx*> (p, f, tel_b, tau)

    ## Description
    # Obtains scaled age and length at puberty, weaning, birth for foetal development. 
    # An extra optional parameter, the stress coefficient for foetal development can modify the rate of development from fast 
    #    (default, and a large stress coefficient of 1e8) to slow (value 1 gives von Bertalanffy growth of the same rate as post-natal development). 
    # Multiply the result with the somatic maintenance rate coefficient to arrive at age at puberty, weaning and birth. 
    #
    # Input
    #
    # * p: 6 or 7 -vector with parameters: g, k, l_T, v_Hb, v_Hx, v_Hp, s_F
    # * f: optional (default f = 1)
    #
    #      - scalar with scaled functional response for period bi
    #      - 2-vector with scaled functional responses for periods bx and xi
    #      - (n,2)-array with scaled time since birth and functional responses in the columns
    #
    # * tel_b: optional scalar with scaled length at birth
    #
    #      or 3-vector with scaled age at birth, reserve density and length at 0
    #
    # * tau: optional n-vector with scaled times since birth
    #
    # Output
    #
    # * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
    # * tau_p: scaled age at puberty \tau_p = a_p k_M
    # * tau_x: scaled age at puberty \tau_x = a_x k_M
    # * tau_b: scaled age at birth \tau_b = a_b k_M
    # * lp: scaled length at puberty
    # * lx: scaled length at weaning
    # * lb: scaled length at birth
    # * info: indicator equals 1 if successful, 0 otherwise

    ## Remarks
    # uses integration over scaled age with event detection; this function replaces get_tx_old 

    ## Examples
    # See predict_Moschus_berezovskii for a gradual change from f_bx to f_xi;
    # and predict_Moschiola_meminna for an instantaneous change

    # unpack pars

    (   g,    # -, energy investment ratio
        k,    # -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
        l_T,  # -, scaled heating length
        v_Hb, # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
        v_Hx, # v_H^x = U_H^x g^2 kM^3/ (1 - kap) v^2; U_B^x = M_H^x/ {J_EAm}
        v_Hp, # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
        s_F,
        f,
    ) = p

    f_0b = 1; # embryo development is independent of nutritional state of the mother
    
    # options = odeset('Events', @event_b, 'AbsTol',1e-8, 'RelTol',1e-8);   

    # [~, ~, tau_b, vl_b] = ode45(@dget_lb, [0, 1e10], [1e-20, 1e-20], options, f_0b, s_F, g, k, v_Hb)
    l_b = vl_b(1,2);
    vel_b = [v_Hb, f_0b, l_b]

    # juvenile & adult
    # options = odeset('Events', event_xp, abstol=1e-9, reltol=1e-9) 
    # [tau, vel, tau_xp, vel_xp] = ode45(dget_lx, [-1e-10, tau], vel_b, options, info_tau, f, g, k, l_T, v_Hx, v_Hp);

    if isempty(tau_xp) 
        tau_x = []; tau_p = []; l_x = []; l_p = [];
    elseif length(tau_xp) == 1
        tau_x = tau_b + tau_xp[1]
        tau_p = []
        l_x = vel_xp[1, 3]
        l_p = []
    else
        tau_x = tau_b + tau_xp[1]
        tau_p = tau_b + tau_xp[2]
        l_x = vel_xp[1, 3]
        l_p = vel_xp[2, 3]
    end

    tvel = [tau, vel]
    tvel[1, :] = []
    info = 1

    if any(!isreal, (tau_b, tau_x, tau_p)) || any(<(zero(tau_b)), (tau_b, tau_x, tau_p)) # tb, tx and tp must be real and positive
        info = 0
    end

    tau = (tau_b, tau_x, tau_p)
    l = (l_b, l_x, l_p)
    transitions = (Birth(), Weaning(), Puberty())
    stages = map(transitions, tau, l) do t, τ, l
        t = (τ - tau_b) / k_M             # d, time since birth at puberty
        L = L_m * l                       # cm, structural length at puberty
        Lw = L / del_M                    # cm, plastron length at puberty
        Ww = wet_weight(at, L, d_V, f, ω)
        a = τ / k_M # TODO is this correct
        rebuild(t, (; l, L, Lw, Ww, τ, a))
    end
    return LifeStages(stages)
end
