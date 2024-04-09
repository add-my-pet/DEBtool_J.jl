function addpseudodata()
    ## addpseudodata
# Adds pseudodata information into inputed data structures 

##
#function [data, units, label, weight] = addpseudodata(data, units, label, weight)
# created 2015/01/16 by Goncalo Marques and Bas Kooijman, 2018/08/26 Bas Kooijman

## Syntax
# [data, units, label, weight] = <../addpseudodata.m *addpseudodata*> (data, units, label, weight)

## Description
# Adds the pseudodata information and weights for purposes of the regression
#
# Inputs:
#
# * data : structure with data values 
# * units : structure with data units 
# * label : structure with data labels 
# * weight : structure with data weights for a regression 
#
# Output: 
#
# * data : structure with data and pseudodata values 
# * units : structure with data and pseudodata units 
# * label : structure with data and pseudodata labels 
# * weight : structure with data and pseudodata weights for a regression 

## Example of use
# [data, units, label, weight] = addpseudodata([], [], [], []);
# Will create the four structures data, units, label and weight with pseudodata information

#global loss_function
#= module addpseudodata
using Parameters
using ModelParameters
using Unitful
using Unitful: °C, K, d, g, cm, mol, J =#
# set pseudodata
    
psdData = (;
    v = 0.02u"cm/d",
    kap = 0.8,
    kap_R = 0.95,
    p_M = 18u"J/d/cm^3",
    k_J = 0.002u"d^-1",
    kap_G = 0.8,
    k = 0.3
)

psdLabel = (;
    v = "energy conductance",
    kap = "allocation fraction to soma",
    kap_R = "reproduction efficiency",
    p_M = "vol-spec som maint",
    k_J = "maturity maint rate coefficient",
    kap_G = "growth efficiency",
    k = "maintenance ratio"
)

# set weights
psdWeight = (;
    v = 0.1,
    kap = 0.1,
    kap_R = 0.1,
    p_M = 0.1,
    k_J = 0.1,
    kap_G = 0.1 * 200, # more weight to kap_G
    k = 0.1
)

# if strcmp(loss_function, 'su')
#   psdWeight.v     = 10^(-4) * psdWeight.v;
#   psdWeight.p_M   = 10^(-4) * psdWeight.p_M;
#   psdWeight.k_J   = 10^(-4) * psdWeight.k_J;
#   psdWeight.kap_R = 10^(-4) * psdWeight.kap_R;
#   psdWeight.kap   = 10^(-4) * psdWeight.kap;
#   psdWeight.kap_G = 10^(-4) * psdWeight.kap_G;
# end
# export(psdData)
# export(psdLabel)
# export(psdWeight)
# export(psdUnits)
# end
(psdData, psdLabel, psdWeight)
end