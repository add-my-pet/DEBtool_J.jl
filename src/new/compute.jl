# was: get_tm_s(p, f, lb, lp)
#
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
# * info: indicator equals 1 if successful, 0 otherwise
## Remarks
# Obsolete function; please use get_tm_mod.
# Theory is given in comments on DEB3 Section 6.1.1.
# See <get_tm.html *get_tm*> for the general case of long growth period relative to life span
function compute_time(e::AbstractEstimator, since::Since{<:Birth}, ::At{<:Ultimate}, p, lb)
    (; g, l_T, ha, s_G, f) = p

    # TODO: explain - for numerical stability?
    if abs(s_G) < 1e-10
        s_G = 1e-10
    end

    li = f - l_T
    hW3 = ha * f * g / 6 / li
    hW = hW3^(1 / 3) # scaled Weibull aging rate
    hG = s_G * f * g * li^2
    hG3 = hG^3       # scaled Gompertz aging rate
    tG = hG / hW
    tG3 = hG3 / hW3  # scaled Gompertz aging rate

    info_lp = 1

    # TODO: explain these branches, and test them
    if abs(s_G) < 1e-10
        error("This abs(s_G) < 1e-10 branch has never been used")
        tm = gamma(4 / 3) / hW
        tm_tail = 0
    elseif hG > 0
        tm = 10 / hG # upper boundary for main integration of S(t)
        tm_tail = expint(exp(tm * hG) * 6 / tG3) / hG
        tm = _integrate_quad(e, hW, tG, tm, tm_tail)
    else # hG < 0
        error("This hG < 0 branch has never been used")
        tm = -1e4 / hG # upper boundary for main integration of S(t)
        hw = hW * sqrt(-3 / tG) # scaled hW
        tm_tail = sqrt(pi) * erfc(tm * hw) / 2 / hw 
        tm = _integrate_quad(e, hW, tG, tm, tm_tail)
    end

    return (; t_m=tm)
end

# TODO: could this range be shorter, or an accuracy parameter?
const QUAD_RANGE = 1 ./ (4:500)

function _integrate_quad(e::AbstractEstimator, hW, tG, tm, tm_tail)
    # Performance critical!!
    # integrate_tm_s is the most deeply nested function call
    # TODO explain what 0 is, why is atol not specified
    quadgk(x -> integrate_tm_s(QUAD_RANGE, x * hW, tG), 0, tm * hW)[1][1] + tm_tail
end

# was fnget_tm_s
# modified 2010/02/25
# called by get_tm_s for life span at short growth periods
# integrate ageing surv prob over scaled age
# t: age * hW 
# Returns: ageing survival prob
function integrate_tm_s(range, t, tG)
    hGt = tG * t # age * hG
    if tG > 0
        # Compute the scaled dataset
        s = c = first(range) * hGt
        for i in 2:lastindex(range)
            x = range[i]
            c *= hGt * x
            s += c 
        end
        exp(-(oneunit(s) + s) * t^3)
    else # tG < 0
        error("Branch not yet tested!") 
        exp(((oneunit(hGt) + hGt + hGt^2 / 2) - exp(hGt)) * 6 / tG^3)
    end
end

# These methods dig down into the LifeStages object,
# and calculate the state variables at each transition - e.g. birth or puberty.
# They may also calculate males and females separately where specified.
#
# Reduce over all lifestages computing basic variables
# The output state of each transition is used as input state for the next
compute_transition_state(e::AbstractEstimator, o::DEBOrganism, pars) =
    compute_transition_state(e, o.lifestages, pars)
function compute_transition_state(e::AbstractEstimator, ls::LifeStages, pars)
    init = (Init((;)),)
    # Reduce over all transitions, where each uses the state of the previous
    states = foldl(values(ls); init) do transition_states, (lifestage, transition)
        prevstate = last(transition_states)
        transition_state = compute_transition_state(e, transition, pars, LifeStages(transition_states), prevstate)
        (transition_states..., transition_state)
    end
    # Remove the init state
    return LifeStages(Base.tail(states))
end
# Handle Dimorphism: split the transition to male and female
compute_transition_state(e::AbstractEstimator, t::Dimorphic, pars, ls::LifeStages, state) =
    Dimorphic(compute_transition_state(e, t.a, pars, ls[basetypeof(t.a)()], state), 
              compute_transition_state(e, t.b, pars, ls[basetypeof(t.b)()], state))
compute_transition_state(e::AbstractEstimator, t::Dimorphic, pars, ls::LifeStages, state::Dimorphic) =
    Dimorphic(compute_transition_state(e, t.a, pars, ls[basetypeof(state.a)()], state.a), 
              compute_transition_state(e, t.b, pars, ls[basetypeof(state.b)()], state.b))
compute_transition_state(e::AbstractEstimator, t::AbstractTransition, pars, ls, state::Dimorphic) =
    Dimorphic(compute_transition_state(e, t, pars, ls, state.a), compute_transition_state(e, t, pars, ls, state.b))
compute_transition_state(e::AbstractEstimator, sex::Female, pars, ls::LifeStages, state) = 
    Female(compute_transition_state(e, sex.val, pars, ls, state))
function compute_transition_state(e::AbstractEstimator, t::Male, pars, ls::LifeStages, state)
    pars_male = merge(pars, pars.male)
    return Male(compute_transition_state(e, t.val, pars_male, ls, state))
end
# This is the actual transition state code!
function compute_transition_state(e::AbstractEstimator, transition::Birth, pars, ls::LifeStages, state)
    (; L_m, del_M, d_V, k_M, w, f) = pars

    τ, l, info = compute_time(e, At(transition), pars, f)
    L = L_m * l                        # cm, structural length at birth at f
    Lw = L / del_M
    Ww = wet_weight(transition, L, d_V, f, w)
    a = τ / k_M # TODO is this correct
    # TODO generalise for multiple temperatures
    Birth((; l, L, Lw, Ww, τ, a))
end
function compute_transition_state(e::AbstractEstimator, trans::Puberty, pars, ls::LifeStages, state)
    (; L_m, del_M, d_V, k_M, w, l_T, g, f) = pars

    # Calculate necessary parameters
    rho_B = 1 / (3 * (1 + f / g))
    l_i = f - l_T
    l_d = l_i - state.val.l

    l, info = compute_length(e, At(trans), pars, state.val.l)
    τ = state.val.τ + log(l_d / (l_i - l)) / rho_B

    # Check if τ is real and positive
    if !isreal(τ) || τ < zero(τ)
        info = false
    end

    t = (τ - state.val.τ) / k_M    # d, time since birth at puberty
    L = L_m * l                    # cm, structural length at puberty
    Lw = L / del_M                 # cm, plastron length at puberty
    Ww = wet_weight(trans, L, d_V, f, w)
    a = τ / k_M # TODO is this correct
    return Puberty((; l, L, Lw, Ww, τ, t, a))
end
function compute_transition_state(e::AbstractEstimator, transition::Ultimate, pars, ls::LifeStages, state)
    (; f, l_T, L_m, del_M, d_V, w) = pars
    l = f - l_T                    # -, scaled ultimate length
    L = L_m * l                    # cm, ultimate structural length at f
    # TODO make these calculations optional based on data?. 
    Lw = L / del_M                 # cm, ultimate plastron length
    Ww = wet_weight(transition, L, d_V, f, w)
    # τ, l, info = compute_time(e, At(transition), pars, f)
    # a = τ / k_M
    # TODO: why was a calculated this way fot Ultimate
    l_b = ls[Birth()].l
    a = compute_lifespan(e, pars, l_b)
    return Ultimate((; l, L, Lw, Ww, a))
end

wet_weight(::Union{Sex,AbstractTransition}, L, d_V, f, ω) =
    L^3 * d_V * (oneunit(f) + f * ω) # transition wet weight

function compute_lifespan(e::AbstractEstimator, pars, l_b)
    (; h_a, k_M) = pars
    # TODO this merge is awful fix and explain ha/h_a
    pars_tm = merge(pars, (; ha=h_a / k_M^2))  # compose parameter vector at T_ref
    (; t_m) = compute_time(e, Age(), At(Ultimate()), pars_tm, l_b) # -, scaled mean life span at T_ref
    am = t_m / k_M
    return am
end

# was reprod_rate
## Description
# Calculates the reproduction rate in number of eggs per time
# for an individual of length L and scaled reserve density f
#
# Input
#
# * L: n-vector with length
# * f: scalar with functional response
# * p: 9-vector with parameters: kap, kapR, g, kJ, kM, LT, v, UHb, UHp
#
#     or optional 2-vector with length, L, and scaled functional response f0
#     for a juvenile that is now exposed to f, but previously at another f
#  
# Output
#
# * R: n-vector with reproduction rates
# * UE0: scalar with scaled initial reserve
# * Lb: scalar with (volumetric) length at birth
# * Lp: scalar with (volumetric) length at puberty
# * info: indicator with 1 for success, 0 otherwise

## Remarks
# See also <reprod_rate_foetus.html *reprod_rate_foetus*>, 
#   <reprod_rate_j.html *reprod_rate_j*>, <reprod_rate_s.html *reprod_rate_s*>.
# For cumulative reproduction, see <cum_reprod.html *cum_reprod*>,
#  <cum_reprod_j.html *cum_reprod_j*>, <cum_reprod_s.html *cum_reprod_s*>

## Example of use
# See <mydata_reprod_rate.m *mydata_reprod_rate*>

#  Explanation of variables:
#  R = kapR * pR/ E0
#  pR = (1 - kap) pC - kJ * EHp
#  [pC] = [Em] (v/ L + kM (1 + LT/L)) f g/ (f + g); pC = [pC] L^3
#  [Em] = {pAm}/ v
# 
#  remove energies; now in lengths, time only
# 
#  U0 = E0/{pAm}; UHp = EHp/{pAm}; SC = pC/{pAm}; SR = pR/{pAm}
#  R = kapR SR/ U0
#  SR = (1 - kap) SC - kJ * UHp
#  SC = f (g/ L + (1 + LT/L)/ Lm)/ (f + g); Lm = v/ (kM g)
#
# unpack parameters; parameter sequence, cf get_pars_r
compute_reproduction_rate(e::AbstractEstimator, o::DEBOrganism, p::NamedTuple, ls::LifeStages) =
    compute_reproduction_rate(e, StandardReproduction(), p, ls)
function compute_reproduction_rate(e::AbstractEstimator, ::StandardReproduction, p::NamedTuple, ls::LifeStages)
    (; kap, kap_R, g, f, k_J, k_M, L_T, v, U_Hb, U_Hp, v_Hb, v_Hp) = p

    L = ls[Female(Ultimate())].L

    L_m = v / (k_M * g) # maximum length
    k = k_J / k_M       # -, maintenance ratio
    l_T = L_T / L_m

    lb = ls[Birth()].l
    lp = ls[Female(Puberty())].l
    Lb = lb * L_m
    Lp = lp * L_m # structural length at birth, puberty

    (; UE0, Lb, info) = init_scaled_reserve(p, lb)
    SC = f * L .^ 3 .* (g ./ L + (1 + L_T ./ L) / L_m) / (f + g)
    SR = (1 - kap) * SC - k_J * U_Hp
    R = (L >= Lp) .* kap_R .* SR ./ UE0 # set reprod rate of juveniles to zero

    return (; R, UE0, Lb, Lp, info)
end

# Subfunctions

function dget_tL(UH, tL, f, g, v, kap, kJ, Lm, LT)
    # called by cum_reprod
    L = tL[2]
    r = v * (f / L - (1 + LT / L) / Lm) / (f + g) # 1/d, spec growth rate
    dL = L * r / 3 # cm/d, d/dt L
    dUH = (1 - kap) * L^3 * f * (1 / L - r / v) - kJ * UH # cm^2, d/dt UH
    dtL = [1; dL] / dUH # 1/cm, d/dUH L
end

# TOD
# function compute_univariate(::Weights, at::Times, pars, Lw_i, Lw_b)
# end
# function compute_univariate(::Weights, at::Lengths, pars, Lw_i, Lw_b)
# end
# function compute_univariate(::ReprodRates, at::Temperatures, pars, Lw_i, Lw_b)
# end
compute_univariate(e::AbstractEstimator, o::DEBOrganism, u::Univariate, pars, lifestages_state, TC) =
    compute_univariate(e, o, u.dependent, u.independent, pars, lifestages_state, TC)
function compute_univariate(e::AbstractEstimator, o::DEBOrganism, dependent::Lengths, independent::Times, pars, lifestages_state, TC)
    (; k_M, f, g) = pars
    Lw_b = lifestages_state[Birth()].Lw
    Lw_i = lifestages_state[Female(Ultimate())].Lw
    # TODO explain these equations
    rT_B = TC * k_M / 3 / (oneunit(f) + f / g)
    return Lw_i .- (Lw_i .- Lw_b) .* exp.(-rT_B .* independent.val)
end

## Description
# Obtains scaled age at birth, given the scaled reserve density at birth. 
# Divide the result by the somatic maintenance rate coefficient to arrive at age at birth. 
#
# Input
#
# * p: 1 or 3-vector with parameters g, k_J/ k_M, v_H^b
#
#     Last 2 values are optional in invoke call to get_lb
#
# * eb: optional scalar with scaled reserve density at birth (default eb = 1)
#  
# Output
#
# * tau_b: scaled age at birth \tau_b = a_b k_M
# * lb: scalar with scaled length at birth: L_b/ L_m
# * info: indicator equals 1 if successful, 0 otherwise

## Remarks
# See also <get_tb1.html *get_tb1*> for backward integration over maturity and
# <get_tb_foetus.html *get_tb_foetus*> for foetal development
function compute_time(e::AbstractEstimator, at::At{<:Birth}, pars::NamedTuple, eb::Number)
    info = true
    l, info = compute_length(e, at, pars, eb)
    (; g) = pars # energy investment ratio

    # TODO explain all of this math
    xb = g / (eb + g)
    αb = 3 * g * xb^(1 / 3) / l
    f1 = _beta(xb) # Precalculate f1 here rather than in _d_time_at_birth inside quadgk
    # Note: this quadgk is the most expensive call in the whole paremeter estimation
    τ = 3 * quadgk(x -> _d_time_at_birth(x, αb, f1), 1e-15, xb; atol=e.quad_atol)[1]
    return (; τ, l, info)
end

# was dget_tb
function _d_time_at_birth(x::Number, αb::Number, f1::Number)
    # called by get_tb
    x ^ (-2 / 3) / (1 - x) / (αb - real(beta0_precalc_f1(x, f1)))
end

## Description
# Obtains scaled length at birth, given the scaled reserve density at birth. 
#
# Input
#
# * p: 3-vector with parameters: g, k, v_H^b (see below)
# * eb: optional scalar with scaled reserve density at birth (default eb = 1)
#  
# Output
#
# * lb: scalar with scaled length at birth 
# * info: indicator equals 1 if successful, 0 otherwise

## Remarks
# The theory behind get_lb, get_tb and get_ue0 is discussed in 
#    <http://www.bio.vu.nl/thb/research/bib/Kooy2009b.html Kooy2009b>.
# Solves y(x_b) = y_b  for lb with explicit solution for y(x)
#   y(x) = x e_H/(1-kap) = x g u_H/ l^3
#   and y_b = x_b g u_H^b/ ((1-kap)l_b^3)
#   d/dx y = r(x) - y s(x);
#   with solution y(x) = v(x) \int r(x)/ v(x) dx
#   and v(x) = exp(- \int s(x) dx).
# A Newton Raphson scheme is used with Euler integration, starting from an optional initial value. 
# Replacement of Euler integration by ode23: <get_lb1.html *get_lb1*>,
#  but that function is much lower.
# Shooting method: <get_lb2.html *get_lb2*>.
# Bisection method (via fzero): <get_lb3.html *get_lb3*>.
# In case of no convergence, <get_lb2.html *get_lb2*> is run automatically as backup.
# Consider the application of <get_lb_foetus.html *get_lb_foetus*> for an alternative initial value.
function compute_length(e::AbstractEstimator, ::At{<:Birth}, p::NamedTuple, eb::Number)
    (; g, k, v_Hb) = p   # g = [E_G] * v/ kap * {p_Am}, energy investment ratio
    # k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
    # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm}

    info = true

    if k == oneunit(k)
        lb = v_Hb^(1 / 3) # exact solution for k = 1
        info = true
        return lb, info
    end
    # if isempty(lb0)
    lb = v_Hb^(1 / 3) # exact solution for k = 1     

    n = 1000 + round(1000 * max(0, k - 1))
    xb = g / (g + eb)
    xb3 = xb^(1 / 3)
    x = LinRange(1e-6, xb, trunc(Int, n))
    # TODO: get the type from context
    buffer = Vector{Float64}(undef, length(x))
    buffer1 = Vector{Float64}(undef, length(x))
    buffer2 = Vector{Float64}(undef, length(x))
    l = Vector{typeof(g)}(undef, length(x))
    r = Vector{typeof(g)}(undef, length(x))
    s = Vector{Float64}(undef, length(x))
    dlnv = Vector{Float64}(undef, length(x))
    dlnl = Vector{Float64}(undef, length(x))
    dv = Vector{Float64}(undef, length(x))
    dl = Vector{Float64}(undef, length(x))
    scum = Vector{Float64}(undef, length(x))
    v = Vector{Float64}(undef, length(x))
    dx = xb / n
    x3 = x .^ (1 / 3)

    f1 = _beta(xb)
    b = real.(beta0_precalc_f1.(x, f1)) ./ (3 * g)
    t0 = xb * g * v_Hb
    i = 0
    norm = 1 # make sure that we start Newton Raphson procedure
    ni = 100 # max number of iterations

    # TODO comment all of this
    while i < ni && norm > 1e-8
        l .= x3 ./ (xb3 ./ lb .- b)
        s .= (k .- x) ./ (1 .- x) .* l ./ g ./ x
        v .= exp.(-dx .* cumsum!(scum, s))
        vb = v[trunc(Int, n)]
        r .= (g .+ l)
        rv = r ./ v
        t = t0 / lb^3 / vb - dx * sum(rv)
        dl = xb3 ./ lb .^ 2 .* l .^ 2 ./ x3
        dlnl .= dl ./ l
        dv .= v .* exp.(-dx .* cumsum!(buffer1, buffer .= s .* dlnl))
        dvb = dv[trunc(Int, n)]
        dlnv .= dv ./ v
        dlnvb = dlnv[trunc(Int, n)]
        dr = dl
        buffer2 .= (dr ./ r .- dlnv) .* rv
        dt = -t0 / lb^3 / vb * (3 / lb + dlnvb) - dx * sum(buffer2)
        # [i lb t dt] # print progress
        lb = lb - t / dt # Newton Raphson step
        norm = t^2
        i = i + 1
    end

    if i == ni || lb < zero(lb) || lb > oneunit(lb) || isnan(norm) || isnan(lb) # no convergence
        # try to recover with a shooting method
        error("This branch has not been tested")
        lb, info = get_lb2(p, eb)
    end

    info == false && @warn "no convergence of l_b"

    return lb, info
end

# was get_lp1
function compute_length(e::AbstractEstimator, ::At{<:Puberty}, p::NamedTuple, l0::Number)
    (; g, k, l_T, v_Hb, v_Hp, f) = p
    sM = haskey(p, :sM) ? p.sM : 1.0
    v_H0 = v_Hb

    lb = l0

    rB = g / 3 / (f + g) # scaled von Bertalanffy growth rate
    li = sM * (f - l_T)  # scaled ultimate length
    ld = li - lb         # scaled length

    # TODO comment all of this math
    b3 = 1 / (1 + g / f) 
    b2 = f * sM - b3 * li

    a0 = - (b2 + b3 * li) * li^2 / k
    a1 = - li * ld * (2 * b2 + 3 * b3 * li) / (rB - k)
    a2 = ld^2 * (b2 + 3 * b3 * li) / (2 * rB - k)
    a3 = - b3 * ld^3 / (3 * rB - k)

    if v_Hp > -a0
        lp = NaN
        info = false
        error()
        @warn "maturity at puberty cannot be reached"
    elseif v_H0 > v_Hp
        lp = 1
        info = false
        error()
        @warn "initial maturity exceeds puberty threshold"
    elseif k == oneunit(k)
        info = true
        lp = v_Hp^(1/3)
        error()
    end

    # Find value of lp where f(lp) == 0
    bounds = (lb, li)
    v_Hja = v_H0 + a0 + a1 + a2 + a3
    lilj = 1 / (li - lb)
    krB = k / rB
    f = lp -> _fn_length_at_puberty(lp, a0, a1, a2, a3, lilj, li, krB, v_Hja, v_Hp)
    lp = solve(ZeroProblem(f, bounds), Bisection())
    info = !isnan(lp)

    return lp, info::Bool
end

# was fnget_lp
function _fn_length_at_puberty(lp, a0, a1, a2, a3, lilj, li, krB, v_Hja, v_Hp)
    tjrB = (li - lp) * lilj # exp(- tau_p r_B) for tau = scaled time since metam
    tjk = tjrB^krB          # exp(- tau_p k)
    # f = 0 if vH(tau_p) = vHp for varying lp
    f = v_Hp + a0 + a1 * tjrB + a2 * tjrB^2 + a3 * tjrB^3 - v_Hja * tjk
    return f
end

# TODO: put parameters in objects so this isn't needed
# ending params with _m is bad and has multiple meanings
function compute_male_params(model::DEBOrganism, par)
    (; kap, z_m, p_M, w_E, w_V, v, E_G, k_M, kap, y_E_V, v_Hpm) = par
    p_Am_m = z_m * p_M / kap           # J/d.cm^2, {p_Am} spec assimilation flux
    E_m_m = p_Am_m / v                 # J/cm^3, reserve capacity [E_m]
    g = E_G / (kap * E_m_m)            # -, energy investment ratio
    m_Em_m = y_E_V * E_m_m / E_G       # mol/mol, reserve capacity
    w = m_Em_m * w_E / w_V             # -, contribution of reserve to weight
    L_m = v / k_M / g                  # cm, max struct length
    return (; w, g, L_m, v_Hp=v_Hpm)
end
