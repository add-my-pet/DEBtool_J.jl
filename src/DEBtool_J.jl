module DEBtool_J

using ModelParameters
using Unitful
using Unitful: °C, K, d, g, cm, mol, J
using Statistics
using Random
using SpecialFunctions
using QuadGK
using SciMLBase
using OrdinaryDiffEqTsit5
using Roots
using ModelParameters.Flatten
using StaticArrays
using DataInterpolations
using ComponentArrays
using DelimitedFiles

import ModelParameters.ConstructionBase

export Estimator, DEBNelderMead, DEBMultimodalEvolutionaryAlgorithm
export Simulator
export DEBAnimal
export MetabolismBehaviorEnvironment
export ArrheniusResponse, LowTorporResponse, HighTorporResponse, LowAndHighTorporResponse
export LifeCycle, LifeStages, Transitions, Dimorphic
export Fertilisation, Birth, Weaning, Puberty, Maturity, Ultimate, Moult, Emergence
export Embryo, Foetus, Baby, Juvenile, Adult, Instar, Pupa, Imago
export Gestation
export Female, Male
export AtTemperature, Weighted
export EstimationData, Univariate, Multivariate, Time, Temperature, Length, FunctionalResponse, Food, DryWeight, WetWeight, O2Consumption, CO2Production, Duration, Period
export AbstractEnvironment, Environment, ConstantEnvironment
export Standard, Accelerated, Hemimetabolous, Holometabolous
export std, stf, stx, sbp, abj, abp, asj, hep, hex, hax, iso221, plant
export std_animal, stf_animal, stx_animal, sbp_animal,
    abj_animal, abp_animal, asj_animal,
    hep_animal, hex_animal, hax_animal, iso221_animal, plant_model
export Iso221, Plant

export estimate, simulate

export defaultpseudodata, defaultweights, defaultchemistry, default_d_V
export compound_parameters

include("simulation/environment.jl")
include("simulation/behavior.jl")
include("sex.jl")
include("estimation/data.jl")
include("estimation/estimation.jl")

include("organism.jl")
include("const.jl")
include("chemistry.jl")
include("synthesizing_units.jl")
include("temperature.jl")

# TODO rethink how estimation/simulation are separated in animals folder
include("animals/lifestages.jl")
include("animals/modes.jl")
include("animals/transition_state.jl")
include("animals/survival_probability.jl")
include("animals/reproduction.jl")
include("animals/scaled_age.jl")
include("animals/length.jl")
include("animals/parameters.jl")
include("animals/init.jl")
include("animals/ode/utils.jl")
include("animals/ode/scaled.jl")
include("animals/ode/unscaled.jl")

# iso221: 2-food, 2-reserve, 1-structure model
include("animals/parameters_iso221.jl")
include("animals/ode/sgr_iso221.jl")
include("animals/ode/iso221_embryo.jl")
include("animals/ode/iso221.jl")

# plant: 2-organ (shoot + root), 2-reserve (C, N) isomorph plant model
# ODE files first so that compound_parameters in parameters_plant.jl can call them
include("plants/ode/rate_plant.jl")
include("plants/ode/assimilation_plant.jl")
include("plants/ode/seed_plant.jl")
include("plants/ode/plant.jl")
include("plants/parameters_plant.jl")

include("estimation/loss.jl")
include("estimation/solvers.jl")
include("estimation/weights.jl")
include("estimation/pseudodata.jl")
include("estimation/predict.jl")

include("simulation/simulate.jl")
include("simulation/traits.jl")

end # module DEBtool_J

