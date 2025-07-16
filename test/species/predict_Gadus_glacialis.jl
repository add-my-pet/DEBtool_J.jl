#module Predict
#export predict
#using Unitful
function predict(par, data, auxData)# predict
    cPar = parscomp_st(par)
    (; T_ref, T_A, del_M, f, kap, kap_R, v, k_J, h_a, s_G, p_M, E_G) = par
    (; k, l_T, v_Hb, v_Hp, L_m, w, k_M, w, L_T, U_Hb, U_Hp, w_E, w_V, y_E_V, v_Hpm) = cPar
    (; temp) = auxData
    (; Li, Lp, Ri, Wwb, Wwi, Wwp, ab, am, psd, tL) = data
    (; E_V, J_E_M, M_Hb, U_Hb, V_Hp, eta_VG, j_E_J, k_M, m_Em, ome, s_H, v_Hb, w_E, w_X, y_P_E, y_X_E,
        E_m, J_E_T, L_T, M_Hp, U_Hp, eta_O, eta_XA, j_E_M, kap_G, n_M, p_Am, u_Hb, v_Hp, w_P, y_E_V, y_P_X, y_X_P,
        J_E_Am, J_X_Am, L_m, M_V, V_Hb, eta_PA, k, l_T, n_O, p_Xm, u_Hp, w, w_V, y_E_X, y_V_E, v_Hj, U_Hj) = cPar
    g2 = cPar.g
    # compute temperature correction factors
    TC = tempcorr(temp.am, T_ref, T_A)

    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    pars_tj = (; g=g2, k, l_T, v_Hb, v_Hj, v_Hp)
    t_j, t_p, t_b, l_j, l_p, l_b, l_i, r_j, r_B, info = get_tj(pars_tj, f)

    # birth
    L_b = L_m * l_b                  # cm, structural length at birth at f
    Lw_b = L_b / del_M
    Ww_b = L_b^3 * d_V * (1 + f * w)       # g, wet weight at birth at f
    a_b = t_b / k_M
    aT_b = a_b / TC

    # metamorphosis from the field
    L_j = L_m * l_j                  # cm, structural length at metamorphosis at f
    Lw_j = L_j/ del_M                # cm, standard length at metamorphosis at f
    Ww_j = L_j^3 *(1 + f * w)        # g, wet weight at metamorphosis 
    aT_j = t_j / k_M / TC                # d, age at metamorphosis at f and T 

    # puberty 
    L_p = L_m * l_p                  # cm, structural length at puberty at f
    Lw_p = L_p/ del_M                # cm, total length at puberty at f
    Ww_p = L_p^3 *(1 + f * w)        # g, wet weight at puberty 
    aT_p = t_p/ k_M/ TC              # d, age at puberty at f and T

    # ultimate
    l_i = f - l_T                    # -, scaled ultimate length
    L_i = L_m * l_i                  # cm, ultimate structural length at f
    Lw_i = L_i / del_M                # cm, ultimate plastron length
    Ww_i = L_i^3 * d_V * (1 + f * w)       # g,  ultimate wet weight

    # reproduction
    pars_R = (; kap, kap_R, g=g2, k_J, k_M, L_T, v, U_Hb, U_Hj, U_Hp) # compose parameter vector at T
    RT_i = TC * reprod_rate_j(L_i, f, pars_R)[1][1]             # #/d, ultimate reproduction rate at T

    # life span
    pars_tm = [g2 l_T h_a / k_M^2 s_G]  # compose parameter vector at T_ref
    t_m = get_tm_s(pars_tm, f, l_b)[1]      # -, scaled mean life span at T_ref
    aT_m = t_m / k_M / TC               # d, mean life span at T

    # uni-variate data

    # time-length
    #rT_B = TC * k_M / 3 / (1 + f / g2)
    #Lw = Lw_i .- (Lw_i - Lw_b) * exp.(-rT_B * data.tL[:,1])
    Main.@infiltrate
    @show pars_tj
    tvel = get_tj(pars_tj, f, nothing, tL[:, 1]*k_M/TC)[1]
    ELw = L_m * tvel[1][:, 4] / del_M
    # pack to output
    #prdData.tL = ELw;
    prdData = (;
        ab=aT_b,
        am=aT_m,
        Lp=Lw_p,
        Li=Lw_i,
        Wwb=Ww_b,
        Wwp=Ww_p,
        Wwi=Ww_i,
        Ri=RT_i,
        tL=ELw,
    )
    return (; prdData, info)
end

#end