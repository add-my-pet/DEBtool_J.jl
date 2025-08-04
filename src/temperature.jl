"""
    AbstractTemperatureResponse

Lifespans are used in `lifespan`
"""
abstract type AbstractTemperatureResponse end

@kwdef struct ArrheniusResponse{TR,TA} <: AbstractTemperatureResponse
    T_ref::TR
    T_A::TA
end
@kwdef struct LowTorporResponse{TR,TA,TL,TAL} <: AbstractTemperatureResponse
    T_ref::TR
    T_A::TA
    T_L::TL
    T_AL::TAL
end
@kwdef struct HighTorporResponse{TR,TA,TH,TAH} <: AbstractTemperatureResponse
    T_ref::TR
    T_A::TA
    T_H::TH
    T_AH::TAH
end

struct LowAndHighTorporResponse{TR,TA,TL,TAL,TH,TAH} <: AbstractTemperatureResponse
    T_ref::TR
    T_A::TA
    T_L::TL
    T_AL::TAL
    T_H::TH
    T_AH::TAH
end

check_temp(tr::ArrheniusResponse, T) = true
check_temp(tr::LowTorporResponse, T) = tr.T_H >= T
check_temp(tr::HighTorporResponse, T) = tr.T_L <= T
check_temp(tr::LowAndHighTorporResponse, T) = tr.T_L <= T && tr.T_H >= T

# TODO add this check somehow, but not in the inner constructor
# _check_T(T_ref, T_L, T_H) = 
    # T_L > T_ref || T_H < T_ref && error("from temp_corr: invalid parameter combination, T_L > T_ref and /or T_H < T_ref")

# Move parameters from pars NameTuple into temperature model objects
# Eventually parameters should just be defined as objects from the start,
# but for now this allows both approaches to work with the same code.
tempcorr(model::ArrheniusResponse, par::NamedTuple, T) =
    tempcorr(ConstructionBase.setproperties(model, par[(:T_ref, :T_A)]), T)
tempcorr(model::LowTorporResponse, par::NamedTuple, T) =
    tempcorr(ConstructionBase.setproperties(model, par[(:T_ref, :T_A, :T_L, :T_AL)]), T)
tempcorr(model::HighTorporResponse, par::NamedTuple, T) =
    tempcorr(ConstructionBase.setproperties(model, par[(:T_ref, :T_A, :T_H, :T_AH)]), T)
tempcorr(model::LowAndHighTorporResponse, pars::NamedTuple, T) =
    tempcorr(ConstructionBase.setproperties(model, par[(:T_ref, :T_A, :T_L, :T_AL, :T_H, :T_AH)]), T)

tempcorr(model::AbstractTemperatureResponse, e::AbstractEnvironment) =
    rebuild(e; data=map(d -> tempcorr(model, d), e.data))
# Most data is not temperature corrected
tempcorr(model::AbstractTemperatureResponse, d::Data) = d
# Temperature data needs correction
tempcorr(model::AbstractTemperatureResponse, d::Temperatures) = 
    tempcorr(model, d.val)
tempcorr(model::AbstractTemperatureResponse, T::AbstractArray) = 
    tempcorr.((model,), T)
function tempcorr(model::ArrheniusResponse, T::Number)
    s_A = _arrenenius_factor(model, T)
    return s_A
end
function tempcorr(model::LowTorporResponse, T::Number)
    (; T_ref, T_L, T_AL) = model # Arrh. temp for upper boundary
    s_A = _arrenenius_factor(model, T)
    s_L_ratio = _low_ratio(T_ref, T_L, T_A, T_AL)
    TC = s_A * ((T <= T_ref) * s_L_ratio + (T > T_ref))
    return TC
end
function tempcorr(model::HighTorporResponse, T::Number)
    (; T_ref, T_H, T_AH) = model # Arrh. temp for upper boundary
    s_A = _arrenenius_factor(model, T)
    s_H_ratio = _high_ratio(T_ref, T_H, T_A, T_AH)
    TC = s_A * ((T >= T_ref) * s_H_ratio + (T < T_ref))
    return TC
end
function tempcorr(model::LowAndHighTorporResponse, T::Number)
    (; T_ref, T_L, T_AL, T_H, T_AH) = model
    s_A = _arrenenius_factor(model, T)
    s_L_ratio = _low_ratio(T_ref, T_L, T_A, T_AL)
    s_H_ratio = _high_ratio(T_ref, T_H, T_A, T_AH)
    TC = s_A * ((T <= T_ref) * s_L_ratio + (T > T_ref) * s_H_ratio)
    return TC
end

_arrenenius_factor(p, T) = exp(p.T_A / p.T_ref - p.T_A ./ T)

_low_ratio(T_ref, T_L, T_A, T_AL) = 
    (1 + exp(T_AL / T_ref - T_AL / T_L)) / (1 + exp(T_AL / T - T_AL / T_L))

_high_ratio(T_ref, T_H, T_A, T_AH) = 
    (1 + exp(T_AH / T_H - T_AH / T_ref)) / (1 + exp(T_AH / T_H - T_AH / T))

