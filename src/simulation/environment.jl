abstract type AbstractEnvironment end

# Wrapper for a DataInterpolations interpolator whose data had Unitful units.
# Units are stripped before interpolation and reattached on retrieval.
struct UnitfulInterp{I, U}
    interp::I
    u_factor::U
end
(ui::UnitfulInterp)(t) = ui.interp(t) * ui.u_factor

"""
    ConstantEnvironment <: AbstractEnvironment

An environment with fixed variables for all times.
"""
struct ConstantEnvironment{Te,F,TC} <: AbstractEnvironment
    temperature::Te
    food::F
    tempcorrection::TC
end
function ConstantEnvironment(; 
    temperature=nothing,
    tempcorrection=nothing,
    food=nothing,
    temperatureresponse=nothing
)
    tempcorrection = if !isnothing(tempcorrection)
        tempcorrection
    elseif isnothing(temperatureresponse) || isnothing(temperature)
        nothing
    else
        tempcorr(temperatureresponse, temperature)
    end
    return ConstantEnvironment(temperature, food, tempcorrection)
end

getattime(e::ConstantEnvironment, x, t) = getproperty(e, x)  
tspan(e::ConstantEnvironment) = first(e.time), last(e.time)

"""
    Environment <: AbstractEnvironment

    Environment(; 
        times,
        temperatures=nothing,
        food=nothing,
        interpolation=CubicSpline, 
        temperatureresponse=nothing
    )

An environment that varies over time.

The results of `getattime(e::Environment, property, t)` are interpolated
from the environmental data using the `interpolation` method.

- `times`:
- `temperatures`: temperatures for each time in `times`.
- `food`: functional responses for each time in `times`.
- `interpolation`: a DataInterpolations.jl `AbstractInterpolation`.
- `temperatureresponse`: a parametrised `AbstractTemperatureResponse` object.
"""
struct Environment{Ti,Te,TC,FR,I<:NamedTuple} <: AbstractEnvironment
    time::Ti
    temperature::Te
    tempcorrection::TC
    food::FR
    interpolators::I
end
function Environment(;
    time,
    temperature=nothing,
    food=nothing,
    interpolation=CubicSpline,
    temperatureresponse=nothing,
    tempcorrection=nothing,
)
    tempcorrection = if !isnothing(tempcorrection)
        tempcorrection  # pre-computed array passed directly
    elseif isnothing(temperatureresponse) || isnothing(temperature)
        nothing
    else
        tempcorr(temperatureresponse, temperature)
    end
    interpolators = if isnothing(interpolation)
        nothing
    else
        # food may be a NamedTuple of arrays (e.g. for iso221: (X1=..., X2=...))
        # in that case create separate interpolators for each food type.
        # DataInterpolations does not support Unitful arrays, so strip units from
        # the food data and store a unit-restoring multiplier alongside the interpolator.
        food_interp = if food isa NamedTuple
            map(food) do fd
                isnothing(fd) && return nothing
                # Always strip potential Unitful units before passing to DataInterpolations.
                # oneunit(Float64) = 1.0 and ustrip(Float64) = identity, so this is safe
                # for plain float arrays too.
                u_factor = oneunit(eltype(fd))
                UnitfulInterp(interpolation(ustrip.(fd), time), u_factor)
            end
        elseif isnothing(food)
            nothing
        else
            interpolation(food, time)
        end
        map((; temperature, tempcorrection)) do d
            isnothing(d) ? nothing : interpolation(d, time)
        end |> nt -> merge(nt, (; food=food_interp))
    end
    return Environment(time, temperature, tempcorrection, food, interpolators)
end

getattime(e::Environment, x::Symbol, t) = _getattime_env(getproperty(e.interpolators, x), t)

# Scalar interpolator (or UnitfulInterp which is callable): call it directly
_getattime_env(interp, t) = interp(t)
# NamedTuple of interpolators (e.g. food=(X1=..., X2=...) for iso221): call each
_getattime_env(interp::NamedTuple, t) = map(f -> f(t), interp)
_getattime_env(::Nothing, t) = nothing
tspan(e::Environment) = first(e.time), last(e.time)

"""
    InteractiveEnvironment <: AbstractEnvironment

    InteractiveEnvironment(; 
        times,
        temperatures=nothing,
        food=nothing,
        interpolation=CubicSpline, 
        temperatureresponse=nothing
    )

An environment that varies over time.

The results of `getattime(e::Environment, property, t)` are interpolated
from the environmental data using the `interpolation` method.

- `times`:
- `temperatures`: temperatures for each time in `times`.
- `food`: functional responses for each time in `times`.
- `interpolation`: a DataInterpolations.jl `AbstractInterpolation`.
- `temperatureresponse`: a parametrised `AbstractTemperatureResponse` object.
"""
# struct InteractiveEnvironment{Ti,Te,TC,FR,I<:NamedTuple}
#     time::Ti
#     temperature::Te
#     tempcorrection::TC
#     food::FR
#     interpolators::I
# end
# function InteractiveEnvironment(; 
#     time,
#     temperature=nothing,
#     food=nothing,
#     interpolation=CubicSpline, 
#     temperatureresponse=nothing
# )
#     tempcorrection = if isnothing(temperatureresponse) || isnothing(temperature)
#         nothing
#     else
#         tempcorr(temperatureresponse, temperature)
#     end
#     interpolators = if isnothing(interpolation)
#         nothing
#     else
#         map((; temperature, tempcorrection, food)) do d
#             isnothing(d) ? nothing : interpolation(d, time)
#         end
#     end
#     return InteractiveEnvironment(time, temperature, tempcorrection, food, interpolators)
# end


