# Specific growth rate solver for iso221 model
# Port of MATLAB DEBtool_M/iso_21/sgr_iso_21.m
# Reference: Kooijman DEB3 book section 5.2.7.1

"""
    _sgr_iso221(m_E1, m_E2, j_E1S, j_E2S, y_VE1, y_VE2, mu_EV, k_E, kap, rho1, r0)

Specific growth rate for isomorph with 2 reserves, allowing for shrinking.
Uses Newton-Raphson with continuation (r0 = previous step value).

# Arguments
- `m_E1, m_E2`:   mol/mol, reserve densities
- `j_E1S, j_E2S`: mol/d/mol, total specific somatic maintenance costs
- `y_VE1, y_VE2`: mol/mol, yield of structure on each reserve
- `mu_EV`:        -, ratio mu_E1/mu_V, used for shrinking flux
- `k_E`:          1/d, reserve turnover rate v/L
- `kap`:          -, allocation fraction to soma
- `rho1`:         -, preference for reserve 1 in maintenance (≈0 for protein reserve)
- `r0`:           1/d, initial guess (use previous step value for continuation)

# Returns
Tuple `(r, j_E1_S, j_E2_S, j_E1C, j_E2C, info)`:
- `r`: 1/d, specific growth rate (negative = shrinking)
- `j_E1_S, j_E2_S`: actual specific somatic maintenance from each reserve
- `j_E1C, j_E2C`: specific mobilisation fluxes
- `info`: true if converged, false otherwise
"""
function _sgr_iso221(m_E1, m_E2, j_E1S, j_E2S, y_VE1, y_VE2, mu_EV, k_E, kap, rho1, r0)
    r = r0
    i = 0
    n_max = 5000
    info = true
    tol = 1e-10 * oneunit(k_E)
    H = oneunit(k_E)  # start above tolerance

    while abs(H) > tol && i < n_max
        # Mobilisation fluxes: j_EiC = m_Ei * (k_E - r)
        j_E1C = m_E1 * (k_E - r)
        j_E2C = m_E2 * (k_E - r)

        # Maintenance SU allocation (parallel complementary with preference rho1 for reserve 1)
        # From DEB3 section 5.2.7 and sgr_iso_21.m
        A = rho1 * j_E1C * j_E2S^2 / j_E1S
        C = -kap * j_E2C * (j_E1C + j_E2C)
        B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2S
        sq = sqrt(max(zero(B * B), B * B - 4 * A * C))
        D = 2 * A + sq - B

        j_E1_S = if D == zero(D)
            kap * j_E1C
        else
            min(kap * j_E1C, 2 * A * j_E1S / D)
        end
        j_E2_S = min(kap * j_E2C, j_E2S * (1 - j_E1_S / j_E1S))

        # Growth fluxes allocated to growth SU
        j_E1G = kap * j_E1C - j_E1_S
        j_E2G = kap * j_E2C - j_E2_S

        # Specific shrinking flux (positive when maintenance cannot be met)
        j_V_S = j_E1S * (1 - j_E1_S / j_E1S - j_E2_S / j_E2S) * mu_EV

        j_V1G = y_VE1 * j_E1G
        j_V2G = y_VE2 * j_E2G

        if j_V1G <= zero(j_V1G) || j_V2G <= zero(j_V2G)
            # Shrinking: no growth, r = -j_V_S
            r = -j_V_S
            H = zero(r)
        else
            # Newton-Raphson step: H = r + j_V_S - harmonic_mean_SU
            H = r + j_V_S - 1 / (1 / j_V1G + 1 / j_V2G - 1 / (j_V1G + j_V2G))

            # Analytical derivative dH/dr (from sgr_iso_21.m)
            dA = -rho1 * m_E1 * j_E2S^2 / j_E1S
            dC = kap * m_E2 * (j_E1C + j_E2C) + kap * j_E2C * (m_E1 + m_E2)
            dB = dC - (m_E1 + (1 - rho1) * m_E2) * j_E2S

            dj_E1_S = if j_E1_S == kap * j_E1C
                -kap * m_E1
            else
                j_E1_S * (dA / A - (2 * dA + (B * dB - 2 * dA * C - 2 * A * dC) / sq - dB) / D)
            end
            dj_E2_S = if j_E2_S == kap * j_E2C
                -kap * m_E2
            else
                -dj_E1_S * j_E2S / j_E1S
            end

            dj_E1G = -kap * m_E1 - dj_E1_S
            dj_E2G = -kap * m_E2 - dj_E2_S
            # dj_V_S is dimensionless (derivative of rate w.r.t. rate); use zero(dj_E1G)
            dj_V_S = (j_V_S > zero(j_V_S)) ? j_E1S * (dj_E1_S / j_E1S + dj_E2_S / j_E2S) * mu_EV : zero(dj_E1G)
            dj_V1G = y_VE1 * dj_E1G
            dj_V2G = y_VE2 * dj_E2G

            dH_inner = dj_V1G / j_V1G^2 + dj_V2G / j_V2G^2 - (dj_V1G + dj_V2G) / (j_V1G + j_V2G)^2
            dH = 1 - dj_V_S - dH_inner * (r + j_V_S - H)^2

            r = r - H / dH
        end

        i += 1
    end

    if i == n_max || isnan(r) || !isreal(r)
        info = false
        @warn "sgr_iso221: no convergence in $i steps; norm = $H; r = $r"
        r = 1e-20 * oneunit(k_E)
        # Recompute final maintenance values at r=1e-20
        j_E1C = m_E1 * (k_E - r)
        j_E2C = m_E2 * (k_E - r)
        A = rho1 * j_E1C * j_E2S^2 / j_E1S
        C = -kap * j_E2C * (j_E1C + j_E2C)
        B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2S
        sq = sqrt(max(zero(B * B), B * B - 4 * A * C))
        D = 2 * A + sq - B
        j_E1_S = min(kap * j_E1C, 2 * A * j_E1S / D)
        j_E2_S = min(kap * j_E2C, j_E2S * (1 - j_E1_S / j_E1S))
    else
        # Recompute final mobilisation fluxes at converged r
        j_E1C = m_E1 * (k_E - r)
        j_E2C = m_E2 * (k_E - r)
        A = rho1 * j_E1C * j_E2S^2 / j_E1S
        C = -kap * j_E2C * (j_E1C + j_E2C)
        B = C + (j_E1C + (1 - rho1) * j_E2C) * j_E2S
        sq = sqrt(max(zero(B * B), B * B - 4 * A * C))
        D = 2 * A + sq - B
        j_E1_S = if D == zero(D)
            kap * j_E1C
        else
            min(kap * j_E1C, 2 * A * j_E1S / D)
        end
        j_E2_S = min(kap * j_E2C, j_E2S * (1 - j_E1_S / j_E1S))
    end

    return r, j_E1_S, j_E2_S, j_E1C, j_E2C, info
end
