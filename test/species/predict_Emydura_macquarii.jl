using DEBtool_J: DEBOrganism, Arrhenius1parTemperatureResponse, Male, Female, Dimorphic, Since, At, Age, Times,
    Embryo, Birth, Juvenile, Adult, Puberty, Death, Ultimate, LifeStages, Times,
    compute, compute_time, compute_lifespan, compute_reproduction, compute_length_at, compute_male

function predict(model, par, data, auxData) # predict
    cPar = parscomp_st(par)
    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    (; T_ref, T_A, del_M, f, kap, kap_R, v, k_J, h_a, s_G, p_M, z_m, E_G) = par
    (; temp) = auxData
    (; Lb, Li, Lim, Lp, Lpm, Ri, Wwb, Wwi, Wwim, Wwp, Wwpm, ab, ab30, am, psd, tL, tp, tpm) = data
    (; k, l_T, v_Hb, v_Hp, L_m, w, k_M, w, L_T, U_Hb, U_Hp, w_E, w_V, y_E_V, v_Hpm) = cPar
    (; E_V, J_E_M, M_Hb, U_Hb, V_Hp, eta_VG, j_E_J, k_M, m_Em, ome, s_H, v_Hb, w_E, w_X, y_P_E, y_X_E,
        E_m, J_E_T, L_T, M_Hp, U_Hp, eta_O, kap_G, n_M, p_Am, u_Hb, v_Hp, w_P, y_E_V, y_P_X, y_X_P,
        J_E_Am, J_X_Am, L_m, k, l_T, u_Hp, w, w_V, y_E_X, y_V_E) = cPar
    g2 = cPar.g
    # map(temp) do t
    #     tempcorr(tr, t)
    # end
    par = merge(par, cPar, (; d_V, f))

    tr = model.temperatureresponse
    TC = tempcorr(tr, par, temp.am)
    TC_30 = tempcorr(tr, par, temp.ab30)
    TC_Ri = tempcorr(tr, par, temp.Ri)

    # males
    # p_Am_m = z_m * p_M / kap             # J/d.cm^2, {p_Am} spec assimilation flux
    # E_m_m = p_Am_m / v                   # J/cm^3, reserve capacity [E_m]
    # g_m = E_G / (kap * E_m_m)             # -, energy investment ratio
    # m_Em_m = y_E_V * E_m_m / E_G         # mol/mol, reserve capacity
    # w_m = m_Em_m * w_E / w_V             # -, contribution of reserve to weight
    # L_mm = v / k_M / g_m                  # cm, max struct length
    # @assert (; w_m, g_m, L_mm) == compute_male(par)

    (; w_m, g_m, L_mm) = compute_male(par)

    par = merge(par, (; w_m, g_m, L_mm, TC, TC_30, TC_Ri))

    lifestage_state = compute(model.lifestages, par)

    # pars_tp = (; g=g2, k, l_T, v_Hb, v_Hp, f)
    # TODO: age and length are combined here, how do we signal/handle/reorganise this
    # (; τ_p, τ_b, l_p, l_b, info) = compute_time(Age(), At(Puberty()), pars_tp)
    # @assert τ_p == get_tp(pars_tp, f)[1]

    # # birth
    # L_b = L_m * l_b                        # cm, structural length at birth at f
    # Lw_b = L_b / del_M
    # Ww_b = L_b^3 * d_V * (1 + f * w)       # g, wet weight at birth at f
    # a_b = τ_b / k_M
    # aT_b = a_b / TC
    # a30_b = a_b / TC_30 # d, age at birth

    # # puberty
    # tT_p = (τ_p - τ_b) / k_M / TC      # d, time since birth at puberty
    # L_p = L_m * l_p                  # cm, structural length at puberty
    # Lw_p = L_p / del_M                # cm, plastron length at puberty
    # Ww_p = L_p^3 * d_V * (1 + f * w)       # g, wet weight at puberty

    # # ultimate
    # l_i = f - l_T                    # -, scaled ultimate length
    # L_i = L_m * l_i                  # cm, ultimate structural length at f
    # Lw_i = L_i / del_M                # cm, ultimate plastron length
    # Ww_i = L_i^3 * d_V * (1 + f * w)       # g,  ultimate wet weight

    # # males
    # pars_tpm = (; g=g_m, k, l_T, v_Hb, v_Hp=v_Hpm, f)
    # # Need a let block to not overwrite param names - remove later
    # (t_pm, t_bm, l_pm, l_bm) = let
    #     x = compute_time(Age(), At(Puberty()), pars_tpm)
    #     @assert Tuple(get_tp(pars_tpm, f)) == Tuple(x)
    #     x
    # end
    # tT_pm = (t_pm - t_bm) / k_M / TC      # d, time since birth at puberty
    # L_pm = L_mm * l_pm
    # Lw_pm = L_pm / del_M # cm, struc, plastron length at puberty
    # Ww_pm = L_pm^3 * d_V * (1 + f * w_m) # g, wet weight at puberty
    # L_im = f * L_mm
    # Lw_im = L_im / del_M # cm, ultimate struct, plastrom length
    # Ww_im = L_im^3 * d_V * (1 + f * w_m)       # g, ultimate wet weight

    # @assert lifestage_state[2][2].b.tT == tT_pm
    # @assert lifestage_state[2][2].b.L == L_pm
    # @assert lifestage_state[2][2].b.Lw == Lw_pm
    # @assert lifestage_state[2][2].b.Ww == Ww_pm
    # @assert lifestage_state[3][2].b.L == L_im
    # @assert lifestage_state[3][2].b.Lw == Lw_im
    # @assert lifestage_state[3][2].b.Ww == Ww_im
    # @assert lifestage_state[1][2].τ == τ_b
    # @assert lifestage_state[1][2].aT[2] == a30_b
    # @assert lifestage_state[1][2].L == L_b
    # @assert lifestage_state[1][2].Lw == Lw_b
    # @assert lifestage_state[1][2].Ww == Ww_b
    # @assert lifestage_state[1][2].aT[1] == aT_b
    # @assert lifestage_state[1][2].aT[2] == a30_b
    # @assert lifestage_state[2][2].a.tT == tT_p
    # @assert lifestage_state[2][2].a.τ == τ_p
    # @assert lifestage_state[2][2].a.L == L_p
    # @assert lifestage_state[2][2].a.Lw == Lw_p
    # @assert lifestage_state[2][2].a.Ww == Ww_p
    # @assert lifestage_state[3][2].a.l == l_i
    # @assert lifestage_state[3][2].a.L == L_i
    # @assert lifestage_state[3][2].a.Lw == Lw_i
    # @assert lifestage_state[3][2].a.Ww == Ww_i

    τ_b =   lifestage_state[1][2].τ
    a30_b = lifestage_state[1][2].aT[2]
    l_b =   lifestage_state[1][2].l
    L_b =   lifestage_state[1][2].L
    Lw_b =  lifestage_state[1][2].Lw
    Ww_b =  lifestage_state[1][2].Ww
    aT_b =  lifestage_state[1][2].aT[1]
    a30_b = lifestage_state[1][2].aT[2]
    tT_p =  lifestage_state[2][2].a.tT
    τ_p =   lifestage_state[2][2].a.τ
    L_p =   lifestage_state[2][2].a.L
    Lw_p =  lifestage_state[2][2].a.Lw
    Ww_p =  lifestage_state[2][2].a.Ww
    l_i =   lifestage_state[3][2].a.l
    L_i =   lifestage_state[3][2].a.L
    Lw_i =  lifestage_state[3][2].a.Lw
    Ww_i =  lifestage_state[3][2].a.Ww

    tT_pm = lifestage_state[2][2].b.tT
    L_pm =  lifestage_state[2][2].b.L
    Lw_pm = lifestage_state[2][2].b.Lw
    Ww_pm = lifestage_state[2][2].b.Ww
    L_im =  lifestage_state[3][2].b.L
    Lw_im = lifestage_state[3][2].b.Lw
    Ww_im = lifestage_state[3][2].b.Ww

    # life span
    # pars_tm = (; g=g2, l_T, ha=h_a / k_M^2, s_G, f)  # compose parameter vector at T_ref
    # (; t_m) = compute_time(Age(), At(Ultimate()), pars_tm, l_b) # -, scaled mean life span at T_ref
    # aT_m = t_m / k_M / TC_am               # d, mean life span at T
    # @assert aT_m == compute_lifespan(par, l_b)
    aT_m = compute_lifespan(par, l_b)

    # reproduction
    # pars_R = (; kap, kap_R, g=g2, k_J, k_M, L_T, v, U_Hb, U_Hp, f) # compose parameter vector at T
    # RT_i = TC_Ri * reprod_rate(L_i, f, pars_R)[1][1]          # #/d, ultimate reproduction rate at T
    # @assert RT_i == compute_reproduction(par, L_i)
    RT_i = compute_reproduction(par, L_i)

    # uni-variate data

    # rT_B = TC * k_M / 3 / (oneunit(f) + f / g2)
    # ELw = Lw_i .- (Lw_i - Lw_b) * exp.(-rT_B * data.tL[:, 1])
    # @assert ELw == compute_length_at(Times(data.tL[:, 1]), par, Lw_i, Lw_b)
    ELw = compute_length_at(Times(data.tL[:, 1]), par, Lw_i, Lw_b)

    # pack to output
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
    # TODO get this from solves
    info = true

    return (; prdData, info)
end

#end
