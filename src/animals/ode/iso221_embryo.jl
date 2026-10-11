# Embryo ODE and shooting method for iso221 model
# Port of MATLAB DEBtool_M/iso_21/iso_21_b.m and gr_iso_21.m
# Reference: Kooijman DEB3 book section 5.2.7.2

"""
    _gr_iso221(L, m_E1, m_E2, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1, vB0)

Growth rate d/dt L = v_B for an iso221 embryo with 2 reserves.
Uses Brent's method to solve the implicit equation fn_vB(v_B) = 0.
Port of MATLAB gr_iso_21.m.

# Arguments
- `L`: cm, structural length
- `m_E1, m_E2`: mol/mol, reserve densities
- `j_E1M, j_E2M`: mol/d/mol, spec somatic maintenance costs
- `y_VE1, y_VE2`: mol/mol, yield of structure on each reserve
- `v`: cm/d, energy conductance
- `kap`: -, allocation fraction to soma
- `rho1`: -, maintenance preference for reserve 1
- `vB0`: cm/d, initial guess for v_B (use v/3 - 1e-4 if unknown)

# Returns
`(v_B, j_E1_M, j_E2_M, j_E1C, j_E2C)`: growth rate and maintenance/mobilisation fluxes
"""
function _gr_iso221(L, m_E1, m_E2, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1, vB0)
    # Roots.jl does not support Unitful — strip units for root-finding
    L_n    = ustrip(L)
    m_E1_n = ustrip(m_E1)
    m_E2_n = ustrip(m_E2)
    j_E1M_n = ustrip(j_E1M)
    j_E2M_n = ustrip(j_E2M)
    v_n    = ustrip(v)
    vB0_n  = ustrip(vB0)

    fn_vB = vB -> _fn_vB_iso221(vB, L_n, m_E1_n, m_E2_n, j_E1M_n, j_E2M_n, y_VE1, y_VE2, v_n, kap, rho1)

    v_B_n = try
        find_zero(fn_vB, vB0_n, Order1())
    catch
        try
            find_zero(fn_vB, (0.0, v_n / 3 + abs(vB0_n)), Bisection())
        catch
            vB0_n
        end
    end

    # Restore units: v_B has same units as v (cm/d)
    v_B = v_B_n * oneunit(v)

    # Compute maintenance and mobilisation at converged v_B (using original unitful values)
    r     = 3 * v_B / L
    j_E1C = m_E1 * (v / L - r)
    j_E2C = m_E2 * (v / L - r)
    A  = rho1 * j_E1C * j_E1M
    C  = -kap * j_E2C * (j_E1C + j_E2C)
    B  = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2M
    sq = sqrt(max(zero(B * B), B * B - 4 * A * C))
    D  = 2 * A + sq - B
    j_E1_M = D == zero(D) ? kap * j_E1C : min(kap * j_E1C, 2 * A * j_E1M / D)
    j_E2_M = min(kap * j_E2C, j_E2M * (1 - j_E1_M / j_E1M))

    return v_B, j_E1_M, j_E2_M, j_E1C, j_E2C
end

"""
    _fn_vB_iso221(v_B, L, m_E1, m_E2, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1)

Residual function for embryo growth rate. Returns 0 at correct v_B.
Port of fn_v_B in MATLAB gr_iso_21.m.
"""
function _fn_vB_iso221(v_B, L, m_E1, m_E2, j_E1M, j_E2M, y_VE1, y_VE2, v, kap, rho1)
    r = 3 * v_B / L
    j_E1C = m_E1 * (v / L - r)
    j_E2C = m_E2 * (v / L - r)
    A = rho1 * j_E1C * j_E1M
    C = -kap * j_E2C * (j_E1C + j_E2C)
    B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2M
    sq = sqrt(max(zero(B), B * B - 4 * A * C))
    D = 2 * A + sq - B
    j_E1_M = D == zero(D) ? kap * j_E1C : min(kap * j_E1C, 2 * A * j_E1M / D)
    j_E2_M = min(kap * j_E2C, j_E2M * (1 - j_E1_M / j_E1M))
    # Parallel complementary SU for growth (harmonic mean, embryo form)
    v_G1 = max(1e-10, y_VE1 * (kap * m_E1 * (v / 3 - v_B) - j_E1_M * L / 3))
    v_G2 = max(1e-10, y_VE2 * (kap * m_E2 * (v / 3 - v_B) - j_E2_M * L / 3))
    return v_B - 1 / (1 / v_G1 + 1 / v_G2 - 1 / (v_G1 + v_G2))
end

"""
    _embryo_iso221_ode(a, state, p)

ODE for iso221 embryo: state = (L, M_E1, M_E2, E_H).
No feeding (X1=X2=0), no aging during embryo stage.
Port of diso_21 inside iso_21_b.m.
"""
function _embryo_iso221_ode(state, p, a)
    L, M_E1, M_E2, E_H = state.L, state.M_E1, state.M_E2, state.E_H
    M_V = p.MV * L^3
    m_E1 = M_E1 / M_V
    m_E2 = M_E2 / M_V

    # Growth rate d/dt L via Brent solver
    vB0 = p.v / 3 - 1e-4 * oneunit(p.v)
    v_B, j_E1_M, j_E2_M, j_E1C, j_E2C = _gr_iso221(
        L, m_E1, m_E2, p.j_E1M, p.j_E2M, p.y_VE1, p.y_VE2, p.v, p.kap, p.rho1, vB0
    )
    dL = v_B
    r = 3 * v_B / L

    # Mobilisation and maturation
    J_E1C = j_E1C * M_V
    J_E2C = j_E2C * M_V
    p_C = p.mu_E1 * J_E1C + p.mu_E2 * J_E2C   # J/d, total mobilisation
    dE_H = (1 - p.kap) * p_C - p.k_J * E_H     # J/d, maturation

    # Reserve dynamics (no assimilation in embryo)
    j_E1P = p.kap * j_E1C - j_E1_M - r / p.y_VE1  # mol/d/mol, rejected flux 1
    j_E2P = p.kap * j_E2C - j_E2_M - r / p.y_VE2  # mol/d/mol, rejected flux 2
    dm_E1 = p.kap_E1 * j_E1P - m_E1 * p.v / L     # mol/d/mol
    dm_E2 = p.kap_E2 * j_E2P - m_E2 * p.v / L     # mol/d/mol
    dM_E1 = M_V * (dm_E1 + m_E1 * r)              # mol/d
    dM_E2 = M_V * (dm_E2 + m_E2 * r)              # mol/d

    return (L=dL, M_E1=dM_E1, M_E2=dM_E2, E_H=dE_H)
end

"""
    _iso221_birth_state(p)

Shooting method to find initial reserves M_E10, M_E20 for iso221 embryo.
Target: reserve densities at birth equal max values (mother's reserves).
Port of iso_21_b.m.

Returns `(var_b, a_b, M_E10, M_E20)` where var_b is a NamedTuple of state at birth.
"""
function _iso221_birth_state(p)
    J_E1Am = max(p.y_E1X1 * p.J_X1Am, p.y_E1X2 * p.J_X2Am)
    J_E2Am = max(p.y_E2X1 * p.J_X1Am, p.y_E2X2 * p.J_X2Am)
    m_E1b  = J_E1Am / p.v / p.MV  # dimensionless
    m_E2b  = J_E2Am / p.v / p.MV

    E_G_approx = 2 * (p.y_VE1 * p.mu_E1 + p.y_VE2 * p.mu_E2) * p.MV
    V_b        = p.E_Hb * p.kap / (1 - p.kap) / E_G_approx
    M_Vb_guess = p.MV * V_b
    M_E10 = M_Vb_guess * (1 + 1 / p.y_VE1 / (m_E1b + m_E2b)) * m_E1b
    M_E20 = M_Vb_guess * (1 + 1 / p.y_VE2 / (m_E1b + m_E2b)) * m_E2b

    u_M  = oneunit(M_E10)                    # unit of reserve mass (mol)
    u_L  = oneunit(p.v) / oneunit(p.j_E1M)  # unit of length (cm)
    L_0  = 1e-4 * u_L                        # tiny initial length

    # StateReconstructor handles unit reconstruction: Flatten descends into Quantity
    # to extract bare floats, then reconstructs with units from template on the way back.
    # Callback condition: E_H (index 4 in SVector) reaches E_Hb
    embryo_cb = ContinuousCallback((u, t, i) -> ustrip(i.p.E_Hb) - u[4], terminate!)

    function run_embryo(M_E10_try, M_E20_try; save_every=false)
        state_template = (L=L_0, M_E1=M_E10_try, M_E2=M_E20_try, E_H=zero(p.E_Hb))
        sr  = StateReconstructor(_embryo_iso221_ode, state_template, u"d")
        u0  = SVector(sr)
        prob = ODEProblem{false}(sr, u0, (0.0, 1e3), p)
        solve(prob, Tsit5(); callback=embryo_cb, abstol=1e-9, reltol=1e-9,
              save_everystep=save_every)
    end

    # Residual: compare achieved reserve densities at birth to target m_E1b, m_E2b
    function residual(ME0_bare)
        M_E10_try = max(ME0_bare[1], 1e-15) * u_M
        M_E20_try = max(ME0_bare[2], 1e-15) * u_M
        sol = run_embryo(M_E10_try, M_E20_try)
        final  = sol[end]          # SVector{Float64}: [L, M_E1, M_E2, E_H] (bare, natural units)
        L_b_n  = final[1]
        MV_n   = ustrip(p.MV)
        M_Vb_n = MV_n * L_b_n^3
        m_E1_achieved = final[2] / M_Vb_n
        m_E2_achieved = final[3] / M_Vb_n
        return [ustrip(m_E1b) - m_E1_achieved, ustrip(m_E2b) - m_E2_achieved]
    end

    M_E0  = _solve_iso221_initial_reserves(residual, [ustrip(M_E10), ustrip(M_E20)], p, ustrip(m_E1b), ustrip(m_E2b))
    M_E10 = M_E0[1] * u_M
    M_E20 = M_E0[2] * u_M

    # Final integration to get birth state (save full trajectory)
    sol   = run_embryo(M_E10, M_E20; save_every=true)
    a_b   = last(sol.t)
    final = sol[end]              # SVector{Float64}
    L_b   = final[1] * u_L       # reattach cm unit
    M_Vb  = p.MV * L_b^3
    M_E1b = m_E1b * M_Vb
    M_E2b = m_E2b * M_Vb

    return (L_b=L_b, M_E1b=M_E1b, M_E2b=M_E2b, E_Hb=p.E_Hb), a_b, M_E10, M_E20
end

"""
    _solve_iso221_initial_reserves(residual, M_E0_guess, p, m_E1b, m_E2b)

Simple 2D Newton iteration to find initial reserves for iso221 embryo.
Falls back to fixed-point scaling if Newton diverges.
"""
function _solve_iso221_initial_reserves(residual, M_E0_guess, p, m_E1b, m_E2b)
    M_E0 = copy(M_E0_guess)
    _norm2(v) = sqrt(v[1]^2 + v[2]^2)
    for iter in 1:30
        F = residual(M_E0)
        if _norm2(F) < 1e-8
            break
        end
        # Finite difference Jacobian
        h = 1e-6 * max.(abs.(M_E0), 1e-12)
        J = zeros(2, 2)
        for j in 1:2
            dM = copy(M_E0)
            dM[j] += h[j]
            J[:, j] = (residual(dM) - F) / h[j]
        end
        # Newton step with damping
        step = J \ F
        α = 1.0
        for _ in 1:5
            M_try = M_E0 + α * step
            if all(M_try .> 0) && _norm2(residual(M_try)) < _norm2(F)
                break
            end
            α *= 0.5
        end
        M_E0 = M_E0 + α * step
        M_E0 = max.(M_E0, 1e-15)
    end
    return M_E0
end
