## predict_pseudodata
# Adds pseudodata predictions into predictions structure 

##
function predict_pseudodata(par, data, prdData)
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

    if haskey(data, :psd)
        cPar = merge(parscomp_st(par), (; par)...)
        prdData = merge(prdData, (; data.psd))
        common_symbols = intersect(keys(prdData.psd), keys(cPar))
        for symb in common_symbols
            prdData = merge(prdData, (psd=merge(prdData.psd, (symb => getproperty(cPar, symb),)),))
        end
    end
    return prdData
end
