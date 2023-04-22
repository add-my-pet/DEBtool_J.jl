using DEBtool_J

global pets = ["Emydura_macquarii"];
include("predict_Emydura_macquarii.jl")

#check_my_pet(pets); 
estim_options("default"); 
estim_options("max_step_number", 5e2); 
estim_options("max_fun_evals", 5e3); 

estim_options("pars_init_method", 2); 
estim_options("results_output", 3); 
estim_options("method", "nm"); 

estim_options("max_step_number", 30); 

#pars_init_method = 2 # needs to come out of estim_options
#pseudodata_pets = 0
#method = "nm"
#filter = 1
#covRules = "no" # needs to come out of estim_options
#estim_pars(pets, pars_init_method, method, filter, covRules)
estim_pars(pets)

