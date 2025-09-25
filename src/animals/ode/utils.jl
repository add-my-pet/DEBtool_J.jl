
# This file holds simulation code adapted from amptool
# Its written so there is only one simulation function and one timestep function,
# model differences are/will be handled with different callbacks, initialisation and acceleration functions

@kwdef struct MetabolismBehaviorEnvironment{M,B,E,P}
    metabolism::M 
    behavior::B = NullBehavior()
    environment::E = ConstantEnvironment()
    par::P
end
function rebuild(mbe::MetabolismBehaviorEnvironment; 
    metabolism=mbe.metabolism, behavior=mbe.behavior, environment=mbe.environment, par=mbe.par
)
    MetabolismBehaviorEnvironment(metabolism, behavior, environment, par)
end

@kwdef struct MetabolismEnvironment{M,E,P}
    metabolism::M 
    environment::E = ConstantEnvironment()
    par::P
end
function rebuild(mbe::MetabolismEnvironment; 
    model=mbe.metabolism, environment=mbe.environment, par=mbe.par
)
    MetabolismBehaviorEnvironment(metabolism, environment, par)
end

"""
    StateReconstructor(f, template)

Integrates with DifferentialEquations.jl to allow nested and types state
without fuss or the need for ComponentArrays.jl. 

StateReconstructor instead using Flatten.jl to reconstruct the template object
from an iterator, such as the `u` state from DiffEq.

"""
struct StateReconstructor{F,T,U}
    f::F
    template::T
    time_units::U
end
function (sr::StateReconstructor)(u::AbstractArray, p, t)
    res = sr.f(to_obj(sr, u), p, t)
    to_vec(sr, res) 
end

function to_vec(sr::StateReconstructor, obj)
    converted = map(Flatten.flatten(obj, Number), Flatten.flatten(sr.template, Number)) do r, t 
        if isnothing(sr.time_units) 
            convert(typeof(t), r)
        else
            convert(typeof(t), r * sr.time_units)
        end
    end
    # TODO get T rather than AbstractFloat
    return SVector(Flatten.flatten(converted, AbstractFloat))
end

to_obj(sr::StateReconstructor, vec::AbstractArray{T}) where T =
    Flatten.reconstruct(sr.template, vec, T)

Base.values(sr::StateReconstructor) = Flatten.flatten(sr.template, AbstractFloat)
Base.collect(sr::StateReconstructor) = collect(values(sr))
Base.Array(sr::StateReconstructor) = collect(sr)

StaticArrays.SVector(sr::StateReconstructor) = SVector(values(sr))
StaticArrays.SArray(sr::StateReconstructor) = SVector(values(sr))

SciMLBase.ODEProblem(sr::StateReconstructor, tspan::Tuple, p) =
    SciMLBase.ODEProblem(sr, SVector(sr), tspan, p)

struct CallbackReconstructor{C,T}
    callback::C
    template::T
end
(cr::CallbackReconstructor)(u::AbstractArray{T}, p, τ) where T =
    cr.callback(Flatten.reconstruct(cr.template, u, T), p, τ)
(cr::CallbackReconstructor)(out::AbstractArray, u::AbstractArray{T}, p, τ) where T =
    cr.callback(out, Flatten.reconstruct(cr.template, u, T), p, τ)

@kwdef struct Simulator{S,AT,RT,Ts}
    solver::S = Tsit5()
    abstol::AT = 1e-9
    reltol::RT = 1e-9
    tspan::Ts
end

function combine_sols!(sol1::SciMLBase.ODESolution, sols...)
    append!(sol1.u, map(s -> s.u, sols)...)
    append!(sol1.t, map(s -> s.t, sols)...)
    append!(sol1.interp.ks, map(s -> s.interp.ks, sols)...)
    return sol1
end
