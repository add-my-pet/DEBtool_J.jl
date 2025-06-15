# created 2000/08/16 by Bas Kooijman; modified 2011/04/10, 2017/07/24

## Syntax
# f = <../beta0.m *beta0*> (x0,x1)

## Description
#  particular incomplete beta function:
#   B_x1(4/3,0) - B_x0(4/3,0) = \int_x0^x1 t^(4/3-1) (1-t)^(-1) dt
#
# Input
#
# * x0: scalar with lower boundary for integration
# * x1: scalar with upper boundary for integratior
#
# Output
#
# * f: scalar with particular incomplete beta function

## Remarks
# See also <../lib/misc/beta_34_0 *beta_34_0*>

## Example of use
# beta0(0.1, 0.2)
function beta0(x0::Number, x1::Number)
    f0 = _beta(x0)
    f1 = _beta(x1)
    f = f1 - f0
    return f
end
function beta0_precalc_f1(x0::Number, f1::Number)
    f0 = _beta(x0)
    f = f1 - f0
    return f
end
# Precalculate part of _beta0
function _beta(x1)
    a3 = sqrt(3)
    x13 = x1^(1 / 3)
    -3 * x13 + a3 * atan((oneunit(x13) + 2 * x13) / a3) - log(Complex(x13 - oneunit(x13))) + log(oneunit(x13) + x13 + x13^2) / 2
end

@noinline _warn_value_range(x0, x1) = @warn "beta0: argument values (" * num2str(x0) * "," * num2str(x1), ") outside (0,1) \n"


## was petregr_f
# Finds parameter values for a pet that minimizes the lossfunction using Nelder Mead's simplex method using a filter
# TODO: single objective/loss/filter function
function optimize!(objective, filter, loss, qvec::Vector; options)
    info = true # initiate info setting
    n_par = length(qvec)

    # Initialize parameters
    rho = 1
    chi = 2
    psi = 0.5
    sigma = 0.5
    onesn = Int.(ones(1, n_par))
    two2np1 = 2:n_par+1
    one2n = 1:n_par
    np1 = n_par + 1

    # Set up a simplex near the initial guess.
    xin = copy(qvec)    # Place input guess in the simplex
    v = zeros(Float64, length(xin), Int(n_par) + 1)
    fv = zeros(Float64, n_par + 1)
    v_test = zeros(size(v, 1))
    v[:, 1] .= xin
    f = objective(qvec)[1]
    fv[1] = loss(f)

    # Following improvement suggested by L.Pfeffer at Stanford TODO: but what does it do???
    usual_delta = options.simplex_size         # 5 percent deltas is the default for non-zero terms
    zero_term_delta = options.simplex_size / 20 # Even smaller delta for zero elements of q
    y_test = similar(xin)
    for j in 1:n_par
        f_test = false
        step_reducer = 1 # step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
        y_test .= xin
        while !f_test
            if xin[j] != 0
                y_test[j] = (1 + usual_delta / step_reducer) * xin[j]
            else
                y_test[j] = zero_term_delta / step_reducer
            end
            qvec .= y_test

            f_test, flag = filter(qvec)
            if !f_test
                println("The parameter set for the simplex construction is not realistic. \n")
                step_reducer = 2 * step_reducer
            else
                f, f_test = objective(qvec)
                if !f_test
                    println("The parameter set for the simplex construction is not realistic. \n")
                    step_reducer = 2 * step_reducer
                end
            end
        end
        v[:, j + 1] = y_test
        fv[j + 1] = loss(f)
    end

    j = sortperm(fv)
    fv = fv[j]
    v = v[:, j]
    how = "initial"
    itercount = 1
    func_evals = n_par + 1
    if options.report
        println(
            "step " * string(itercount) * " ssq ",
            string(minimum(fv)) * "-",
            string(maximum(fv)) * " " * how * "\n"
        )
    end
    info = true

    # Main algorithm
    # Iterate until the diameter of the simplex is less than options.tol_simplex
    #   AND the function values differ from the min by less than options.tol_fun,
    #   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
    while func_evals < options.max_fun_evals && itercount < options.max_step_number
        #if maximum(Unitful.ustrip(abs.(v[:, two2np1] .- v[:, onesn]))) <= options.tol_simplex && maximum(Unitful.ustrip(abs.(fv[1].-fv[two2np1]))) <= options.tol_fun
        if maximum(Unitful.ustrip(abs.(view(v, :, two2np1) .- view(v, :, onesn)))) <=
            options.tol_simplex && maximum(Unitful.ustrip(abs.(fv[1] .- fv[two2np1]))) <= options.tol_fun
            break
        end
        how = ""

        # Compute the reflection point

        # xbar = average of the n (NOT n+1) best points
        xbar = (sum(view(v, :, one2n); dims=2) ./ n_par) 
        xr = (1 + rho) * xbar - rho * v[:, np1]
        qvec .= xr
        fxr = maybe_objective(objective, filter, loss, qvec, fv)
        func_evals = func_evals + 1

        if fxr < fv[1]
            # Calculate the expansion point
            xe = (1 + rho * chi) .* xbar - rho * chi .* v[:, np1]
            qvec .= xe
            fxe = maybe_objective(objective, filter, loss, qvec, fv)
            func_evals = func_evals + 1
            if fxe < fxr
                v[:, np1] = xe
                fv[np1] = fxe
                how = "expand"
            else
                v[:, np1] = xr
                fv[np1] = fxr
                how = "reflect"
            end
        else # fv(:,1) <= fxr
            if fxr < fv[n_par]
                v[:, np1] = xr
                fv[np1] = fxr
                how = "reflect"
            else # fxr >= fv[:, n_par]
                # Perform contraction
                if fxr < fv[np1]
                    # Perform an outside contraction
                    xc = (1 + psi * rho) .* xbar - psi * rho .* v[:, np1]
                    qvec .= xc
                    fxc = maybe_objective(objective, filter, loss, qvec, fv)
                    func_evals = func_evals + 1

                    if fxc <= fxr
                        v[:, np1] = xc
                        #fv[:,np1][1] = fxc;
                        fv[np1] = fxc
                        how = "contract outside"
                    else
                        # perform a shrink
                        how = "shrink"
                    end
                else
                    # Perform an inside contraction
                    xcc = (1 - psi) .* xbar + psi .* v[:, np1]
                    qvec .= xcc
                    fxcc = maybe_objective(objective, filter, loss, qvec, fv)
                    func_evals = func_evals + 1

                    if fxcc < fv[np1]
                        v[:, np1] = xcc
                        fv[np1] = fxcc
                        how = "contract inside"
                    else
                        # perform a shrink
                        how = "shrink"
                    end
                end
                if how == "shrink"
                    for j in two2np1
                        f_test = false
                        step_reducer = 1 # step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
                        while !f_test
                            v_test = v[:, 1] + sigma / step_reducer * (v[:, j] - v[:, 1])
                            qvec .= v_test
                            f_test, flag = filter(qvec)
                            if !f_test
                                println(
                                    "The parameter set for the simplex shrinking is not realistic. \n",
                                )
                                step_reducer = 2 * step_reducer
                            else
                                f, f_test = objective(qvec)
                                if !f_test
                                    println(
                                        "The parameter set for the simplex shrinking is not realistic. \n",
                                    )
                                    step_reducer = 2 * step_reducer
                                end
                            end
                        end
                        v[:, j] = v_test
                        fv[j] = loss(f)
                    end
                    func_evals = func_evals + n_par
                end
            end
        end
        j = sortperm(fv)
        fv = fv[j]
        v = v[:, j]
        itercount = itercount + 1
        if options.report && mod(itercount, 100) == 0
            println(
                "step " * string(itercount) * " ssq ",
                string(minimum(fv)) * "-",
                string(maximum(fv)) * " " * how * "\n",
            )
        end
    end # while

    qvec .= v[:, 1]

    fval = minimum(fv)
    if func_evals >= options.max_fun_evals
        if options.report
            println(
                "No convergences with " * string(options.max_fun_evals) * " function evaluations\n",
            )
        end
        info = false
    elseif itercount >= options.max_step_number
        if options.report
            println("No convergences with " * string(options.max_step_number) * " steps\n")
        end
        info = false
    else
        if options.report
            println("Successful convergence \n")
        end
        info = true
    end
    return (qvec, info, itercount, fval)
end

## Description
# Calculates the loss function
#   w' (d - f)^2/ (mean_d^2 + mean_f^2)
# multiplicative symmetric bounded 
#
# Input
#
# * data: vector with (dependent) data
# * meanData: vector with mean value of data per set
# * prdData: vector with predictions
# * meanPrdData: vector with mean value of predictions per set
# * weights: vector with weights for the data
function lossfunction_sb(data, meanData, prdData, meanPrdData, weights)
    prdData  = map(prdData, data) do p, d
        p isa Unitful.Quantity ? ustrip(Unitful.unit(d), p) : p
    end
    meanPrdData = map(meanPrdData, meanData) do p, d
        p isa Unitful.Quantity ? ustrip(Unitful.unit(d), p) : p
    end
    data = map(ustrip, data)
    meanData = map(ustrip, meanData)
    return lossfunction_sb(map(SVector, (data, meanData, prdData, meanPrdData, weights))...)
end
function lossfunction_sb(data::SVector, meanData::SVector, prdData::SVector, meanPrdData::SVector, weights::SVector)
    return sum(weights .* ((data .- prdData) .^ 2 ./ (meanData .^ 2 .+ meanPrdData .^ 2)))
end

function struct2vector(structin::NamedTuple, structref)
    combined = _combine(structin, structref)
    meanstruct = _mean(combined, structref)
    vec = Flatten.flatten(combined, Number)
    meanvec = Flatten.flatten(meanstruct, Number)

    return vec, meanvec
end

Base.@assume_effects :foldable function _combine(x::NamedTuple, ref::NamedTuple{N2}) where N2
    map(N2) do n
        _combine(x[n], ref[n])
    end |> NamedTuple{N2}
end
_combine(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_combine(x, ref) = x

Base.@assume_effects :foldable function _mean(x::NamedTuple, ref::NamedTuple{N2}) where N2
    map(N2) do n
        _mean(x[n], ref[n])
    end |> NamedTuple{N2}
end
_mean(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_mean(x::AbstractArray, ref::AbstractArray) = (m = mean(x); map(_ -> m, ref))
_mean(x::Number, ref::Number) = x * 1.0


function maybe_objective(objective, filter, loss, qvec, fv)
    f_test, flag = filter(qvec)
    if !f_test
        fv[np1] + 1
    else
        f, f_test = objective(qvec)
        if !f_test
            fv[np1] + 1
        else
            loss(f)
        end
    end
end
