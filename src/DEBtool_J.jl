module DEBtool_J

using ModelParameters
using Unitful
using Unitful: °C, K, d, g, cm, mol, J
using Statistics
using Random
using SpecialFunctions
using QuadGK
using OrdinaryDiffEq
using Roots
using ModelParameters.Flatten
using StaticArrays
using DataInterpolations
using ComponentArrays
using DelimitedFiles

import ModelParameters.ConstructionBase

export Estimator, DEBNelderMead, DEBMultimodalEvolutionaryAlgorithm
export DEBAnimal
export ModelParEnv
export ArrheniusResponse, LowTorporResponse, HighTorporResponse, LowAndHighTorporResponse
export LifeCycle, LifeStages, Transitions, Dimorphic
export Conception, Birth, Weaning, Puberty, Maturity, Ultimate, Moult, Emergence
export Embryo, Foetus, Baby, Juvenile, Adult, Instar, Pupa, Imago
export Gestation
export Female, Male
export AtTemperature, Weighted
export EstimationData, Univariate, Multivariate, Time, Temperature, Length, FunctionalResponse, Food, DryWeight, WetWeight, Duration, Period
export AbstractEnvironment, Environment, ConstantEnvironment
export Standard, FoetalDevelopment, FoetalDevelopmentX, GrowthCeasesAtPuberty, Accelerated, Hemimetabolous, Holometabolous
export std, stf, stx, sbp, abj, abp, asj, hep, hex, hax
export std_animal, stf_animal, stx_animal, sbp_animal, 
    abj_animal, abp_animal, asj_animal, 
    hep_animal, hex_animal, hax_animal

export estimate, simulate

export defaultpseudodata, defaultpseudoweights, defaultweights, defaultchemistry, default_d_V

export DEFAULT_CHEMICAL_PARAMETERS,
    DEFAULT_CHEMICAL_POTENTIALS,
    DEFAULT_CHEMICAL_POTENTIAL_OF_MINERALS,
    DEFAULT_CHEMICAL_INDICES_FOR_MINERALS,
    DEFAULT_CHEMICAL_INDICES_FOR_WATER_ORGANICS

include("const.jl")
include("chemistry.jl")
include("data.jl")
include("environment.jl")
include("behavior.jl")
include("synthesizing_units.jl")
include("temperature.jl")

# TODO rethink how estimation/simulation are separated in animals folder
include("estimation/estimation.jl")

include("animals/traits.jl")
include("animals/lifestages.jl")
include("animals/modes.jl")
include("animals/transition_state.jl")
include("animals/survival_probability.jl")
include("animals/reproduction.jl")
include("animals/scaled_age.jl")
include("animals/length.jl")
include("animals/parameters.jl")
include("animals/misc.jl")
include("animals/init.jl")

include("estimation/loss.jl")
include("estimation/solvers.jl")
include("estimation/weights.jl")
include("estimation/pseudodata.jl")
include("estimation/predict.jl")

include("simulation/simulate.jl")

end # module DEBtool_J

