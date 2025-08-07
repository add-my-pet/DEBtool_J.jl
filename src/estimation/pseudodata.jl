# Adds pseudodata information into inputed data structures 
# was addpseudodata
function defaultpseudodata(custom::Union{NamedTuple,Nothing}=nothing)
    # TODO explain and justify these
    defaults = (;
        v = 0.02u"cm/d",
        κ = 0.8,
        κ_R = 0.95,
        p_M = 18u"J/d/cm^3",
        k_J = 0.002u"d^-1",
        κ_G = 0.8,
        k = 0.3
    )
    return isnothing(custom) ? defaults : merge(defaults, custom)
end

    # label = (;
    #     v = "energy conductance",
    #     κ = "allocation fraction to soma",
    #     κ_R = "reproduction efficiency",
    #     p_M = "vol-spec som maint",
    #     k_J = "maturity maint rate coefficient",
    #     κ_G = "growth efficiency",
    #     k = "maintenance ratio"
    # )

function defaultpseudoweights(custom::Union{NamedTuple,Nothing})
    # TODO explain and justify these
    defaults = (;
        v = 0.1,
        κ = 0.1,
        κ_R = 0.1,
        p_M = 0.1,
        k_J = 0.1,
        κ_G = 0.1 * 200, # more weight to κ_G
        k = 0.1
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
function predict_pseudodata(model, par, data::EstimationData, predicted::EstimationData)
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
