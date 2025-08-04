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
defaultweights(data) = Flatten.modify(_defaultweight, data, SELECT)

function _defaultweight(d::AbstractArray)
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
_defaultweight(d::Univariate) = _defaultweight(d.dependent.val)
_defaultweight(d::AtTemperature) = _defaultweight(d.x)
_defaultweight(d::Number) = 1.0
