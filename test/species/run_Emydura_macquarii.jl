using DEBtool_J
using ModelParameters
using MAT
using Test
using Flatten
using Unitful
using DataInterpolations
using ModelParameters: strip

srcpath = dirname(pathof(DEBtool_J))
speciespath = realpath(joinpath(srcpath, "../test/species"))
species = "Emydura_macquarii"
ntpar = include(joinpath(speciespath, "pars_init_" * species * ".jl")) 
par = StaticModel(ntpar) # create a 'Model' out of the Pars struct
# compute temperature correction factors
temperatureresponse = strip(ArrheniusResponse(; ntpar[(:T_ref, :T_A)]...))
metabolism = std_organism(;
    temperatureresponse,
    life = Life(
        Embryo() => Birth(),
        Juvenile() => Dimorphic(Female(Puberty()), Male(Puberty())),
        Adult() => Dimorphic(Female(Ultimate()), Male(Ultimate())),
    ),
)
estimator = Estimator(;
    method = DEBNelderMead(),
    max_step_number = 5000,
    max_fun_evals = 5000,
)
speciesdata = include(joinpath(speciespath, "mydata_" * species * ".jl")) # load the mydata file 
@time parout, nsteps, info, fval = estimate(estimator, metabolism, par, speciesdata);

# using ProfileView
# @profview estimate(estimator, metabolism, par, speciesdata);

@testset "Parameter consistency" begin # get results from Matlab
    file = matopen(joinpath(speciespath, "data", species, "results_$species.mat"))
    varname = "par"
    par_matlab = read(file, varname)
    close(file)

    par_julia = NamedTuple{parout[:fieldname]}(parout[:val])
    println()
    for k in keys(par_julia)
        v1 = par_matlab[string(k)]
        v2 = par_julia[k]
        is_equal = isapprox(v1, v2; atol=1e-4, rtol=1e-4)  # Tweak tolerance as needed
        print(rpad(k, 10), ": ", v1, " vs ", v2, " → ") 
        is_equal ? printstyled("✔"; color=:green) : printstyled("✘"; color=:red)
        println()
        @test is_equal
    end
    println()
end

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
mpe = DEBtool_J.MetabolismBehaviorEnvironment(; metabolism, environment, par=parent(parout))
@time sol = simulate(mpe; tspan=(0.0, 7000.0))
p = stripparams(parout)
p = merge(p, DEBtool_J.compound_parameters(metabolism, p))
plot(map(x -> x[2], sol.u) .* p.L_m / p.del_M)
sol

using GLMakie
plot(mpe)

# using ProfileView
# @profview 1 + 2
# @profview simulate(model, parout, environment)
# sim(model, par, environment, n) = for i in 1:n simulate(model, stripparams(par), environment); end
# @time sim(model, par, environment, 500)

# TODO: test simulation outputs
