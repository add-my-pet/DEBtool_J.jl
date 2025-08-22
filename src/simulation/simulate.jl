"""
    simulate(s::Simulator mbe::MetabolismBehaviorEnvironment)

Simulates lifecycle trajectory, returning an OrdinaryDiffEQ.jl output.

# Arguments

- `mbe`: a `ModelBehaviorEnvironment` object

# Keywords

- `solver` OrdinaryDiffEq solver, `Tsit5()` by default. 
- `abstol` absolute tolerance, 1e-9 by default 
- `reltol` relative tolerance, 1e-9 by default 
- `tspan` timespan tuple, taken from the range of environment data by default.

was get_indDyn_mod in amptool
"""
function simulate(s::Simulator, mbe::MetabolismBehaviorEnvironment)
    (; metabolism, behavior, environment, par) = mbe
    (; solver, abstol, reltol, tspan) = s
    # Reomove any ModelParameters Model or Param wrappers
    par = stripparams(par)
    # Add compound parameters to pars
    # TODO: more generic way to do this
    par = merge(par, compound_parameters(metabolism, par))
    mbe = MetabolismBehaviorEnvironment(metabolism, behavior, environment, par)
    state_template = initialise_state(mbe)
    # Initiale state
    sr = StateReconstructor(d_sim, state_template, u"d")
    u_ref = Ref(SVector(f))

    lifestage_sols = map(transitions(metabolism)) do transition
        # Define the mode-specific callback function. This controls 
        # how the solver handles specific lifecycle events.
        p = rebuild(transition, mbe)
        u = u_ref[]
        callback = simulation_callback(p, state_template)
        # Define the ODE to solve with function, initial state, 
        # timespan and parameters
        problem = ODEProblem(sr, u, tspan, p)
        # Solve for lifestage up to transition
        sol = solve(problem, solver; callback, abstol, reltol)
        # Update transition state
        u_ref[] = to_obj(sr, sol[end])
        sol
    end

    return combine_sols!(lifestage_sols...)
end
