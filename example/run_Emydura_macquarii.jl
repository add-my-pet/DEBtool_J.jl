using DEBtool_J
using Parameters
using ModelParameters
using Unitful

pets = ["Emydura_macquarii"];
#include("predict_Emydura_macquarii.jl")
include("pars_init_" * pets[1] * ".jl")
# creates struct Par - can interact with this e.g. like Par().T_ref.val
par_model = Model(Par()) # create a 'Model' out of the Pars struct
# can interact with par_model e.g. like this: par_model[:val], or make a vector: collect(par_model[:val])
#check_my_pet(pets); 
estim_opts = estim_options("default"); 
#estim_options("max_step_number", 5e2); 
#estim_options("max_fun_evals", 5e3); 

###estim_options("pars_init_method", 2); 
#estim_options("results_output", 3); 
#estim_options("method", "nm"); 

# currently takes 55 seconds to do 500 steps, matlab takes just under 40
estim_pars(pets, par_model, metaPar, estim_opts)

