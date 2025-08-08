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
function compute_male_params(model::DEBAnimal, par)
    # TODO better detection here
    if haskey(par, :z_m)
        (; κ, z_m, p_M, w_E, w_V, v, E_G, k_M, κ, y_E_V, v_Hpm) = par
        p_Am_m = z_m * p_M / κ           # J/d.cm^2, {p_Am} spec assimilation flux
        E_m_m = p_Am_m / v                 # J/cm^3, reserve capacity [E_m]
        g = E_G / (κ * E_m_m)            # -, energy investment ratio
        m_Em_m = y_E_V * E_m_m / E_G       # mol/mol, reserve capacity
        ω = m_Em_m * w_E / w_V             # -, contribution of reserve to weight
        L_m = v / k_M / g                  # cm, max struct length
        return (; ω, g, L_m, v_Hp=v_Hpm)
    else
        (;) 
    end
end

# TODO
# function compute_variate(::Weights, at::Time, pars, Lw_i, Lw_b)
# end
# function compute_variate(::Weights, at::Length, pars, Lw_i, Lw_b)
# end
# function compute_variate(::ReprodRates, at::Temperature, pars, Lw_i, Lw_b)
# end
compute_variate(e::AbstractEstimator, o::DEBAnimal, us::Tuple, pars, transition_state, TC) =
    map(us) do u
        compute_variate(e, o, u, pars, transition_state, TC)
    end
function compute_variate(e::AbstractEstimator, o::DEBAnimal, u::AtTemperature, pars, transition_state, TC_main)
    TC_data = tempcorr(temperatureresponse(o), u.t)
    compute_variate(e, o, u.x, pars, transition_state, TC_data)
end
compute_variate(e::AbstractEstimator, o::DEBAnimal, u::Univariate, pars, transition_state, TC) =
    compute_variate(e, o, u.independent, u.dependent, pars, transition_state, TC)
function compute_variate(e::AbstractEstimator, o::DEBAnimal, u::Multivariate, pars, transition_state, TC)
    map(u.dependents) do d
        compute_variate(e, o, u.independent, d, pars, transition_state, TC)
    end
end
function compute_variate(e::AbstractEstimator, o::DEBAnimal, u::Multivariate{<:Temperature}, pars, transition_state, TC)
    TCs = tempcorr(temperatureresponse(o), u.independent.val)
    map(u.dependents) do d
        compute_variate(e, o, u.independent, d, pars, transition_state, TC)
    end
end
function compute_variate(e::AbstractEstimator, o::DEBAnimal, independent::Time, dependent::Length, pars, transition_state, TC)
    (; k_M, f, g) = pars
    Lw_b = transition_state[Birth()].Lw
    Lw_i = transition_state[Ultimate()].Lw
    # TODO explain these equations
    rT_B = TC * k_M / 3 / (oneunit(f) + f / g)
    EWw = Lw_i .- (Lw_i .- Lw_b) .* exp.(-rT_B .* independent.val)
    return EWw
end

function compute_variate(e::AbstractEstimator, o::DEBAnimal, independent::Time, dependent::WetWeight, pars, transition_state, TC)
    (; f, k_M, L_m, v, ω) = pars
    L_b = transition_state[Birth()].L # cm, length at birth, ultimate
    L_i = transition_state[Ultimate()].L
    # time-weight 
    # f = f_tW TODO: how to allow a specific f for variate data
    ir_B = 3 / k_M + 3 * f * L_m / v
    rT_B = TC / ir_B     # d, 1/von Bert growth rate
    return (L_i .- (L_i .- L_b) .* exp.(-rT_B .* independent.val)) .^ 3 .* (oneunit(f) + f * ω) # g, wet weight
end
