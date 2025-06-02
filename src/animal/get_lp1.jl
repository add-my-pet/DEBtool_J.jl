function get_lp1(p, f, l0)
    (; g, k, l_T, v_Hb, v_Hp) = p
    sM = haskey(p, :sM) ? p.sM : 1.0
    v_H0 = v_Hb

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
    li = sM * (f - l_T)   # scaled ultimate length
    ld = li - lb         # scaled length

    b3 = 1 / (1 + g / f) 
    b2 = f * sM - b3 * li

    a0 = - (b2 + b3 * li) * li^2 / k
    a1 = - li * ld * (2 * b2 + 3 * b3 * li) / (rB - k)
    a2 = ld^2 * (b2 + 3 * b3 * li) / (2 * rB - k)
    a3 = - b3 * ld^3 / (3 * rB - k)

    if v_Hp > -a0
        lp = NaN
        info_lp = false
        println("Warning in get_lp1: maturity at puberty cannot be reached")
    elseif v_H0 > v_Hp
        lp = 1
        info_lp = false
        println("Warning in get_lp1: initial maturity exceeds puberty threshold")
    elseif k == 1
        lp = v_Hp^(1/3)
        info_lp = true
    else
        #lp, info_lp = fzero(fnget_lp, [lb, li], [], a0, a1, a2, a3, lb, li, k, rB, v_H0, v_Hp)
        # try
            lp = fzero((lp) -> fnget_lp(lp, a0, a1, a2, a3, lb, li, k, rB, v_H0, v_Hp), lb, li)
            info_lp = true
        # catch
            # info_lp = false
        # end
    end

    if @isdefined(info_lb)
        info = min(info_lb, info_lp)
    else
        info = info_lp
    end

    return lp, lb, info
end
