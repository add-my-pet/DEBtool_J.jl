abstract type AbstractEnvironment end

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
        map((; temperature, tempcorrection, food)) do d
            isnothing(d) ? nothing : interpolation(d, time)
        end
    end
    return Environment(time, temperature, tempcorrection, food, interpolators)
end

getattime(e::Environment, x::Symbol, t) = getproperty(e.interpolators, x)(t)
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


