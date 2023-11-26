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

    nm, nst = fieldnm_wtxt(data, "psd")
    if nst > 0
        # unpack coefficients
        cPar = parscomp_st(par)  #allPar = par;
        #allPar = ntuple(i -> getfield(par, fieldnames(typeof(par))[i]), length(fieldnames(typeof(par))))
        #allPar = NamedTuple{Tuple(fieldnames(typeof(par)))}(tuple(getfield(par, f) for f in fieldnames(typeof(par))))
        npar = length(fieldnames(typeof(par)))
        global allPar = NamedTuple{Tuple(map(Symbol, fieldnames(typeof(par)))[1:npar-1])}(
            getfield.(Ref(par), fieldnames(typeof(par))[1:npar-1]),
        )
        fieldNames = fieldnames(typeof(cPar))
        for i = 1:length(fieldNames)
            fldnm = fieldNames[i]
            eval(Meta.parse("allPar = merge(allPar, ($fldnm = cPar.$fldnm,))"))
        end

        fldnm = nm[1]

        # TO DO - why does it need .Emydura_macquarii here?
        varnm = eval(Meta.parse("fieldnames(typeof(data.Emydura_macquarii.$fldnm))"))

        # adds pseudodata predictions to structure
        for i = 1:length(varnm)
            varnm2 = String(varnm[i])
            if i == 1
                eval(Meta.parse("psdtemp = ($varnm2 = allPar.$varnm2,)"))
            else
                eval(Meta.parse("psdtemp = merge(psdtemp, ($varnm2 = allPar.$varnm2,))"))
            end
            #prdData.psd.(varnm{i}) = allPar.(varnm{i});
        end
        prdData = merge(prdData, (psd = psdtemp,))
    end
    return (prdData)
end
