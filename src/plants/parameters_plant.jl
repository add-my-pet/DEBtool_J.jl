
# Parameters and compound parameters for the Plant DEB model.
# Based on DynamicEnergyBudgets.jl (BiophysicalEcology/DynamicEnergyBudgets.jl)
# Reference parameter values from DEBplant isomorph.jl (rafaqz/DEBplant)

"""
    compound_parameters(model::DEBAnimal{<:Plant}, p::NamedTuple)

Compute compound parameters for the plant model.

Evaluates photosynthesis and N-uptake at reference environmental conditions
(stored as `*_ref` parameters) with TC = 1 to find equilibrium reserve densities.

Returns:
- `m_Cm`: dimensionless, max C-reserve density (mol C / mol structure)
- `m_Nm`: dimensionless, max N-reserve density (mol N / mol structure)
"""
function compound_parameters(model::DEBAnimal{<:Plant}, p::NamedTuple)
    # TC = 1.0 at reference temperature
    j_C_photo = _kooijman_photosynthesis(
        p.J_L_ref, p.X_C_ref, p.X_O_ref, 1.0,
        p.j_L_Amax, p.J_L_K, p.j_C_Amax, p.K_C,
        p.j_O_Amax, p.K_O, p.k_C_binding, p.k_O_binding,
        p.SLA, p.w_V,
    )
    j_N_up = _kooijman_N_uptake(
        p.X_NH_ref, p.X_NO_ref, p.X_H_ref, 1.0,
        p.j_NH_Amax, p.K_NH, p.j_NO_Amax, p.K_NO, p.K_H, p.ρNO,
    )
    # Max reserve densities at equilibrium with reference conditions (r ≈ 0).
    # uconvert(NoUnits) collapses the mixed-unit ratio (e.g. μmol*d/(mol*s)) to a
    # plain Float64, so that m_Cm * V [mol] → C [mol] without unit entanglement.
    m_Cm = uconvert(Unitful.NoUnits, j_C_photo / p.k)
    m_Nm = uconvert(Unitful.NoUnits, j_N_up    / p.k)
    return (; m_Cm, m_Nm)
end

"""
    filter_params(model::DEBAnimal{<:Plant}, p::NamedTuple)

Parameter filter for the plant model. Checks key parameters are positive.
"""
function filter_params(model::DEBAnimal{<:Plant}, p::NamedTuple)
    positive_pars = (p.k, p.j_E_mai, p.y_V_E, p.κsoma, p.M_VRb, p.M_VSb, p.M_VSp)
    count(x -> x <= zero(x), positive_pars) > 0 && return false, SomeNegativeOrZero
    return true, Pass
end
