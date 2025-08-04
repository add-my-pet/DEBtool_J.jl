abstract type AbstractEstimationData end

@kwdef struct EstimationData{TSC,TSB,L,WW,G,R,U,P} <: AbstractEstimationData
    timesinceconception::TSC = nothing
    timesincebirth::TSB = nothing
    length::L = nothing
    wetweight::WW = nothing
    reproduction::R = nothing
    gestation::G = nothing
    univariate::U = nothing
    pseudo::P = nothing
end

abstract type Data end

"""
    Sequence <: Data

Abstract supertype for a sequence of data points,
usually wrapping a vector.
"""
abstract type Sequence <: Data end
(::Type{T})() where T<:Sequence = T(nothing)

struct Temperatures{T} <: Sequence
    val::T
end
struct Lengths{T} <: Sequence
    val::T
end
struct Food{T} <: Sequence
    val::T
end
struct FunctionalResponses{T} <: Sequence
    val::T
end
struct Times{T} <: Sequence
    val::T
end
struct DryWeights{T} <: Sequence
    val::T
end
struct WetWeights{T} <: Sequence
    val::T
end

struct Univariate{I<:Sequence,D<:Sequence} <: Data
    independent::I
    dependent::D
end

struct Multivariate{I<:Sequence,D<:Tuple{<:Sequence,Vararg}} <: Data
    independent::I
    dependents::D
end

struct AtTemperature{T,X}
    t::T
    x::X
end

# Object/type utilities copied from DimensionalData.jl

basetypeof(::Type{T}) where T = T.name.wrapper
basetypeof(::T) where T = basetypeof(T)
rebuild(::T, x) where T = basetypeof(T)(x)
