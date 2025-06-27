function predict(e::AbstractEstimator, model::DEBOrganism, par, speciesdata) # predict
    (; data, temp) = speciesdata
    compound_par = compound_parameters(model, par)
    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    par = merge(par, compound_par, (; d_V))
    # Add male params, will be empty if there is no dimorphic lifestage
    male = compute_male_params(model, par)
    par = merge(par, (; male))
    lifestage_state = compute_transition_state(e, model.lifestages, par)

    tr = model.temperatureresponse
    TC = tempcorr(tr, par, temp)
    (; R) = compute_reproduction_rate(e, model, par, lifestage_state)
    r_at_t = Flatten.flatten(data.reproduction, AtTemperature)
    RT = if isempty(r_at_t)
        R * TC
    else
        TC_R = tempcorr(tr, par, only(r_at_t).t)
        R * TC_R
    end

    predictions = (
        age = _temp_correct_predictions(x -> x.a, tr, par, lifestage_state, data.age, TC),
        time = _temp_correct_predictions(x -> x.t, tr, par, lifestage_state, data.time, TC),
        length = map(x -> lifestage_state[x].Lw, data.length),
        wetweigth = map(x -> lifestage_state[x].Ww, data.wetweight),
    )
    # Only calculate reproduction when needed
    if haskey(data, :reproduction)
        (; R) = compute_reproduction_rate(e, model, par, lifestage_state)
        r_at_t = Flatten.flatten(data.reproduction, AtTemperature)
        RT = if isempty(r_at_t)
            R * TC
        else
            TC_R = tempcorr(tr, par, only(r_at_t).t)
            R * TC_R
        end
        predictions = merge(predictions, (; reproduction=RT))
    end
    if haskey(data, :univariate)
        # uni-variate data
        univariate = map(data.univariate) do u
            compute_univariate(e, model, u, par, lifestage_state, TC)
        end
        predictions = merge(predictions, (; univariate))
    end

    info = true # TODO get this from solves
    return (; predictions, info)
end

function _temp_correct_predictions(fieldgetter::Function, tr, par::NamedTuple, ls::LifeStages, pred, TC::Number)
    map(pred) do p
        if p isa AbstractTransition{<:AtTemperature}
            fieldgetter(ls[p]) / tempcorr(tr, par, p.val.t)
        else
            fieldgetter(ls[p]) / TC
        end
    end
end
