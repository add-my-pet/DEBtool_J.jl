using DEBtool_J
include(joinpath(dirname(pathof(DEBtool_J)), "../test/test_utils.jl"))

species = "Vulpes_vulpes"
(; organism, par, data) = load_species(species)
estimator = Estimator(; method=DEBNelderMead(), max_step_number=500, max_fun_evals=5000)

@time parout, nsteps, info, fval = estimate(estimator, organism, par, data);
compare_matlab(species, parout)
