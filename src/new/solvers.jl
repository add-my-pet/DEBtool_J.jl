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
# * x1: scalar with upper boundary for integration
#
# Output
#
# * f: scalar with particular incomplete beta function

## Remarks
# See also <../lib/misc/beta_34_0 *beta_34_0*>

## Example of use
# beta0(0.1, 0.2)
function _beta0!(buffer::AbstractArray, x0::AbstractArray, x1::Number)
    buffer .= _beta0.(x0, x1)
end
function _beta0(x0::Number, x1::Number)
    # if x0 < 0 | x0 >= 1 | x1 < 0 | x1 >= 1
    #   println("Warning from beta0: argument values (" * string(x0) * "," * string(x1) * ") outside (0,1) \n");
    #   f = [;];
    #   dbstack
    #   return;
    # elseif x0 > x1
    #   println("Warning from beta0: lower boundary " * string(x0) * " larger than upper boundary " * string(x1) * " \n");
    #   f = [;];
    #   dbstack
    #   return;
    # end

    n0 = length(x0)
    n1 = length(x1)
    if n0 != n1 && n0 != 1 && n1 != 1
        _warn_value_range(x0, x1)
        f = NaN
        return f
    end

    x03 = x0^(1 / 3)
    x13 = x1^(1 / 3)
    a3 = sqrt(3)
    f1 = -3 * x13 + a3 * atan((oneunit(x13) + 2 * x13) / a3) - log(Complex(x13 - oneunit(x13))) + log(oneunit(x13) + x13 + x13^2) / 2
    f0 = -3 * x03 + a3 * atan((oneunit(x03) + 2 * x03) / a3) - log(Complex(x03 - oneunit(x03))) + log(Complex(oneunit(x03) + x03 + x03^2)) / 2
    f = f1 - f0

    return f
end

@noinline _warn_value_range(x0, x1) = @warn "beta0: argument values (" * num2str(x0) * "," * num2str(x1), ") outside (0,1) \n"



## wass petregr_f
# Finds parameter values for a pet that minimizes the lossfunction using Nelder Mead's simplex method using a filter

function optimize(model, par, data, auxData, weights, filternm, options)
end

# function struct2vector(structin::NamedTuple, nm::NamedTuple, structref)
#     combined = _combine(structin, nm, structref)
#     _mean(combined, structref)
#     meanstruct = _mean(combined, structref)
#     vec = Flatten.flatten(combined, Real) |> SVector
#     meanvec = Flatten.flatten(meanstruct, Real) |> SVector

#     return vec, meanvec
# end

function _combine(x::NamedTuple, ref::NamedTuple{NM}) where NM
    map(NM) do n
        haskey(x, n) ? _combine(x[n], ref[n]) : ref[n]
    end |> NamedTuple{NM}
end
_combine(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_combine(x, ref) = x

function _mean(x::NamedTuple, ref::NamedTuple{NM}) where NM
    map(NM) do n
        _mean(x[n], ref[n])
    end |> NamedTuple{NM}
end
_mean(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_mean(x::AbstractArray, ref::AbstractArray) = (m = mean(x); map(_ -> m, ref))
_mean(x::Number, ref::Number) = x * 1.0

