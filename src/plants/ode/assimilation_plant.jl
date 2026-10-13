
# Assimilation functions for the plant DEB model.
# Ports of DynamicEnergyBudgets.jl src/components/assimilation.jl
#
# Two formulations:
#   Shoot: KooijmanSLAPhotosynthesis (light + CO2 + O2 with competitive binding)
#   Root:  KooijmanNH4_NO3Assim     (ammonia + nitrate with water-potential correction)

"""
    half_sat(rate, K, X)

Monod (Michaelis-Menten) half-saturation kinetics: `rate * X / (K + X)`.
"""
half_sat(rate, K, X) = rate * X / (K + X)

"""
    _kooijman_photosynthesis(J_L_F, X_C, X_O, TC,
                              j_L_Amax, J_L_K, j_C_Amax, K_C, j_O_Amax, K_O,
                              k_C_binding, k_O_binding, SLA, w_V)

Kooijman SLA photosynthesis model (exact port from DynamicEnergyBudgets.jl).
Returns specific C-assimilation rate (mol C / mol structure / d), or zero if negative.

Arguments:
- `J_L_F`: photon flux (mol/m²/d)
- `X_C`, `X_O`: CO2 and O2 concentrations (mol/L)
- `TC`: temperature correction factor (dimensionless, applied to C and O fluxes, NOT light)
- `j_L_Amax`: max specific light uptake (mol/m²/d per mol·structure)
- `J_L_K`: light half-saturation (mol/m²/d)
- `j_C_Amax`: max specific CO2 uptake (mol/m²/d per mol·structure)
- `K_C`: CO2 half-saturation (mol/L)
- `j_O_Amax`: max specific O2 uptake (mol/m²/d per mol·structure)
- `K_O`: O2 half-saturation (mol/L)
- `k_C_binding`, `k_O_binding`: competitive binding scaling rates
- `SLA`: specific leaf area (m²/kg)
- `w_V`: molar weight of structure (g/mol = kg/kmol; convert: g/mol = 1e-3 kg/mol)
"""
function _kooijman_photosynthesis(J_L_F, X_C, X_O, TC,
                                   j_L_Amax, J_L_K, j_C_Amax, K_C,
                                   j_O_Amax, K_O, k_C_binding, k_O_binding,
                                   SLA, w_V)
    # mass_area_coef converts from per-area to per-mol-structure:
    # w_V [g/mol] * SLA [m²/kg] = w_V * SLA * 1e-3 [m²/mol] → dimensionless rate converter
    mass_area_coef = w_V * SLA

    # Light uptake (not temperature-dependent)
    j1_l = half_sat(j_L_Amax, J_L_K, J_L_F) * mass_area_coef / 2

    # CO2 and O2 uptake (temperature-dependent)
    j1_c = half_sat(j_C_Amax, K_C, X_C) * mass_area_coef * TC
    j1_o = half_sat(j_O_Amax, K_O, X_O) * mass_area_coef * TC

    # Photorespiration: O2 competes with CO2 for binding sites
    bound_c = j1_c / k_C_binding
    bound_o = j1_o / k_O_binding

    # Net C intake after photorespiration
    j_c_net = j1_c - j1_o
    j1_co = j1_c + j1_o

    # Light-limitation factor
    co_l = j1_co / j1_l - j1_co / (j1_l + j1_co)

    # Specific photosynthesis rate (per mol structure)
    j_C_photo = j_c_net / (1 + bound_c + bound_o + co_l)

    return max(j_C_photo, zero(j_C_photo))
end

"""
    _kooijman_N_uptake(X_NH, X_NO, X_H, TC,
                        j_NH_Amax, K_NH, j_NO_Amax, K_NO, K_H, ρNO)

Kooijman NH4/NO3 nitrogen assimilation with water-potential correction.
Returns specific N-assimilation rate (mol N / mol structure / d).

The water correction modifies effective half-saturation via:
  `K1_NH = half_sat(K_NH, K_H, X_H)` (K_H = water half-saturation)
"""
function _kooijman_N_uptake(X_NH, X_NO, X_H, TC,
                              j_NH_Amax, K_NH, j_NO_Amax, K_NO, K_H, ρNO)
    # Water-modified half-saturation constants
    K1_NH = half_sat(K_NH, K_H, X_H)
    K1_NO = half_sat(K_NO, K_H, X_H)

    # Specific uptake rates (temperature-dependent)
    J1_NH = half_sat(j_NH_Amax, K1_NH, X_NH) * TC
    J_NO  = half_sat(j_NO_Amax, K1_NO, X_NO) * TC

    return J1_NH + ρNO * J_NO
end
