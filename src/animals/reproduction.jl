
"""
    compute_reproduction_rate(estimator, o::DEBAnimal, par, transitions)

Calculates the reproduction rate in number of eggs per time
for an individual given transition.

## Returns

- `R: n-vector with reproduction rates
- `UE0`: scalar with scaled initial reserve
- `info`: indicator with 1 for success, 0 otherwise
"""
compute_reproduction_rate(e::AbstractEstimator, o::DEBAnimal, p::NamedTuple, trans::Transitions) =
    compute_reproduction_rate(lifecycle(o)[1][1], e, o, p, trans)
function compute_reproduction_rate(stage, e::AbstractEstimator, model::DEBAnimal, p::NamedTuple, trans::Transitions)
    (; κ, κ_R, g, f, k_J, k_M, L_T, v, U_Hb, U_Hp) = p

    L = trans[Ultimate()].L

    L_m = v / (k_M * g) # maximum length
    k = k_J / k_M       # -, maintenance ratio

    l_b = trans[Birth()].l
    l_p = trans[Puberty()].l
    L_b = l_b * L_m
    L_p = l_p * L_m # structural length at birth, puberty

    UE0 = _reprod_init(stage, model, p, L_b, l_b)

    SC = f * L .^ 3 .* (g ./ L + (1 + L_T ./ L) / L_m) / (f + g)
    SR = (1 - κ) * SC - k_J * U_Hp
    R = (L >= L_p) .* κ_R .* SR ./ UE0 # set reprod rate of juveniles to zero

    return R
end

# TODO this should just be initial_scaled_reserved, but Foetus needs work
function _reprod_init(stage::Foetus, model, p, L_b, l_b)
    (; f, g, v) = p
    return L_b^3 * (f + g) / v * (1 + 3 * l_b / 4 / f) # d.cm^2, scaled cost per foetus
end
function _reprod_init(stage::Embryo, model, p, L_b, l_b)
    (; UE0) = initial_scaled_reserve(model.mode, p, l_b)
    return UE0
end

"""
    gestation(pars::NamedTuple, τ_b, TC)

Calculate gestation time given scaled time to birth and temperature. 
"""
function gestation(pars::NamedTuple, τ_b, TC)
    (; t_0, k_M) = pars
    t_0 + τ_b / k_M / TC  # d, gestation time at f and T
end
