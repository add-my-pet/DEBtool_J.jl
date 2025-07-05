# TODO reorganise where these functions live

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
function optimize!(objective, filter, loss, estimator::Estimator{DEBNelderMead}, qvec::Vector)
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
    xin = copy(qvec) # Place input guess in the simplex
    v = zeros(Float64, length(xin), Int(n_par) + 1)
    fv = zeros(Float64, n_par + 1)
    v_test = zeros(size(v, 1))
    v[:, 1] .= xin
    f = objective(qvec)[1]
    fv[1] = loss(f)

    # Following improvement suggested by L.Pfeffer at Stanford 
    # TODO: but what does it do and why is it needed
    # This code prevents us rolling loss/objective/filter into one function
    usual_delta = estimator.method.simplex_size         # 5 percent deltas is the default for non-zero terms
    zero_term_delta = usual_delta / 20 # Even smaller delta for zero elements of q
    y_test = similar(xin)
    for j in 1:n_par
        f_test = false
        step_reducer = 1 # step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
        y_test .= xin
        while !f_test
            y_test[j] = if xin[j] != 0
                (1 + usual_delta / step_reducer) * xin[j]
            else
                zero_term_delta / step_reducer
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
    if estimator.verbose
        println("step " * string(itercount) * " ssq ",
            string(minimum(fv)) * "-",
            string(maximum(fv)) * " " * how * "\n"
        )
    end
    info = true

    # Main algorithm
    # Iterate until the diameter of the simplex is less than tol_simplex
    #   AND the function values differ from the min by less than tol_fun,
    #   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
    while func_evals < estimator.max_fun_evals && itercount < estimator.max_step_number
        if maximum(Unitful.ustrip(abs.(view(v, :, two2np1) .- view(v, :, onesn)))) <=
            estimator.method.tol_simplex && maximum(Unitful.ustrip(abs.(fv[1] .- fv[two2np1]))) <= estimator.method.tol_fun
            break
        end
        how = ""

        # Compute the reflection point

        # xbar = average of the n (NOT n+1) best points
        xbar = (sum(view(v, :, one2n); dims=2) ./ n_par) 
        xr = (1 + rho) * xbar - rho * v[:, np1]
        qvec .= xr
        fxr = maybe_objective(objective, filter, loss, qvec, np1, fv)
        func_evals = func_evals + 1

        if fxr < fv[1]
            # Calculate the expansion point
            xe = (1 + rho * chi) .* xbar - rho * chi .* v[:, np1]
            qvec .= xe
            fxe = maybe_objective(objective, filter, loss, qvec, np1, fv)
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
                    fxc = maybe_objective(objective, filter, loss, qvec, np1, fv)
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
                    fxcc = maybe_objective(objective, filter, loss, qvec, np1, fv)
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
                                println("The parameter set for the simplex shrinking is not realistic. \n")
                                step_reducer = 2 * step_reducer
                            else
                                f, f_test = objective(qvec)
                                if !f_test
                                    println("The parameter set for the simplex shrinking is not realistic. \n")
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
        if estimator.verbose && mod(itercount, 100) == 0
            println(
                "step " * string(itercount) * " ssq ",
                string(minimum(fv)) * "-",
                string(maximum(fv)) * " " * how * "\n",
            )
        end
    end # while

    qvec .= v[:, 1]

    fval = minimum(fv)
    if func_evals >= estimator.max_fun_evals
        estimator.verbose && println("No convergences with " * string(estimator.max_fun_evals) * " function evaluations\n")
        info = false
    elseif itercount >= estimator.max_step_number
        estimator.verbose && println("No convergences with " * string(estimator.max_step_number) * " steps\n")
        info = false
    else
        estimator.verbose && println("Successful convergence \n")
        info = true
    end
    return (qvec, info, itercount, fval)
end


function struct2vector(structin, structref)
    combined = _combine(structin, structref)
    return Flatten.flatten(combined, Number)
end
function struct2means(structin, structref)
    meanstruct = _mean(structin, structref)
    return Flatten.flatten(meanstruct, Number)
end

const SELECT = Union{Number,AbstractArray,AtTemperature,Univariate}

function _combine(xs::Union{Tuple,NamedTuple}, refs::NamedTuple)
    map(Flatten.flatten(xs, SELECT), Flatten.flatten(refs, SELECT)) do x, ref
        _combine(x, ref)
    end |> Flatten.flatten
end
_combine(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_combine(x::AbstractArray, ref::AbstractArray) = x
_combine(x::Number, ref::Number) = x
_combine(x::Pair, ref::Pair) = x
_combine(x::AtTemperature, ref::AtTemperature) = _combine(only(Flatten.flatten(x.x, SELECT)), only(Flatten.flatten(x.x, SELECT)))
_combine(x::Univariate, ref::Univariate) = _combine(only(Flatten.flatten(x.dependent, SELECT)), only(Flatten.flatten(ref.dependent, SELECT)))
_combine(x::SVector, ref::Univariate) = _combine(x, only(Flatten.flatten(ref.dependent, SELECT)))
_combine(x::SVector, ref::AtTemperature) = _combine(x, ref.x)
_combine(x::Number, ref::AtTemperature) = _combine(x, ref.x)

function _mean(xs::NamedTuple, refs::NamedTuple)
    map(Flatten.flatten(xs, SELECT), Flatten.flatten(refs, SELECT)) do x, ref
        _mean(x, ref)
    end |> Flatten.flatten
end
_mean(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_mean(x::AbstractArray, ref::AbstractArray) = (m = mean(x); map(_ -> m, ref))
_mean(x::Number, ref::Number) = x * 1.0
_mean(x::AtTemperature, ref::AtTemperature) = _mean(only(Flatten.flatten(x.x, SELECT)), only(Flatten.flatten(ref.x, SELECT)))
_mean(x::Univariate, ref::Univariate) = _mean(only(Flatten.flatten(x.dependent, SELECT)), only(Flatten.flatten(ref.dependent, SELECT)))
_mean(x::SVector, ref::Univariate) = _mean(x, only(Flatten.flatten(ref.dependent, SELECT)))
_mean(x::SVector, ref::AtTemperature) = _mean(x, only(Flatten.flatten(ref.x, SELECT)))
_mean(x::Number, ref::AtTemperature) = _mean(x, only(Flatten.flatten(ref.x, SELECT)))

function maybe_objective(objective, filter, loss, qvec, np1, fv)
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
