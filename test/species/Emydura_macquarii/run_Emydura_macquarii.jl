using DEBtool_J
srcpath = dirname(pathof(DEBtool_J))
include(joinpath(srcpath, "../test/test_utils.jl"))

species = "Emydura_macquarii"
(; organism, par, data) = load_species(species)

# compute temperature correction factors
estimator = Estimator(;
    method = DEBNelderMead(),
    max_step_number = 5000,
    max_fun_evals = 5000,
)

@time parout, nsteps, info, fval = estimate(estimator, organism, par, data);
compare_matlab(species, parout)

tspan = (0.0, 8000.0)
environment = ConstantEnvironment(; 
    time=tspan,
    temperature=u"K"(22.0u"°C"),
    functionalresponse=1.0,
    temperatureresponse,
) 
# environment = Environment(; time=[0.0, 300.0, 600, 900.0, 1200.0, 2000.0],
#     temperature=u"K".([10.0, 15.0, 22.0, 10.0, 10.0, 20.0]u"°C"),
#     functionalresponse=[1.0, 0.8, 1.0, 0.9, 0.7, 1.0],
#     temperatureresponse,
#     interpolation=QuadraticInterpolation,
# ) 
# mpe = DEBtool_J.MetabolismBehaviorEnvironment(; metabolism, environment, par=parent(parout))
# using ProfileView
# @profview sol = simulate(mpe; tspan=(0.0, 7000.0))
# p = stripparams(parout)
# p = merge(p, DEBtool_J.compound_parameters(metabolism, p))
# plot(map(x -> x[2], sol.u) .* p.L_m / p.del_M)
# sol

# using GLMakie
# plot(mpe)

# using ProfileView
# @profview 1 + 2
# @profview simulate(model, parout, environment)
# sim(model, par, environment, n) = for i in 1:n simulate(model, stripparams(par), environment); end
# @time sim(model, par, environment, 500)

# TODO: test simulation outputs
