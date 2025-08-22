using DEBtool_J
include(joinpath(dirname(pathof(DEBtool_J)), "../test/test_utils.jl"))

# Estimation
species = "Emydura_macquarii"
(; data, organism, par) = species_context = load_species(species);
estimator = Estimator(; max_step_number=5000, max_fun_evals=5000);
@time parout, nsteps, info, fval = estimate(estimator, species_context);

using ProfileView
@profview estimate(estimator, species_context);

# Test against matlab results
compare_matlab(species, parout)
