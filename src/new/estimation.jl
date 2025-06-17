const DEFAULT_RANDOM_SEEDS = [
    2147483647,
    2874923758,
    1284092845,  # The values of the seed used to
    2783758913,
    3287594328,
    2328947617,  # generate random values (each one is used in a
    1217489374,
    1815931031,
    3278479237,  # single run of the algorithm).
    3342427357,
    223758927,
    3891375891,
    1781589371,
    1134872397,
    2784732823,
    2183647447,
    24923758,
    122845,
    2783784093,
    394328,
    2328757617,
    12174974,
    18593131,
    3287237,
    33442757,
    2235827,
    3837891,
    17159371,
    34211397,
    2842823,
]

abstract type DEBOptimizer end
struct DEBNelderMead <: DEBOptimizer end
@kwdef struct DEBMultimodalEvolutionaryAlgorithm{R} <: DEBOptimizer 
    search_method::String = "mm_shade" # Use mm_shade: Success-History based Adaptive Differential Evolution
    # If not defined then sets the values recommended by the author,
    # which are 100 for mm_shade ('mm_shade') and 18 * problem size for L-mm_shade.
    gen_factor::Float64 = 0.5    # Percentage bounds for individual
    bounds_from_ind::Int = 1
    refine_best::Bool = false     # If a local search is applied to the best individual found.
    verbose_options::Int = 5 # The number of solutions to show from the  set of optimal solutions found by the  algorithm through the calibration process.
    random_seeds::Vector{Int} = DEFAULT_RANDOM_SEEDS
    seed_index::Int = 1 # index for seeds for random number generator
    ranges::Union{Float64,Nothing} = nothing #struct(); # The range struct is empty by default.
    add_initial::Bool = false     # If to add an invidivual taken from initial data into first population.                     # (only if it the 'add_initial' option is activated)
    verbose::Bool = false  # If to print some information while the calibration process is running.
    rng::R = MersenneTwister(random_seeds[seed_index]) # initialize the number generator is with a seed, to be updated for each run of the calibration method.
    max_calibration_time::Int = 30 # The maximum calibration time calibration process.
end

abstract type AbstractEstimator end

@kwdef struct StandardEstimator{M<:DEBOptimizer,L,C} <: AbstractEstimator
    method::M = DEBNelderMead()
    lossfunction::L = lossfunction_sb
    max_step_number::Int = 500
    filter::Bool = true
    max_fun_evals::Int = 10000
    report::Bool = true
    tol_simplex::Float64 = 1e-4
    tol_fun::Float64 = 1e-4
    simplex_size::Float64 = 0.05
    num_results::Int = 50   # The size for the multimodal algorithm's population.
    factor_type::String = "mult" # The kind of factor to be applied when generating individuals
    num_runs::Int = 5 # The number of runs to perform.
    sigma_share::Float64 = 0.1
    calibration::C
    # for mmea method (taken from calibration_options)
    # initialization. (e.g. A value of 0.9 means that, for a parameter value of 1,
    # the range for generation is [(1 - 0.9) * 1, 1 * (1 + 0.9)] so
    # the new parameter value will be a random between [0.1, 1.9]
    #('mult' is multiplicative (Default) | 'add' if
    # additive);
    # If the value is equal to 1 the parameters are generated from the data initial values
    # if is 0 then the parameters are generated from the pseudo data values.
    # method == "mmea" && !filter && @warn "estim_options: use a filter with method `:mmea`"
    # 0 <= sigma_share <= 1 || throw(ArgumentError("sigma_share must be between 0 and 1"))
end


function estimate(estimator::StandardEstimator, model, par::P, mydata_pet) where P
    (; data, auxData, weights) = mydata_pet

    # Y: vector with all dependent data, NaNs omitted
    # W: vector with all weights, but those that correspond NaNs in data omitted
    y, meany = struct2vector(data, data)
    W = struct2vector(weights, data)[1]
    return _estimate_inner(estimator, model, par, mydata_pet, y, meany, W)
end

# Function barrier so local functions are type stable
function _estimate_inner(estimator::StandardEstimator, model, par::P, mydata_pet, y, meany, W) where P
    (; data, auxData, weights) = mydata_pet

    function objective(parvec)
        par1 = stripparams(ModelParameters.update(par, parvec)::P)
        prdData, info = predict(model, par1, data, auxData)
        prdData1 = predict_pseudodata(model, par1, data, prdData)
        return prdData1, info
    end
    function filter(parvec)
        par1 = ModelParameters.stripparams(ModelParameters.update(par, parvec))
        filter_params(model, par1)
    end
    function loss(f)
        p, meanp = struct2vector(f, data)
        estimator.lossfunction(y, meany, p, meanp, W)
    end

    qvec = collect(par[:val])::Vector{Float64}
    qvec, info, nsteps, fval = optimize!(objective, filter, loss, estimator, qvec)
    par = ModelParameters.update(par, qvec)
    return par, nsteps, info, fval
end

