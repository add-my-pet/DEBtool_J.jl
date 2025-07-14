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
model = std_organism(;
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
@time parout, nsteps, info, fval = estimate(estimator, model, par, speciesdata);

# using ProfileView
# @profview parout, nsteps, info, fval = estimate(model, options, par, data)

@testset "Parameter consistency" begin
    # get results from Matlab
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

environment = ConstantEnvironment(; 
    time=(0.0, 1000.0),
    temperature=u"K"(22.0u"°C"),
    functionalresponse=1.0,
    temperatureresponse,
) 
environment = Environment(; 
    time=[0.0, 300.0, 600, 900.0, 1200.0, 2000.0],
    temperature=u"K".([10.0, 15.0, 22.0, 10.0, 10.0, 20.0]u"°C"),
    functionalresponse=[1.0, 0.8, 1.0, 0.9, 0.7, 1.0],
    temperatureresponse,
    interpolation=QuadraticInterpolation,
) 
@time sol = simulate(model, parout, environment; tspan=(0.0, 1000.0))

# Interactive plots

using GLMakie
using MakieDraw

MakieModel((; model, par=parent(parout))) do layout, obs
    sol = lift(obs) do (; model, par)
        simulate(model, par, environment)
    end
    # Define an axis to plot into
    ax1 = Axis(layout[1:5, 1])
    # And plot a heatmap of the output of `f`
    plot!(ax1, sol)
    # Plot the environment 
    if environment isa Environment
        time = environment.interpolators.temperature.t
        temp = environment.interpolators.temperature.u
        fr = environment.interpolators.functionalresponse.u
        ax2 = Axis(layout[6, 1])
        ax3 = Axis(layout[7, 1])
        # DataCanvas(time, temp; color=:red, axis=ax2, figure=layout.parent.parent, scatter_kw=(; label="Temperature"))
        # DataCanvas(time, fr; color=:green, axis=ax3, figure=layout.parent.parent, scatter_kw=(; label="FR"))
        scatterlines!(ax2, time, temp; color=:red, label="Temperature")
        scatterlines!(ax3, time, fr; color=:green, label="Functional respoonse")
        axislegend(ax2)
        axislegend(ax3)
    end
end

# @time simulate(model, strip(par), environment);
# using ProfileView
# @profview 1 + 2
# @profview simulate(model, parout, environment)
# sim(model, par, environment, n) = for i in 1:n simulate(model, stripparams(par), environment); end
# @time sim(model, par, environment, 500)

# TODO: test simulation outputs
