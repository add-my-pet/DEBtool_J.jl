function compute_lifespan(e::AbstractEstimator, pars, l_b)
    (; h_a, k_M) = pars
    # TODO this merge is awful fix and explain ha/h_a
    pars_tm = merge(pars, (; ha=h_a / k_M^2))  # compose parameter vector at T_ref
    (; t_m) = scaled_mean_age(Ultimate(), e, pars_tm, l_b) # -, scaled mean life span at T_ref
    am = t_m / k_M
    return am
end

# TODO: put parameters in objects so this isn't needed
# ending params with _m is bad and has multiple meanings
function compute_male_params(model::DEBOrganism, par)
    # TODO better detection here
    if haskey(par, :z_m)
        (; kap, z_m, p_M, w_E, w_V, v, E_G, k_M, kap, y_E_V, v_Hpm) = par
        p_Am_m = z_m * p_M / kap           # J/d.cm^2, {p_Am} spec assimilation flux
        E_m_m = p_Am_m / v                 # J/cm^3, reserve capacity [E_m]
        g = E_G / (kap * E_m_m)            # -, energy investment ratio
        m_Em_m = y_E_V * E_m_m / E_G       # mol/mol, reserve capacity
        w = m_Em_m * w_E / w_V             # -, contribution of reserve to weight
        L_m = v / k_M / g                  # cm, max struct length
        return (; w, g, L_m, v_Hp=v_Hpm)
    else
        (;) 
    end
end

# TODO
# function compute_univariate(::Weights, at::Times, pars, Lw_i, Lw_b)
# end
# function compute_univariate(::Weights, at::Lengths, pars, Lw_i, Lw_b)
# end
# function compute_univariate(::ReprodRates, at::Temperatures, pars, Lw_i, Lw_b)
# end
compute_univariate(e::AbstractEstimator, o::DEBOrganism, u::Univariate, pars, lifestages_state, TC) =
    compute_univariate(e, o, u.dependent, u.independent, pars, lifestages_state, TC)
function compute_univariate(e::AbstractEstimator, o::DEBOrganism, dependent::Lengths, independent::Times, pars, lifestages_state, TC)
    (; k_M, f, g) = pars
    Lw_b = lifestages_state[Birth()].Lw
    Lw_i = lifestages_state[Female(Ultimate())].Lw
    # TODO explain these equations
    rT_B = TC * k_M / 3 / (oneunit(f) + f / g)
    return Lw_i .- (Lw_i .- Lw_b) .* exp.(-rT_B .* independent.val)
end
