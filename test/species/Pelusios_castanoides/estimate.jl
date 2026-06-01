using DEBtool_J, TraitDataSources
include(joinpath(dirname(pathof(DEBtool_J)), "../test/test_utils.jl"))
get!(ENV, "DEB_TRAITS_PATH", raw"C:\Users\mrke\Dropbox\Current Research Projects\trait_database\DEB_traits")

species = "Pelusios_castanoides"

# Build a fresh species context: organism+par from pars_init, data from DB.
# Pseudo data overrides match mydata_Emydura_macquarii.jl (from MATLAB weights.psd.k_J=0).
(; organism, par) = include(joinpath(@__DIR__, "pars_init_" * species * ".jl"));
par = StaticModel(par);
estimator = Estimator(; max_step_number=10000, max_fun_evals=10000);

data = materialize(
    TraitQuery(species, weights = ((trait=:tL, weight=10.0),)),
    DEBTraitDB(),
);
context  = (; organism, par, data);
par_out, nsteps, info, fval = estimate(estimator, context);

NamedTuple{par[:fieldname]}(par_out[:val])
