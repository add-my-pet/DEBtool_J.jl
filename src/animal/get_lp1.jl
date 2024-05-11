function get_lp1(p, f, l0)
    g = p[1]   # energy investment ratio
    k = p[2]   # k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
    lT = p[3]  # scaled heating length {p_T}/[p_M]
    vH0 = p[4] # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
    vHp = p[5] # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}
    sM = length(p) == 6 ? p[6] : 1

    if !@isdefined(f)
        f = 1
    end

    if !@isdefined(l0)
        lb, info_lb = get_lb([g, k, vH0], f)
    elseif length(l0) < 2
        lb = l0
        info = true
    else
        l, vH0 = l0
        lb, info_lb = get_lb([g, k, vH0], f)
    end

    rB = g / 3 / (f + g) # scaled von Bertalanffy growth rate
    li = sM * (f - lT)   # scaled ultimate length
    ld = li - lb         # scaled length

    b3 = 1 / (1 + g / f) 
    b2 = f * sM - b3 * li

    a0 = - (b2 + b3 * li) * li^2 / k
    a1 = - li * ld * (2 * b2 + 3 * b3 * li) / (rB - k)
    a2 = ld^2 * (b2 + 3 * b3 * li) / (2 * rB - k)
    a3 = - b3 * ld^3 / (3 * rB - k)

    if vHp > -a0
        lp = NaN
        info_lp = false
        println("Warning in get_lp1: maturity at puberty cannot be reached")
    elseif vH0 > vHp
        lp = 1
        info_lp = false
        println("Warning in get_lp1: initial maturity exceeds puberty threshold")
    elseif k == 1
        lp = vHp^(1/3)
        info_lp = true
    else
        #lp, info_lp = fzero(fnget_lp, [lb, li], [], a0, a1, a2, a3, lb, li, k, rB, vH0, vHp)
        try
            lp = fzero((lp) -> fnget_lp(lp, a0, a1, a2, a3, lb, li, k, rB, vH0, vHp), lb, li)
            info_lp = true
        catch
            info_lp = false
        end
    end

    if @isdefined(info_lb)
        info = min(info_lb, info_lp)
    else
        info = info_lp
    end

    return lp, lb, info
end
