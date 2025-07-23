"""
    compute_scaled_mean 

# TODO better name like compute_scaled_mean_lifehistory

was get_tm_mod

Obtains scaled mean age at death and other transistions by integration survival prob over age. 
Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death. 

# Arguments
#
- `model`: DEBOrganism
- `par`

# Keywords

- `h_B`; optional vector with background hazards for each stage: e.g. for std model h_B0b, h_Bbp, h_Bpi (default: zero's)
- `thinning`: optional boolean for thinning (default: false)

# State variables used in simulation

`q`:   scaled aging acceleration
`h_A`: scaled hazard rate due to aging
`S`:   survival prob
`t`:   scaled cumulative survival

# Output

- `S`: survival probabilities at life history events 
- `τ`: scaled ages at life history events 
"""
# function compute_scaled_mean_lifehistory(model, p; 
#     abstol=1e-7, 
#     reltol=1e-7,
#     callback=DiscreteCallback(dead_for_sure, terminate!),
#     thinning=false,
#     solver=Tsit5(),
#     h_B=zeros(length(life(model))),
#     kw...
# )
#     compute_scaled_mean_lifehistory(model.mode, model, p; 
#         callback, solver, abstol, reltol, thinning, h_B, kw...
#     )
# end

# function compute_scaled_mean_lifehistory(
#     mode::Union{typeof(std()),typeof(stf()),typeof(sbp())}, model, p; 
#     solver, thinning, h_B, kw...
# )
#     (; g, k, v_Hb, h_a, s_G, f) = p
#     (; S_b, q_b, h_Ab, τ_b) = compute_survival_probability(Birth(), model, merge(p, (; h_B0b=h_B[1], ρ_N=0.0)))
#     # TODO: better handling of f/eb functional response at birth
#     birth_state = compute_scaled_mean(Since(Conception()), Birth(), p, f) # -, scaled ages and lengths at birth
#     puberty_state = compute_scaled_mean(Since(Conception()), Puberty(), merge(p, (; l_T=0.0)), birth_state) # -, scaled ages and lengths at puberty
#     τ_b, l_b = birth_state.τ, birth_state.l
#     τ_p, l_p = puberty_state.τ, puberty_state.l

#     u0 = init_qhSt(q_b, h_Ab, S_b, τ_b)
#     transitions = @SVector[zero(τ_p), τ_p - τ_b, 1e8oneunit(τ_p)]
#     tspan = (first(transitions), last(transitions))
#     # TODO: τ_p having two meanings (since birth/since conception) 
#     # is bad practice - we need different symbols for these
#     pars = (; model, f, τ_p=τ_p - τ_b, l_b, g, s_G, h_a, h_B, thinning);
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.(transitions)

#     τ_m = qhSt[end][4]
#     S_p = qhSt[2][3]
#     S = (; b=S_b, p=S_p)
#     τ = (; b=τ_b, p=τ_p, m=τ_m)
#     return (; S, τ)
# end
# Same as std because dget_qhSt dispatch is the only difference
# function compute_scaled_mean_lifehistory(mode::typeof(sbp()), model, p; 
#     h_B=zeros(5), thinning=false
# )
#     (; g, k, v_Hb, v_Hp, h_a, s_G, f) = p
#     (; S_b, q_b, h_Ab, τ_b) = get_Sb([g k v_Hb h_a s_G h_B[1]], f);
#     (; τ_p, l_p, l_b) = get_tp([g k 0 v_Hb v_Hp], f); # -, scaled ages and lengths at puberty, birth

#     u0 = init_qhSt(q_b, h_Ab, S_b, τ_b)
#     tspan = (zero(τ_p), τ_p - τ_b, 1e8oneunit(τ_p))
#     pars = (; model, f, τ_p - τ_b, l_b, l_p, g, s_G, h_a, h_B, thinning)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver)
#     qhSt = sol.u

#     τ_m = qhSt[end, 4]
#     S_p = qhSt[2, 3]
#     S = [S_b, S_p]
#     τ = [τ_b, τ_p]
#     return (; τ_m, S, τ)
# end
# Same as std if get_Sb_foetus and get_tp_foetus dispatch on mode in get_Sb and get_tp
# function compute_scaled_mean_lifehistory(mode::typeof(stf()), model, p; h_B=zeros(5), thinning=false)
#     (; g, k, v_Hb, v_Hp, h_a, s_G, f) = p

#     (; S_b, q_b, h_Ab, τ_b) = get_Sb_foetus([g k v_Hb h_a s_G h_B[1]], f);
#     (τ_p, l_p, l_b) = get_tp_foetus([g k 0 v_Hb v_Hp], f); # -, scaled ages and lengths at puberty, birth

#     u0 = init_qhSt(q_b, h_Ab, S_b, τ_b)
#     tspan = (zero(τ_p), τ_p - τ_b, 1e8oneunit(τ_p))
#     pars = (; model, f, τ_p=τ_p - τ_b, l_b, g, s_G, h_a, h_B, thinning);
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver)
#     qhSt = sol.u

#     τ_m = qhSt[end, 4]
#     S_p = qhSt[2, 3]
#     S = [S_b, S_p]
#     τ = [τ_b, τ_p]
#     return (; τ_m, S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(stx()), model, p; 
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hx, v_Hp, h_a, s_G, f) = p

#     sp_pars = (; g, k, v_Hb, h_a, s_G, h_B=h_B[1], ρ_N=0.0, f)
#     (; S_b, q_b, h_Ab, τ_b) = compute_survival_probability(Birth(), model, sp_pars)
#     (; τ_p, τ_x, l_p, l_x, l_b) = get_tx([g k 0 v_Hb v_Hx v_Hp], f); # -, scaled ages and lengths at puberty, birth

#     u0 = init_qhSt(q_b, h_Ab, S_b, τ_b)
#     transitions = @SVector[zero(τ_x), τ_x - τ_b, τ_p - τ_b, 1e8oneunit(τ_x)]
#     tspan = (first(transitions), last(transitions))
#     pars = (; model, f, τ_x=τ_x - τ_b, τ_p=τ_p - τ_b, l_b, g, s_G, h_a, h_B, thinning)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.(transitions)

#     τ_m = qhSt[end, 4]
#     S_x = qhSt[2, 3]
#     S_p = qhSt[3, 3]
#     S = (; b=S_b, x=S_x, p=S_p)
#     τ = (; b=τ_b, x=τ_x, p=τ_p, m=τ_m)  
#     return (; S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(ssj()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hs, v_Hp, t_sj, k_E, h_a, s_G, f) = p

#     sp_pars = (; g, k, v_Hb, h_a, s_G, h_B=h_B[1], ρ_N=0.0, f)
#     (; S_b, q_b, h_Ab, τ_b) = compute_survival_probability(Birth(), model, sp_pars) 
     
#     (; τ_s, l_s, l_b) = get_tp((; g, k, l_T=0.0, v_Hb, v_Hs), f) # -, scaled ages and lengths at start skrink
#     (; τ_p, l_p) = get_tp((; g, k, l_T=0.0, v_Hs, v_Hp), f) # -, scaled ages and lengths at puberty

#     τ_j = τ_s + t_sj * k_M # -, scaled age at end metamorphosis
#     k_E = k_E / k_M; # - scaled shrinking rate

#     u0 = init_qhSt(q_b, h_Ab, S_b, τ_b)
#     transitions = @SVector[zero(τ_s), τ_s - τ_b, τ_j - τ_b, τ_p - τ_b, 1e8oneunit(τ_s)]
#     tspan = (first(transitions), last(transitions))
#     pars = (; model, f, τ_s=τ_s - τ_b, τ_p=τ_p - τ_b, τ_j, l_b, l_s, k_E, g, s_G, h_a, h_B, thinning)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.(transitions)

#     τ_m = qhSt[end, 4]
#     S_s = qhSt[2, 3]
#     S_j = qhSt[3, 3]
#     S_p = qhSt[4, 3]
#     S = [S_b, S_s, S_j, S_p]
#     τ = [τ_b, τ_s, τ_j, τ_p]
#     return (; τ_m, S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(abj()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hj, v_Hp, h_a, s_G, f) = p
#     (; τ_m, τ_p, τ_j, τ_b, S_p, S_j, S_b, info) = get_tm_j([g, k, 0, v_Hb, v_Hj, v_Hp, h_a, s_G], f)

#     S = [S_b, S_j, S_p]
#     τ = [τ_b, τ_j, τ_p]
#     return (; τ_m, S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(asj()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hs, v_Hs, v_Hp, h_a, s_G, f) = p
#     sp_pars = (; g, k, v_Hb, h_a, s_G, h_B=h_B[1], ρ_N=0.0, f)
#     (; S_b, q_b, h_Ab, τ_b) = compute_survival_probability(Birth(), model, sp_pars)
#     (; τ_s, τ_j, τ_p, τ_b, l_s, l_j, l_p, l_b, l_i, ρ_j, ρ_B) = get_ts([g k 0 v_Hb v_Hs v_Hj v_Hp], f); 

#     u0 = init_qhSt(q_b, h_Ab, S_b, τ_b)
#     transitions = @SVector[zero(τ_s), τ_s - τ_b, τ_j - τ_b, τ_p - τ_b, 1e8oneunit(τ_s)]
#     tspan = (first(transitions), last(transitions))
#     pars = (; model, f, τ_s=τ_s - τ_b, τ_j=τ_j - τ_b, τ_p=τ_p - τ_b, l_b, l_s, l_j, l_i, ρ_j, ρ_B, g, s_G, h_a, h_B, thinning)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.(transitions)

#     τ_m = qhSt[end, 4]
#     S_s = qhSt[2, 3]
#     S_j = qhSt[3, 3]
#     S_p = qhSt[4, 3]
#     S = [S_b, S_s, S_j, S_p]
#     τ = [τ_b, τ_s, τ_j, τ_p]
#     return (; τ_m, S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(abp()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hp, h_a, s_G, f) = p

#     (; S_b, q_b, h_Ab, τ_b) = get_Sb([g k v_Hb h_a s_G h_B[1]], f);
#     (; τ_j, τ_p, τ_b, l_j, l_p, l_b, l_i, ρ_j, ρ_B) = get_tj([g k 0 v_Hb v_Hp v_Hp+1e-9], f); 

#     u0 = init_qhSt(q_b, h_Ab, S_b, τ_b)
#     transitions = @SVector[zero(τ_p), τ_p - τ_b, 1e8oneunit(τ_p)]
#     tspan = (first(transitions), last(transitions))
#     pars = (; model, f, τ_p=τ_j - τ_b, l_b, l_p, ρ_j, g, s_G, h_a, h_B, thinning)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.u

#     τ_m = qhSt[end, 4]
#     S_p = qhSt[2, 3]
#     S = [S_b, S_p]
#     τ = [τ_b, τ_j]
#     return (; τ_m, S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(hep()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hp, v_Rj, h_a, s_G, f) = p
#     (; τ_j, τ_p, τ_b, l_j, l_p, l_b, l_i, ρ_j, ρ_B) = get_tj_hep([g, k, v_Hb, v_Hp, v_Rj], f);

#     u0 = SVector((0.0, 0.0, 1.0, 0.0))
#     pars = (; model, f, τ_je=1e-6, l_b, l_p, l_e=l_j, g, s_G, h_a, h_B)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.(transitions)

#     τ_m = qhSt[end, 4]
#     S_b = S_p = S_j = 1.0 
#     S = [S_b, S_p, S_j]
#     τ = [τ_b, τ_p, τ_j]
#     return (; τ_m, S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(hax()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hp, v_Rj,v_He, kap, kap_V, h_a, s_G, f) = p
#     (; τ_j, τ_e, τ_p, τ_b, l_j, l_e, l_p, l_b, l_i, ρ_j) = get_tj_hax((; g, k, v_Hb, v_Hp, v_Rj, v_He, kap, kap_V, f))

#     u0 = SVector((0.0, 0.0, 1.0, 0.0))
#     transitions = @SVector[zero(τ_e), τ_e - τ_j, 1e8oneunit(τ_e)]
#     tspan = (first(transitions), last(transitions))
#     pars = (; model, f, τ_je=τ_e - τ_j, l_b, l_p, l_e, g, s_G, h_a, h_B)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.(transitions)

#     τ_m = qhSt[3, 4]
#     S_e = qhSt[2, 3] 
#     S_b = S_p = S_j = oneunit(S_e)
#     S = [S_b, S_p, S_j, S_e]
#     τ = [τ_b, τ_p, τ_j, τ_e]
#     return (; τ_m, S, τ)
# end
# function compute_scaled_mean_lifehistory(mode::typeof(hex()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_He, s_j, kap, kap_V, h_a, s_G, f) = p
#     (; τ_j, τ_e, τ_b, l_j, l_e, l_b, ρ_j) = get_tj_hex((; g, k, v_Hb, v_He, s_j, kap, kap_V, f));

#     u0 = SVector((0.0, 0.0, 1.0, 0.0))
#     transitions = @SVector[zero(τ_e), τ_e - τ_j, 1e8oneunit(τ_e)]
#     tspan = (first(transitions), last(transitions))
#     pars = (; model, f, τ_je=τ_e - τ_j, l_b, l_p=l_j, l_e, g, s_G, h_a, h_B)
#     problem = ODEProblem(_d_qhSt, u0, tspan, pars)
#     sol = solve(problem, solver; kw...)
#     qhSt = sol.(transitions)

#     τ_m = qhSt[3, 4]
#     S_b = S_j = oneunit(S_e)
#     S_e = qhSt[2, 3]
#     S = [S_b, S_j, S_e]
#     τ = [τ_b, τ_j, τ_e]

#     return (; τ_m, S, τ)
# end

# subfunctions

# init_qhSt(q_b, h_Ab, S_b, τ_b) = 
#     SVector((max(zero(q_b), q_b), max(zero(h_Ab), h_Ab), S_b, τ_b))

# # event dead_for_sure
# dead_for_sure(qhSt, t, integrator) = qhSt[3] > 1e-6

# # TODO a better name for this function
# function calc_lr(f, g, l__, τ)
#     ρ_B = 1 / 3 / (oneunit(f) + f / g) 
#     l = f - (f - l__) * exp(-τ * ρ_B)
#     r = 3 * ρ_B * (f / l - oneunit(l))
#     return l, r
# end

# function d_output(; f, q, l, g, r, s_G, h_a, h_A, h_B, S, thinning)
#     h_X = thinning * r * 2 / 3
#     h = h_A + h_B + h_X 

#     dq = f * (q * l^3 * s_G + h_a) * (g / l - r) - r * q
#     dh_A = q - r * h_A
#     dS = -h * S
#     dt = S

#     return SVector((dq, dh_A, dS, dt))
# end


# _d_qhSt(u, p, τ) = d_qhSt(p.model.mode, u, p, τ)
# function d_qhSt(::Union{typeof(std()),typeof(stf())}, qhSt, pars, τ)
#     (; f, τ_p, l_b, g, s_G, h_a, h_B, thinning) = pars
#     (q, h_A, S) = qhSt

#     h_B = τ < τ_p ? h_B[2] : h_B[3]
#     l, r = calc_lr(f, g, l_b, τ)

#     return d_output(; f, q, l, g, r, s_G, h_a, h_A, h_B, S, thinning)
# end
# function d_qhSt(::typeof(stx()), qhSt, pars, τ)
#     (; f, τ_x, τ_p, l_b, g, s_G, h_a, h_B, thinning) = pars
#     (q, h_A, S) = qhSt

#     h_B = if τ < τ_x
#         h_B[2]
#     elseif τ < τ_p
#         h_B[3]
#     else # adult
#         h_B[4]
#     end
#     l, r = calc_lr(f, g, l_b, τ)

#     return d_output(; f, q, l, g, r, s_G, h_a, h_A, h_B, S, thinning)
# end
# function d_qhSt(::typeof(ssj()), qhSt, pars, τ)
#     (; f, τ_s, τ_p, τ_j, l_b, l_s, k_E, g, s_G, h_a, h_B, thinning) = pars
#     (q, h_A, S) = qhSt

#     if τ < τ_s
#         l, r = calc_lr(f, g, l_b, τ)
#         h_B = h_B[2]
#     elseif τ < τ_j
#         l, r = l_s * exp(-k_E * (τ - τ_s)), 0.0 # TODO units/type
#         h_B = h_B[3]
#     elseif τ < τ_p
#         l_j = l_s * exp(-k_E * (τ_j - τ_s)) 
#         l, r = calc_lr(f, g, l_j, τ - τ_j)
#         h_B = h_B[3]
#     else
#         l_j = l_s * exp(-k_E * (τ_j - τ_s)) 
#         l, r = calc_lr(f, g, l_j, τ - τ_j)
#         h_B = h_B[4]
#     end

#     return d_output(; f, q, l, g, r, s_G, h_a, h_A, h_B, S, thinning)
# end
# function d_qhSt(::typeof(sbp()), qhSt, pars, τ)
#     (; f, τ_p, l_b, l_p, g, s_G, h_a, h_B, thinning) = pars
#     (q, h_A, S) = qhSt

#     if τ < τ_p
#         l, r = calc_lr(f, g, l_b, τ)
#         h_B = h_B[2]
#     else # adult
#         l, r = l_p, 0.0
#         h_B = h_B[3]
#     end
    
#     return d_output(; f, q, l, g, r, s_G, h_a, h_A, h_B, S, thinning)
# end
# function d_qhSt(::typeof(abj()), qhSt, pars, τ) 
#     (; f, τ_j, τ_p, l_b, l_j, l_i, ρ_j, ρ_B, g, s_G, h_a, h_B, thinning) = pars
#     (q, h_A, S) = qhSt

#     if τ < τ_j
#         l = l_b * exp(τ * ρ_j / 3)
#         r = ρ_j
#         s_M = l / l_b
#         h_B = h_B[2]
#     elseif τ < τ_p
#         l = l_i - (l_i - l_j) * exp(-(τ - τ_j) * ρ_B)
#         r = 3 * ρ_B * (f / l - oneunit(l))
#         s_M = l_j / l_b
#         h_B = h_B[3]
#     else # adult
#         l = l_i - (l_i - l_j) * exp(- (τ - τ_j) * ρ_B)
#         r = 3 * ρ_B * (f / l - oneunit(l))
#         s_M = l_j / l_b
#         h_B = h_B[4]
#     end

#     return d_output(; f, q, l, g=g * s_M, r, s_G, h_a, h_A, h_B, S, thinning)
# end
# function d_qhSt(::typeof(asj()), qhSt, pars, τ)
#     (; f, τ_s, τ_j, τ_p, l_b, l_s, l_j, l_i, ρ_j, ρ_B, g, s_G, h_a, h_B, thinning) = pars
#     (q, h_A, S) = qhSt

#     if τ < τ_s
#         h_B = h_B[2]
#         l, r = calc_lr(f, g, l_b, τ)
#         s_M = oneunit(l / l_s)
#     elseif τ < τ_j
#         h_B = h_B[3]
#         l = l_s * exp((τ - τ_s) * ρ_j / 3)
#         r = ρ_j
#         s_M = l / l_s
#     elseif τ < τ_p
#         h_B = h_B[4]
#         l = l_i - (l_i - l_j) * exp(- (τ - τ_j) * ρ_B)
#         r = 3 * ρ_B * (f / l - oneunit(l))
#         s_M = l_j / l_s
#     else # adult
#         h_B = h_B[5]
#         l = l_i - (l_i - l_j) * exp(- (τ - τ_j) * ρ_B)
#         r = 3 * ρ_B * (f / l - oneunit(l))
#         s_M = l_j / l_s
#     end

#     return d_output(; f, q, l, g=g * s_M, r, s_G, h_a, h_A, h_B, S, thinning)
# end
# function d_qhSt(::typeof(abp()), qhSt, pars, τ)
#     (; f, τ_p, l_b, l_p, ρ_j, g, s_G, h_a, h_B, thinning) = pars
#     (q, h_A, S) = qhSt

#     if τ < τ_p
#         h_B = h_B[2]
#         l = l_b * exp(τ * ρ_j / 3)
#         r = ρ_j
#         s_M = l / l_b
#     else # adult
#         h_B = h_B[3]
#         l = l_p
#         r = zero(ρ_j)
#         s_M = l_p / l_b
#     end

#     return d_output(; f, q, l, g=g * s_M, r, s_G, h_a, h_A, h_B, S, thinning)
# end
# function d_qhSt(::Union{typeof(hex()),typeof(hax()),typeof(hep())}, qhSt, pars, τ)
#     (; f, τ_je, l_b, l_p, l_e, g, s_G, h_a, h_B) = pars
#     (q, h_A, S) = qhSt

#     if τ < τ_je # time till pupation (τ=0 at start pupation)
#         h_B = h_B[3]
#         h = h_A + h_B 
#         dq = 0.0 # TODO use the correct units for this
#         dh_A = zero(q)
#     else
#         h_B = h_B[4]
#         h = h_A + h_B 
#         s_M = l_p / l_b
#         dq = f * (q * l_e^3 * s_G + h_a) * g * s_M / l_e
#         dh_A = q
#     end

#     dS = -h * S
#     dt = S

#     return SVector((dq, dh_A, dS, dt))
# end


# Older deprecated methods

# was: get_tm_s(p, f, lb, lp)
#
## Description
# Obtains scaled mean age at death assuming a short growth period relative to the life span
# Divide the result by the somatic maintenance rate coefficient to arrive at the mean age at death.
# The variant get_tm_foetus does the same in case of foetal development.
# If the input parameter vector has only 4 elements (for [g, lT, ha/ kM2, sG]),
#   it skips the calulation of the survival probability at birth and puberty.
#
# Input
#
# * p: 4 or 7-vector with parameters: [g lT ha sG] or [g k lT vHb vHp ha SG]
# * f: optional scalar with scaled reserve density at birth (default eb = 1)
# * lb: optional scalar with scaled length at birth (default: lb is obtained from get_lb)
#
# Output
#
# * tm: scalar with scaled mean life span
# * info: indicator equals 1 if successful, 0 otherwise
## Remarks
# Obsolete function; please use get_tm_mod.
# Theory is given in comments on DEB3 Section 6.1.1.
# See <get_tm.html *get_tm*> for the general case of long growth period relative to life span
function compute_scaled_mean(::Since{<:Birth}, at::Ultimate, e::AbstractEstimator, p, lb)
    (; g, l_T, ha, s_G, f) = p

    # TODO: explain - for numerical stability?
    if abs(s_G) < 1e-10
        s_G = 1e-10
    end

    li = f - l_T
    hW3 = ha * f * g / 6 / li
    hW = hW3^(1 / 3) # scaled Weibull aging rate
    hG = s_G * f * g * li^2
    hG3 = hG^3       # scaled Gompertz aging rate
    tG = hG / hW
    tG3 = hG3 / hW3  # scaled Gompertz aging rate

    info_lp = 1

    # TODO: explain these branches, and test them
    if abs(s_G) < 1e-10
        error("This abs(s_G) < 1e-10 branch has never been used")
        tm = gamma(4 / 3) / hW
        tm_tail = 0
    elseif hG > 0
        tm = 10 / hG # upper boundary for main integration of S(t)
        tm_tail = expint(exp(tm * hG) * 6 / tG3) / hG
        tm = _integrate_quad(hW, tG, tm, tm_tail)
    else # hG < 0
        error("This hG < 0 branch has never been used")
        tm = -1e4 / hG # upper boundary for main integration of S(t)
        hw = hW * sqrt(-3 / tG) # scaled hW
        tm_tail = sqrt(pi) * erfc(tm * hw) / 2 / hw 
        tm = _integrate_quad(hW, tG, tm, tm_tail)
    end

    return (; t_m=tm)
end

## Description
# Obtains scaled age at birth, given the scaled reserve density at birth. 
# Divide the result by the somatic maintenance rate coefficient to arrive at age at birth. 
#
# Input
#
# * p: 1 or 3-vector with parameters g, k_J/ k_M, v_H^b
#
#     Last 2 values are optional in invoke call to get_lb
#
# * eb: optional scalar with scaled reserve density at birth (default eb = 1)
#  
# Output
#
# * τ_b: scaled age at birth \τ_b = a_b k_M
# * lb: scalar with scaled length at birth: L_b/ L_m
# * info: indicator equals 1 if successful, 0 otherwise

## Remarks
# was get_tb
function compute_scaled_mean(::Since{<:Conception}, at::Birth, pars::NamedTuple, eb::Number)
    (; g) = pars # energy investment ratio
    info = true
    l, info = compute_length(at, pars; eb)

    # TODO explain all of this math
    xb = g / (eb + g)
    αb = 3 * g * xb^(1 / 3) / l
    f1 = incomplete_beta_side(xb) # Precalculate f1 here rather than in _d_time_at_birth inside quadgk
    # Note: this quadgk is the most expensive call in `estimate`
    τ = 3 * quadgk(x -> _d_time_at_birth(x, αb, f1), 1e-15, xb; atol=1e-6)[1]
    return (; τ, l, info)
end

# TODO: could this range be shorter, or an accuracy parameter?
const QUAD_RANGE = 1 ./ (4:500)

function _integrate_quad(hW, tG, tm, tm_tail)
    # Performance critical!!
    # integrate_tm_s is the most deeply nested function call
    # TODO explain what 0 is, why is atol not specified
    quadgk(x -> _integrate_tm_s(QUAD_RANGE, x * hW, tG), 0, tm * hW)[1][1] + tm_tail
end

# was fnget_tm_s
# modified 2010/02/25
# called by get_tm_s for life span at short growth periods
# integrate ageing surv prob over scaled age
# t: age * hW 
# Returns: ageing survival prob
function _integrate_tm_s(range, t, tG)
    hGt = tG * t # age * hG
    if tG > 0
        # Compute the scaled dataset
        s = c = first(range) * hGt
        for i in 2:lastindex(range)
            x = range[i]
            c *= hGt * x
            s += c 
        end
        exp(-(oneunit(s) + s) * t^3)
    else # tG < 0
        error("Branch not yet tested!") 
        exp(((oneunit(hGt) + hGt + hGt^2 / 2) - exp(hGt)) * 6 / tG^3)
    end
end

# was dget_tb
function _d_time_at_birth(x::Number, αb::Number, f1::Number)
    # called by get_tb
    x ^ (-2 / 3) / (1 - x) / (αb - real(incomplete_beta_precalc(x, f1)))
end


## get_tp
# Gets scaled age and length at puberty, birth

##
## Syntax
# varargout = <../get_tp.m *get_tp*>(p, f, tel_b, τ)

## Description
# Obtains scaled ages, lengths at puberty, birth for the std model at constant food, temperature;
# Assumes that scaled reserve density e always equals f; if third input is specified and its second
# element is not equal to second input (if specified), <get_tpm *get_tpm*> is run.
#
# Input
#
# * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
# * f: optional scalar with functional response (default f = 1) or (n,2)-array with scaled time since birth and functional response
# * tel_b: optional scalar with scaled length at birth
#
#      or 3-vector with scaled age at birth, reserve density and length at 0
# * τ: optional n-vector with scaled times since birth
#
# Output
#
# * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
# * τ_p: scaled age at puberty \τ_p = a_p k_M
# * τ_b: scaled age at birth \τ_b = a_b k_M
# * lp: scaled length at puberty
# * lb: scaled length at birth
# * info: indicator equals 1 if successful, 0 otherwise

## Remarks
# Function <get_tp_foetus.html *get_tp_foetus*> does the same for foetal development; the result depends on embryonal development.
# A previous version of get_tp had as optional 3rd input a 2-vector with scaled length, l, and scaled maturity, vH, for a juvenile that is now exposed to f, but previously at another f.
# Function <get_tpm *get_tpm*> took over this use.
# Optional inputs might be empty

## Example of use
# τ_p = get_tp([.5, .1, .1, .01, .2]) or tvel = get_tp([.5, .1, .1, .01, .2],[],[],0:0.014:) 
function compute_scaled_mean(::Since{<:Conception}, at::Puberty, p::NamedTuple, state::NamedTuple)
    #  unpack pars
    (; g, k, l_T, v_Hb, v_Hp, f) = p
    τ_b, l_b = state.τ, state.l
    
    # Ensure v_Hp is greater than v_Hb
    @assert v_Hp >= v_Hb
    
    # Calculate necessary parameters
    ρ_B = 1 / (3 * (1 + f / g))
    l_i = f - l_T
    l_d = l_i - l_b
    
    info = true
    # Determine if reproduction is possible and calculate l_p and τ_p accordingly
    if k == 1 && f * l_i^2 > v_Hp * k
        l_b = v_Hb^(1 / 3)
        τ_b = get_tb(p[[1, 2, 4]], f, l_b)
        l_p = v_Hp^(1/3)
        τ_p = τ_b + log(l_d / (l_i - l_p)) / ρ_B
    elseif f * l_i^2 <= v_Hp * k
        τ_p = NaN
        l_p = NaN
        info = false
    else
        l_p, info = compute_length(Puberty(), p, l_b)
        τ_p = τ_b + log(l_d / (l_i - l_p)) / ρ_B
    end
    
    # Check if τ_p is real and positive
    if !isreal(τ_p) || τ_p < 0
        info = false
    end
    
    return (; τ=τ_p, l=l_p, info)
end

