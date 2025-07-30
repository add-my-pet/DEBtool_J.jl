using DEBtool_J
srcpath = dirname(pathof(DEBtool_J))
include(joinpath(srcpath, "../test/test_utils.jl"))

species = "Vulpes_vulpes"
(; organism, par, data) = load_species(species)

# compute temperature correction factors
estimator = Estimator(;
    method = DEBNelderMead(),
    max_step_number = 500,
    max_fun_evals = 5000,
)

@time parout, nsteps, info, fval = estimate(estimator, organism, par, data);
compare_matlab(species, parout)
