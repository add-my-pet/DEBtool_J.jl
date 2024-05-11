## setweights
# Sets automatically the weights for the data (to be used in a regression)  

##
function setweights(data)
    # created 2015/01/16 by Goncalo Marques and Bas Kooijman; modified 2015/03/30, 2016/02/11, 2016/05/06 by Goncalo Marques

    ## Syntax
    # weight = <../setweights.m *setweights*> (data, weight)

    ## Description
    # computes weights for given data and adds it to the weight structure:
    # one divided by the number of data-points
    #
    # Inputs:
    #
    # * data : structure with data 
    # * weight : structure with weights
    #
    # Output: 
    #
    # * weight : structure with added weights from data 

    ## Example of use
    # weight = setweights(data, [])
    # computes the data weights for all data and outputs a new structure weight with the results 
    # weight = setweights(data, weight)
    # computes the missing data weights in structure weight and adds them to it 
    # Function to strip units from values
    # Function to strip units from values
    weight = (;)
    nm = fieldnames(typeof(data)) # vector of cells with names of data sets
    for i = 1:length(nm)
        nvar = size(getproperty(data, nm[i]), 2)
        #if ~isfield(weight, nm[i]) 
        if nvar == 1 # zero-variate data
            weight = merge(weight, (Symbol(nm[i]) => 1,))
        elseif nvar == 2 # uni- or bi-variate data
            N = size(getproperty(data, nm[i]), 1)
            weight = merge(weight, (Symbol(nm[i]) => ones(N, nvar - 1) / N / (nvar - 1),))
        else # tri-variate data
            N = size(getproperty(data, nm[i]), 1)
            nvar = size(getproperty(data, nm[i]), 3)
            weight = merge(weight, (Symbol(nm[i]) => ones(N, nvar, npage) / N / nvar / npage,))
        end
        #end
    end
    (weight)
end
