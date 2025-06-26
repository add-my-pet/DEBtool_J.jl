function predict(e::AbstractEstimator, model::DEBOrganism, par, speciesdata) # predict
    (; data, temp) = speciesdata
    cPar = compound_parameters(model, par)
    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    par = merge(par, cPar, (; d_V))
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
        age = map(data.age) do x
            if x isa AbstractTransition{<:AtTemperature}
                lifestage_state[x].a / tempcorr(tr, par, x.val.t)
            else
                lifestage_state[x].a / TC
            end
        end,
        time = map(data.time) do x
            if x isa AbstractTransition{<:AtTemperature}
                lifestage_state[x].t / tempcorr(tr, par, x.val.t)
            else
                lifestage_state[x].t / TC
            end
        end,
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
    #
    # predictions2 = (
    #     age = _temp_correct_predictions(tr, par, lifestage_state, data.age, TC),
    #     time = _temp_correct_predictions(tr, par, lifestage_state, data.time, TC),
    #     length = map(x -> lifestage_state[x].Lw, data.length),
    #     wetweigth = map(x -> lifestage_state[x].Ww, data.wetweight),
    #     Ri=RT,
    #     tL,
    # )

function _temp_correct_predictions(tr, par, lifestage_state, pred, TC)
    map(pred) do x
        if x isa AbstractTransition{<:AtTemperature}
            lifestage_state[x].a / tempcorr(tr, par, x.val.t)
        else
            lifestage_state[x].a / TC
        end
    end
end
