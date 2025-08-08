# TODO tis is kind of incoherent

"""
    scaled_age(at::Birth, pars::NamedTuple, eb::Number)

Obtains scaled age at birth, given the scaled reserve density at birth. 
Divide the result by the somatic maintenance rate coefficient to arrive at age at birth. 

## Arguments

- `at`: dispatch for `Birth`
- `p`: parameter `NamedTuple`
- `eb`: optional scalar with scaled reserve density at birth (default eb = 1)

## Output `NamedTuple`

- `τ`: scaled age at birth τ = a_b k_M
- `l`: scalar with scaled length at birth: L_b/ L_m
- `info`: indicator equals 1 if successful, 0 otherwise

## Remarks

was get_tb
"""
function scaled_age(at::Birth, pars::NamedTuple, eb::Number;
    l=nothing, # TODO handle eb and l more generically
)
    (; g) = pars # energy investment ratio
    info = true
    if isnothing(l)
        l, info = compute_length(at, pars; eb)
    end

    # TODO explain all of this math
    xb = g / (eb + g)
    αb = 3 * g * xb^(1 / 3) / l
    f1 = incomplete_beta_side(xb) # Precalculate f1 here rather than in _d_time_at_birth inside quadgk
    # Note: this `quadgk` is the most expensive call in `estimate`
    τ = 3 * quadgk(x -> _d_time_at_birth(x, αb, f1), 1e-15, xb; atol=1e-6)[1]
    return (; τ, l, info)
end

function _d_time_at_birth(x::Number, αb::Number, f1::Number)
    x ^ (-2 / 3) / (1 - x) / (αb - real(incomplete_beta_precalc(x, f1)))
end

# gets scaled age and length at puberty, weaning, birth for foetal development.

"""
    scaled_age(at::AbstractTransition, par::NamedTuple, given::AbstractTransition)

Gets scaled age and length `at` a transition.

Obtains scaled ages, lengths at puberty, birth for the std model at constant food, temperature;
Assumes that scaled reserve density e always equals f; if third input is specified and its second
element is not equal to second input (if specified), <get_tpm *get_tpm*> is run.

## Input

- `at`: 
- `par`: `NamedTuple` of parameters.
- `given`: state at previous transition TODO this should be explicitly wrapped in Birth

## Output `NamedTuple`

- `τ`: scaled age at transition
- `l`: scaled length at transition
- `info`: indicator equals `true` if successful, `false` otherwise

## Remarks

Function <get_tp_foetus.html *get_tp_foetus*> does the same for foetal development; 
the result depends on embryonal development.
A previous version of get_tp had as optional 3rd input a 2-vector with scaled length, l, 
and scaled maturity, vH, for a juvenile that is now exposed to f, but previously at another f.
Function <get_tpm *get_tpm*> took over this use.
Optional inputs might be empty

was get_tp
"""
function scaled_age(at::Puberty, p::NamedTuple, given::Birth)
    #  unpack pars
    (; g, k, l_T, v_Hb, v_Hp, f) = p
    τ_b, l_b = given.val.τ, given.val.l

    # Ensure v_Hp is greater than v_Hb
    @assert v_Hp >= v_Hb

    # Calculate necessary parameters
    ρ_B = 1 / (3 * (1 + f / g))
    l_i = f - l_T
    l_d = l_i - l_b

    info = true
    # Determine if reproduction is possible and calculate l_p and τ_p accordingly
    if k == 1 && f * l_i^2 > v_Hp * k
        # TODO why are these calculated again we have them
        l_b = v_Hb^(1 / 3)
        τ_b = scaled_age(Birth(), pars, f; l=l_b)
        l_p = v_Hp^(1 / 3)
        τ_p = τ_b + log(l_d / (l_i - l_p)) / ρ_B
    elseif f * l_i^2 <= v_Hp * k
        τ_p = NaN
        l_p = NaN
        info = false
    else
        l_p, info = compute_length(Puberty(), p, l_b)
        τ_p = τ_b + log(l_d / (l_i - l_p)) / ρ_B
    end

    # Check if τ_p is real and positive
    if !isreal(τ_p) || τ_p < 0
        info = false
    end

    return (; τ=τ_p, l=l_p, info)
end

"""
    scaled_mean_age(at::AbstractTransition, estimator::AbstractEstimator, par::NamedTuple, lb)

Obtains scaled mean age at death assuming a short growth period relative to the life span
Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death.
The variant get_tm_foetus does the same in case of foetal development.
If the input parameter vector has only 4 elements (for [g, lT, ha/ kM2, sG]),
  it skips the calulation of the survival probability at birth and puberty.

## Arguments

- `at`: The transition to get the age at.
- `estimator`: AbstractEstimator object.
- `par`: parameter `NamedTuple`
- `lb`: optional scalar with scaled length at birth (default: lb is obtained from get_lb)

## Output `NamedTuple`

- `t_m`: scalar with scaled mean life span
- `info`: indicator equals 1 if successful, 0 otherwise

## Remarks

was: get_tm_s(p, f, lb, lp)
Obsolete function; please use get_tm_mod.

Theory is given in comments on DEB3 Section 6.1.1.
See <get_tm.html *get_tm*> for the general case of long growth period relative to life span
"""
function scaled_mean_age(at::Ultimate, e::AbstractEstimator, p, lb)
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
        tm = _integrate_quad(hW, tG, tm, tm_tail)
    else # hG < 0
        error("This hG < 0 branch has never been used")
        tm = -1e4 / hG # upper boundary for main integration of S(t)
        hw = hW * sqrt(-3 / tG) # scaled hW
        tm_tail = sqrt(pi) * erfc(tm * hw) / 2 / hw 
        tm = _integrate_quad(hW, tG, tm, tm_tail)
    end

    return (; t_m=tm)
end

# TODO: could this range be shorter, or an accuracy parameter?
const QUAD_RANGE = 1 ./ (4:500)

function _integrate_quad(hW, tG, tm, tm_tail)
    # Performance critical!!
    # integrate_tm_s is the most deeply nested function call
    # TODO explain what 0 is, why is atol not specified
    quadgk(x -> _q_tm_s(QUAD_RANGE, x * hW, tG), 0, tm * hW)[1][1] + tm_tail
end

# was fnget_tm_s
# modified 2010/02/25
# called by get_tm_s for life span at short growth periods
# integrate ageing surv prob over scaled age
# t: age * hW 
# Returns: ageing survival prob
function _q_tm_s(range, t, tG)
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


