module DEBtool_J

using ModelParameters
using Parameters
using Unitful
using Unitful: °C, K, d, g, cm, mol, J
using Statistics
using Random
using SpecialFunctions
using QuadGK
using OrdinaryDiffEq
using Roots

#abstract type AbstractPseudoData end
#abstract type AbstractUniVariate end
#abstract type AbstractZeroVariate end
#abstract type AbstractDEBModel end

# abstract type Data end
# abstract type AuxData end
# abstract type MetaData end
# abstract type TxtData end
# abstract type Weights end

#struct Std <: AbstractDEBModel end
# struct EcoCode <: MetaData end
# struct Temp <: AuxData end
# struct Psd <: Data end

export beta0, tempcorr, calibration_options, addpseudodata, estim_options, estim_pars
export fieldnm_wtxt, filter_std, mydata_pets, parscomp_st, petregr_f
export predict, predict_pseudodata, print_filterflag, reach_birth, struct2vector
export fieldnmst_st, lossfunction_sb, dget_l_ISO, dget_l_ISO_t, get_lb, get_lb2
export get_lp, get_tb, get_tp, get_tpm, get_ue0, get_tm_s, initial_scaled_reserve, reprod_rate
export get_lp1, fnget_lp
export @unpack

include("../src/lib/misc/beta0.jl")
include("../src/lib/misc/tempcorr.jl")
include("../src/lib/MultiCalib4DEB/configuration/calibration_options.jl")
include("../src/lib/pet/addpseudodata.jl")
include("../src/lib/pet/estim_options.jl")
include("../src/lib/pet/estim_pars.jl")
include("../src/lib/pet/fieldnm_wtxt.jl")
include("../src/lib/pet/filter_std.jl")
include("../src/lib/pet/mydata_pets.jl")
#include("../src/lib/pet/parGrp2Pets.jl")
include("../src/lib/pet/parscomp_st.jl")
include("../src/lib/pet/petregr_f.jl")
#include("../src/lib/pet/predict_pets.jl")
include("../src/lib/pet/predict_pseudodata.jl")
include("../src/lib/pet/print_filterflag.jl")
include("../src/lib/pet/reach_birth.jl")
include("../src/lib/pet/setweights.jl")

include("../src/lib/regr/fieldnmnst_st.jl")
include("../src/lib/regr/lossfunction_sb.jl")

include("../src/animal/dget_l_ISO.jl")
include("../src/animal/dget_l_ISO_t.jl")
include("../src/animal/get_lb.jl")
include("../src/animal/get_lb2.jl")
include("../src/animal/get_lp.jl")
include("../src/animal/get_tb.jl")
include("../src/animal/get_tp.jl")
include("../src/animal/get_tpm.jl")
include("../src/animal/get_ue0.jl")
include("../src/animal/get_tm_s.jl")
include("../src/animal/initial_scaled_reserve.jl")
include("../src/animal/reprod_rate.jl")
include("../src/animal/fnget_lp.jl")
include("../src/animal/get_lp1.jl")

srcpath = dirname(pathof(DEBtool_J))
examplepath = realpath(joinpath(srcpath, "../example"))
pet = "Emydura_macquarii";
include(joinpath(examplepath, "predict_" * pet * ".jl"))

end # module DEBtool_J
