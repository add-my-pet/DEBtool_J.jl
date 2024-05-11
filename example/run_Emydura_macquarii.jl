using DEBtool_J
using ModelParameters
using Unitful

srcpath = dirname(pathof(DEBtool_J))
examplepath = realpath(joinpath(srcpath, "../example"))

pet = "Emydura_macquarii";

(; par, metapar) = let # Let block so we only import the last variable into scope
    include(joinpath(examplepath, "pars_init_" * pet * ".jl"))
end
par_model = Model(par) # create a 'Model' out of the Pars struct
data, auxData, metaData, txtData, weights = include(joinpath(examplepath, "mydata_" * pet * ".jl")) # load the mydata file

data_pet = (data, auxData, metaData, txtData, weights)
# EstimOptions to replace the globals set by `estim_options` below
options = DEBtool_J.EstimOptions(;
    max_step_number = 5000,
    max_fun_evals = 5000,
    pars_init_method = 2, 
    results_output = 3, 
    method = "nm"
) 

#check_my_pet(pets); 

# currently takes 20 seconds to converge in 1660 steps, matlab takes 1 in 8 seconds in 1650 steps
#@time estim_pars(options, pet, par_model, metapar, data_pet)
@time parout, nsteps, info, fval = estim_pars(options, pet, par_model, metapar, data_pet)