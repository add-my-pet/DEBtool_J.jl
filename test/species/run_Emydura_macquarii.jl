using DEBtool_J
using ModelParameters
using Unitful
using MAT
using Test

srcpath = dirname(pathof(DEBtool_J))
speciespath = realpath(joinpath(srcpath, "../test/species"))
species = "Emydura_macquarii"

(; par, metapar) = let # Let block so we only import the last variable into scope
    include(joinpath(speciespath, "pars_init_" * species * ".jl"))
end
par = StaticModel(par) # create a 'Model' out of the Pars struct
data = include(joinpath(speciespath, "mydata_" * species * ".jl")) # load the mydata file
resultsnm = "results_" * species * ".jld2"
calibration = calibration_options("results_filename", resultsnm)

# compute temperature correction factors
model = DEBOrganism(
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifestages = LifeStages(
        Embryo() => Birth(),
        Juvenile() => Dimorphic(Female(Puberty()), Male(Puberty())),
        Adult() => Dimorphic(Female(Ultimate()), Male(Ultimate())),
    )
)

# EstimOptions to replace the globals set by `estim_options` below
options = EstimOptions(;
    max_step_number = 5000,
    max_fun_evals = 5000,
    pars_init_method = 2, 
    results_output = 3, 
    method = "nm",
    calibration,
) 
@time parout, nsteps, info, fval = estimate(model, options, par, data)

# using ProfileView
# @profview parout, nsteps, info, fval = estim_pars(model, options, species, par_model, data_pet)

# get results from Matlab
file = matopen(joinpath(speciespath, "data", species, "results_$species.mat"))
varname = "par"
par_matlab = read(file, varname)
close(file)

@testset "Parameter consistency" begin
    par_names = par[:fieldname] # get the field names
    free = NamedTuple{par_names}(par[:free]) # get the vector of free parameters
    parnm = keys(free)
    np = length(parnm)
    index = (1:np)[collect(values(free)) .== 1]

    # TODO clean this up 
    par_jul = Dict(string(k) => v for (k, v) in collect(pairs(parout))[index])
    par_jul_stripped = NamedTuple{Tuple(Symbol.(keys(par_jul)))}(ustrip.(values(par_jul)))
    par_julia = Dict(string(k) => v for (k, v) in pairs(par_jul_stripped))
    println()
    for k in intersect(keys(par_matlab), keys(par_julia))
        v1 = par_matlab[k]
        v2 = par_julia[k]
        is_equal = isapprox(v1, v2; atol=1e-4, rtol=1e-4)  # Tweak tolerance as needed
        print(rpad(k, 10), ": ", v1, " vs ", v2, " → ") 
        is_equal ? printstyled("✔"; color=:green) : printstyled("✘"; color=:red)
        println()
        @test is_equal
    end
    println()
end
