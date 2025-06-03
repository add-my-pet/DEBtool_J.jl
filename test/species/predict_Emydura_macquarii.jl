using DEBtool_J: Arrhenius1parTemperatureResponse, Since, At, Age, Embryo, Birth, Juvenile, Adult, Puberty, Death, Ultimate, LifeStages, compute

function predict(par, data, auxData) # predict
    cPar = parscomp_st(par)
    par = merge(par, cPar)

    (; T_ref, T_A, del_M, f, kap, kap_R, v, k_J, h_a, s_G, p_M, z_m, E_G) = par
    (; k, l_T, v_Hb, v_Hp, L_m, w, k_M, w, L_T, U_Hb, U_Hp, w_E, w_V, y_E_V, v_Hpm) = cPar
    (; temp) = auxData
    (; Lb, Li, Lim, Lp, Lpm, Ri, Wwb, Wwi, Wwim, Wwp, Wwpm, ab, ab30, am, psd, tL, tp, tpm) = data
    (; E_V, J_E_M, M_Hb, U_Hb, V_Hp, eta_VG, j_E_J, k_M, m_Em, ome, s_H, v_Hb, w_E, w_X, y_P_E, y_X_E,
        E_m, J_E_T, L_T, M_Hp, U_Hp, eta_O, kap_G, n_M, p_Am, u_Hb, v_Hp, w_P, y_E_V, y_P_X, y_X_P,
        J_E_Am, J_X_Am, L_m, k, l_T, u_Hp, w, w_V, y_E_X, y_V_E) = cPar
    g2 = cPar.g

    # compute temperature correction factors
    tr = Arrhenius1parTemperatureResponse(T_ref, T_A)
    TC = tempcorr(tr, temp.am)
    TC_30 = tempcorr(tr, temp.ab30)
    TC_Ri = tempcorr(tr, temp.ri)
    TC_am = tempcorr(tr, temp.am)

    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    pars_tp = (; g=g2, k, l_T, v_Hb, v_Hp, f)
    # TODO: age and length are combined here, how do we signal/handle/reorganise this
    (; τ_p, τ_b, l_p, l_b, info) = compute(Age(), At(Puberty()), pars_tp)
    @assert τ_p == get_tp(pars_tp, f)[1]

    lifestages = LifeStages(
        Embryo() => Birth(), 
        Juvenile() => Puberty(), 
        Adult() => Ultimate(),
    )
    lifestage_state = compute(lifestages, par)

    # birth
    L_b = L_m * l_b                        # cm, structural length at birth at f
    Lw_b = L_b / del_M
    Ww_b = L_b^3 * d_V * (1 + f * w)       # g, wet weight at birth at f
    a_b = t_b / k_M
    aT_b = a_b / TC
    a30_b = a_b / TC_30 # d, age at birth

    # puberty 
    tT_p = (t_p - t_b) / k_M / TC      # d, time since birth at puberty
    L_p = L_m * l_p                  # cm, structural length at puberty
    Lw_p = L_p / del_M                # cm, plastron length at puberty
    Ww_p = L_p^3 * d_V * (1 + f * w)       # g, wet weight at puberty

    # ultimate
    l_i = f - l_T                    # -, scaled ultimate length
    L_i = L_m * l_i                  # cm, ultimate structural length at f
    Lw_i = L_i / del_M                # cm, ultimate plastron length
    Ww_i = L_i^3 * d_V * (1 + f * w)       # g,  ultimate wet weight

    # reproduction
    pars_R = (; kap, kap_R, g2, k_J, k_M, L_T, v, U_Hb, U_Hp, f) # compose parameter vector at T
    RT_i = TC_Ri * reprod_rate(L_i, f, pars_R)[1][1]          # #/d, ultimate reproduction rate at T

    # life span
    pars_tm = (; g=g2, l_T, ha=h_a / k_M^2, s_G, f)  # compose parameter vector at T_ref
    (; t_m) = compute(Age(), At(Maturity()), pars_tm, l_b) # -, scaled mean life span at T_ref
    aT_m = t_m / k_M / TC_am               # d, mean life span at T

    # males
    p_Am_m = z_m * p_M / kap             # J/d.cm^2, {p_Am} spec assimilation flux
    E_m_m = p_Am_m / v                   # J/cm^3, reserve capacity [E_m]
    g_m = E_G / (kap * E_m_m)             # -, energy investment ratio
    m_Em_m = y_E_V * E_m_m / E_G         # mol/mol, reserve capacity 
    w_m = m_Em_m * w_E / w_V             # -, contribution of reserve to weight
    L_mm = v / k_M / g_m                  # cm, max struct length
    pars_tpm = (; g=g_m, k, l_T, v_Hb, v_Hp=v_Hpm, f)
    # Need a let block to not overwrite param names - remove later
    (t_pm, t_bm, l_pm, l_bm) = let 
        x = compute(Age(), At(Puberty()), pars_tpm)
        @assert Tuple(get_tp(pars_tpm, f)) == Tuple(x)
        x
    end
    tT_pm = (t_pm - t_bm) / k_M / TC      # d, time since birth at puberty
    L_pm = L_mm * l_pm
    Lw_pm = L_pm / del_M # cm, struc, plastron length at puberty
    Ww_pm = L_pm^3 * d_V * (1 + f * w_m) # g, wet weight at puberty 
    L_im = f * L_mm
    Lw_im = L_im / del_M # cm, ultimate struct, plastrom length
    Ww_im = L_im^3 * d_V * (1 + f * w_m)       # g, ultimate wet weight

    # uni-variate data

    # time-length
    rT_B = TC * k_M / 3 / (1 + f / g2)
    ELw = Lw_i .- (Lw_i - Lw_b) * exp.(-rT_B * data.tL[:,1])

    # pack to output
    #prdData.tL = ELw;
    prdData = (;
        ab=aT_b,
        ab30=a30_b,
        tp=tT_p,
        tpm=tT_pm,
        am=aT_m,
        Lb=Lw_b,
        Lp=Lw_p,
        Lpm=Lw_pm,
        Li=Lw_i,
        Lim=Lw_im,
        Wwb=Ww_b,
        Wwp=Ww_p,
        Wwpm=Ww_pm,
        Wwi=Ww_i,
        Wwim=Ww_im,
        Ri=RT_i,
        tL=ELw,
    )
    return (; prdData, info)
end

#end
