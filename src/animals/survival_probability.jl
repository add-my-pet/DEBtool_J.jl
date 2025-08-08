"""
    compute_survival_probability(at::Birth, model, pars; kw...)

Gets survival probability at birth and scaled variables

Obtains survival probability at birth by integration survival prob over scaled age. All variables/parameters  are dimensionless.
Called by ssd functions for statistics at population level; ρ_N is scaled spec pop growth rate, h_B0b, scaled background hazard between 0 and b.

# Arguments

- model: an `AbstractDEBOrganism`
- pars: `NamedTuple` with parameters: g k v_Hb h_a S_G h_B0b ρ_N f. 
    - `h_B0b`: scaled background hazard.
    - `f`: scalar with scaled reserve density at birth (usual default f = 1.0)

# Output

A `NamedTuple` with fields:

TODO: make the math real latex
- `S_b`: scalar with survival probability at birth
- `q_b`: scalar with scaled acceleration at birth: `q(b) / k_M^2`
- `h_Ab`: scalar scaled hazard at birth: `h_A(b) / k_M`
- `τ_b`: scalar scaled age at birth
- `τ_0b`: \\int_0^τ_b exp(-ρ_N * τ) S(τ) dτ
- `u_E0`: scaled initial reserve
- `l_b`: scaled length at birth
- `info`: boolean with success `true` or failure `false`

# Remarks

Was `get_Sb` and `get_Sb_foetus`
 
To unscale:

- `q_b` by multiplying with `kT_M^2`
- `h_Ab` with `kT_M`
- `τ_b` and `τ_0b` with `1 / k_M`
- `l3_0b` with `kT_M * L_m^3`
- `u_E_0b` with `kT_M * {p_Am}*v^2/k_M^3/g^2`
"""
function compute_survival_probability(at::Birth, model, p;
    abstol=1e-9, reltol=1e-9, kw...
)
    compute_survival_probability(at, model.mode, p; abstol, reltol, kw...)
end
function compute_survival_probability(at::Birth, mode::typeof(std()), p; 
    solver=Tsit5(), kw...
)
    # TODO is this s_G or S_G ??
    (; g, k, v_Hb, h_a, s_G, h_B0b, ρ_N, f) = p
    eb = 1.0
    l_b, info = compute_length(at, p; eb)
    u_E0 = get_ue0(mode, p, eb, l_b)

    # birth event where v_H > v_Hb
    function birth(ulvqhS, τ, integrator)
        v_H = ulvqhS[3] 
        # TODO: make sure this works
        return v_H - v_Hb > zero(v_H)
    end
    callback = ContinuousCallback(birth, terminate!)

    # TODO: why 1.001, 1e-5 and 1.0
    ulvqhS_0 = @SVector[1.001 * u_E0, 1e-5, 0.0, 0.0, 0.0, 1.0, 0.0] # initial value
    tspan = (0.0, 1e8)
    problem = ODEProblem(d_ulvqhS, ulvqhS_0, tspan, p)
    # try
        sol = solve(problem, solver; 
            isoutofdomain=(u, p, t) -> any(<(0), u), 
            callback, kw...
        )
    # catch
        # sol = solve(problem, solver; callback, kw...);
    # end
    τ_b = sol.t[end] # TODO get τ from sol
    return _survival_probability_output(sol; τ_b, u_E0, l_b, info)
end
function compute_survival_probability(at::Birth, mode::typeof(stf()), p; kw...)
    (; u_E0, l_b, τ_b, info) = get_ue0(mode, p)

    # TODO: why 1e-9 and 1.0
    elvqhS_0 = @SVector[f, 1e-9, 0.0, 0.0, 0.0, 1.0, 0.0] # initial value
    tspan = (0, τ_b)
    problem = ODEProblem(d_ulvqhS, ulvqhS_0, tspan, pars)
    sol = solve(problem, solver; nonnegative=ones(10), kw...)

    return _survival_probability_output(sol; τ_b, u_E0, l_b, info)
end

function _survival_probability_output(sol; τ_b, u_E0, l_b, info)
    u = sol.u
    q_b = max(0, u[end][4])
    h_Ab = max(0, u[end][5])
    S_b = max(0, u[end][6])
    τ_0b = u[7]
    return (; S_b, q_b, h_Ab, τ_b, τ_0b, u_E0, l_b, info)
end


## subfunctions

# ode's for change of embryo state
function d_ulvqhS(ulvqhS::AbstractVector, p::NamedTuple, τ::Number)
    (; g, k, v_Hb, h_a, s_G, h_B0b, ρ_N) = p
    u_E, l, v_H, q, h, S = ulvqhS

    q = max(zero(q), q)
    h = max(zero(h), h)
    e = g * u_E / l^3

    # TODO explain these equations line by line
    du_E = -u_E * l^2 * (g + l) / (u_E + l^3)
    dl = (g * u_E - l^4) / (u_E + l^3) / 3
    dv_H = u_E * l^2 * (g + l) / (u_E + l^3) - k * v_H
    ρ = (e / l - 1) / (1 + e / g)
    dq = g * u_E * (q * s_G + h_a / l^3) * (g / l - ρ) - ρ * q
    dh = q - ρ * h
    dS = -(h + h_B0b) * S

    dl0 = S * exp(-ρ_N * τ)

    return @SVector[du_E, dl, dv_H, dq, dh, dS, dl0]
end
# Foetal
function d_elvqhS(elvqhS::AbstractVector, p::NamedTuple, τ::Number)
    (; g, k, v_Hb, h_a, s_G, h_B0b, ρ_N) = p
    e, l, v_H, q, h, S = elvqhS
    q = max(zero(q), q)
    h = max(zero(h), h)

    # TODO explain these
    de = 0 # no change in scaled reserve density during foetal development
    dl = (e - l) / (e + g) * g / 3
    dv_H = e * l^2 * (g + l) / (g + e) - k * v_H
    r = (e / l - 1) / (1 + e / g)
    dq = e * (q * l^3 * s_G + h_a) * (g / l - r) - r * q
    dh = q - r * h
    dS = -(h + h_B0b) * S

    dl0 = S * exp(-ρ_N * τ);

    return @SVector[de, dl, dv_H, dq, dh, dS, dl0]
end
