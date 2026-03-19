
# ODE system for the Plant DEB model.
# Two-organ (shoot + root), 2-reserve (C, N) isomorph plant with CatabolismCNshared.
#
# Port of:
#   MATLAB: C:\git\DEBtool_M\plant\flux_plant.m
#   Julia:  https://github.com/BiophysicalEcology/DynamicEnergyBudgets.jl
#   Example: https://github.com/rafaqz/DEBplant (models/isomorph.jl)
#
# State (6 variables):
#   Shoot: V_S (structure), C_S (C-reserve), N_S (N-reserve)
#   Root:  V_R (structure), C_R (C-reserve), N_R (N-reserve)
#
# For CatabolismCNshared (single turnover rate k for both C and N), the general
# reserve E is an instantaneous flux (SU merge of C and N catabolism) rather than
# an accumulated state variable. dE/dt = 0 by construction of the rate equation.
#
# Lifecycle (uses same types as iso221 / std):
#   Seed (Embryo) → Germination (Birth, when V_R ≥ M_VRb)
#   Seedling (Juvenile) → Reproduction (Puberty, when V_S ≥ M_VSp)
#   Adult → Ultimate

# -------------------------------------------------------------------------
# State initialisation

"""
    initialise_state(o::DEBAnimal{<:Plant}, mbe::MetabolismBehaviorEnvironment)

Start simulation from germination state to avoid stiffness from tiny initial volume.
The Birth() callback fires immediately (V_R ≥ M_VRb at t=0), then Juvenile runs.
"""
function initialise_state(o::DEBAnimal{<:Plant}, mbe::MetabolismBehaviorEnvironment)
    p = stripparams(mbe.par)
    p = merge(p, compound_parameters(o, p))
    germ = _plant_germination_state(p)
    return (;
        V_S = germ.V_S,
        C_S = germ.C_S,
        N_S = germ.N_S,
        V_R = germ.V_R,
        C_R = germ.C_R,
        N_R = germ.N_R,
    )
end

# -------------------------------------------------------------------------
# Main ODE dispatch

"""
    d_sim(state, tr::AbstractTransition, metabolism::DEBAnimal{<:Plant}, me, t)

Plant DEB ODE. State: (V_S, C_S, N_S, V_R, C_R, N_R).

Per-organ dynamics (CatabolismCNshared):
  - C and N catabolized at rate k*TC - r_organ
  - SU merge (ParallelComplementarySU) → general reserve flux j_E
  - Growth rate r solved from: y_V_E*(κsoma*j_E - j_E_mai*TC) - r = 0
  - Passive translocation: rejected C from each organ → other organ's C reserve
                           rejected N from each organ → other organ's N reserve

Port of MATLAB flux_plant.m / DynamicEnergyBudgets.jl.
"""
function d_sim(state, tr::AbstractTransition, metabolism::DEBAnimal{<:Plant}, me, t)
    (; environment, par) = me
    (; V_S, C_S, N_S, V_R, C_R, N_R) = state

    # Clip reserves to ≥ 0 to avoid solver drift into negative territory
    V_S = max(V_S, zero(V_S));  C_S = max(C_S, zero(C_S));  N_S = max(N_S, zero(N_S))
    V_R = max(V_R, zero(V_R));  C_R = max(C_R, zero(C_R));  N_R = max(N_R, zero(N_R))

    # Unpack parameters
    (; j_E_mai, y_V_E, y_E_C, y_E_N, κsoma, k,
       j_C_Amax, J_L_K, j_L_Amax, K_C, j_O_Amax, K_O,
       k_C_binding, k_O_binding, SLA, w_V,
       j_NH_Amax, K_NH, j_NO_Amax, K_NO, K_H, ρNO,
       M_VSd, M_VRd, M_VRb) = par

    # Temperature correction
    TC = getattime(environment, :tempcorrection, t)
    kTC = k * TC            # temperature-corrected turnover rate
    j_E_mai_TC = j_E_mai * TC

    # Environmental inputs
    food = getattime(environment, :food, t)
    J_L_F = food.J_L      # photon flux (mol/m²/d)
    X_C   = food.X_C      # CO2 concentration (mol/L)
    X_O   = food.X_O      # O2 concentration (mol/L)
    X_NH  = food.X_NH     # ammonia (mol/L)
    X_NO  = food.X_NO     # nitrate (mol/L)
    X_H   = food.X_H      # water (mol/L, for N uptake water correction)

    # Seed stage: no assimilation until V_R reaches M_VRb
    in_seed = V_R < par.M_VRb

    # ---- SHOOT organ ----
    # Isomorphic scaling: specific surface area ∝ V^(-1/3) (normalised by reference mass M_VSd)
    scaling_S = V_S > zero(V_S) ? (V_S / M_VSd)^(-one(V_S)/3) : oneunit((V_S / M_VSd)^(-one(V_S)/3))

    # Relative reserves (mol/mol structure)
    m_CS = V_S > zero(V_S) ? C_S / V_S : zero(C_S / oneunit(V_S))
    m_NS = V_S > zero(V_S) ? N_S / V_S : zero(N_S / oneunit(V_S))

    # Growth rate (shoot) — solved from y_V_E*(κsoma*j_E(r) - j_E_mai*TC) - r = 0
    r_S, _ = _rate_plant(m_CS, m_NS, kTC, kTC, j_E_mai_TC, y_E_C, y_E_N, y_V_E, κsoma)

    # Catabolism and SU merge (shoot)
    J_C_cat_S = C_S * (kTC - r_S)
    J_N_cat_S = N_S * (kTC - r_S)
    J_C_rej_S, J_N_rej_S, _ = _stoich_merge_plant(J_C_cat_S, J_N_cat_S, y_E_C, y_E_N)

    # ---- ROOT organ ----
    scaling_R = V_R > zero(V_R) ? (V_R / M_VRd)^(-one(V_R)/3) : oneunit((V_R / M_VRd)^(-one(V_R)/3))

    m_CR = V_R > zero(V_R) ? C_R / V_R : zero(C_R / oneunit(V_R))
    m_NR = V_R > zero(V_R) ? N_R / V_R : zero(N_R / oneunit(V_R))

    r_R, _ = _rate_plant(m_CR, m_NR, kTC, kTC, j_E_mai_TC, y_E_C, y_E_N, y_V_E, κsoma)

    J_C_cat_R = C_R * (kTC - r_R)
    J_N_cat_R = N_R * (kTC - r_R)
    J_C_rej_R, J_N_rej_R, _ = _stoich_merge_plant(J_C_cat_R, J_N_cat_R, y_E_C, y_E_N)

    # ---- ASSIMILATION (post-germination) ----
    if in_seed
        J_C_ass_S = zero(J_C_cat_S)
        J_N_ass_R = zero(J_N_cat_R)
    else
        j_C_photo = _kooijman_photosynthesis(J_L_F, X_C, X_O, TC,
                                              j_L_Amax, J_L_K, j_C_Amax, K_C,
                                              j_O_Amax, K_O, k_C_binding, k_O_binding,
                                              SLA, w_V)
        J_C_ass_S = j_C_photo * V_S * scaling_S

        j_N_up = _kooijman_N_uptake(X_NH, X_NO, X_H, TC,
                                     j_NH_Amax, K_NH, j_NO_Amax, K_NO, K_H, ρNO)
        J_N_ass_R = j_N_up * V_R * scaling_R
    end

    # ---- PASSIVE TRANSLOCATION (lossless rejected-reserve exchange) ----
    # Rejected C from root → shoot C-reserve (root had excess C over what N could bind)
    # Rejected C from shoot → root C-reserve (shoot had excess C over what N could bind)
    # Rejected N from shoot → root N-reserve (shoot had excess N over what C could bind)
    # Rejected N from root → shoot N-reserve (root had excess N over what C could bind)

    # ---- STATE DERIVATIVES ----
    # Shoot structure
    dV_S = r_S * V_S

    # Shoot C-reserve:
    #   + assimilation from photosynthesis
    #   - total catabolism (C withdrawn from reserve)
    #   + incoming rejected C from root (lossless passive translocation)
    dC_S = J_C_ass_S - J_C_cat_S + J_C_rej_R

    # Shoot N-reserve:
    #   - total catabolism (N withdrawn from reserve)
    #   + incoming rejected N from root (lossless passive translocation)
    dN_S = -J_N_cat_S + J_N_rej_R

    # Root structure
    dV_R = r_R * V_R

    # Root C-reserve:
    #   - total catabolism
    #   + incoming rejected C from shoot
    dC_R = -J_C_cat_R + J_C_rej_S

    # Root N-reserve:
    #   + assimilation from soil
    #   - total catabolism
    #   + incoming rejected N from shoot
    dN_R = J_N_ass_R - J_N_cat_R + J_N_rej_S

    return (;
        V_S=dV_S, C_S=dC_S, N_S=dN_S,
        V_R=dV_R, C_R=dC_R, N_R=dN_R,
    )
end

# -------------------------------------------------------------------------
# Lifecycle event callbacks for Plant
# State order: V_S(1), C_S(2), N_S(3), V_R(4), C_R(5), N_R(6)

"""
Birth (germination) fires when root structure V_R reaches M_VRb.
"""
function transition_event(::Birth, model::DEBAnimal{<:Plant}, template)
    CallbackReconstructor(template) do u, t, i
        ustrip(i.p.val.par.M_VRb - u.metabolism.V_R)
    end
end

"""
Puberty (reproduction start) fires when shoot structure V_S reaches M_VSp.
"""
function transition_event(::Puberty, model::DEBAnimal{<:Plant}, template)
    CallbackReconstructor(template) do u, t, i
        ustrip(i.p.val.par.M_VSp - u.metabolism.V_S)
    end
end
