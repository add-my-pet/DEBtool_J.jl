using DEBtool_J
using ModelParameters
using Unitful

srcpath = dirname(pathof(DEBtool_J))
examplepath = realpath(joinpath(srcpath, "../example"))

pets = ["Emydura_macquarii"];
#include("predict_Emydura_macquarii.jl")
(; par, metapar) = let # Let block so we only import the last variable into scope
    include(joinpath(examplepath, "pars_init_" * pets[1] * ".jl"))
end
par_model = Model(par) # create a 'Model' out of the Pars struct
data_pets = mydata_pets(pets, examplepath)

# EstimOptions to replace the globals set by `estim_options` below
options = DEBtool_J.EstimOptions(;
    max_step_number = 500,
    max_fun_evals = 5000,
    pars_init_method = 2, 
    results_output = 3, 
    method = "nm"
) 

#check_my_pet(pets); 

# currently takes 55 seconds to do 500 steps, matlab takes just under 40
estim_pars(options, pets, par_model, metapar, data_pets.data)
