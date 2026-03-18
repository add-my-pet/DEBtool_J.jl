# Parameters and compound parameters for the iso221 model
# (2 foods, 2 reserves, 1 structure, isomorph)
# Reference: Kooijman DEB3 book section 5.2.7; MATLAB DEBtool_M/iso_21/

"""
    compound_parameters(model::DEBAnimal{Iso221}, p::NamedTuple)

Compute compound parameters for the iso221 model from primary parameters.

Returns a NamedTuple including:
- `m_E1m`, `m_E2m`: mol/mol, maximum reserve densities (from best food)
- `L_m`: cm, maximum structural length (r=0 at max reserves)
- `n_O`: 4×7 matrix of chemical indices for organics (X1,X2,V,E1,E2,P1,P2)
- `n_M`: 4×4 matrix of chemical indices for minerals (CO2,H2O,O2,NH3)
- `w_O`: 7-vector of molecular weights for organics
"""
function compound_parameters(model::DEBAnimal{<:Iso221}, p::NamedTuple)
    # Maximum reserve densities: best assimilation rate from either food
    # mol/d.cm^2, max specific assimilation rates for each reserve from each food
    J_E1Am_X1 = p.y_E1X1 * p.J_X1Am
    J_E1Am_X2 = p.y_E1X2 * p.J_X2Am
    J_E2Am_X1 = p.y_E2X1 * p.J_X1Am
    J_E2Am_X2 = p.y_E2X2 * p.J_X2Am
    J_E1Am = max(J_E1Am_X1, J_E1Am_X2)  # mol/d.cm^2, max assim rate for reserve 1
    J_E2Am = max(J_E2Am_X1, J_E2Am_X2)  # mol/d.cm^2, max assim rate for reserve 2

    # mol/mol, max reserve densities (state-independent)
    m_E1m = J_E1Am / p.v / p.MV
    m_E2m = J_E2Am / p.v / p.MV

    # mu_EV: ratio of chemical potentials, used in shrinking flux
    mu_EV = p.mu_E1 / p.mu_V

    # Maximum structural length: find L such that sgr_iso221(m_E1m, m_E2m, L) = 0
    # At max size assimilation just balances mobilization and maintenance
    L_m = _get_Lm_iso221(p, m_E1m, m_E2m, mu_EV)

    # Chemical indices matrix for organics: 4 rows (C,H,O,N), 7 cols (X1,X2,V,E1,E2,P1,P2)
    n_O = @SMatrix[
        p.n_CX1  p.n_CX2  p.n_CV  p.n_CE1  p.n_CE2  p.n_CP1  p.n_CP2  # C
        p.n_HX1  p.n_HX2  p.n_HV  p.n_HE1  p.n_HE2  p.n_HP1  p.n_HP2  # H
        p.n_OX1  p.n_OX2  p.n_OV  p.n_OE1  p.n_OE2  p.n_OP1  p.n_OP2  # O
        p.n_NX1  p.n_NX2  p.n_NV  p.n_NE1  p.n_NE2  p.n_NP1  p.n_NP2  # N
    ]u"mol" / u"mol"

    # Chemical indices for minerals: 4×4, same as standard model
    n_M = @SMatrix[
        p.n_CC p.n_CH p.n_CO p.n_CN  # CO2
        p.n_HC p.n_HH p.n_HO p.n_HN  # H2O
        p.n_OC p.n_OH p.n_OO p.n_ON  # O2
        p.n_NC p.n_NH p.n_NO p.n_NN  # NH3
    ]u"mol" / u"mol"

    # Molecular weights for organics (g/mol): n_O' * [12,1,16,14]
    w_O = n_O' * @SVector[12, 1, 16, 14]u"g/mol"

    return (;
        m_E1m, m_E2m, J_E1Am, J_E2Am, mu_EV, L_m, n_O, n_M, w_O,
    )
end

"""
    _get_Lm_iso221(p, m_E1m, m_E2m, mu_EV)

Find maximum structural length L_m for the iso221 model by solving r(L_m) = 0.

Uses Brent's method (`find_zero` from Roots.jl) over [1e-3, 1e3] cm.
Port of MATLAB `get_Lm_iso_21.m`.
"""
function _get_Lm_iso221(p, m_E1m, m_E2m, mu_EV)
    (; j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1) = p
    # Roots.jl find_zero does not support Unitful — strip units for root-finding
    v_n      = ustrip(v)
    j_E1M_n  = ustrip(j_E1M)
    j_E2M_n  = ustrip(j_E2M)
    m_E1m_n  = ustrip(m_E1m)
    m_E2m_n  = ustrip(m_E2m)
    mu_EV_n  = ustrip(mu_EV)
    f = L_n -> begin
        k_E = v_n / L_n
        r_n, = _sgr_iso221(m_E1m_n, m_E2m_n, j_E1M_n, j_E2M_n,
                           y_VE1, y_VE2, mu_EV_n, k_E, kap, rho1, 0.0)
        ustrip(r_n)  # ensure bare float even if _sgr_iso221 returns units
    end
    try
        L_m_n = find_zero(f, (1e-3, 1e3), Bisection())
        # Restore units: L has same units as v/j_E1M = (cm/d)/(1/d) = cm
        return L_m_n * oneunit(v) / oneunit(j_E1M)
    catch
        @warn "get_Lm_iso221: no convergence, using fallback estimate"
        return oneunit(v) / oneunit(j_E1M)  # 1 cm (or bare 1.0 if no units)
    end
end

"""
    filter_params(model::DEBAnimal{<:Iso221}, p::NamedTuple)

Parameter filter for iso221 model. Checks that primary parameters are positive.
"""
function filter_params(model::DEBAnimal{<:Iso221}, p::NamedTuple)
    positive_pars = (
        p.J_X1Am, p.J_X2Am, p.v, p.kap, p.MV,
        p.mu_E1, p.mu_E2, p.mu_V,
        p.j_E1M, p.j_E2M,
        p.y_VE1, p.y_VE2,
        p.E_Hb, p.E_Hp,
        p.k_J, p.T_A,
    )
    count(x -> x <= zero(x), positive_pars) > 0 && return false, SomeNegativeOrZero
    p.kap >= 1 && return false, GreaterThan1
    p.E_Hb >= p.E_Hp && return false, MaturityLevelsDontIncrease
    return true, Pass
end
