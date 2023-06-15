using DEBtool_J
using Parameters
using ModelParameters
using Unitful

# creates struct Par - can interact with this e.g. like Par().T_ref.val
include("pars_init.jl")
par_model = Model(Par()) # create a 'Model' out of the Pars struct
# can interact with par_model e.g. like this: par_model[:val], or make a vector: collect(par_model[:val])

estim_opts = estim_options("default"); 

# currently takes 15 seconds to do 500 steps, matlab takes just under 40
estim_pars(par_model, metaPar, estim_opts)

