struct Arrhenius1parTemperatureResponse <: AbstractTemperatureResponse
    # T_ref::TR
    # T_A::TA
end
struct Arrhenius3parTemperatureResponse <: AbstractTemperatureResponse
    # T_ref::TR
    # T_L::TL
    # T_H::TH
end

# TODO: the rest of the parameters
struct Arrhenius5parTemperatureResponse <: AbstractTemperatureResponse
    # T_ref::TR
    # T_L::TL
    # T_H::TH
    # function Arrhenius5parTemperatureResponse(T_ref::TR... T_L::TL, T_H::TH) where {TR,TL,TH}
    #     T_L > T_ref || T_H < T_ref && error("from temp_corr: invalid parameter combination, T_L > T_ref and/or T_H < T_ref")
    #     new{TL,TH,TR}(T_ref, ..., T_L, T_H)
    # end
end

tempcorr(model::Arrhenius1parTemperatureResponse, pars::NamedTuple, e::AbstractEnvironment) =
    rebuild(e; data=map(d -> tempcorr(model, pars, d), e.data))
# Most data is not temperature corrected
tempcorr(model::Arrhenius1parTemperatureResponse, pars::NamedTuple, d::Data) = d
# Temperature data needs correction
tempcorr(model::Arrhenius1parTemperatureResponse, pars::NamedTuple, d::Temperatures) = 
    tempcorr(model, pars, d.val)
tempcorr(model::Arrhenius1parTemperatureResponse, pars::NamedTuple, T::AbstractArray) = 
    tempcorr.((model,), (pars,), T)
function tempcorr(model::Arrhenius1parTemperatureResponse, pars::NamedTuple, T::Number)
    s_A = _arrenenius_factor(model, pars, T)
    return s_A
end
function tempcorr(model::Arrhenius3parTemperatureResponse, pars::NamedTuple, T::Number)
    error("Not tested")
    s_A = _arrenenius_factor(model, pars, T)
    (; T_ref, T_L, T_H, T_AH, T_AL) = pars # Arrh. temp for upper boundary
    if T_H < T_ref
        s_L_ratio = (1 + exp(T_AL / T_ref - T_AL / T_L)) / (1 + exp(T_AL / T - T_AL / T_L))
        TC = s_A * ((T <= T_ref) * s_L_ratio + (T > T_ref))
    else
        s_H_ratio = (1 + exp(T_AH / T_H - T_AH / T_ref)) / (1 + exp(T_AH / T_H - T_AH / T))
        TC = s_A * ((T >= T_ref) * s_H_ratio + (T < T_ref))
    end
end
function tempcorr(model::Arrhenius5parTemperatureResponse, pars::NamedTuple, T::Number)
    error("Not tested")
    s_A = _arrenenius_factor(model, pars, T)
    (; T_ref, T_L, T_H, T_AL, T_AH) = pars
    s_L_ratio = (1 + exp(T_AL / T_ref - T_AL / T_L)) / (1 + exp(T_AL ./ T - T_AL / T_L))
    s_H_ratio = (1 + exp(T_AH / T_H - T_AH / T_ref)) / (1 + exp(T_AH / T_H - T_AH / T))
    TC = s_A * ((T <= T_ref) * s_L_ratio + (T > T_ref) * s_H_ratio)
    return S_A
end


_arrenenius_factor(model, p, T) = exp(p.T_A / p.T_ref - p.T_A ./ T)

