function fieldnmnst_st(data)
    # created 2013/05/02 by Gonçalo Marques; modified 2013/09/27
    #
    ## Description
    #  creates a list of field names of a structure and its number
    #
    ## Input
    #  st: a matlab structure 
    #  
    ## Output
    #  nm: vector of field names
    #  nst: number of fields
    #
    ## Remarks
    #  fieldnmnst_st will produce a list of the fields of the last level of
    #  the structure. For example for the structure x with:
    #  x.len
    #  x.len.dat1
    #  x.len.dat2
    #  x.temp
    #  x.reprod
    #  x.reprod.dat
    #  the list of field names will be:
    #  nm = ["len.dat1", "len.dat2", "temp", "repod.dat"]
    fields = String.(collect(keys(data)))
    #fields = String.(collect(keys(data...)))
    fields2 = nothing
     if data[1][i] isa NamedTuple
        if i == 1
            fields2 = (species .* '.' .* (fields[i] .* '.')) .* String.(collect(keys(data[1][i])))
        else
            fields2 =  (species .* '.' .* fields[1:(i-1)], (species .* '.'.* (fields[i] .* '.')) .* String.(collect(keys(data[1][i]))))
        end
     else
        if i == 1
            fields2 = species .* '.'.* fields[i]
        else
            fields2 = (species .* '.' .* fields[1:i], species .* '.'.* fields[i])
        end
     end
    nm = collect(Iterators.flatten(fields2))
    nst = length(nm)
    # ## Code
    # nm = fieldnames(typeof(data))
    # nst = length(nm) # number of data sets
    # baux = 1
    # while baux == 1
    #     nmaux = []
    #     baux = 0
    #     for i = 1:nst
    #         #eval(['isstruct(st.', nm{i}, ')'])
    #         nmi = Symbol("data." * nm[i])
    #         #if eval(Meta.parse("length(fieldnames(typeof(data.$nmi)))")) > 1#eval(['isstruct(st.', nm{i}, ')'])
    #         #    eval(Meta.parse("vaux=fieldnames(typeof(data.$nmi))"))
    #         if isa(getproperty(data, Symbol(nmi)), NamedTuple)#length(fieldnames(typeof(getproperty(data, Symbol(nmi))))) > 1#eval(['isstruct(st.', nm{i}, ')'])
    #             vaux=fieldnames(typeof(getproperty(data, Symbol(nmi))))
    #             #eval(["vaux = fieldnames(st.", nm{i}, ");"]);
    #             nv = length(vaux)
    #             for j = 1:nv
    #                 #nmaux = [nmaux; cellstr(strcat(nm{i}, ".", vaux{j}))];
    #                 push!(nmaux, string(nm[i], ".", vaux[j]))
    #             end
    #             baux = 1
    #         else
    #             # nmaux = [nmaux; nm(i)];
    #             push!(nmaux, nm[i])
    #         end
    #     end
    #     nm = deepcopy(nmaux)
    #     nst = length(nm)        
    # end
    return (nm, nst)
end
