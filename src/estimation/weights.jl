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
defaultweights(data) = Flatten.modify(_defaultweight, data, Union{SELECT,Weighted})

const DEFAULT_NUMBER_WEIGHT = 1.0

# Weighted have pre-specified weights
function _defaultweight(d::Weighted)
    v = inner_val(d)
    if v isa Number
        return d.weight
    elseif v isa AbstractArray
        w = d.weight / length(v)
        return map(_ -> w, v)
    else
        error("$v is not a valid type to add weight to")
    end
end
_defaultweight(d::Data) = _defaultweight(d.val)
_defaultweight(d::Univariate) = _defaultweight(d.dependent)
_defaultweight(d::Multivariate) = map(_defaultweight, d.dependents)
_defaultweight(d::AtTemperature) = _defaultweight(d.val)
_defaultweight(d::AbstractLifeStage) = _defaultweight(d.val)
_defaultweight(d::AbstractTransition) = _defaultweight(d.val)

# Numbers have a default weight
_defaultweight(d::Number) = DEFAULT_NUMBER_WEIGHT
# Vectors the weight is divided by the length.
# TODO: this is an opinionated approach, there should be other options
function _defaultweight(d::AbstractVector)
    N = length(d)
    weight = DEFAULT_NUMBER_WEIGHT / N
    return map(_ -> weight, d)
end
