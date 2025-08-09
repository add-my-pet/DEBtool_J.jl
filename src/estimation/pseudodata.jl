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

    # if strcmp(loss_function, 'su')
    #   psdWeight.v     = 10^(-4) * psdWeight.v;
    #   psdWeight.p_M   = 10^(-4) * psdWeight.p_M;
    #   psdWeight.k_J   = 10^(-4) * psdWeight.k_J;
    #   psdWeight.κ_R = 10^(-4) * psdWeight.κ_R;
    #   psdWeight.κ   = 10^(-4) * psdWeight.κ;
    #   psdWeight.κ_G = 10^(-4) * psdWeight.κ_G;
    # end
    
    # data = merge(pseudodata, data)
    # weights = merge(pseudoweights, weights)

    # return (; data, label, weights)
# end

# created 2015/02/04 by Goncalo Marques
# modified 2015/07/29

## Syntax
# prd = <../predict_pseudodata.m *predict_pseudodata*> (par, data, prdData)

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
# * prdData : structure with predicted data and pseudodata 

## Example of use
# prdData = predict_pseudodata(par, data, prdData)
function predict_pseudodata(model, par, data::EstimationFields, predicted::EstimationFields)
    if !isnothing(data.pseudo)
        compound_pars = merge(compound_parameters(model, par), par)
        common_keys = _common_keys(data.pseudo, compound_pars)
        predicted = ConstructionBase.setproperties(predicted, (; pseudo=merge(data.pseudo, compound_pars[common_keys])))
    end
    return predicted
end

@generated function _common_keys(::NamedTuple{K1}, ::NamedTuple{K2}) where {K1,K2}
    Expr(:tuple, map(QuoteNode, intersect(K1, K2))...)
end
