# Adds pseudodata information into inputed data structures 
# was addpseudodata
function defaultpseudodata(custom::Union{NamedTuple,Nothing}=nothing)
    # TODO explain and justify these
    defaults = (;
        v = Weighted(0.1, 0.02u"cm/d"),
        κ = Weighted(0.1, 0.8),
        κ_R = Weighted(0.1, 0.95),
        p_M = Weighted(0.1, 18u"J/d/cm^3"),
        k_J = Weighted(0.1, 0.002u"d^-1"),
        κ_G = Weighted(20.0, 0.8),
        k = Weighted(0.1, 0.3),
    )
    return isnothing(custom) ? defaults : merge(defaults, custom)
end

## Description

# Appends pseudodata predictions to a structure containing predictions for real data. 
# Predictions generated using the par structure
#
# Inputs:
#
# * par : structure with parameters 
# * data : structure with data
# * prdData : structure with data predictions 
#
# Output: 
#
# * predicted : structure with predicted data and pseudodata 

## Example of use
# prdData = predict_pseudodata(par, data, prdData)
function predict_pseudodata(model, par, data::EstimationFields, predicted::EstimationFields)
    if isnothing(data.pseudo)
        return predicted
    else
        all_pars = merge(compound_parameters(model, par), par)
        return ConstructionBase.setproperties(predicted, (; pseudo=all_pars[keys(data.pseudo)]))
    end
end
