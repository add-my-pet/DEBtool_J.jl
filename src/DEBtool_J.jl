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

export EstimOptions
export DEBOrganism
export Arrhenius1parTemperatureResponse, Arrhenius3parTemperatureResponse, Arrhenius5parTemperatureResponse
export LifeStages, Dimorphic
export Birth, Puberty, Ultimate
export Embryo, Juvenile, Adult
export Female, Male

# New
export predict, estimate

# Old
export beta0, tempcorr, calibration_options, addpseudodata, estim_options, estim_pars
export fieldnm_wtxt, filter_std, mydata_pets, parscomp_st, petregr_f
export predict_pseudodata, print_filterflag, reach_birth, struct2vector
export fieldnmst_st, lossfunction_sb, dget_l_ISO, dget_l_ISO_t, get_lb, get_lb2
export get_lp, get_tb, get_tp, get_tpm, get_ue0, get_tm_s, initial_scaled_reserve, reprod_rate
export get_lp1, fnget_lp

include("new/types.jl")
include("new/temperature.jl")
include("new/init.jl")
include("new/compute.jl")
include("new/predict.jl")
include("new/solvers.jl")
include("new/parameters.jl")
include("new/calibration.jl")
include("new/options.jl")
include("new/weights.jl")
include("new/pseudodata.jl")

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
