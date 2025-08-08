using DEBtool_J
using Flatten
include(joinpath(dirname(pathof(DEBtool_J)), "../test/test_utils.jl"))

species = "Emydura_macquarii"
(; data, par) = species_context = load_species(species);
estimator = Estimator(; max_step_number=5000, max_fun_evals=5000)

# Test pars, data, weight and pseudodata are correct
@test par[:val] == (13.2002, 12.8559, 0.060464, 0.7362, 16.4025, 0.00060219, 7857.8605, 13660.0, 1.168e7, 4.711e6, 1.211e-9, 0.61719)
@test data.weights.pseudo == (v = 0.1, κ = 0.1, κ_R = 0.1, p_M = 0.1, k_J = 0.0, κ_G = 20.0, k = 0.1)
@test map(ustrip, data.data.pseudo) == (v = 0.02, κ = 0.8, κ_R = 0.95, p_M = 18, k_J = 0.002, κ_G = 0.8, k = 0.3)
flat_ref = (78.0, 303.15, 48.0, 7628.499999999999, 3650.0, 2007.5, 2.7, 18.7, 14.7, 21.4, 20.8, 8.0, 2669.0, 1297.0, 4000.0, 3673.0, 295.15, 0.09863013698630137, 358.065, 358.065, 713.9399999999999, 713.9399999999999, 714.3050000000001, 714.3050000000001, 714.3050000000001, 714.67, 714.67, 723.7950000000001, 1034.045, 1061.42, 1069.815, 1070.18, 1089.16, 1097.92, 1399.045, 1399.41, 1399.41, 1407.805, 1417.295, 1417.295, 1417.295, 1435.91, 6.876, 7.09, 8.369, 8.689, 9.115, 9.435, 9.808, 10.075, 10.235, 10.661, 11.141, 11.354, 9.701, 10.768, 12.42, 11.674, 13.22, 13.326, 13.646, 12.1, 12.42, 12.633, 12.953, 14.072, 0.02, 0.8, 0.95, 18, 0.002, 0.8, 0.3, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.08333333333333333, 0.1, 0.1, 0.1, 0.1, 0.0, 20.0, 0.1, 295.15)
@test Flatten.flatten(data.data, Real) == flat_ref[1:73]
@test Flatten.flatten(data.weights, Real) == flat_ref[74:end-1]

@time parout, nsteps, info, fval = estimate(estimator, species_context)
compare_matlab(species, parout)

# tspan = (0.0, 8000.0)
# environment = ConstantEnvironment(; 
#     time=tspan,
#     temperature=u"K"(22.0u"°C"),
#     functionalresponse=1.0,
#     temperatureresponse,
# ) 
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
