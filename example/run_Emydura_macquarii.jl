using DEBtool_J
using ModelParameters
using Unitful
using MAT
using Test

srcpath = dirname(pathof(DEBtool_J))
examplepath = realpath(joinpath(srcpath, "../example"))

pet = "Emydura_macquarii";

(; par, metapar) = let # Let block so we only import the last variable into scope
    include(joinpath(examplepath, "pars_init_" * pet * ".jl"))
end
par_model = Model(par) # create a 'Model' out of the Pars struct
data, auxData, metaData, txtData, weights = include(joinpath(examplepath, "mydata_" * pet * ".jl")) # load the mydata file

data_pet = (data, auxData, metaData, txtData, weights)
# EstimOptions to replace the globals set by `estim_options` below
options = DEBtool_J.EstimOptions(;
    max_step_number = 5000,
    max_fun_evals = 5000,
    pars_init_method = 2, 
    results_output = 3, 
    method = "nm"
) 

#check_my_pet(pets); 

# currently takes 20 seconds to converge in 1660 steps, matlab takes 1 in 8 seconds in 1650 steps
#@time estim_pars(options, pet, par_model, metapar, data_pet)
@time parout, nsteps, info, fval = estim_pars(options, pet, par_model, metapar, data_pet)

# get results from Matlab
file = matopen("tests/Emydura_macquarii_20171009/Emydura_macquarii/results_Emydura_macquarii.mat")
varname = "par"
par_matlab = read(file, varname)
close(file)

par_free = Dict(
    string(k) => v for (k, v) in sort(collect(pairs(parout.free)); by=first)
)
par_jul = (; filter(p -> p[1] != :free, pairs(parout))...)
par_jul_stripped = NamedTuple{keys(pars_jul)}(ustrip.(values(par_jul)))
par_julia = Dict(
    string(k) => v for (k, v) in sort(collect(pairs(par_jul_stripped)); by=first)
)

par_julia_free = Dict(k => v for (k, v) in par_julia if get(par_free, k, 0) == 1)
par_matlab_free = Dict(k => v for (k, v) in par_matlab if get(par_free, k, 0) == 1)

common_keys = intersect(keys(par_matlab_free), keys(par_julia_free))
for k in sort(collect(common_keys))
    v1 = par_matlab_free[k]
    v2 = par_julia_free[k]
    is_equal = isapprox(v1, v2; atol=1e-4, rtol=1e-4)  # Tweak tolerance as needed
    println(rpad(k, 10), ": ", v1, " vs ", v2, " → ", is_equal ? "✔" : "✘")
end

@testset "Parameter consistency" begin
    for k in intersect(keys(par_matlab_free), keys(par_julia_free))
        v1 = par_matlab_free[k]
        v2 = par_julia_free[k]
        @test isapprox(v1, v2; atol=1e-4, rtol=1e-4)
    end
end