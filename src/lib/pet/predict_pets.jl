function predict_pets(parGrp, data, auxData)
    # created 2015/01/17 by Goncalo Marques, modified 2015/03/30 by Goncalo Marques
    # modified 2015/08/03 by Starrlight, 2015/08/26 by Goncalo Marques, 2018/05/22 by Bas Kooijman

    ## Syntax
    # [prdData, info] = <../predict_pets.m *predict_pets*>(parGrp, data, auxData)

    ## Description
    # get predictions from predict files
    #
    # Input
    # 
    # * parGrp: structure with par for several pets
    # * data: structure with data for several pets
    # * auxData: structure with auxiliary data for several pets
    #
    # Output
    #
    # * prdData: structure with predictions for several pets
    # * info: scalar with combined success (1) or failure (0) of predictions

    info = false
    mypet = parGrp
    parPets = parPets_struct(mypet)
    prdData = NamedTuple()
    # produce predictions

        petnm = "mypet"
        out = predict(parPets.mypet, data.mypet, auxData.mypet)
        outData = out[1]
        info = out[2]
        petnm = "mypet"
        prdData = (; mypet = outData)
        if ~info
            return
        end
        # predict pseudodata
        outPseudoData = predict_pseudodata(parPets.mypet, data.mypet, prdData.mypet)
        prdData = (; mypet = outPseudoData)

    return(;prdData, info)
end