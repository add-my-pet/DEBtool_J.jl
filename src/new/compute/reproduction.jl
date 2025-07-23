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
compute_reproduction_rate(e::AbstractEstimator, o::DEBOrganism, p::NamedTuple, ls::Transitions) =
    compute_reproduction_rate(e, o.reproduction, o, p, ls)
function compute_reproduction_rate(e::AbstractEstimator, mode::StandardReproduction, model::DEBOrganism, p::NamedTuple, ls::Transitions)
    (; kap, kap_R, g, f, k_J, k_M, L_T, v, U_Hb, U_Hp, v_Hb, v_Hp) = p

    L = ls[Female(Ultimate())].L

    L_m = v / (k_M * g) # maximum length
    k = k_J / k_M       # -, maintenance ratio
    l_T = L_T / L_m

    lb = ls[Birth()].l
    lp = ls[Female(Puberty())].l
    L_b = lb * L_m
    L_p = lp * L_m # structural length at birth, puberty

    (; UE0, L_b, info) = initial_scaled_reserve(model.mode, p, lb)
    SC = f * L .^ 3 .* (g ./ L + (1 + L_T ./ L) / L_m) / (f + g)
    SR = (1 - kap) * SC - k_J * U_Hp
    R = (L >= L_p) .* kap_R .* SR ./ UE0 # set reprod rate of juveniles to zero

    return (; R, UE0, L_b, L_p, info)
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

