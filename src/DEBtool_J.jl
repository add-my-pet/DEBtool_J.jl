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

export StandardEstimator, DEBNelderMead, DEBMultimodalEvolutionaryAlgorithm
export DEBOrganism
export Arrhenius1parTemperatureResponse, Arrhenius3parTemperatureResponse, Arrhenius5parTemperatureResponse
export LifeStages, Dimorphic
export Birth, Puberty, Maturity, Ultimate
export Embryo, Juvenile, Adult
export Female, Male
export AtTemperature
export Data, Univariate, Times, Lengths, Food

export estimate, addpseudodata, setweights

# TODO make these types
export DEFAULT_CHEMICAL_PARAMETERS,
    DEFAULT_CHEMICAL_POTENTIALS,
    DEFAULT_CHEMICAL_POTENTIAL_OF_MINERALS,
    DEFAULT_CHEMICAL_INDICES_FOR_MINERALS,
    DEFAULT_CHEMICAL_INDICES_FOR_WATER_ORGANICS

include("new/const.jl")
include("new/types.jl")
include("new/temperature.jl")
include("new/init.jl")
include("new/loss.jl")
include("new/estimation.jl")
include("new/solvers.jl")
include("new/predict.jl")
include("new/compute.jl")
include("new/parameters.jl")
include("new/weights.jl")
include("new/pseudodata.jl")
# include("new/calibration.jl")

# include("lib/misc/beta0.jl")
# include("lib/misc/tempcorr.jl")
# include("lib/MultiCalib4DEB/configuration/calibration_options.jl")
# include("lib/pet/addpseudodata.jl")
# include("lib/pet/estim_options.jl")
# include("lib/pet/estim_pars.jl")
# include("lib/pet/fieldnm_wtxt.jl")
# include("lib/pet/filter_std.jl")
# include("lib/pet/mydata_pets.jl")
# include("lib/pet/parscomp_st.jl")
# include("lib/pet/petregr_f.jl")
# include("lib/pet/predict_pseudodata.jl")
# include("lib/pet/print_filterflag.jl")
# include("lib/pet/reach_birth.jl")
# include("lib/pet/setweights.jl")
# include("lib/regr/fieldnmnst_st.jl")
# include("lib/regr/lossfunction_sb.jl")

# include("animal/dget_l_ISO.jl")
# include("animal/dget_l_ISO_t.jl")
# include("animal/get_lb.jl")
# include("animal/get_lb2.jl")
# include("animal/get_lp.jl")
# include("animal/get_tb.jl")
# include("animal/get_tp.jl")
# include("animal/get_tpm.jl")
# include("animal/get_ue0.jl")
# include("animal/get_tm_s.jl")
# include("animal/initial_scaled_reserve.jl")
# include("animal/reprod_rate.jl")
# include("animal/fnget_lp.jl")
# include("animal/get_lp1.jl")

end # module DEBtool_J
