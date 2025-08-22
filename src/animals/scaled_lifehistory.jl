"""
    scaled_mean_lifehistory 

# TODO better name like scaled_mean_lifehistory

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
# function scaled_mean_lifehistory(model, p; 
#     abstol=1e-7, 
#     reltol=1e-7,
#     callback=DiscreteCallback(dead_for_sure, terminate!),
#     thinning=false,
#     solver=Tsit5(),
#     h_B=zeros(length(life(model))),
#     kw...
# )
#     scaled_mean_lifehistory(model.mode, model, p; 
#         callback, solver, abstol, reltol, thinning, h_B, kw...
#     )
# end

# function scaled_mean_lifehistory(
#     mode::Union{typeof(std()),typeof(stf()),typeof(sbp())}, model, p; 
#     solver, thinning, h_B, kw...
# )
#     (; g, k, v_Hb, h_a, s_G, f) = p
#     (; S_b, q_b, h_Ab, τ_b) = survival_probability(Birth(), model, merge(p, (; h_B0b=h_B[1], ρ_N=0.0)))
#     # TODO: better handling of f/eb functional response at birth
#     birth_state = scaled_mean(Since(Fertilisation()), Birth(), p, f) # -, scaled ages and lengths at birth
#     puberty_state = scaled_mean(Since(Fertilisation()), Puberty(), merge(p, (; l_T=0.0)), birth_state) # -, scaled ages and lengths at puberty
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
# function scaled_mean_lifehistory(mode::typeof(sbp()), model, p; 
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
# function scaled_mean_lifehistory(mode::typeof(stf()), model, p; h_B=zeros(5), thinning=false)
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
# function scaled_mean_lifehistory(mode::typeof(stx()), model, p; 
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
# function scaled_mean_lifehistory(mode::typeof(ssj()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hs, v_Hp, t_sj, k_E, h_a, s_G, f) = p

#     sp_pars = (; g, k, v_Hb, h_a, s_G, h_B=h_B[1], ρ_N=0.0, f)
#     (; S_b, q_b, h_Ab, τ_b) = survival_probability(Birth(), model, sp_pars) 
     
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
# function scaled_mean_lifehistory(mode::typeof(abj()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hj, v_Hp, h_a, s_G, f) = p
#     (; τ_m, τ_p, τ_j, τ_b, S_p, S_j, S_b, info) = get_tm_j([g, k, 0, v_Hb, v_Hj, v_Hp, h_a, s_G], f)

#     S = [S_b, S_j, S_p]
#     τ = [τ_b, τ_j, τ_p]
#     return (; τ_m, S, τ)
# end
# function scaled_mean_lifehistory(mode::typeof(asj()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hs, v_Hs, v_Hp, h_a, s_G, f) = p
#     sp_pars = (; g, k, v_Hb, h_a, s_G, h_B=h_B[1], ρ_N=0.0, f)
#     (; S_b, q_b, h_Ab, τ_b) = survival_probability(Birth(), model, sp_pars)
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
# function scaled_mean_lifehistory(mode::typeof(abp()), model, p;
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
# function scaled_mean_lifehistory(mode::typeof(hep()), model, p;
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
# function scaled_mean_lifehistory(mode::typeof(hax()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_Hp, v_Rj,v_He, κ, κ_V, h_a, s_G, f) = p
#     (; τ_j, τ_e, τ_p, τ_b, l_j, l_e, l_p, l_b, l_i, ρ_j) = get_tj_hax((; g, k, v_Hb, v_Hp, v_Rj, v_He, κ, κ_V, f))

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
# function scaled_mean_lifehistory(mode::typeof(hex()), model, p;
#     solver, h_B, thinning, kw...
# )
#     (; g, k, v_Hb, v_He, s_j, κ, κ_V, h_a, s_G, f) = p
#     (; τ_j, τ_e, τ_b, l_j, l_e, l_b, ρ_j) = get_tj_hex((; g, k, v_Hb, v_He, s_j, κ, κ_V, f));

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


