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
    fullnmaux = Symbol[]
    fullnm = Symbol[]

    #   while length(nmaux) > 0
    #     if strcmp(nmaux(1), txt)
    #       fullnm = {txt};
    #     elseif eval(['isstruct(st.' , nmaux{1}, ')'])
    #       fullnmaux = [fullnmaux; nmaux(1)];      
    #     end
    #     nmaux(1) = [];
    #   end

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
        for i = 1:length(nmaux)
            if nmaux2[i] == txt
                push!(fullnm, join(fullnmaux[1], txt, "."))
            elseif isstruct(getproperty(st, joinpath(fullnmaux[1], nmaux2[i])))
                push!(fullnmaux, join(fullnmaux[1], nmaux2[i], "."))
            end
        end
        popfirst!(fullnmaux)
    end

    #   while length(fullnmaux) > 0
    #     eval(['nmaux = fieldnames(st.', fullnmaux{1},');']);
    #     for i = 1:length(nmaux)
    #       if strcmp(nmaux(i), txt)
    #         fullnm = [fullnm; cellstr(strcat(fullnmaux{1}, '.', txt))];
    #       elseif eval(['isstruct(st.',fullnmaux{1} ,'.' , nmaux{i}, ')'])
    #         fullnmaux = [fullnmaux; cellstr(strcat(fullnmaux{1}, '.', nmaux{i}))];
    #       end
    #     end
    #     fullnmaux(1) = [];
    #   end

    nm = fullnm
    nst = length(fullnm)
    return (; nm, nst)
end
