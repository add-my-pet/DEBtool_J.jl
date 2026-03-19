
# Growth rate solver for the plant DEB model
# Port of DynamicEnergyBudgets.jl src/components/rate.jl
#
# Solves: y_V_E * (κsoma * j_E(r) - j_E_mai * TC) - r = 0
# where j_E(r) = synthesizing_unit(m_C*(kC*TC - r)*y_E_C, m_N*(kN*TC - r)*y_E_N)
# Uses Secant method from Roots.jl (same tolerance as DynamicEnergyBudgets.jl: 1e-10)

"""
    _rate_plant(m_C, m_N, kC_TC, kN_TC, j_E_mai_TC, y_E_C, y_E_N, y_V_E, κsoma)

Find the specific growth rate `r` (1/d) for one organ.

Arguments are all temperature-corrected where required:
- `m_C`, `m_N`: relative reserves (mol/mol structure)
- `kC_TC`, `kN_TC`: temperature-corrected turnover rates (1/d)
- `j_E_mai_TC`: temperature-corrected specific maintenance rate (1/d)
- `y_E_C`, `y_E_N`: yields from C- and N-reserve to general reserve
- `y_V_E`: yield from general reserve to structure
- `κsoma`: fraction of catabolised reserve to soma

Returns `(r, alive)` where `alive = true` if a positive root was found.
"""
function _rate_plant(m_C, m_N, kC_TC, kN_TC, j_E_mai_TC, y_E_C, y_E_N, y_V_E, κsoma)
    one_r = oneunit(kC_TC)
    r0 = -2 * one_r
    r1 =  1 * one_r

    # rate_formula: y_V_E * (κsoma * j_E(r) - j_E_mai) - r = 0
    function f(r)
        j_C = m_C * (kC_TC - r)
        j_N = m_N * (kN_TC - r)
        j_E = _su_plant(j_C * y_E_C, j_N * y_E_N)
        y_V_E * (κsoma * j_E - j_E_mai_TC) - r
    end

    atol = one_r * 1e-10
    r, info = _find_zero_secant(f, r0, r1, atol, 200)

    if info != :converged || r < zero(r)
        return zero(r), false
    end
    return r, true
end

"""
    _su_plant(j_Ea, j_Eb)

ParallelComplementarySU: merge two substrate fluxes stoichiometrically.
Formula from DynamicEnergyBudgets.jl synthesizing_units.jl.
"""
function _su_plant(j_Ea, j_Eb)
    denom = j_Ea^2 + j_Eb^2 + j_Ea * j_Eb
    denom > zero(denom) ? j_Ea * j_Eb * (j_Ea + j_Eb) / denom : zero(j_Ea)
end

"""
    _stoich_merge_plant(Jv, Jw, yv, yw)

Merge two reserve catabolism fluxes into general reserve via ParallelComplementarySU.
Returns (J_v_rej, J_w_rej, J_Evw).
"""
function _stoich_merge_plant(Jv, Jw, yv, yw)
    JEvw = _su_plant(Jv * yv, Jw * yw)
    (Jv - JEvw / yv), (Jw - JEvw / yw), JEvw
end

"""
    _find_zero_secant(f, x0, x1, atol, maxiters)

Simple secant method root-finder. Returns `(root, :converged)` or `(x1, :failed)`.
"""
function _find_zero_secant(f, x0, x1, atol, maxiters)
    f0 = f(x0)
    f1 = f(x1)
    for _ in 1:maxiters
        abs(f1) < atol && return x1, :converged
        df = f1 - f0
        abs(df) < atol * 1e-10 && return x1, :failed   # stalled: step in f too small
        x2 = x1 - f1 * (x1 - x0) / df
        x0, f0 = x1, f1
        x1, f1 = x2, f(x2)
    end
    return x1, :failed
end
