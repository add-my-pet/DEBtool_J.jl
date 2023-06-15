## fieldnm_wtxt
# Searches for fields with a given name in a multilevel structure 

##
function fieldnm_wtxt(st, txt)
    # created 2015/01/17 by Goncalo Marques

    ## Syntax
    # [nm, nst] = <../fieldnm_wtxt.m *fieldnm_wtxt*> (st, txt)

    ## Description
    # creates a list of field names of a structure with txt and its number
    #
    # Inputs:
    #
    # * st : structure to be searched
    # * txt : string with field name to be searched
    #
    # Output: 
    #
    # * nm : vector containing the fields with the string txt
    # * nst : scalar with the size of nm

    ## Example of use
    #  Suppose one has the structure x with the following fields:
    #    x.value.temp
    #    x.value.len
    #    x.value.reprod
    #    x.unit.temp
    #    x.unit.len
    #    x.temp
    #  the command fieldnm_wtxt(x, 'temp') will produce
    #    nm = ['x.value.temp', 'x.unit.temp', 'x.temp']
    #    nst = 3


    nmaux = fieldnames(typeof(st))
    nmaux2 = collect(nmaux)
    fullnmaux = []
    fullnm = []
    while length(nmaux2) > 0
        if nmaux2[1] == Symbol(txt)
            fullnm = [fullnm; txt]
        elseif isa(getproperty(st, nmaux2[1]), psdData_struct)
            fullnmaux = [fullnmaux; nmaux2[1]]
        end
        popfirst!(nmaux2)
    end

    while length(fullnmaux) > 0
        nmaux = fieldnames(typeof(getproperty(st, fullnmaux[1])))
        nmaux2 = collect(nmaux)
        for i in 1:length(nmaux2)
            if nmaux2[i] == txt
                push!(fullnm, join(fullnmaux[1], txt, "."))
            elseif isstruct(getproperty(st, joinpath(fullnmaux[1], nmaux2[i])))
                push!(fullnmaux, join(fullnmaux[1], nmaux2[i], "."))
            end
        end
        popfirst!(fullnmaux)
    end
    nm = fullnm
    nst = length(fullnm)
    return (; nm, nst)
end
