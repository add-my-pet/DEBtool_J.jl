
abstract type DEBData end
abstract type AbstractPseudoData <: DEBData end
abstract type AbstractUniVariate <: DEBData end
abstract type AbstractZeroVariate <: DEBData end

abstract type AbstractDEBModel end

# abstract type Data end
# abstract type AuxData end
# abstract type MetaData end
# abstract type TxtData end
# abstract type Weights end

#struct Std <: AbstractDEBModel end
# struct EcoCode <: MetaData end
# struct Temp <: AuxData end
# struct Psd <: Data end

abstract type AbstractAuxType end

abstract type AbstractMorph end

struct V0Morph <: AbstractMorph end
struct V1Morph <: AbstractMorph end
struct Isomorph <: AbstractMorph end
# struct VHalf <: AbstractMorph end

"""
    AbstractLifespan

Lifespans are used in `lifespan`
"""
abstract type AbstractLifespan end
struct StandardLifespan end

function lifespan(ls::StandardLifespan, par, cpar)
    # TODO why are par and cpar kept separate
    (; h_a) = par 
    (; g, l_T, h_a, k_M, s_G) = cpar

    pars_tm = (g, l_T, h_a / k_M ^ 2, s_G)  # compose parameter vector at T_ref
    tau_m = get_tm_s(pars_tm, f, l_b)       # -, scaled mean life span at T_ref
    mean_lifespan_at_T = tau_m / kT_M       # d, mean life span at T
    return mean_lifespan_at_T
end

"""
    AbstractTemperatureResponse

Lifespans are used in `lifespan`
"""
abstract type AbstractTemperatureResponse end

struct Arrhenius1parTemperatureResponse{TR,TA}
    T_ref::TR
    T_A::TA
end
struct Arrhenius3parTemperatureResponse <: AbstractTemperatureResponse
    T_ref::TR
    T_L::TL
    T_H::TH
end
struct Arrhenius5parTemperatureResponse{TR,TL,TH} <: AbstractTemperatureResponse
    T_ref::TR
    T_L::TL
    T_H::TH
    function Arrhenius5parTemperatureResponse(T_ref::TR... T_L::TL, T_H::TH) where {TR,TL,TH}
        T_L > T_ref || T_H < T_ref && error("from temp_corr: invalid parameter combination, T_L > T_ref and/or T_H < T_ref")
        new{TL,TH,TR}(T_ref, ..., T_L, T_H)
    end
end

function temperaturecorrection(model::Arrhenius1parTemperatureResponse, T)
    s_A = _arrenenius_factor(model, T)
    return s_A
end
function temperaturecorrection(model::Arrhenius3parTemperatureResponse, T)
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
function temperaturecorrection(model::Arrhenius5parTemperatureResponse, T)
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
    return S_A
end

abstract type AbstractLifestage end

abstract type AbstractEmbrio <: AbstractLifestage end
abstract type AbstractJouvenile <: AbstractLifestage end
abstract type AbstractAdult <: AbstractLifestage end
abstract type AbstractInstar{N} <: AbstractLifestage end

struct Embrio <: AbstractEmbrio end
struct Jouvenile <: AbstractJouvenile end
struct Adult <: AbstractAdult end
struct Instar{N} <: AbstractInstar{N} end

abstract type AbstractTransition end

abstract type AbstractBirth <: AbstractTransition end
abstract type AbstractPuberty <: AbstractTransition end
abstract type AbstractMetamorphosis <: AbstractTransition end
abstract type AbstractAsymtote <: AbstractTransition end

struct Birth <: AbstractBirth end
struct Puberty <: AbstractPuberty end
struct Metamorphosis <: AbstractMetamorphosis end
struct Asymtote <: AbstractAsymtote end

function transition(model::Birth, pars)
    # birth
    L_b = L_m * l_b                  # cm, structural length at birth at f
    Lw_b = L_b / del_M
    Ww_b = L_b^3 * d_V * (1 + f * w) # g, wet weight at birth at f
    a_b = t_b / k_M
    aT_b = a_b / TC
    a30_b = a_b / TC_30 # d, age at birth

    return (; L_b, Lw_b, Ww_b)
end
function transition(model::Puberty, pars)
    # puberty 
    tT_p = (t_p - t_b) / k_M / TC      # d, time since birth at puberty
    L_p = L_m * l_p                    # cm, structural length at puberty
    Lw_p = L_p / del_M                 # cm, plastron length at puberty
    Ww_p = L_p^3 * d_V * (1 + f * w)   # g, wet weight at puberty

    return (; L_p, Lw_p, Ww_p)
end
function transition(model::Asymptote, pars)
    # ultimate
    l_i = f - l_T                     # -, scaled ultimate length
    L_i = L_m * l_i                   # cm, ultimate structural length at f
    Lw_i = L_i / del_M                # cm, ultimate plastron length
    Ww_i = L_i^3 * d_V * (1 + f * w)  # g,  ultimate wet weight

    return (; L_i, Lw_i, Ww_i)
end

struct Dimorphic{F,M}
    female::F
    male::M
end


abstract type AbstractLifeStages end

@kw_def struct LifeStages{LS<:Tuple{Pair}}
    lifestages::LS
end

LifeStages(
    Embryo() => Birth(),
    Jouvenile() => Dimorphic(; female=Puberty(), male=Puberty()),
    Adult() => Death(),
)


## reprod_rate
# gets reproduction rate as function of time

##

"""
    AbstractReproduction

Lifespans are used in `reproduction`
"""
abstract type AbstractReproduction end

struct StandardReproduction end

function reproduction(r::StandardReproduction, par, cpar)
    (; kap, kap_R, v) = par 
    (; g, k_J, k_M, L_T, U_Hb, U_Hp) = cpar

    pars_R = (g, k_J, k_M, L_T, v, U_Hb, U_Hp)            # compose parameter vector at T
    reproduction_rate_at_T = TC_Ri * reprod_rate(L_i, f, pars_R)[1][1] # #/d, ultimate reproduction rate at T
    return reproduction_rate_at_T
end

struct Life{E}
    events::E
end

abstract type FeedingMode end
struct Feeding end
struct NoFeeding end

abstract type Mode end
# std
struct Standard <: Mode end 
# stf
struct FoetalDevelopment <: Mode end 
# stx
struct FoetalDevelopmentX <: Mode end 
# ssj?
# sbp
struct GrowthCeasesAtPuberty <: Mode end 
struct Accelerated{A<:AbstractEvent,B<:AbstractEvent} <: Mode
    startevent::A
    stopevent::B
end

@kwdef struct DEBModel{O}
    option::O = Standard()
end

option(model::Model) = model.standard

"""
    Hemimetabolous(feeding::FeedingMode)

# abp = Hemimetabolous{Feeding}
# hep = Hemimetabolous{NotFeeding}
"""
struct Hemimetabolous{F} <: Mode
    feeding::F
end

"""
    Holometabolous(feeding::FeedingMode)

# unnamed = Holometabolous{Feeding}
# hax = Holometabolous{NoFeeding}
# hex = Holometabolous{NoFeeding} (but maybe its not worth converting)
"""
struct Holometabolous{F} <: Mode
    feeding::F
end

# Deb model definitions ?
std() = DEBModel(Standard())
stf() = DEBModel(FoetalDevelopment())
stx() = DEBModel(FoetalDevelopmentX())
sbp() = DEBModel(GrowthCeasesAtPuberty())
hax() = DEBModel(Holometabolous(NoFeeding()))
hex() = DEBModel(Holometabolous(NoFeeding()))



# Gets chemical indices and chemical potential of N-waste from phylum, class

# abstract type Element end

# struct C <: Element end
# struct H <: Element end
# struct O <: Element end
# struct N <: Element end
# struct P <: Element end

# # State 
# struct Structure{E<:Tuple}
#     elements::E
# end

# # Waste type

# abstract type AbstractNitrogenWaste end

# # Do these make sense?
# struct Ammonoletic <: AbstractNitrogenWaste end
# struct Ureotelic <: AbstractNitrogenWaste end
# struct Uricotelic <: AbstractNitrogenWaste end
# struct CustomNWaste{Ch,HN,ON,NN,N,Am} <: AbstractNitrogenWaste
#     n_CN::CN
#     n_HN::HN
#     n_ON::ON
#     n_NN::NN
#     mu_N::N
#     ammonia::Am
# end
