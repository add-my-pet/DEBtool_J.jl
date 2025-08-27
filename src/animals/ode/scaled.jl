# No e for birth
init_scaled_state(::DEBAnimal) = nothing
init_scaled_state(::DEBAnimal{<:StandardFoetalDiapause}) = (v_H=1e-20, l=1e-20, aging=()) # aging_init(o))

function d_scaled(state, at::Birth, τ) # τ: scaled time since start development
    par = at.val.par
    (; v_H, l) = state
    (; g, k, v_Hb, f) = par
    s_F = haskey(at.val.par, :s_F) ? par.s_F : 1e10
    f = getattime(at.val.environment, :food, τ)

    l_i = s_F * f # -, scaled ultimate length
    f = s_F * f   # -, scaled functional response

    dl = (g / 3) * (l_i - l) / (f + g)  # d/d τ l
    dv_H = 3 * l^2 * dl + l^3 - k * v_H # d/d τ v_H
    return (; v_H=dv_H, l=dl, aging=d_scaled_aging(state, at, τ))
end
function d_scaled(state, at::AbstractTransition, τ)
    par = at.val.par
    (; g, k, v_Hb, l_T) = par
    (; v_H, e, l) = state

    f = getattime(at.val.environment, :food, τ)

    ρ = g * (e / l - 1 - l_T / l) / (e + g) # -, spec growth rate

    de = (f - e) * g / l # d/d τ e
    dl = l * ρ / 3 # -, d/d τ l
    dv_H = e * l^2 * (l + g) / (e + g) - k * v_H # -, d/d τ v_H

    return (; v_H=dv_H, e=de, l=dl, aging=d_scaled_aging(state, at, τ))
end

scaled_transition_callback(tr::AbstractTransition, model, template) = 
    ContinuousCallback(scaled_transition_event(tr, model, template), terminate!)
# Death is a discrete event? Maybe it should be continuous on a vector?
scaled_transition_callback(tr::Ultimate, model, template) = 
    DiscreteCallback(scaled_transition_event(tr, model, template), terminate!)

# Events - based on v_H
scaled_transition_event(::Birth, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.val.par.v_Hb - u.v_H
end
scaled_transition_event(::Puberty, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.val.par.v_Hp - u.v_H
end
scaled_transition_event(::Metamorphosis, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.val.par.v_Hj - u.v_H
end
scaled_transition_event(::Weaning, model, template) = CallbackReconstructor(template) do u, t, i
    i.p.val.par.v_Hx - u.v_H
end
scaled_transition_event(::Ultimate, model, template) = CallbackReconstructor(template) do u, t, i
    u.aging.S > 1e-6
end

"""
    d_scaled_aging(state, at::AbstractTransition, τ)

# Arguments

- `state`
- `at`: An transition wrapper struct holding a `MetabolismBehaviorEnvironment` object for the simulation.
- 'τ': scaled time since birth

## State variables for `aging` field

- 'q':   -, scaled aging acceleration
- 'h_A': -, scaled hazard rate due to aging
- 'S':   -, survival prob
- 't':   -, scaled cumulative survival

"""
d_scaled_aging(state, at::AbstractTransition, τ) = d_scaled_aging(state.aging, state, at, τ)
d_scaled_aging(::Tuple{}, state, at::AbstractTransition, τ) = ()
function d_scaled_aging(aging::NamedTuple, state, at::AbstractTransition, τ)
    par = at.val.par
    thinning = false # TODO 
    (; f, g, s_G, h_a, k_M) = par
    h_a = h_a / k_M^2 # scale
    h_B = haskey(par, :h_B) ? par.h_B : 0.0 
    (; q, h_A, S, t) = aging  
    l = state.l
  
    rho_B = 1/ 3/ (1 + f/ g)g 
    r = 3 * rho_B * (f/ l - 1)g

    dq = f * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q
    dh_A = q - r * h_A
    h_X = thinning * r * 2 / 3
    h = h_A + h_B + h_X
    dS = -h * S
    dt = S

    return (; q=dq, h_A=dh_A, S=dS, t=dt) 
end

aging_init(o) = (; q=0.0, h_A=0.0, S=1.0, t=0.0)

