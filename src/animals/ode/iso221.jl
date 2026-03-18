# ODE system for the iso221 model
# (2 foods, 2 reserves, 1 structure, isomorph)
# Port of MATLAB DEBtool_M/iso_21/diso_221.m
# Reference: Kooijman DEB3 book section 5.2.7

# -------------------------------------------------------------------------
# State initialisation

"""
    initialise_state(o::DEBAnimal{<:Iso221}, mbe::MetabolismBehaviorEnvironment)

Compute initial state for iso221 at fertilisation (start of embryo stage).
Runs the embryo shooting method to find initial reserves M_E10, M_E20.
"""
function initialise_state(o::DEBAnimal{<:Iso221}, mbe::MetabolismBehaviorEnvironment)
    p = stripparams(mbe.par)
    p = merge(p, compound_parameters(o, p))
    var_b, a_b, M_E10, M_E20 = _iso221_birth_state(p)
    # Start simulation from birth state to avoid extreme reserve density at tiny L_0.
    # (Starting at fertilization gives m_E1 = M_E10/M_V0 ~1e11, forcing r~200 d^{-1} and millions of ODE steps.)
    # The Birth() callback fires immediately (E_H = E_Hb at t=0), then Juvenile stage runs normally.
    return (;
        M_E1 = var_b.M_E1b,
        M_E2 = var_b.M_E2b,
        M_V  = p.MV * var_b.L_b^3,
        E_H  = var_b.E_Hb,
        M_R1 = zero(var_b.M_E1b),
        M_R2 = zero(var_b.M_E2b),
        q    = zero(p.h_a),
        h    = zero(p.j_E1M),
        S    = 1.0,
    )
end

# -------------------------------------------------------------------------
# Main ODE dispatch

"""
    d_sim(state, tr::AbstractTransition, metabolism::DEBAnimal{<:Iso221}, me, t)

ODE for the iso221 model. Dispatches on `DEBAnimal{<:Iso221}`.
State: (M_E1, M_E2, M_V, E_H, M_R1, M_R2, q, h, S)

Port of MATLAB diso_221.m.
"""
function d_sim(state, tr::AbstractTransition, metabolism::DEBAnimal{<:Iso221}, me, t)
    (; environment, par) = me
    (; M_E1, M_E2, M_V, E_H, M_R1, M_R2, q, h, S) = state

    # Clip reserves to avoid numerical issues
    M_E1 = max(M_E1, zero(M_E1))
    M_E2 = max(M_E2, zero(M_E2))
    M_V  = max(M_V,  1e-20 * oneunit(M_V))

    TC = getattime(environment, :tempcorrection, t)
    food = getattime(environment, :food, t)

    # No assimilation during embryo stage (direct E_H comparison — avoids broken hasreached)
    in_embryo = E_H < par.E_Hb
    X1 = in_embryo ? zero(food.X1) : food.X1
    X2 = in_embryo ? zero(food.X2) : food.X2

    # Unpack parameters
    (; J_X1Am, J_X2Am, F_X1m, F_X2m, M_X1, M_X2,
       y_E1X1, y_E2X1, y_E1X2, y_E2X2,
       y_VE1, y_VE2, v, kap, kap_E1, kap_E2,
       mu_E1, mu_E2, mu_V,
       j_E1M, j_E2M, J_E1T, J_E2T, MV,
       k_J, k1_J, rho1,
       E_Hb, E_Hp,
       h_a, s_G, h_H, del_V,
       m_E1m, m_E2m, mu_EV, L_m
    ) = par

    # Temperature-corrected rates
    JT_X1Am = TC * J_X1Am
    JT_X2Am = TC * J_X2Am
    FT_X1m  = TC * F_X1m
    FT_X2m  = TC * F_X2m
    vT      = TC * v
    kT_J    = TC * k_J
    k1T_J   = TC * k1_J

    # Help quantities
    L = (M_V / MV)^(1/3)     # cm, structural length
    m_E1 = M_E1 / M_V         # mol/mol, reserve density 1
    m_E2 = M_E2 / M_V         # mol/mol, reserve density 2
    kT_E = vT / L              # 1/d, reserve turnover rate

    # Somatic maintenance (volume + surface-area linked)
    jT_E1S = TC * j_E1M + TC * J_E1T / MV / L  # mol/d/mol
    jT_E2S = TC * j_E2M + TC * J_E2T / MV / L  # mol/d/mol

    # -----------------------------------------------------------------------
    # Feeding and functional responses (Kooijman 2010, section 5.2.7)

    # Reserve stress factors (drive food competition)
    m_E1m_TC = max(y_E1X1 * JT_X1Am, y_E1X2 * JT_X2Am) / vT / MV
    m_E2m_TC = max(y_E2X1 * JT_X1Am, y_E2X2 * JT_X2Am) / vT / MV
    s1 = max(zero(m_E1), 1 - m_E1 / m_E1m_TC)  # stress from reserve 1 deficit
    s2 = max(zero(m_E2), 1 - m_E2 / m_E2m_TC)  # stress from reserve 2 deficit

    # Competition coefficients: how much X1 competes against X2 (and vice versa)
    rho_X1X2 = (s1 * max(zero(s1), M_X1 / M_X2 * y_E1X1 / y_E1X2 - 1) +
                s2 * max(zero(s2), M_X1 / M_X2 * y_E2X1 / y_E2X2 - 1))
    rho_X2X1 = (s1 * max(zero(s1), M_X2 / M_X1 * y_E1X2 / y_E1X1 - 1) +
                s2 * max(zero(s2), M_X2 / M_X1 * y_E2X2 / y_E2X1 - 1))

    # Alpha/beta coefficients for functional response (diso_221.m lines 81-85)
    # X1, X2 are food densities in mol/cm^2 (2D environment); convert to number densities
    # by dividing by particle size M_X (mol/particle), giving N = #/cm^2.
    # hT_XAm = JT_XAm/M_X has units d^{-1}cm^{-2}; F_Xm*N_X = d^{-1}*cm^{-2} ✓
    hT_X1Am = JT_X1Am / M_X1
    hT_X2Am = JT_X2Am / M_X2
    N_X1 = X1 / M_X1   # number density: #/cm^2
    N_X2 = X2 / M_X2
    alphaT_X1 = hT_X1Am + FT_X1m * N_X1 + FT_X2m * rho_X2X1 * N_X2
    alphaT_X2 = hT_X2Am + FT_X2m * N_X2 + FT_X1m * rho_X1X2 * N_X1
    betaT_X1  = FT_X1m * N_X1 * (1 - rho_X1X2)
    betaT_X2  = FT_X2m * N_X2 * (1 - rho_X2X1)
    denom = alphaT_X1 * alphaT_X2 - betaT_X1 * betaT_X2
    # f1, f2 are dimensionless (0-1); false branch uses zero(denom)/oneunit(denom) = 0.0 dimensionless
    f0 = zero(denom) / oneunit(denom)
    f1 = denom > zero(denom) ? (alphaT_X2 * FT_X1m * N_X1 - betaT_X1 * FT_X2m * N_X2) / denom : f0
    f2 = denom > zero(denom) ? (alphaT_X1 * FT_X2m * N_X2 - betaT_X2 * FT_X1m * N_X1) / denom : f0
    f1 = max(f0, f1)
    f2 = max(f0, f2)

    # -----------------------------------------------------------------------
    # Assimilation
    # JT_EiA (mol/d) = surface-specific rate * L^2; jT_EiA (d^{-1}) = JT_EiA / (MV * L^3)
    JT_E1A = (f1 * y_E1X1 * JT_X1Am + f2 * y_E1X2 * JT_X2Am) * L^2  # mol/d
    JT_E2A = (f1 * y_E2X1 * JT_X1Am + f2 * y_E2X2 * JT_X2Am) * L^2  # mol/d
    jT_E1A = JT_E1A / MV / L^3   # d^{-1}, spec assimilation (= JT_E1A / M_V)
    jT_E2A = JT_E2A / MV / L^3

    # -----------------------------------------------------------------------
    # Growth rate — embryo uses Brent solver (stable at tiny L); post-birth uses NR
    rT, jT_E1_S, jT_E2_S, jT_E1C, jT_E2C = if in_embryo
        vB0 = vT / 3 - 1e-4 * oneunit(vT)
        v_B, j1S, j2S, j1C, j2C = _gr_iso221(
            L, m_E1, m_E2, jT_E1S, jT_E2S, y_VE1, y_VE2, vT, kap, rho1, vB0
        )
        3 * v_B / L, j1S, j2S, j1C, j2C
    else
        rT_, j1S, j2S, j1C, j2C, _ = _sgr_iso221(
            m_E1, m_E2, jT_E1S, jT_E2S, y_VE1, y_VE2, mu_EV, kT_E, kap, rho1, zero(kT_E)
        )
        rT_, j1S, j2S, j1C, j2C
    end
    jT_V_S = max(zero(rT), -rT)  # specific shrinking rate

    # Rejected fluxes
    jT_E1P = kap * jT_E1C - jT_E1_S - (rT + jT_V_S) / y_VE1
    jT_E2P = kap * jT_E2C - jT_E2_S - (rT + jT_V_S) / y_VE2

    # -----------------------------------------------------------------------
    # Reserve dynamics
    dm_E1 = jT_E1A - jT_E1C + kap_E1 * jT_E1P - rT * m_E1  # mol/d/mol
    dm_E2 = jT_E2A - jT_E2C + kap_E2 * jT_E2P - rT * m_E2
    dM_E1 = M_V * (dm_E1 + rT * m_E1)   # mol/d
    dM_E2 = M_V * (dm_E2 + rT * m_E2)

    # -----------------------------------------------------------------------
    # Structure
    dM_V = rT * M_V   # mol/d

    # -----------------------------------------------------------------------
    # Mobilisation power (for maturation/reproduction)
    JT_E1C = jT_E1C * M_V  # mol/d
    JT_E2C = jT_E2C * M_V  # mol/d
    pT_C = mu_E1 * JT_E1C + mu_E2 * JT_E2C  # J/d, total mobilisation power

    # -----------------------------------------------------------------------
    # Maturation / reproduction
    is_adult  = E_H >= par.E_Hp
    is_juv    = !is_adult

    dE_H_mat = (1 - kap) * pT_C - kT_J * E_H
    # Rejuvenation when maturity maintenance exceeds (1-kap)*pC
    dE_H_rej = -k1T_J * (E_H - (1 - kap) * pT_C / kT_J)
    dE_H = if is_adult
        zero(dE_H_mat)
    elseif dE_H_mat < zero(dE_H_mat)
        dE_H_rej
    else
        dE_H_mat
    end

    # Reproduction buffer (only in adults)
    JT_E1R = pT_C > zero(pT_C) ? JT_E1C * (1 - kap - kT_J * E_H / pT_C) : zero(JT_E1C)
    JT_E2R = pT_C > zero(pT_C) ? JT_E2C * (1 - kap - kT_J * E_H / pT_C) : zero(JT_E2C)
    dM_R1 = is_adult ? par.kap_R1 * JT_E1R : zero(JT_E1R)
    dM_R2 = is_adult ? par.kap_R2 * JT_E2R : zero(JT_E2R)

    # -----------------------------------------------------------------------
    # Aging (Weibull + Gompertz; same formulation as standard model)
    JT_E1Am_val = max(y_E1X1 * JT_X1Am, y_E1X2 * JT_X2Am)
    JT_E2Am_val = max(y_E2X1 * JT_X1Am, y_E2X2 * JT_X2Am)
    JT_E1S_vol = TC * j_E1M * MV  # mol/d/cm^3
    JT_E2S_vol = TC * j_E2M * MV
    L_m_TC = kap * min(JT_E1Am_val / JT_E1S_vol, JT_E2Am_val / JT_E2S_vol)

    kT_C = (jT_E1C - jT_E1P) / m_E1 + (jT_E2C - jT_E2P) / m_E2  # 1/d, summed p_C/E_m
    dq = (q * (L / L_m_TC)^3 * s_G + h_a) * kT_C - rT * q
    dh = q - rT * h
    dS = -S * h  # survival from aging only (shrinking/rejuvenation hazards omitted for now)

    return (;
        M_E1=dM_E1, M_E2=dM_E2, M_V=dM_V,
        E_H=dE_H, M_R1=dM_R1, M_R2=dM_R2,
        q=dq, h=dh, S=dS,
    )
end

# -------------------------------------------------------------------------
# Lifecycle event callbacks for iso221 (same maturity thresholds as std model)

function transition_event(::Birth, model::DEBAnimal{<:Iso221}, template)
    CallbackReconstructor(template) do u, t, i
        ustrip(i.p.val.par.E_Hb - u.metabolism.E_H)
    end
end

function transition_event(::Puberty, model::DEBAnimal{<:Iso221}, template)
    CallbackReconstructor(template) do u, t, i
        ustrip(i.p.val.par.E_Hp - u.metabolism.E_H)
    end
end
