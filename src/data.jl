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
# Always convert temperature to kelvin
function Temperature(x::Quantity{<:Any,<:Any,Unitful.FreeUnits})
    x1 = u"K"(A)
    Temperature{typeof(x1)}(x1)
end
function Temperature(A::AbstractArray{<:Quantity{<:Any,<:Any,<:Unitful.FreeUnits}})
    A1 = u"K".(A)
    Temperature{typeof(A1)}(A1)
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
ConstructionBase.constructorof(::Type{<:Duration{X}}) where {X} = Duration{X}
"""
    Period{A,B} <: Data

    Period{A,B}(data)

Wrapper for data on the period between two transitions, `A` and `B`.
"""
struct Period{A,B,T} <: Data
    val::T
end
Period{A,B}(val::T) where {A,B,T} = Period{A,B,T}(val)
ConstructionBase.constructorof(::Type{<:Period{A,B}}) where {A,B} = Period{A,B}

# TODO: can we just use Multivariate for everything?
struct Univariate{I<:Data,D<:Data} <: Data
    independent::I
    dependent::D
end
function Univariate(independent, dependent, data::SMatrix)
    @assert size(data, 2) == 2
    iv = inner_val(independent)
    dv = inner_val(dependent)
    idata = rebuild_inner(independent, isnothing(iv) ? data[:, 1] : data[:, 1] .* iv)
    ddata = rebuild_inner(dependent, isnothing(dv) ? data[:, 2] : data[:, 2] .* dv)
    return Univariate(idata, ddata)
end
function Univariate(independent, dependent, path::AbstractString)
    data, header = readdlm(path, ','; header=true)
    # TODO check the header names match ?
    Univariate(independent, dependent, SMatrix{size(data)...}(data))
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
function Multivariate(independent, dependents::Tuple, data::SMatrix)
    @assert size(data, 2) == length(dependents) + 1 "$(size(data, 2)) $(length(dependents) + 1)"
    iv = inner_val(independent)
    idata = isnothing(iv) ? data[:, 1] : data[:, 1] .* iv
    ddata = map(dependents, ntuple(identity, length(dependents))) do d, i
        dv = inner_val(d)
        rebuild_inner(d, isnothing(dv) ? data[:, i] : data[:, i] .* dv)
    end
    return Multivariate(rebuild_inner(independent, idata), ddata)
end
function Multivariate(independent, dependents::Tuple, path::AbstractString)
    data, header = readdlm(path, ','; header=true)
    @assert size(data, 2) == length(dependents) + 1 "$(size(data, 2)) $independent $dependents $data"
    # TODO does this really need to be static? it will fail if not but probably shouldn't
    Multivariate(independent, dependents, SMatrix{size(data)...}(data))
end

abstract type DataContext{X,V} <: Data end
"""
    AtTemperature(temperature, val)

A wrapper type to specify that observed data was at a different 
temperature to the default for the observations.

# Example

```julia
AtTemperature(22.0u"°C", Birth(2.0u"cm"))
```
"""
struct AtTemperature{T<:Number,V} <: DataContext{T,V}
    t::T
    val::V
end
AtTemperature(t::Number) = AtTemperature(t, nothing)
rebuild(at::AtTemperature, val) = AtTemperature(at.t, val)

"""
    Weighted(weight, val)

A wrapper type to specify that observed data takes a specific weight.
If `val` is an array a `Real` weight will be evenly distributed over all members.

# Example

This vector of lengths has a weight of 2.0 divided over its values.

```julia
Weighted(2.0, lenghts)
```
"""
struct Weighted{W<:Real,V} <: DataContext{W,V}
    weight::W
    val::V
end
Weighted(weight::Real) = Weighted(weight, nothing)
rebuild(w::Weighted, val) = Weighted(w.weight, val)


# Object/type utilities copied from DimensionalData.jl
# these make it easy to wrap objects in a type wrapper
basetypeof(::Type{T}) where T = ConstructionBase.constructorof(T)
basetypeof(::T) where T = basetypeof(T)
rebuild(::T, val) where T = basetypeof(T)(val)

rebuild_inner(d::Data, val) = rebuild(d, rebuild_inner(d.val,  val))
rebuild_inner(d, val) = val

inner_val(d::Data) = inner_val(d.val)
inner_val(val) = val
