## predict_pets
# get predictions from predict files

##
function predict_pets(pets, parGrp, data, auxData)
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

    global outData, outPseudoData

    info = false
    parPets = parGrp2Pets(parGrp, pets) # convert parameter structure of group of that of pets 

    # produce predictions
    n_pets = length(pets)
    for i = 1:n_pets
        petnm = pets[i]
        #[prdData.(pets{i}), info] = feval(["predict_", pets{i}], parPets.(pets{i}), data.(pets{i}), auxData.(pets{i}));
        out = eval(Meta.parse("predict_$petnm(parPets.$petnm, data.$petnm, auxData.$petnm)"))
        outData = out[1]
        info = out[2]
        petnm = pets[i]
        eval(Meta.parse("prdData = (;$petnm = outData)"))

        if ~info
            return
        end

        # predict pseudodata
        outPseudoData = eval(Meta.parse("predict_pseudodata(parPets.$petnm, data.$petnm, prdData.$petnm)"))
        eval(Meta.parse("prdData = (;$petnm = outPseudoData)"))

        #prdData.(pets{i}) = predict_pseudodata(parPets.(pets{i}), data.(pets{i}), prdData.(pets{i}));
    end
    return(;prdData, info)
end