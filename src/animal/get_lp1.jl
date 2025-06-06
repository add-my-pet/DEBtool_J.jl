# Gest scaled length at puberty

## Description
# Obtains scaled length at puberty at constant food density. 
# If initial scaled length (third input) is not specified, it is computed (using automatic initial estimate); 
# If it is specified, however, is it just copied to the (second) output. 
# Food density is assumed to be constant.
#
# Input
#
# * p: 5-vector with parameters: g, k, l_T, v_H^0, v_H^p 
#      or 6-vector with parameters: g, k, l_T, v_H^0, v_H^p, sM
# * f: optional scalar with scaled functional responses (default 1)
# * l0: optional scalar with scaled initial length (birth, metamosphosis or other)
#
#      or optional 2-vector with scaled length, l, and scaled maturity, vH
#      for a juvenile that is now exposed to f, but previously at another f
#      l0 should be specified for foetal development
#  
# Output
#
# * lp: scalar with scaled length at puberty
# * lb: scalar with scaled length at the begining 
# * info: indicator equals 1 if successful, 0 otherwise

## Remarks
# Element p(4) contains scaled murity at birth if l0 is absent or a scalar, or scaled maturity at zero if l0 is of length 2.
# Similar to <get_lp.html *get_lp*>, which uses integration, rather than root finding
# Function <get_lp1_foetus.html *get_lp1_foetus*> does the same, but then for foetal development. 

## Example of use
# get_lp1([.5, .1, .1, .01, .2])
function get_lp1(p, f, l0)
    (; g, k, l_T, v_Hb, v_Hp) = p
    sM = haskey(p, :sM) ? p.sM : 1.0
    v_H0 = v_Hb

    info = true
    if !@isdefined(l0)
        error()
        lb, info_lb = get_lb((; g, k, v_H0), f)
    elseif length(l0) < 2
        lb = l0
        info = true
    else
        error()
        l, v_H0 = l0
        lb, info_lb = get_lb((; g, k, v_H0), f)
    end

    rB = g / 3 / (f + g) # scaled von Bertalanffy growth rate
    li = sM * (f - l_T)  # scaled ultimate length
    ld = li - lb         # scaled length

    b3 = 1 / (1 + g / f) 
    b2 = f * sM - b3 * li

    a0 = - (b2 + b3 * li) * li^2 / k
    a1 = - li * ld * (2 * b2 + 3 * b3 * li) / (rB - k)
    a2 = ld^2 * (b2 + 3 * b3 * li) / (2 * rB - k)
    a3 = - b3 * ld^3 / (3 * rB - k)

    if v_Hp > -a0
        lp = NaN
        info = false
        @warn "maturity at puberty cannot be reached"
    elseif v_H0 > v_Hp
        lp = 1
        info = false
        @warn "initial maturity exceeds puberty threshold"
    elseif k == oneunit(k)
        lp = v_Hp^(1/3)
    else
        #lp, info_lp = fzero(fnget_lp, [lb, li], [], a0, a1, a2, a3, lb, li, k, rB, v_H0, v_Hp)
        # try
            lp = fzero((lp) -> fnget_lp(lp, a0, a1, a2, a3, lb, li, k, rB, v_H0, v_Hp), lb, li)
        # catch
            # info_lp = false
        # end
    end

    return lp, lb, info
end
