## setweights
# Sets automatically the weights for the data (to be used in a regression)  
#
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
setweights(data) = Flatten.modify(generateweight, data, SELECT)

function generateweight(d::AbstractArray)
    nvar = size(d, 2)
    if nvar == 1 # uni- or bi-variate data
        N = size(d, 1)
        SVector{N}(ones(N)) / N / nvar
    else # tri-variate data
        error("Multiple columns of data not yet tested")
        # N = size(getproperty(data, nm[i]), 1)
        # nvar = size(getproperty(data, nm[i]), 3)
        # weight = merge(weight, (nm[i] => ones(N, nvar, npage) / N / nvar / npage,))
    end
end
generateweight(d::Univariate) = generateweight(d.dependent.val)
generateweight(d::AtTemperature) = generateweight(d.x)
generateweight(d::Number) = 1.0
