using DEBtool_J
include(joinpath(dirname(pathof(DEBtool_J)), "../test/test_utils.jl"))

species = "Spodoptera_frugiperda"
species_context = load_species(species)
estimator = Estimator(; max_step_number=200, max_fun_evals=5000)

@time parout, nsteps, info, fval = estimate(estimator, species_context);
compare_matlab(species, parout)
