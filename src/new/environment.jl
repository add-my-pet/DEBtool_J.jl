abstract type AbstractEnvironment end

"""
    ConstantEnvironment <: AbstractEnvironment

An environment with fixed variables for all times.
"""
struct ConstantEnvironment{Ti,Te,TC,FR} <: AbstractEnvironment
    time::Ti
    temperature::Te
    tempcorrection::TC
    functionalresponse::FR
end
function ConstantEnvironment(; 
    time=(0.0, 365.0),
    temperature=nothing,
    tempcorrection=nothing,
    functionalresponse=nothing,
    temperatureresponse=nothing
)
    tempcorrection = if !isnothing(tempcorrection)
        tempcorrection
    elseif isnothing(temperatureresponse) || isnothing(temperature)
        nothing
    else
        tempcorr(temperatureresponse, temperature)
    end
    return ConstantEnvironment(time, temperature, tempcorrection, functionalresponse)
end

getattime(e::ConstantEnvironment, x, t) = getproperty(e, x)  
tspan(e::ConstantEnvironment) = first(e.time), last(e.time)

"""
    Environment <: AbstractEnvironment

    Environment(; 
        times,
        temperatures=nothing,
        functionalresponses=nothing,
        interpolation=CubicSpline, 
        temperatureresponse=nothing
    )

An environment that varies over time.

The results of `getattime(e::Environment, property, t)` are interpolated
from the environmental data using the `interpolation` method.

- `times`:
- `temperatures`: temperatures for each time in `times`.
- `functionalresponses`: functional responses for each time in `times`.
- `interpolation`: a DataInterpolations.jl `AbstractInterpolation`.
- `temperatureresponse`: a parametrised `AbstractTemperatureResponse` object.
"""
struct Environment{Ti,Te,TC,FR,I<:NamedTuple} <: AbstractEnvironment
    time::Ti
    temperature::Te
    tempcorrection::TC
    functionalresponse::FR
    interpolators::I
end
function Environment(; 
    time,
    temperature=nothing,
    functionalresponse=nothing,
    interpolation=CubicSpline, 
    temperatureresponse=nothing
)
    tempcorrection = if isnothing(temperatureresponse) || isnothing(temperature)
        nothing
    else
        tempcorr(temperatureresponse, temperature)
    end
    interpolators = if isnothing(interpolation)
        nothing
    else
        map((; temperature, tempcorrection, functionalresponse)) do d
            isnothing(d) ? nothing : interpolation(d, time)
        end
    end
    return Environment(time, temperature, tempcorrection, functionalresponse, interpolators)
end

getattime(e::Environment, x::Symbol, t) = getproperty(e.interpolators, x)(t)
tspan(e::Environment) = first(e.time), last(e.time)

"""
    InteractiveEnvironment <: AbstractEnvironment

    InteractiveEnvironment(; 
        times,
        temperatures=nothing,
        functionalresponses=nothing,
        interpolation=CubicSpline, 
        temperatureresponse=nothing
    )

An environment that varies over time.

The results of `getattime(e::Environment, property, t)` are interpolated
from the environmental data using the `interpolation` method.

- `times`:
- `temperatures`: temperatures for each time in `times`.
- `functionalresponses`: functional responses for each time in `times`.
- `interpolation`: a DataInterpolations.jl `AbstractInterpolation`.
- `temperatureresponse`: a parametrised `AbstractTemperatureResponse` object.
"""
# struct InteractiveEnvironment{Ti,Te,TC,FR,I<:NamedTuple}
#     time::Ti
#     temperature::Te
#     tempcorrection::TC
#     functionalresponse::FR
#     interpolators::I
# end
# function InteractiveEnvironment(; 
#     time,
#     temperature=nothing,
#     functionalresponse=nothing,
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
#         map((; temperature, tempcorrection, functionalresponse)) do d
#             isnothing(d) ? nothing : interpolation(d, time)
#         end
#     end
#     return InteractiveEnvironment(time, temperature, tempcorrection, functionalresponse, interpolators)
# end

