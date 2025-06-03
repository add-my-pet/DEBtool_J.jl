"""
    AbstractTemperatureResponse

Lifespans are used in `lifespan`
"""
abstract type AbstractTemperatureResponse end

struct Arrhenius1parTemperatureResponse{TR,TA}
    T_ref::TR
    T_A::TA
end
struct Arrhenius3parTemperatureResponse{TR,TL,TH} <: AbstractTemperatureResponse
    T_ref::TR
    T_L::TL
    T_H::TH
end

# TODO: the rest of the parameters
struct Arrhenius5parTemperatureResponse{TR,TL,TH} <: AbstractTemperatureResponse
    T_ref::TR
    T_L::TL
    T_H::TH
    # function Arrhenius5parTemperatureResponse(T_ref::TR... T_L::TL, T_H::TH) where {TR,TL,TH}
    #     T_L > T_ref || T_H < T_ref && error("from temp_corr: invalid parameter combination, T_L > T_ref and/or T_H < T_ref")
    #     new{TL,TH,TR}(T_ref, ..., T_L, T_H)
    # end
end

function tempcorr(model::Arrhenius1parTemperatureResponse, T)
    s_A = _arrenenius_factor(model, T)
    return s_A
end
function tempcorr(model::Arrhenius3parTemperatureResponse, T)
    s_A = _arrenenius_factor(model, T)
    (; T_ref, T_L, T_H, T_AH, T_AL) = pars_T(3) # Arrh. temp for upper boundary
    if T_H < T_ref
        s_L_ratio = (1 + exp(T_AL ./ T_ref - T_AL / T_L)) ./ (1 + exp(T_AL ./ T - T_AL / T_L))
        TC = s_A .* ((T <= T_ref) .* s_L_ratio + (T > T_ref))
    else # pars_T(2) > T_ref
        s_H_ratio = (1 + exp(T_AH / T_H - T_AH ./ T_ref)) ./ (1 + exp(T_AH / T_H - T_AH ./ T))
        TC = s_A .* ((T >= T_ref) .* s_H_ratio + (T < T_ref))
    end
end
function tempcorr(model::Arrhenius5parTemperatureResponse, T)
    s_A = _arrenenius_factor(model, T)
    (; T_ref, T_L, T_H, T_AL, T_AH) = model
    s_L_ratio = (1 + exp(T_AL / T_ref - T_AL / T_L)) ./ (1 + exp(T_AL ./ T - T_AL / T_L))
    s_H_ratio = (1 + exp(T_AH / T_H - T_AH / T_ref)) ./ (1 + exp(T_AH / T_H - T_AH ./ T))
    TC = s_A .* ((T <= T_ref) .* s_L_ratio + (T > T_ref) .* s_H_ratio)
    return S_A
end

function _arrenenius_factor(model, T)
    (; T_A, T_ref) = model # Arrhenius temperature
    s_A = exp(T_A / T_ref - T_A ./ T)  # Arrhenius factor
    return s_A
end
