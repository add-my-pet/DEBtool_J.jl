using DEBtool_J, TraitDataSources
include(joinpath(dirname(pathof(DEBtool_J)), "../test/test_utils.jl"))

species = "Emydura_macquarii"

# Set DB path before load_species — pars_init now uses DEBTraitDB() for chemistry defaults.
get!(ENV, "DEB_TRAITS_PATH", raw"C:\Users\mrke\Dropbox\Current Research Projects\trait_database\DEB_traits")

# ── Old approach: hand-authored mydata file ────────────────────────────────────

(; data, organism, par) = species_context = load_species(species);
estimator = Estimator(; max_step_number=5000, max_fun_evals=5000);
@time parout, nsteps, info, fval = estimate(estimator, species_context);
compare_matlab(species, parout)

# ── New approach: database-driven data via materialize ─────────────────────────

# Build a fresh species context: organism+par from pars_init, data from DB.
# Pseudo data overrides match mydata_Emydura_macquarii.jl (from MATLAB weights.psd.k_J=0).
(; organism, par) = include(joinpath(@__DIR__, "pars_init_" * species * ".jl"))
par = StaticModel(par)

db_data = materialize(
    TraitQuery(species; pseudo=(; k_J=Weighted(0.0, 0.002u"d^-1"))),
    DEBTraitDB(),
)
db_ctx  = (; organism, par, data=db_data)
db_par, db_nsteps, db_info, db_fval = estimate(estimator, db_ctx)
@test db_info   # true = converged
@testset "DB parameters match hand-made estimates" begin
    hand = NamedTuple{parout[:fieldname]}(parout[:val])
    db   = NamedTuple{db_par[:fieldname]}(db_par[:val])
    println("\n  parameter  : hand-made  vs  DB")
    for k in keys(hand)
        haskey(db, k) || continue
        v1, v2 = hand[k], db[k]
        is_equal = isapprox(v1, v2; atol=1e-4, rtol=1e-4)
        print("  ", rpad(k, 10), ": ", v1, " vs ", v2, " → ")
        is_equal ? printstyled("✔\n"; color=:green) : printstyled("✘\n"; color=:red)
        @test is_equal
    end
    println()
end