# was: get_tm_s(p, f, lb, lp)
function compute_time(since::Since{Birth}, ::At{Ultimate}, p, lb)
    ## Description
    # Obtains scaled mean age at death assuming a short growth period relative to the life span
    # Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death.
    # The variant get_tm_foetus does the same in case of foetal development.
    # If the input parameter vector has only 4 elements (for [g, lT, ha/ kM2, sG]),
    #   it skips the calulation of the survival probability at birth and puberty.
    #
    # Input
    #
    # * p: 4 or 7-vector with parameters: [g lT ha sG] or [g k lT vHb vHp ha SG]
    # * f: optional scalar with scaled reserve density at birth (default eb = 1)
    # * lb: optional scalar with scaled length at birth (default: lb is obtained from get_lb)
    #
    # Output
    #
    # * tm: scalar with scaled mean life span
    # * Sb: scalar with survival probability at birth (if length p = 7)
    # * Sp: scalar with survival prabability at puberty (if length p = 7)
    # * info: indicator equals 1 if successful, 0 otherwise

    ## Remarks
    # Obsolete function; please use get_tm_mod.
    # Theory is given in comments on DEB3 Section 6.1.1.
    # See <get_tm.html *get_tm*> for the general case of long growth period relative to life span

    ## Example of use
    # get_tm_s([.5, .1, .1, .01, .2, .1, .01])

    # if length(p) >= 7
    #     #  unpack pars
    #     (; g, l_T, ha, s_G, f) = p
    #     #k   = p(2); # k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
    #     #vHb = p(4); # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
    #     #vHp = p(5); # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
    # elseif length(p) == 4
    #     #  unpack pars
    #     (; g, l_T, ha, s_G, f) = p
    # end
    (; g, l_T, ha, s_G, f) = p
    lT = l_T
    sG = s_G

    if abs(sG) < 1e-10
        sG = 1e-10
    end

    li = f - lT
    hW3 = ha * f * g / 6 / li
    hW = hW3^(1 / 3) # scaled Weibull aging rate
    hG = sG * f * g * li^2
    hG3 = hG^3     # scaled Gompertz aging rate
    tG = hG / hW
    tG3 = hG3 / hW3             # scaled Gompertz aging rate

    info_lp = 1
    # if length(p) >= 7
    #     if !@isdefined(lp) && !@isdefined(lb)
    #         lp, lb, info_lp = get_lp(p, f)
    #     elseif !@isdefined(lp) || isempty(lp) # fix this
    #         lp, lb, info_lp = compute_time(since, At(Puberty()), p)
    #     end

    #     # get scaled age at birth, puberty: tb, tp
    #     tb, lb, info_tb = get_tb(p, f, lb)
    #     irB = 3 * (1 + f / g)
    #     tp = tb + irB * log((li - lb) / (li - lp))
    #     hGtb = hG * tb
    #     Sb = exp((1 - exp(hGtb) + hGtb + hGtb^2 / 2) * 6 / tG3)
    #     hGtp = hG * tp
    #     Sp = exp((1 - exp(hGtp) + hGtp + hGtp^2 / 2) * 6 / tG3)
    #     if info_lp == 1 && info_tb == 1
    #         info = 1
    #     else
    #         info = false
    #     end
    # else # length(p) == 4
        Sb = NaN
        Sp = NaN
        info = 1
    # end

    if abs(sG) < 1e-10
        tm = gamma(4 / 3) / hW
        tm_tail = 0
    elseif hG > 0
        tm = 10 / hG # upper boundary for main integration of S(t)
        tm_tail = expint(exp(tm * hG) * 6 / tG3) / hG
        tm = quadgk(x -> fnget_tm_s(x * hW, tG), 0, tm * hW)[1][1] + tm_tail
        #tm = quad(@fnget_tm_s, 0, tm * hW, [], [], tG)/ hW + tm_tail;
    else # hG < 0
        tm = -1e4 / hG # upper boundary for main integration of S(t)
        hw = hW * sqrt(-3 / tG) # scaled hW
        tm_tail = sqrt(pi) * erfc(tm * hw) / 2 / hw
        tm = quadgk(x -> fnget_tm_s(x * hW, tG), 0, tm * hW)[1][1] + tm_tail
        #tm = quad(@fnget_tm_s, 0, tm * hW, [], [], tG)/ hW + tm_tail;
    end

    return (; t_m=tm, Sb, Sp, info)
end

# was; get_tp(p, f=1, tel_b=nothing, τ=nothing)
function compute_time(::Since{Birth}, ::At{Puberty}, p)#, tel_b=nothing, τ=nothing)
    ## Syntax
    # varargout = <../get_tp.m *get_tp*>(p, f, tel_b, τ)

    ## Description
    # Obtains scaled ages, lengths at puberty, birth for the std model at constant food, temperature;
    # Assumes that scaled reserve density e always equals f; if third input is specified and its second
    # element is not equal to second input (if specified), <get_tpm *get_tpm*> is run.
    #
    # Input
    #
    # * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p
    # * f: optional scalar with functional response (default f = 1) or (n,2)-array with scaled time since birth and functional response
    # * tel_b: optional scalar with scaled length at birth
    #
    #      or 3-vector with scaled age at birth, reserve density and length at 0
    # * τ: optional n-vector with scaled times since birth
    #
    # Output
    #
    # * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
    # * τ_p: scaled age at puberty \τ_p = a_p k_M
    # * τ_b: scaled age at birth \τ_b = a_b k_M
    # * lp: scaled length at puberty
    # * lb: scaled length at birth
    # * info: indicator equals 1 if successful, 0 otherwise

    ## Remarks
    # Function <get_tp_foetus.html *get_tp_foetus*> does the same for foetal development; the result depends on embryonal development.
    # A previous version of get_tp had as optional 3rd input a 2-vector with scaled length, l, and scaled maturity, vH, for a juvenile that is now exposed to f, but previously at another f.
    # Function <get_tpm *get_tpm*> took over this use.
    # Optional inputs might be empty

    ## Example of use
    # τ_p = get_tp([.5, .1, .1, .01, .2]) or tvel = get_tp([.5, .1, .1, .01, .2],[],[],0:0.014:)

        #  unpack pars
        (; g, k, l_T, v_Hb, v_Hp, f) = p
        tel_b = τ = nothing

       # If f has 2 columns and τ is not specified, issue a warning and return
        if size(f, 2) == 2
            if τ === nothing
                @warn "Warning from get_tp: f has 2 columns, but τ is not specified"
                return get_tpm(p, f, tel_b, τ)
            end
        end

        # If tel_b is provided and not empty, and the second element of tel_b is not equal to f
        # and τ is specified, call get_tpm and return the result
        if tel_b !== nothing
            if length(tel_b) == 1
                τ_b = get_tb(p[[1, 2, 4]], f)
                l_b = tel_b
            elseif tel_b[2] != f && τ != nothing
                return get_tpm(p, f, tel_b, τ)
            elseif tel_b[2] != f
                return get_tpm(p, f, tel_b)
            else
                τ_b = tel_b[1]
                #e_b   = tel_b[2];
                l_b = tel_b[3]
            end
        else
            τ_b, l_b, info = get_tb(p, f)
        end

        # if tel_b !== nothing && length(tel_b) == 1
        #     τ_b, l_b, _ = get_tb(p[[1, 2, 4]], f)
        #     τ_p, l_p, _ = get_tp(p, f, tel_b, τ)
        #     return τ_p, τ_b, l_p, l_b, 1
        # elseif tel_b !== nothing && tel_b[2] != f && τ !== nothing
        #     return get_tpm(p, f, tel_b, τ)
        # elseif tel_b !== nothing && tel_b[2] != f
        #     return get_tpm(p, f, tel_b)
        # elseif tel_b !== nothing
        #     τ_b = tel_b[1]
        #     l_b = tel_b[3]
        # else
        #     τ_b, l_b, _ = get_tb(p[[1, 2, 4]], f)
        # end

        # Ensure v_Hp is greater than v_Hb
        if v_Hp < v_Hb
            @warn "Warning from get_tp: v_Hp < v_Hb"
            τ_b, l_b = get_tb(p, f)
            τ_p = nothing
            l_p = nothing
            return (; τ_p, τ_b, l_p, l_b, info=0)
        end

        # Calculate necessary parameters
        rho_B = 1 / (3 * (1 + f / g))
        l_i = f - l_T
        l_d = l_i - l_b

        # Determine if reproduction is possible and calculate l_p and τ_p accordingly
        if k == 1 && f * l_i^2 > v_Hp * k
            l_b = v_Hb^(1/3)
            τ_b = get_tb(p[[1, 2, 4]], f, l_b)
            l_p = v_Hp^(1/3)
            τ_p = τ_b + log(l_d / (l_i - l_p)) / rho_B
            info = true
        elseif f * l_i^2 <= v_Hp * k
            τ_b, l_b = get_tb(p, f)
            τ_p = NaN
            l_p = NaN
            info = false
        else
            l_p, _, info = get_lp1(p, f, l_b)
            τ_p = τ_b + log(l_d / (l_i - l_p)) / rho_B
        end

        # If τ is specified, compute additional values for maturity
        if τ !== nothing
            b3 = 1 / (1 + g / f)
            b2 = f - b3 * l_i
            a0 = - (b2 + b3 * l_i) * l_i^2 / k
            a1 = - l_i * l_d * (2 * b2 + 3 * b3 * l_i) / (rho_B - k)
            a2 = l_d^2 * (b2 + 3 * b3 * l_i) / (2 * rho_B - k)
            a3 = - b3 * l_d^3 / (3 * rho_B - k)
            ak = v_Hb + a0 + a1 + a2 + a3

            τ = reshape(τ, :, 1)  # Make sure τ is a column vector
            ert = exp(-rho_B * τ)
            ekt = exp(-k * τ)
            l = l_i - l_d * exp(-rho_B * τ)
            v_H = min(v_Hp, -a0 - a1 * ert - a2 * ert.^2 - a3 * ert.^3 + ak * ekt)
            tvel = hcat(τ, v_H, f .* ones(size(τ)), l)
        end

        # Check if τ_p is real and positive
        if !isreal(τ_p) || τ_p < 0
            info = false
        end

        # Return results
        if τ !== nothing
            return (; tvel, τ_p, τ_b, l_p, l_b, info)
        else
            return (; τ_p, τ_b, l_p, l_b, info)
        end
end

# Reduce over all lifestages computing basic variables
# The output state of each transition is used as input state for the next
function compute(ls::LifeStages, pars)
    init = (nothing => (;),)
    # Reduce over all transitions, where each uses the state of the previous
    states = reduce(values(ls); init) do transition_states, (lifestage, transition)
        _, prevstate = last(transition_states)
        transition_state = transition => compute(transition, pars, prevstate)
        (transition_states..., transition_state)
    end
    # Remove the init state
    return Base.tail(states)
end

# Handle Dimorphism: split the transition to male and female
compute(t::Dimorphic, pars, state::NamedTuple) =
    Dimorphic(compute(t.a, pars, state), compute(t.b, pars, state))
compute(t::Dimorphic, pars, state::Dimorphic) =
    Dimorphic(compute(t.a, pars, state.a), compute(t.b, pars, state.b))
compute(t::AbstractTransition, pars, state::Dimorphic) =
    Dimorphic(compute(t, pars, state.a), compute(t, pars, state.b))

function compute(t::Birth, pars, state::NamedTuple)
    (; L_m, del_M, d_V, k_M, w, f, TC, TC_30) = pars

    # TODO: remove the duplication of birth/puberty computations
    (; τ_b, l_b, info) = compute_time(Age(), At(Puberty()), pars)
    l = l_b
    τ = τ_b
    L = L_m * l                        # cm, structural length at birth at f
    Lw = L / del_M
    Ww = wet_weight(t, L, d_V, f, w)
    a = τ / k_M
    # TODO generalise for multiple temperatures
    temps = (TC, TC_30)
    aT = map(temps) do T
        a / T
    end
    (; l, L, Lw, Ww, τ, aT)
end
compute(sex::Female, pars, state::NamedTuple) = compute(sex.val, pars, state)
function compute(t::Puberty, pars, state::NamedTuple)
    (; L_m, del_M, d_V, k_M, w, TC, f) = pars

    # TODO: remove the duplication of birth/puberty computations
    (; τ_p, l_p, info) = compute_time(Age(), At(Puberty()), pars)
    l = l_p
    τ = τ_p

    tT = (τ - state.τ) / k_M / TC  # d, time since birth at puberty
    L = L_m * l                    # cm, structural length at puberty
    Lw = L / del_M                 # cm, plastron length at puberty
    Ww = wet_weight(t, L, d_V, f, w)

    return (; l, L, Lw, Ww, τ, tT)
end
function compute(t::Ultimate, pars, state::NamedTuple)
    (; f, l_T, L_m, del_M, d_V, w) = pars
    l = f - l_T                    # -, scaled ultimate length
    L = L_m * l                    # cm, ultimate structural length at f
    Lw = L / del_M                 # cm, ultimate plastron length
    Ww = wet_weight(t, L, d_V, f, w)
    return (; l, L, Lw, Ww)
end

function compute(t::Male{Puberty}, pars, state::NamedTuple)
    (; f, k, l_T, L_mm, del_M, d_V, g_m, w_m, v_Hb, v_Hpm, k_M, TC) = pars
    pars_tpm = (; g=g_m, k, l_T, v_Hb, v_Hp=v_Hpm, f)
    # Need a let block to not overwrite param names - remove later
    τ_p, τ_b, l = let 
        (; τ_p, τ_b, l_p, info) = compute_time(Age(), At(Puberty()), pars_tpm)
        τ_p, τ_b, l_p
    end
    tT = (τ_p - τ_b) / k_M / TC      # d, time since birth at puberty
    L = L_mm * l
    Lw= L / del_M # cm, struc, plastron length at puberty
    Ww = wet_weight(t, L, d_V, f, w_m)
    return (; l, L, Lw, Ww, τ=τ_p, tT)
end
function compute(t::Male{Ultimate}, pars, state::NamedTuple)
    (; f, l_T, L_mm, del_M, d_V, w_m) = pars
    l = f - l_T                    # -, scaled ultimate length
    L = f * L_mm
    Lw = L / del_M # cm, ultimate struct, plastrom length
    Ww = wet_weight(t, L, d_V, f, w_m)
    return (; l, L, Lw, Ww)
end

wet_weight(::Union{Sex,AbstractTransition}, L, d_V, f, ω) =
    L^3 * d_V * (oneunit(f) + f * ω) # transition wet weight

function compute_lifespan(pars, l_b)
    (; h_a, k_M, TC_am) = pars
    # TODO this merge is awful fix and explain ha/h_a
    pars_tm = merge(pars, (; ha=h_a / k_M^2))  # compose parameter vector at T_ref
    (; t_m) = compute_time(Age(), At(Ultimate()), pars_tm, l_b) # -, scaled mean life span at T_ref
    aT_m = t_m / k_M / TC_am               # d, mean life span at T
    return aT_m
end

function compute_reproduction(pars, L_i)
    RT_i = pars.TC_Ri * reprod_rate(L_i, pars.f, pars)[1][1]          # #/d, ultimate reproduction rate at T
    return RT_i
end
