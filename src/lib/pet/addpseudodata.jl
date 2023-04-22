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
@with_kw mutable struct psdData_struct{L,R,M}
    v::L = 0.02cm/d
    kap::Float64 = 0.8
    kap_R::Float64 = 0.95
    p_M::M = 18J/d/cm^3
    k_J::R = 0.002d^-1
    kap_G::Float64 = 0.8
    k::Float64 = 0.3
end
psdData = psdData_struct()

@with_kw mutable struct psdUnits_struct
    v::String = "cm/d"
    kap::String = "-"
    kap_R::String = "-"
    p_M::String = "J/d.cm^3"
    k_J::String = "1/d"
    kap_G::String = "-"
    k::String = "-"
end
psdUnits = psdUnits_struct()

@with_kw mutable struct psdLabel_struct
    v::String = "energy conductance"
    kap::String = "allocation fraction to soma"
    kap_R::String = "reproduction efficiency"
    p_M::String = "vol-spec som maint"
    k_J::String = "maturity maint rate coefficient"
    kap_G::String = "growth efficiency"
    k::String = "maintenance ratio"
end
psdLabel = psdLabel_struct()

# set weights
@with_kw mutable struct psdWeight_struct
    v::Float64 = 0.1
    kap::Float64 = 0.1
    kap_R::Float64 = 0.1
    p_M::Float64 = 0.1
    k_J::Float64 = 0.1
    kap_G::Float64 = 0.1
    k::Float64 = 0.1
end
psdWeight = psdWeight_struct()

psdWeight.kap_G = 200 * psdWeight.kap_G;   # more weight to kap_G

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