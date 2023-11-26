function predict_Emydura_macquarii(par, data, auxData)# predict
    cPar = parscomp_st(par)
    @unpack T_ref, T_A, del_M, f, kap, kap_R, v, k_J, h_a, s_G, p_M, z_m, E_G = par
    @unpack k, l_T, v_Hb, v_Hp, L_m, w, k_M, w, L_T, U_Hb, U_Hp, w_E, w_V, y_E_V, v_Hpm = cPar 
    @unpack temp = auxData
    @unpack Lb, Li, Lim, Lp, Lpm, Ri, Wwb, Wwi, Wwim, Wwp, Wwpm, ab, ab30, am, psd, tL, tp, tpm = data
    @unpack E_V, J_E_M, M_Hb, U_Hb, V_Hp, eta_VG, j_E_J, k_M, m_Em, ome, s_H, v_Hb, w_E, w_X, y_P_E, y_X_E,
    E_m, J_E_T, L_T, M_Hp, U_Hp, eta_O, eta_XA, j_E_M, kap_G, n_M, p_Am, u_Hb, v_Hp, w_P, y_E_V, y_P_X, y_X_P,
    J_E_Am, J_X_Am, L_m, M_V, V_Hb, eta_PA, k, l_T, n_O, p_Xm, u_Hp, w, w_V, y_E_X, y_V_E = cPar
    g2 = cPar.g
    # compute temperature correction factors
    TC = tempcorr(temp.am, T_ref, T_A);
    TC_30 = tempcorr(temp.ab30, T_ref, T_A);
    TC_Ri = tempcorr(temp.ri, T_ref, T_A);
    TC_am = tempcorr(temp.am, T_ref, T_A);

    d_V = 1g / cm^3                # cm, physical length at birth at f

    pars_tp = [g2 k l_T v_Hb v_Hp]
    t_p, t_b, l_p, l_b, info = get_tp(pars_tp, f)

    # birth
    L_b = L_m * l_b                  # cm, structural length at birth at f
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
    pars_R = [kap kap_R g2 k_J k_M L_T v U_Hb U_Hp] # compose parameter vector at T
    RT_i = TC_Ri * reprod_rate(L_i, f, pars_R)[1]             # #/d, ultimate reproduction rate at T

    # life span
    pars_tm = [g2 l_T h_a / k_M^2 s_G]  # compose parameter vector at T_ref
    t_m = get_tm_s(pars_tm, f, l_b)[1]      # -, scaled mean life span at T_ref
    aT_m = t_m / k_M / TC_am               # d, mean life span at T

    # males
    p_Am_m = z_m * p_M / kap             # J/d.cm^2, {p_Am} spec assimilation flux
    E_m_m = p_Am_m / v                   # J/cm^3, reserve capacity [E_m]
    g_m = E_G / (kap * E_m_m)             # -, energy investment ratio
    m_Em_m = y_E_V * E_m_m / E_G         # mol/mol, reserve capacity 
    w_m = m_Em_m * w_E / w_V             # -, contribution of reserve to weight
    L_mm = v / k_M / g_m                  # cm, max struct length
    pars_tpm = [g_m k l_T v_Hb v_Hpm]
    t_pm, t_bm, l_pm, l_bm = get_tp(pars_tpm, f)
    tT_pm = (t_pm - t_bm) / k_M / TC      # d, time since birth at puberty
    L_pm = L_mm * l_pm
    Lw_pm = L_pm / del_M # cm, struc, plastron length at puberty
    Ww_pm = L_pm^3 * d_V * (1 + f * w_m) # g, wet weight at puberty 
    L_im = f * L_mm
    Lw_im = L_im / del_M # cm, ultimate struct, plastrom length
    Ww_im = L_im^3 * d_V * (1 + f * w_m)       # g, ultimate wet weight

    # pack to output
    # prdData.ab = aT_b;
    # prdData.ab30 = a30_b;
    # prdData.tp = tT_p;
    # prdData.tpm = tT_pm;
    # prdData.am = aT_m;
    # prdData.Lb = Lw_b;
    # prdData.Lp = Lw_p;
    # prdData.Lpm = Lw_pm;
    # prdData.Li = Lw_i;
    # prdData.Lim = Lw_im;
    # prdData.Wwb = Ww_b;
    # prdData.Wwp = Ww_p;
    # prdData.Wwpm = Ww_pm;
    # prdData.Wwi = Ww_i;
    # prdData.Wwim = Ww_im;
    # prdData.Ri = RT_i;

    # uni-variate data

    # time-length
    rT_B = TC * k_M / 3 / (1 + f / g2)
    ELw = Lw_i .- (Lw_i - Lw_b) * exp.(-rT_B * data.tL[1])

    # pack to output
    #prdData.tL = ELw;
    prdData = (;
        ab = aT_b,
        ab30 = a30_b,
        tp = tT_p,
        tpm = tT_pm,
        am = aT_m,
        Lb = Lw_b,
        Lp = Lw_p,
        Lpm = Lw_pm,
        Li = Lw_i,
        Lim = Lw_im,
        Wwb = Ww_b,
        Wwp = Ww_p,
        Wwpm = Ww_pm,
        Wwi = Ww_i,
        Wwim = Ww_im,
        Ri = RT_i,
        tL = ELw,
    )
    return (; prdData, info)
end
