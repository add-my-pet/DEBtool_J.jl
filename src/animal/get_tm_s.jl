## get_tm_s
# Obtains scaled mean age at death for short growth periods

##
#function get_tm_s(p, f, lb, lp)
#    # created 2009/02/21 by Bas Kooijman, modified 2014/03/17, 2015/01/18

#    ## Syntax
#    # [tm, Sb, Sp, info] = <../get_tm_s.m *get_tm_s*>(p, f, lb, lp)

#    ## Description
#    # Obtains scaled mean age at death assuming a short growth period relative to the life span
#    # Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death. 
#    # The variant get_tm_foetus does the same in case of foetal development.
#    # If the input parameter vector has only 4 elements (for [g, lT, ha/ kM2, sG]), 
#    #   it skips the calulation of the survival probability at birth and puberty.   
#    #
#    # Input
#    #
#    # * p: 4 or 7-vector with parameters: [g lT ha sG] or [g k lT vHb vHp ha SG]
#    # * f: optional scalar with scaled reserve density at birth (default eb = 1)
#    # * lb: optional scalar with scaled length at birth (default: lb is obtained from get_lb)
#    # * lp: optional scalar with scaled length at puberty
#    #  
#    # Output
#    #
#    # * tm: scalar with scaled mean life span
#    # * Sb: scalar with survival probability at birth (if length p = 7)
#    # * Sp: scalar with survival prabability at puberty (if length p = 7)
#    # * info: indicator equals 1 if successful, 0 otherwise

#    ## Remarks
#    # Obsolete function; please use get_tm_mod.
#    # Theory is given in comments on DEB3 Section 6.1.1. 
#    # See <get_tm.html *get_tm*> for the general case of long growth period relative to life span

#    ## Example of use
#    # get_tm_s([.5, .1, .1, .01, .2, .1, .01])

#    if !@isdefined(f)
#        f = 1 # maximum value as juvenile
#    end

#    if length(p) >= 7
#        #  unpack pars
#        g = p[1] # energy investment ratio
#        #k   = p(2); # k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
#        lT = p[3] # scaled heating length {p_T}/[p_M]Lm
#        #vHb = p(4); # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
#        #vHp = p(5); # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
#        ha = p[6] # h_a/ k_M^2, scaled Weibull aging acceleration
#        sG = p[7] # Gompertz stress coefficient

#    elseif length(p) == 4
#        #  unpack pars
#        g = p[1] # energy investment ratio
#        lT = p[2] # scaled heating length {p_T}/[p_M]Lm
#        ha = p[3] # h_a/ k_M^2, scaled Weibull aging acceleration
#        sG = p[4] # Gompertz stress coefficient
#    end

#    if abs(sG) < 1e-10
#        sG = 1e-10
#    end

#    li = f - lT
#    hW3 = ha * f * g / 6 / li
#    hW = hW3^(1 / 3) # scaled Weibull aging rate
#    hG = sG * f * g * li^2
#    hG3 = hG^3     # scaled Gompertz aging rate
#    tG = hG / hW
#    tG3 = hG3 / hW3             # scaled Gompertz aging rate

#    info_lp = 1
#    if length(p) >= 7
#        if !@isdefined(lp) && !@isdefined(lb)
#            lp, lb, info_lp = get_lp(p, f)
#        elseif !@isdefined(lp) || isempty(lp) # fix this
#            lp, lb, info_lp = get_lp(p, f, lb)
#        end

#        # get scaled age at birth, puberty: tb, tp
#        tb, lb, info_tb = get_tb(p, f, lb)
#        irB = 3 * (1 + f / g)
#        tp = tb + irB * log((li - lb) / (li - lp))
#        hGtb = hG * tb
#        Sb = exp((1 - exp(hGtb) + hGtb + hGtb^2 / 2) * 6 / tG3)
#        hGtp = hG * tp
#        Sp = exp((1 - exp(hGtp) + hGtp + hGtp^2 / 2) * 6 / tG3)
#        if info_lp == 1 && info_tb == 1
#            info = 1
#        else
#            info = false
#        end
#    else # length(p) == 4
#        Sb = NaN
#        Sp = NaN
#        info = 1
#    end

#    if abs(sG) < 1e-10
#        tm = gamma(4 / 3) / hW
#        tm_tail = 0
#    elseif hG > 0
#        tm = 10 / hG # upper boundary for main integration of S(t)
#        tm_tail = expint(exp(tm * hG) * 6 / tG3) / hG
#        tm = (quadgk(x -> fnget_tm_s(x, tG), 0, tm * hW)[1]/hW)[1] + tm_tail
#        #tau_b = 3 * quadgk(x -> dget_tb(x, ab, xb), 1e-15, xb)[1];
#        #tm = quad(@fnget_tm_s, 0, tm * hW, [], [], tG)/ hW + tm_tail;

#    else # hG < 0
#        tm = -1e4 / hG # upper boundary for main integration of S(t)
#        hw = hW * sqrt(-3 / tG) # scaled hW
#        tm_tail = sqrt(pi) * erfc(tm * hw) / 2 / hw
#        tm = (quadgk(x -> fnget_tm_s(x, tG), 0, tm * hW)[1]/hW)[1] + tm_tail
#        #tm = quad(@fnget_tm_s, 0, tm * hW, [], [], tG)/ hW + tm_tail;
#    end
#    (tm, Sb, Sp, info)
#end

function get_tm_s(p, f, lb)
    # created 2009/02/21 by Bas Kooijman, modified 2014/03/17, 2015/01/18

    ## Syntax
    # [tm, Sb, Sp, info] = <../get_tm_s.m *get_tm_s*>(p, f, lb)

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

    if !@isdefined(f)
        f = 1 # maximum value as juvenile
    end

    if length(p) >= 7
        #  unpack pars
        g = p[1] # energy investment ratio
        #k   = p(2); # k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
        lT = p[3] # scaled heating length {p_T}/[p_M]Lm
        #vHb = p(4); # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
        #vHp = p(5); # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
        ha = p[6] # h_a/ k_M^2, scaled Weibull aging acceleration
        sG = p[7] # Gompertz stress coefficient

    elseif length(p) == 4
        #  unpack pars
        g = p[1] # energy investment ratio
        lT = p[2] # scaled heating length {p_T}/[p_M]Lm
        ha = p[3] # h_a/ k_M^2, scaled Weibull aging acceleration
        sG = p[4] # Gompertz stress coefficient
    end

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
    if length(p) >= 7
        if !@isdefined(lp) && !@isdefined(lb)
            lp, lb, info_lp = get_lp(p, f)
        elseif !@isdefined(lp) || isempty(lp) # fix this
            lp, lb, info_lp = get_lp(p, f, lb)
        end

        # get scaled age at birth, puberty: tb, tp
        tb, lb, info_tb = get_tb(p, f, lb)
        irB = 3 * (1 + f / g)
        tp = tb + irB * log((li - lb) / (li - lp))
        hGtb = hG * tb
        Sb = exp((1 - exp(hGtb) + hGtb + hGtb^2 / 2) * 6 / tG3)
        hGtp = hG * tp
        Sp = exp((1 - exp(hGtp) + hGtp + hGtp^2 / 2) * 6 / tG3)
        if info_lp == 1 && info_tb == 1
            info = 1
        else
            info = false
        end
    else # length(p) == 4
        Sb = NaN
        Sp = NaN
        info = 1
    end

    if abs(sG) < 1e-10
        tm = gamma(4 / 3) / hW
        tm_tail = 0
    elseif hG > 0
        tm = 10 / hG # upper boundary for main integration of S(t)
        tm_tail = expint(exp(tm * hG) * 6 / tG3) / hG
        tm = (quadgk(x -> fnget_tm_s(x * hW, tG), 0, tm * hW)[1])[1] + tm_tail
        #tm = quad(@fnget_tm_s, 0, tm * hW, [], [], tG)/ hW + tm_tail;

    else # hG < 0
        tm = -1e4 / hG # upper boundary for main integration of S(t)
        hw = hW * sqrt(-3 / tG) # scaled hW
        tm_tail = sqrt(pi) * erfc(tm * hw) / 2 / hw
        tm = (quadgk(x -> fnget_tm_s(x * hW, tG), 0, tm * hW)[1])[1] + tm_tail
        #tm = quad(@fnget_tm_s, 0, tm * hW, [], [], tG)/ hW + tm_tail;
    end
    (tm, Sb, Sp, info)
end

# subfunction

function fnget_tm_s(t, tG)
    # modified 2010/02/25
    # called by get_tm_s for life span at short growth periods
    # integrate ageing surv prob over scaled age
    # t: age * hW 
    # S: ageing survival prob

    hGt = tG * t # age * hG
    if tG > 0
        # Compute the scaled dataset
        S =
            exp.(
                -(1 .+ sum(cumprod((hGt .* (1 ./ (4:500)))', dims = 2), dims = 2))' .*
                t .^ 3
            )
        # S= exp.((-(1 .+ byrow(byrow(Dataset(hGt' .* (1 ./ (4:500)'), :auto), cumprod), sum))' .* t.^3)');
    else # tG < 0
        S = exp.((((1 .+ hGt .+ hGt .^ 2 / 2) - exp.(hGt)) * 6 / tG^3)')
    end
end
