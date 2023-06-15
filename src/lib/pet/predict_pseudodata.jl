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
    cPar = parscomp_st(par)
    npar = length(fieldnames(typeof(par)))
    allPar = NamedTuple{Tuple(map(Symbol, fieldnames(typeof(par)))[1:npar-1])}(getfield.(Ref(par), fieldnames(typeof(par))[1:npar-1]))

    fieldNames = fieldnames(typeof(cPar))
    allPar = merge(allPar, NamedTuple(fldnm => getfield(cPar, fldnm) for fldnm in fieldNames))
    # TO DO - need to make this use 'nm' instead
    varnm = fieldnames(typeof(data.psd))
    psdtemp = NamedTuple{varnm}(getfield(allPar, Symbol(v)) for v in varnm)
    prdData = merge(prdData, (psd=psdtemp,))
  end
  return (prdData)
end