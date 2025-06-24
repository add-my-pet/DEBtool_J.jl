abstract type DEBOptimizer end

@kwdef struct DEBNelderMead <: DEBOptimizer 
    simplex_size::Float64 = 0.05
    tol_simplex::Float64 = 1e-4
    tol_fun::Float64 = 1e-4
end
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
    rng::R = MersenneTwister(random_seeds[seed_index]) # initialize the number generator is with a seed, to be updated for each run of the calibration method.
    max_calibration_time::Int = 30 # The maximum calibration time calibration process.
    sigma_share::Float64 = 0.1
    num_runs::Int = 5 # The number of runs to perform.
    factor_type::String = "mult" # The kind of factor to be applied when generating individuals
    num_results::Int = 50   # The size for the multimodal algorithm's population.
    # for mmea method (taken from calibration_options)
    # initialization. (e.g. A value of 0.9 means that, for a parameter value of 1,
    # the range for generation is [(1 - 0.9) * 1, 1 * (1 + 0.9)] so
    # the new parameter value will be a random between [0.1, 1.9]
    #('mult' is multiplicative (Default) | 'add' if
    # additive);
    # If the value is equal to 1 the parameters are generated from the data initial values
    # if is 0 then the parameters are generated from the pseudo data values.
    # 0 <= sigma_share <= 1 || throw(ArgumentError("sigma_share must be between 0 and 1"))
    # method == "mmea" && !filter && @warn "estim_options: use a filter with method `:mmea`"
end

"""
    AbstractEstimator

Abstract supertype for all methods to estimate DEB parameters.
"""
abstract type AbstractEstimator end

"""
    estimate(estimator::AbstractEstimator, model, params, data)

Estimates parameter values for a DEB model.

- `estimator`: parameter estimation method.
- `model`: DEB organism model definition.
- `params`: model parameter `NamedTuple`. May be integrated into `model` in future iterations.
- `data`: `NamedTuple` of data to predict with the model.
"""
function estimate end

"""
    StandardEstimator <: AbstractEstimator

The standard DEBtool parameter estimator.


- `method`: optimization method, `DEBNelderMead` and `DEBMultimodalEvolutionaryAlgorithm`.
    In future may allow arbitrary Optimization.jl optimizers.
- `lossfunction`: `AbstractLoss`, `SymmetricBoundedLoss()` by default.
- `max_step_number` maximum number of step, 500 by default.
- `max_fun_evals` maximum function evals, 10000 by default.
- `filter`: whether to filter paramters, `true` by defualt.
- `verbose`: whether to print information during optimization, `true` by defualt.
"""
@kwdef struct StandardEstimator{M<:DEBOptimizer,L} <: AbstractEstimator
    method::M = DEBNelderMead()
    lossfunction::L = SymmetricBoundedLoss()
    max_step_number::Int = 500
    max_fun_evals::Int = 10000
    quad_atol::Float64 = 1e-6
    filter::Bool = true
    verbose::Bool = true
end

function estimate(estimator::StandardEstimator, model, par, speciesdata)
    (; data, weights) = speciesdata

    # Precalculate data means and weights
    meandatavec = struct2means(data, data)
    weightsvec = struct2means(weights, data)
    return _estimate_inner(estimator, model, par, speciesdata, meandatavec, weightsvec)
end

# Function barrier so local functions are type stable
function _estimate_inner(e::StandardEstimator, model, par::P, speciesdata, meandatavec, weightsvec) where P
    (; data) = speciesdata

    function objective(parvec)
        par1 = stripparams(ModelParameters.update(par, parvec)::P)
        (; prdData, info) = predict(e, model, par1, speciesdata)
        prdData1 = predict_pseudodata(model, par1, data, prdData)
        return prdData1, info
    end
    data_loss(predictions) = loss(e.lossfunction, predictions, data, meandatavec, weightsvec)
    function param_filter(parvec)
        par1 = ModelParameters.stripparams(ModelParameters.update(par, parvec))
        filter_params(model, par1)
    end

    qvec = collect(par[:val])::Vector{Float64}
    qvec, info, nsteps, fval = optimize!(objective, param_filter, data_loss, e, qvec)
    par = ModelParameters.update(par, qvec)
    return par, nsteps, info, fval
end
