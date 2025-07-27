using DEBtool_J
using ModelParameters
using MAT
using Test
using Unitful
using DataInterpolations
using ModelParameters: strip

function load_species(species::AbstractString)
    sp = _speciespath(species)
    (; organism, par) = include(joinpath(sp, "pars_init_" * species * ".jl")) 
    par = StaticModel(par) # create a 'Model' out of the Pars struct
    data = include(joinpath(sp, "mydata_" * species * ".jl")) # load the mydata file 
    return (; organism, par, data)
end

function compare_matlab(species::AbstractString, parout)
    @testset "Parameter consistency" begin # get results from Matlab
        file = matopen(joinpath(_speciespath(species), "matlab", "results_$species.mat"))
        matlabvarname = "par"
        par_matlab = read(file, matlabvarname)
        close(file)

        par_julia = NamedTuple{parout[:fieldname]}(parout[:val])
        println()
        for k in keys(par_julia)
            mk = first(string(k)) == 'κ' ? replace(string(k), "κ" => "kap") : string(k) 
            v1 = par_matlab[mk]
            v2 = par_julia[k]
            is_equal = isapprox(v1, v2; atol=1e-4, rtol=1e-4)  # Tweak tolerance as needed
            print(rpad(k, 10), ": ", v1, " vs ", v2, " → ") 
            is_equal ? printstyled("✔"; color=:green) : printstyled("✘"; color=:red)
            println()
            @test is_equal
        end
        println()
    end
end

_speciespath(species) = realpath(joinpath(dirname(pathof(DEBtool_J)), "../test/species/$species"))
