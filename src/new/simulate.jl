# Description
# Obtains predictions for state trajectories and some traits for start of development till death by aging,
# in a possibly dynamic environment, using parameters from the AmP collection.
# These parameter can be overwritten.
# The code does not include spawning events, weights do not include
# reproduction buffer.
# Starvation allows shrinking in structural mass. For other type of
# starvation rules the code should be modified.

# Input
#
# * model: character string with model (e.g. 'std', 'abj')
# * par: structure with parameters
# * tT: optional (nT,2)-array with time and temperature in Kelvin (default: T=T_typical)
#     If scalar, the temperature is assumed to be constant
# * tf: optional (nX,2)-array with time and functional response
#     If scalar, the food density is assumed to be constant (default f=1)
#
# Output
#
# * tELHR: (n,5)-array with time and simulated values for E, V, H, R
# * tWNXO: (n,5)-array with time and simulated values for wet weight,
# number of offspring, food consumed, O2 consumprion
# * tpAMGRD: (n,6)-array with time and simulated values of powers (assim, maint, growth, matur/reprod, dissipation)
# * aLW: vector with age, structural length, weight at life cycle event;
# computed using events during integration
# * aLWc: vector with age, structural length, weight at life cycle event
# at mean values of temperature and food. computed using the DEBtool functions
# was get_indDyn_mod
function simulate(model, par, environment; solver=Tsit5(), abstol=1e-9, reltol=1e-9)
    par = stripparams(par)
    # TODO: more generic way to do this
    par = merge(par, compound_parameters(model, par))
    (; k_M, p_Am, f) = par

    # tr = model.temperatureresponse
    # TC = tempcorr(tr, par, mean(environment.temperatures))
    # TODO: renaming this parameter after scaling is not great practice
    # as it now means a different thing. We could use another name after scaling.
    # If the equations it is passed to can work either way maybe its ok?
    # sca_par = merge(par, (; h_a=par.h_a / par.k_M^2)) # needs (; g, k, v_Hb, h_a, s_G, f)
    # (; τ_m) = compute_scaled_mean(Age(), Death(), model, sca_par)
    # a_m = τ_m / k_M / TC # d, mean life span

    l_b, info = compute_length(Birth(), par)
    (; UE0) = initial_scaled_reserve(model.mode, par, l_b)
    E_0 = UE0 * p_Am # J, energy in egg
    # TODO explain why 1e-4
    ELHR0 = @SVector[ustrip(u"J", E_0), 1e-4, 0.0, 0.0] # initial conditions at fertilization
    simulate_inner(model.mode, model, par, environment, ELHR0, solver; abstol, reltol)
end
function simulate_inner(
    mode::Union{typeof(std()),typeof(sbp())}, model, par, environment, ELHR0, solver; kw...
)
    # birth_state = compute_scaled_mean(Since(Conception()), Birth(), par, par.f) # -, scaled ages and lengths
    # puberty_state = compute_scaled_mean(Since(Conception()), Puberty(), par, birth_state) # -, scaled ages and lengths
    # τ_b, l_b = birth_state[(:τ, :l)]
    # # TODO: this should also be just (:τ, :l)
    # τ_p, l_p = puberty_state[(:τ_p, :l_p)]

    # L_bc = L_m * l_b # cm, length at birth and puberty at constant f
    # L_pc = L_m * l_p
    # a_bc = τ_b / k_M / mean(temp_corrections)
    # a_pc = τ_p / k_M / mean(temp_corrections)
    # Ww_bc = L_bc^3 * (1 + f * ome)
    # Ww_pc = L_pc^3 * (1 + f * ome)
    # L_ic = f * L_m # cm, ultimate struct length at mean constant f
    # Ww_ic = L_ic^3 * (1 + f * ome) # g, ultimate wet weight at mean constant f
    function _below_H(ELHR, t, integrator)
        H = ELHR[3] * u"J"
        any(<(H), all_E_H(mode, par))
    end
    callback = ContinuousCallback(_below_H, terminate!)
    ode_par = (; model, par, environment)
    tspan = first(environment.times), last(environment.times)
    problem = ODEProblem(d_sim, ELHR0, tspan, ode_par)
    return solve(problem, solver; callback, kw...)
end
function simulate_inner(
    mode::typeof(abj()), model, par, environment, ELHR0, solver, condition; kw...
)
    # pars_tj = [g k l_T v_Hb v_Hj v_Hp]
    # [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj(pars, f) # -, scaled ages and lengths
    # L_bc = L_m * l_b
    # L_jc = l_j * L_m
    # L_pc = l_p * L_m
    # a_bc = tau_b / k_M / mean(tTC[:, 2])
    # a_jc = tau_j / k_M / mean(tTC[:, 2])
    # a_pc = tau_p / k_M / mean(tTC[:, 2])
    # Ww_bc = L_bc^3 * (1+f*ome)
    # Ww_jc = L_jc^3 * (1+f*ome)
    # Ww_pc = L_pc^3 * (1+f*ome)
    # L_ic = f * L_m * (L_jc / L_bc)     # cm, ultimate struct length at mean constant f
    # Ww_ic = L_ic^3 * (1 + f * ome)   # g, ultimate wet weight at mean constant f

    # pars_abj = [p_Am, v, p_M, k_J, kap, kap_G, E_G, E_Hb, E_Hj, E_Hp]
    # options = odeset('Events',@stage_events_abj, 'AbsTol',1e-9, 'RelTol',1e-9);
    # 1st call from fertilization to birth
    # s_M = 1
    # [t1, ELHR1, te, ye, ie] = ode45(@dget_ELHR_abj, tspan, ELHR0, options, pars_abj, tTC, tf, NaN, s_M, isterminal)

    callback = ContinuousCallback(condition, terminate!)
    tspan = first(times), last(times)

    ode_par = (; model, par, environment)
    # 1st call from fertilization to birth
    L_b = NaN
    s_M = 1.0
    accelerating = false
    ode_par_1 = merge(ode_par, (; par=merge(par, (; L_b, s_M, accelerating))))
    tspan_1 = (te, tspan[end])
    u_1 = ELHR0
    isterminal = @SVector[true, false, false]
    problem = ODEProblem(_d_ELHR, u_1, tspan_1, ode_par_1)
    sol_1 = solve(problem, solver; callback, kw...)

    # 2nd call from birth to metamorphosis
    u_2 = sol_1.u[end] .+ 1e-8
    L_b = sol_1.ye[2]
    s_M = NaN
    t_2 = sol.what
    accelerating = true
    ode_par_2 = merge(ode_par, (; par=merge(par, (; L_b, S_M, accelerating))))
    tspan_2 = (t_2, tspan[end])
    isterminal = @SVector[false, true, false]
    problem = ODEProblem(_d_ELHR, u_2, tspan_2, ode_par_2)
    sol_b = solve(problem, solver; callback, kw...)

    # 3nd call from metamorphosis to the end of simulation
    L_j = sol_2.ye[2]
    u_3 = sol_2.u[end] .+ 1e-8
    t_3 = sol.what
    isterminal = @SVector[false, false, false]
    s_M = L_j / L_b
    # s_M = L_j / L_s
    L_b = NaN
    accelerating = false
    ode_par_c = merge(ode_par, (; par= merge(par, (; L_b, s_M, accelerating))))
    tspan_c = (t_c, tspan[end])
    problem = ODEProblem(_d_ELHR, u_c, tspan_c, ode_par_c)
    sol_c = solve(problem, solver; callback, kw...)

    # if isempty(te)
    #     te = NaN
    #     ye = NaN * ones(1, 4)
    #     @warn "birth is not reached"
    # end

    # a_b = te
    # L_b = ye[2]
    # Ww_b = ye[2]^3 + ye(1) * w_E / mu_E / d_E; # age (d), struc length (cm), weight (g) at birth
    # # 2nd call from birth to metamorphosis
    # [t2, ELHR2, te, ye, ie] = ode45(dget_ELHR_abj, (te, tspan[end]), ye+1e-8, options, pars_abj, tTC, tf, L_b, NaN, isterminal);
    # t2[1] = []
    # ELHR2[1, :] = []

    # if isempty(te)
    #     te = NaN
    #     ye = NaN * ones(1, 4)
    #     @warn "metamorphosis is not reached"
    # end

    # a_j = te
    # L_j = ye[2]
    # Ww_j = ye[2]^3 + ye[1] * w_E / mu_E / d_E # age (d), struc length (cm), weight (g) at metamorphosis
    # 3nd call from metamorphosis to the end of simulation
    # [t3, ELHR3, te, ye, ie] = ode45(dget_ELHR_abj, [te, tspan[end]], ye+1e-8, options, pars_abj, tTC, tf, NaN, s_M, isterminal);
    # t3[1] = []
    # ELHR3[1, :] =[]

    # if isempty(te)
    #     te = NaN
    #     ye = NaN * ones(1, 4)
    #     @warn "puberty is not reached"
    # end

    # a_p = te
    # L_p = ye[2]
    # Ww_p = ye[2]^3 + ye[1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at puberty
    # # catenate matrices
    # t = [t1; t2; t3]
    # ELHR = [ELHR1; ELHR2; ELHR3];
    # L_i = NaN
    # Ww_i = NaN # not applicaple in dynamic environment
    # calculate powers
    # pars_pj = [p_Am, v, p_M, k_J, kap, kap_R, E_G, kap_G]
    # f_s = spline1(t, tf)
    # TC_s = spline1(t, tTC)
    # pAMGD = powers_j(ELHR, f_s, pars_pj, L_b, L_b, L_j, L_p) .* TC_s
    # JM = - (n_M\n_O) * eta_O * pAMGD(:, [1 4 3])'  # mol/d: J_C, J_H, J_O, J_N in rows
    # aLW = [a_b; a_j; a_p; a_m; L_b; L_j; L_p; L_i; Ww_b; Ww_j; Ww_p; Ww_i];
    # # use the get_* functions of the DEBtool
    # aLWc = [a_bc; a_jc; a_pc; a_m; L_bc; L_jc; L_pc; L_ic; Ww_bc; Ww_jc; Ww_pc; Ww_ic];
end
function simulate_inner(
    mode::typeof(asj()), model, par, environment, ELHR0, solver; kw...
)
    # pars_ts = [g, k, 0, v_Hb, v_Hs, v_Hj, v_Hp]
    # [tau_s, tau_j, tau_p, tau_b, l_s, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_ts(pars_ts, f) # -, scaled ages and lengths
    # L_bc = L_m * l_b
    # L_sc = l_s * L_m
    # L_jc = l_j * L_m
    # L_pc = l_p * L_m
    # a_bc = tau_b/k_M/mean(tTC(:, 2))
    # a_sc = tau_s/k_M/mean(tTC(:, 2))
    # a_jc = tau_j/k_M/mean(tTC(:, 2))
    # a_pc = tau_p/k_M/mean(tTC(:, 2))
    # Ww_bc = L_bc^3 * (1+f*ome); Ww_sc = L_jc^3 * (1+f*ome);
    # Ww_jc = L_jc^3 * (1+f*ome); Ww_pc = L_pc^3 * (1+f*ome);
    # L_ic = f * L_m * (L_jc/L_bc);     # cm, ultimate struct length at mean constant f
    # Ww_ic = L_ic^3 * (1 + f * ome);   # g, ultimate wet weight at mean constant f
    #
    # pars_asj = [p_Am, v, p_M, k_J, kap, kap_G, E_G, E_Hb, E_Hs, E_Hj, E_Hp];
    # options = odeset('Events', stage_events_asj, 'AbsTol',1e-9, 'RelTol',1e-9);
    # 1st call from fertilization to start of metabolic acceleration
    s_M = 1.0
    isterminal = [0, 1, 0, 0]
    # [t1, ELHR1, te, ye, ie] = ode45(dget_ELHR_asj, tspan, ELHR0, options, pars_asj, tTC, tf, NaN, s_M, isterminal);
    # if isempty(te)
    #     te[1] = NaN
    #     te[2] = NaN
    #     ye = NaN * ones(2, 4)
    #     @warn "birth is not reached"
    # elseif length(te) == 1
    #     te[2] = NaN
    #     ye[2, :] = NaN * ones(1, 4)
    #     @warn "start of accel is not reached"
    # end
    # a_b = te[1]
    # Ww_b = ye[1, 2]^3 + ye[1, 1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at birth
    # a_s = te[2]
    L_b = ye[1, 2]
    L_s = ye[2, 2]
    # Ww_s = ye[2, 2]^3 + ye[2, 1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at start of accel
    # 2nd call from start of acceleration to metamorphosis (end of acceleration)
    isterminal = [0, 0, 1, 0]
    # [t2, ELHR2, te, ye, ie] = ode45(dget_ELHR_asj, [te[2], tspan[end]], ye(2, :)+1e-8, options, pars_asj, tTC, tf, L_s, NaN, isterminal)
    # t2[1] = []
    ELHR2[1, :] = []
    # if isempty(te)
    #     te = NaN
    #     ye = NaN * ones(1,4)
    #     @warn "metamorphosis is not reached"
    # end
    # a_j = te
    # Ww_j = ye[2]^3 + ye(1) * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at metamorphosis
    # 3nd call from metamorphosis to the end of simulation
    L_j = ye[2]
    s_M = L_j / L_s
    isterminal = [0, 0, 0, 0]
    # [t3, ELHR3, te, ye, ie] = ode45(@dget_ELHR_asj, [te, tspan[end]], ye+1e-8, options, pars_asj, tTC, tf, NaN, s_M, isterminal);
    # t3[1] = []
    ELHR3[1, :] = []
    # if isempty(te)
    #     te = NaN
    #     ye[:] = NaN * ones(1, 4)
    #     @warn "puberty is not reached"
    # end
    # a_p = te
    L_p = ye[2]
    # Ww_p = ye[2]^3 + ye[1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at puberty
    # catenate matrices
    t = [t1; t2; t3]
    ELHR = [ELHR1; ELHR2; ELHR3]
    # L_i = NaN
    # Ww_i = NaN # not applicaple in dynamic environment
    # # calculate powers
    # pars_pj = [p_Am, v, p_M, k_J, kap, kap_R, E_G, kap_G]
    # f_s = spline1(t, tf)
    # TC_s = spline1(t, tTC)
    # pAMGD = powers_j(ELHR, f_s, pars_pj, L_b, L_s, L_j, L_p) .* TC_s
    # JM = -(n_M \ n_O) * eta_O * pAMGD(:, [1 4 3])'  # mol/d: J_C, J_H, J_O, J_N in rows
    # #
    # aLW = [a_b; a_s; a_j; a_p; a_m; L_b; L_s; L_j; L_p; L_i; Ww_b; Ww_s; Ww_j; Ww_p; Ww_i]
    # # use the get_* functions of the DEBtool
    # aLWc = [a_bc; a_sc; a_jc; a_pc; a_m; L_bc; L_sc; L_jc; L_pc; L_ic; Ww_bc; Ww_sc; Ww_jc; Ww_pc; Ww_ic]
end
function simulate_inner(
    mode::typeof(abp()), model, par, environment, ELHR0, solver; kw...
)
    # pars_tj = [g k l_T v_Hb v_Hp v_Hp+1e-6]
    # [tau_p, tau_pp, tau_b, l_p, l_pp, l_b, l_i, rho_j, rho_B] = get_tj(pars_tj, f) # -, scaled ages and lengths
    # L_bc = L_m * l_b
    # L_pc = l_p * L_m
    # a_bc = tau_b / k_M / mean(tTC[:, 2])
    # a_pc = tau_p / k_M / mean(tTC[:, 2])
    # Ww_bc = L_bc^3 * (1+f*ome)
    # Ww_pc = L_pc^3 * (1+f*ome)
    # L_ic = NaN
    # Ww_ic = NaN  # growth stops at puberty

    # pars_abp = [p_Am, v, p_M, k_J, kap, kap_G, E_G, E_Hb, E_Hp]
    # options = odeset('Events', @stage_events_abp, 'AbsTol', 1e-9, 'RelTol',1e-9);
    # 1st call from fertilization to birth
    s_M = 1.0
    isterminal = [1, 0]
    # [t1, ELHR1, te, ye, ie] = ode45(d_ELHR, tspan, ELHR0, options, pars_abp, tTC, tf, NaN, s_M, isterminal);
    # if isempty(te)
    #     te = NaN; ye = NaN * ones(1,4)
    #     @warn "birth is not reached"
    # end
    # a_b = te
    L_b = ye(2)
    # Ww_b = ye(2)^3 + ye(1) * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at birth
    # 2nd call from birth to the end of simulation
    isterminal = [0, 0]
    # [t2, ELHR2, te, ye, ie] = ode45(d_ELHR, (te, tspan[end]), ye+1e-8, options, pars_abp, tTC, tf, L_b, NaN, isterminal)
    # t2[1] = []
    # ELHR2[1, :] = []
    # if isempty(te)
    #     te = NaN; ye = NaN * ones(1, 4)
    #     @warn "puberty is not reached"
    # end
    # a_p = te
    L_p = ye[2]
    # Ww_p = ye[2]^3 + ye[1] * w_E/mu_E/d_E # age (d), struc length (cm), weight (g) at puberty
    # catenate matrices
    # t = [t1, t2]
    # TODO: remove start of each
    ELHR = [ELHR1, ELHR2]
    # L_i = NaN
    # Ww_i = NaN
    # a_99 = NaN # not applicaple in dynamic environment
    # # calculate powers
    # pars_pj = [p_Am, v, p_M, k_J, kap, kap_R, E_G, kap_G]
    # f_s = spline1(t, tf)
    # TC_s = spline1(t, tTC)
    # pAMGD = powers_j(ELHR, f_s, pars_pj, L_b, L_b, L_p, L_p) .* TC_s
    # JM = -(n_M \ n_O) * eta_O * pAMGD(:, [1 4 3])'  # mol/d: J_C, J_H, J_O, J_N in rows
    # pAMGD[:, 3] = pAMGD[:, 3] .* (ELHR[:, 2] < L_p) # adults do not grow
    # #
    # aLW = [a_b; a_p; a_m; L_b; L_p; L_i; Ww_b; Ww_p; Ww_i]
    # # use the get_* functions of the DEBtool
    # aLWc = [a_bc; a_pc; a_m; L_bc; L_pc; L_ic; Ww_bc; Ww_pc; Ww_ic]
end

# d_sim
# Define changes in state variables
# t: time
# ELHR: 4-vector with state variables
#         E, J, reserve energy
#         L, cm, structural length
#         E_H, J, cumulated energy inversted into maturity (E_H in Kooijman 2010)
#         E_R, J, reproduction buffer (E_R in Kooijman 2010)
#
# Params
# p_Am   J/d.cm^2, surface-area-specific maximum assimilation rate
# v      cm/d, energy conductance
# p_M    J/d.cm^3, somatic maint
# k_J    1/d, maturity maint rate coeff
# kap    -, fraction allocated to growth + som maint
# kap_G  -, growth efficiency
# E_G    J/cm^3, volume-specific costs of structure
#
# dELHR: 4-vector with change in E, L, H, R
function d_sim(ELHR, p, t)
    (; model, par, environment) = p
    (; p_Am, v, p_M, k_J, kap, E_Hb, E_Hp) = par

    E_, L_, E_H_ = ELHR
    # Add units
    E = E_ * u"J"
    L = L_ * u"cm"
    E_H = E_H_ * u"J"

    TC = environment.interpolators.tempcorrections(t) # C, temperature at t
    f_t = environment.interpolators.functionalresponses(t) # -, scaled functional response at t
    s_M = acceleration_factor(model.mode, par, L)
    pT_Am, vT, pT_M, kT_J = map(x -> x * TC, (p_Am, v, p_M, k_J)) # temp correction TODO: rates should already be grouped
    r = specific_growth_rate(model.mode, merge(par, (; vT, pT_M, s_M)), (E, L, E_H))

    # TODO explain all the equations
    pA = (pT_Am * s_M * f_t * L^2) * (E_H >= E_Hb) # J/d, assimilation
    pC = E * (s_M * vT / L - r) # J/d, mobilized energy flux

    # generate derivatives
    # Change in reserve E is the difference between assimmilated mobilized energy
    dE = pA - pC # J/d, change in energy in reserve
    # Length L changes as the growth rate * the current length TODO: why / 3
    dL = r * L / 3 # cm/d, change in length
    # Maturitity H and reproduction R buffers receive (1 - κ) * mobilized flux, minus maturity maintenancy 
    # There is no investment in maturation after puberty 
    dE_H = ((1 - kap) * pC - kT_J * E_H) * (E_H < E_Hp) # J/d, change in cumulated energy invested in maturation
    # And no investment in reproduction before puberty
    dE_R = ((1 - kap) * pC - kT_J * E_Hp) * (E_H >= E_Hp) # J/d, change in reproduction buffer

    # Strip to days and pack as state variables
    # TODO: strip to the time units of `t` like ustrip("uJ" / units(t), x)
    return @SVector[ustrip(u"J/d", dE), ustrip(u"cm/d", dL), ustrip(u"J/d", dE_H), ustrip(u"J/d", dE_R)]
end

# TODO: this should dispatch on a field of the model, not the mode
function specific_growth_rate(mode::Union{typeof(sbp()), typeof(abp())}, pars, ELH)
    E_H = ELH[3]
    if E_H >= pars.E_Hp
        # adults do not grow, and do not shrink
        0.0u"d^-1" # d^-1, specific growth rate
    else
        specific_growth_rate(std(), pars, state)
    end
end
function specific_growth_rate(mode::Mode, par, ELH)
    E, L, E_H = ELH
    (; kap, kap_G, E_G, s_M, vT, pT_M) = par
    # TODO why is growth efficiency optional here
    kap_G_or_1 = (kap * E * s_M * vT < pT_M * L^4) ? kap_G : oneunit(kap_G) # section 4.1.5 comments to Kooy2010
    (E * s_M * vT / L - pT_M * L^3 / kap) / (E * s_M + kap_G_or_1 * E_G * L^3 / kap) # d^-1, specific growth rate
end

# -, multiplication factor for v and {p_Am}
# TODO: do this without specifying L_s or L_b - just L and e.g. lifestages[Birth()].L
# Then it would be generalised to any lifestage.
acceleration_factor(::Accelerated{<:IsoMorph,<:MaturityLevel}, p, L) = p.accelerating ? L / p.L_s : p.s_M
acceleration_factor(::Accelerated{<:IsoMorph,<:Birth}, p, L) = p.accelerating ? L / p.L_b : p.s_M
acceleration_factor(::Mode, pars, L) = 1.0 # Non-accelerating modes

# Get all E_H variables to compare to E_H
all_E_H(::typeof(std()), p) = p.E_Hb, p.E_Hp
# all_E_H(::typeof(stx()), p) = p.E_Hb, p.E_Hx, p.E_Hp
all_E_H(::typeof(abj()), p) = p.E_Hb, p.E_Hj, p.E_Hp
all_E_H(::typeof(asj()), p) = p.E_Hb, p.E_Hs, p.E_Hj, p.E_Hp
all_E_H(::typeof(abp()), p) = p.E_Hb, p.E_Hp

# power functions
#
# function powers(ELHR, f_s, p, L_b, L_p)
#     # Gets powers assimilation, mobilisation, somatic maintenance, maturity maintenance,
#     # growth, reproduction and dissipation for the std model

#     # unpack state variables
#     E  = ELHR(:,1); L = ELHR(:,2); E_H = ELHR(:,3);

#     # unpack parameters
#     (;  p_Am,  # J/d.cm^2, surface-area-specific maximum assimilation rate
#         v,     # cm/d, energy conductance
#         p_M,   # J/d.cm^3, somatic maint
#         k_J,   # 1/d, maturity maint rate coeff
#         kap,   # -, fraction allocated to growth + som maint
#         kap_R, # -, fraction of reprod flux that is fixed in embryo reserve
#         E_G,   # J/cm^3, volume-specific costs of structure
#         kap_G, # -, growth efficiency
#      ) = p

#     V = L .^ 3
#     assim = L > L_b
#     kappa_R = kap_R * ones(length(L),1)
#     kappa_R = kappa_R .* (L>L_p)

#     # powers
#     pA = assim .* (p_Am * f_s .* L.^2)     # assim
#     pS = p_M * V;                      # somatic  maint
#     r = if kap * E * v >= p_M * L.^4 # section 4.1.5 comments to Kooy2010
#         (v * E ./ L - pS / kap)./ (E + E_G * V / kap); # d^-1, specific growth rate
#     else
#         (v * E ./ L - pS / kap)./ (E + kap_G * E_G * V/ kap); # d^-1, specific growth rate
#     end
#     pC  = E .* (v./ L - r);    # J/d, mobilized energy flux
#     pJ = k_J * E_H;            # maturity maint
#     pG = r .* V * E_G;         # growth
#     pR = (1 - kap) * pC - pJ;  # maturation/reproduction
#     pD = pS + pJ + (1 - kappa_R) .* pR ;  # dissipation
#     pmaint = pS+pJ;

#     return pA, pmaint, pG, pR, pD
# end

# powers_j differences: s_M

#     s_M = 1* (L<L_s) + L/L_s .*(L>=L_s & L<L_j) + L_j/L_s .*(L>=L_j);
#     # powers
#     pA = p_Am * assim .* f_s .* s_M .* L.^2;     # assim
#     r = if kap * E .* s_M * v >= p_M * L.^4 # section 4.1.5 comments to Kooy2010
#         (v * s_M .* E./L - pS/ kap)./ (E + E_G * V/ kap); # d^-1, specific growth rate
#     else
#         (v * s_M .* E./L - pS/ kap)./ (E + kap_G * E_G * V/ kap); # d^-1, specific growth rate
#     end
#     pC  = E .* (v* s_M./ L - r);  # /d, mobilized energy flux
