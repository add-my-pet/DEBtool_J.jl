function predict(e::AbstractEstimator, model::DEBAnimal, par, data, temp)
    par = merge(compound_parameters(model, par), par)
    # Add male params, they will be empty if there is no dimorphic lifestage
    male = compute_male_params(model, par)
    par = merge(par, (; male))

    transitions = compute_transition_state(e, model, par)
    tr = model.temperatureresponse
    TC = tempcorr(tr, par, temp)

    # ages = _temp_correct_predictions(x -> x.a, tr, par, transitions, (Birth(), Female(Puberty()), Female(Ultimate())), TC)
    # tspan = (0.0, ustrip(u"d", last(ages)))

    # environment = ConstantEnvironment(;
    #     time=tspan,
    #     functionalresponse=par.f,
    #     tempcorrection=TC,
    # ) 
    # mpe = DEBtool_J.MetabolismBehaviorEnvironment(; metabolism=model, environment, par)
    # sol = simulate(mpe; tspan)
    # vals = map(a -> sol(ustrip(u"d", a)), ages)
    # Birth length is the same
    # @assert sol[1][2] * par.L_m / par.del_M ≈ predictions.length[1] 
    # @show predictions.length[4] 
    # @show last(vals)[2] * par.L_m / par.del_M
    # @show sol[end][2] * par.L_m / par.del_M
    # Only calculate reproduction when needed

    predictions = EstimationData(
        timesinceconception = isnothing(data.timesinceconception) ? nothing : _temp_correct_predictions(x -> x.a, tr, par, transitions, data.timesinceconception, TC),
        timesincebirth = isnothing(data.timesincebirth) ? nothing : _temp_correct_predictions(x -> x.t, tr, par, transitions, data.timesincebirth, TC),
        length = isnothing(data.length) ? nothing : map(x -> transitions[x].Lw, data.length),
        wetweight = isnothing(data.wetweight) ? nothing : map(x -> transitions[x].Ww, data.wetweight),
        gestation = isnothing(data.gestation) ? nothing : gestation(par, transitions[Birth()].τ, TC),
        reproduction = if isnothing(data.reproduction)
            nothing
        else
            (; R) = compute_reproduction_rate(e, model, par, transitions)
            r_at_t = Flatten.flatten(data.reproduction, AtTemperature)
            RT = if isempty(r_at_t)
                R * TC
            else
                TC_R = tempcorr(tr, par, only(r_at_t).t)
                R * TC_R
            end
        end,
        variate = if isnothing(data.variate)
            nothing
        else
            # uni-variate data
            map(data.variate) do u
                compute_variate(e, model, u, par, transitions, TC)
            end
        end
     )

    info = true 
    # Sort the returned value to match the data
    return (; predictions, info)
end

function _temp_correct_predictions(fieldgetter::Function, tr, par::NamedTuple, ls::Transitions, pred, TC::Number)
    map(pred) do p
        if p isa AbstractTransition{<:AtTemperature}
            fieldgetter(ls[p]) / tempcorr(tr, par, p.val.t)
        else
            fieldgetter(ls[p]) / TC
        end
    end
end
