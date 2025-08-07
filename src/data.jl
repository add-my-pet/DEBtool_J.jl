abstract type AbstractEstimationData end

# TODO: rethink this object
# It may be better if it has no named fields,
# and instead holds a tuple of wrapped objects, e.g. WetWeight, Duration etc.
# that would allow new data types to be added easily. But it may also be overkill.
"""
    EstimationData <: AbstractEstimationData

    EstimationData(; kw...)

A wrapper for all data used to estimate model parameters in [`estimate`](@ref).

# Keywords

- `timesinceconception`:
- `timesincebirth`:
- `length`:
- `wetweight`:
- `dryweight`:
- `reproduction`:
- `duration`:
- `gestation`:
- `variate`:
- `pseudo`:
"""
struct EstimationData{TSC,TSB,L,WW,DW,R,D,G,V,P} <: AbstractEstimationData
    timesinceconception::TSC
    timesincebirth::TSB
    length::L
    wetweight::WW
    dryweight::DW
    reproduction::R
    duration::D
    gestation::G
    variate::V
    pseudo::P
end
function EstimationData(;
    timesinceconception = nothing,
    timesincebirth = nothing,
    length = nothing,
    wetweight = nothing,
    dryweight = nothing,
    reproduction = nothing,
    duration = nothing,
    gestation = nothing,
    variate = nothing,
    pseudo = nothing,
)
    pseudo = defaultpseudodata(pseudo)
    return EstimationData(timesinceconception, timesincebirth, length, wetweight, dryweight, reproduction, duration, gestation, variate, pseudo)
end

Base.merge(ed::EstimationData, nt::NamedTuple) = ConstructionBase.setproperties(ed, nt)

# TODO better describe, maybe rename this more specifically
abstract type Data end

(::Type{T})() where T<:Data = T(nothing)

"""
    Temperature <: Data

    Temperature(data)

Wrapper for temperature data.

Often the `independent` argument to `Univariate` or `Multivariate` datasets.
"""
struct Temperature{T} <: Data
    val::T
end
"""
    Length <: Data

    Length(data)

Wrapper for length data.
"""
struct Length{T} <: Data
    val::T
end
# TODO is this needed?
struct Food{T} <: Data
    val::T
end
struct FunctionalResponse{T} <: Data
    val::T
end
"""
    Time <: Data

    Time(data)

Wrapper for time data. 

Usually the `independent` argument to `Univariate` or `Multivariate` datasets.
"""
struct Time{T} <: Data
    val::T
end
"""
    DryWeight <: Data

    DryWeight(data)

Wrapper for dry weight data.
"""
struct DryWeight{T} <: Data
    val::T
end
"""
    WetWeight <: Data

    WetWeight(data)

Wrapper for wet weight data.
"""
struct WetWeight{T} <: Data
    val::T
end
"""
    Duration{X} <: Data

    Duration{X}(data)

Wrapper for duration data, for life stage of type `X`.
"""
struct Duration{X,T} <: Data
    val::T
end
Duration{X}(val::T) where {X,T} = Duration{X,T}(val)
"""
    Period{A,B} <: Data

    Period{A,B}(data)

Wrapper for data on the period between two transitions, `A` and `B`.
"""
struct Period{A,B,T} <: Data
    val::T
end
Period{A,B}(val::T) where {A,B,T} = Period{A,B,T}(val)

# TODO: can we just use Multivariate for everything?
struct Univariate{I<:Data,D<:Data} <: Data
    independent::I
    dependent::D
end
function Univariate(independent, dependent, data::AbstractMatrix)
    @assert size(data, 2) == 2
    iv = independent.val
    dv = dependent.val
    @show iv dv
    idata = isnothing(iv) ? data[:, 1] : data[:, 1] .* iv
    ddata = isnothing(dv) ? data[:, 2] : data[:, 2] .* dv
    @show idata ddata
    return Univariate(rebuild(independent, idata), rebuild(dependent, data[:, 2]))
end

"""
    Multivariate <: Data

    Multivariate(independent, dependents, [data])

Container for multivariate datasets.

If a data argument is used, it is expected to be a matrix or table of values
with columns matching the number of dependent variables plus the independent variable.

If dependent or independent variables hold values other than `nothing`, it will
be multiplied with the data columns to e.g. add units.
"""
struct Multivariate{I<:Data,D<:Tuple{<:Data,Vararg}} <: Data
    independent::I
    dependents::D
end
function Multivariate(independent, dependent::Tuple, data::AbstractMatrix)
    @assert size(data, 2) == length(dependents) + 1
    iv = independent.val
    idata = isnothing(iv) ? data[:, 1] : data[:, 1] .* iv
    ddata = map(dependents, ntuple(identity, length(dependents))) do d, i
        dv = d.val
        rebuild(d, isnothing(dv) ? data[:, i] : data[:, i] .* dv)
    end
    return Univariate(rebuild(independent, idata), ddata)
end

"""
    AtTemperature(temperature, val)

A wrapper type to specify that observed data was at a different 
temperature to the default for the observations.

# Example

```julia
AtTemperature(22.0u"°C", Birth(2.0u"cm"))
```
"""
struct AtTemperature{T,X}
    t::T
    x::X
end

# Object/type utilities copied from DimensionalData.jl
# these make it easy to wrap objects in a type wrapper
basetypeof(::Type{T}) where T = T.name.wrapper
basetypeof(::T) where T = basetypeof(T)
rebuild(::T, x) where T = basetypeof(T)(x)
