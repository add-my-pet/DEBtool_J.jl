function predict(e::AbstractEstimator, model::DEBOrganism, par, data, temp)

    compound_par = compound_parameters(model, par)
    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    par = merge(par, compound_par, (; d_V))
    # Add male params, will be empty if there is no dimorphic lifestage
    male = compute_male_params(model, par)
    par = merge(par, (; male))
    transitions = compute_transition_state(e, model, par)

    tr = model.temperatureresponse
    TC = tempcorr(tr, par, temp)
    (; R) = compute_reproduction_rate(e, model, par, transitions)
    r_at_t = Flatten.flatten(data.reproduction, AtTemperature)
    RT = if isempty(r_at_t)
        R * TC
    else
        TC_R = tempcorr(tr, par, only(r_at_t).t)
        R * TC_R
    end

    predictions = (
        timesinceconception = _temp_correct_predictions(x -> x.a, tr, par, transitions, data.timesinceconception, TC),
        timesincebirth = _temp_correct_predictions(x -> x.t, tr, par, transitions, data.timesincebirth, TC),
        length = map(x -> transitions[x].Lw, data.length),
        wetweight = map(x -> transitions[x].Ww, data.wetweight),
    )
    ages = _temp_correct_predictions(x -> x.a, tr, par, transitions, (Birth(), Female(Puberty()), Female(Ultimate())), TC)
    tspan = (0.0, ustrip(u"d", last(ages)))

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
    if !isnothing(data.reproduction)
        (; R) = compute_reproduction_rate(e, model, par, transitions)
        r_at_t = Flatten.flatten(data.reproduction, AtTemperature)
        RT = if isempty(r_at_t)
            R * TC
        else
            TC_R = tempcorr(tr, par, only(r_at_t).t)
            R * TC_R
        end
        predictions = merge(predictions, (; reproduction=RT))
    end
    if !isnothing(data.univariate)
        # uni-variate data
        univariate = map(data.univariate) do u
            compute_univariate(e, model, u, par, transitions, TC)
        end
        predictions = merge(predictions, (; univariate))
    end
    predictions = EstimationData(; predictions...)

    info = true # TODO get this from solves
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
