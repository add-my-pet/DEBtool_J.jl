# These are very preliminary ideas...
# abstract type DEBData end
# abstract type AbstractPseudoData <: DEBData end
# abstract type AbstractUniVariate <: DEBData end
# abstract type AbstractZeroVariate <: DEBData end

# abstract type Data end
# abstract type AuxData end
# abstract type MetaData end
# abstract type TxtData end
# abstract type Weights end

# struct EcoCode <: MetaData end
# struct TemperatureData <: AuxData end
# struct PseudoData <: AbstractPseudoData end

abstract type AbstractMorph end

struct Isomorph <: AbstractMorph end
struct V0Morph <: AbstractMorph end
struct V1Morph <: AbstractMorph end
# struct VHalf <: AbstractMorph end

abstract type AbstractLifestage end

abstract type AbstractEmbryo <: AbstractLifestage end
abstract type AbstractJuvenile <: AbstractLifestage end
abstract type AbstractAdult <: AbstractLifestage end
abstract type AbstractInstar{N} <: AbstractLifestage end

struct Embryo <: AbstractEmbryo end
struct Juvenile <: AbstractJuvenile end
struct Adult <: AbstractAdult end
struct Instar{N} <: AbstractInstar{N} end

abstract type AbstractEvent end
abstract type AbstractTransition <: AbstractEvent end

struct Birth <: AbstractTransition end
struct Puberty <: AbstractTransition end
struct Metamorphosis <: AbstractTransition end
struct Maturity <: AbstractTransition end
struct Ultimate <: AbstractTransition end
struct Death <: AbstractTransition end

@kwdef struct Dimorphic{F<:Union{AbstractTransition,AbstractLifestage},M<:Union{AbstractTransition,AbstractLifestage}}
    female::F
    male::M
end

abstract type AbstractLifeStages end

@kwdef struct LifeStages{LS<:Tuple}
    lifestages::LS
end
LifeStages(args::Pair...) = LifeStages(args)

Base.values(ls::LifeStages) = ls.lifestages

LifeStages(
    Embryo() => Birth(),
    Juvenile() => Dimorphic(; female=Puberty(), male=Puberty()),
    Adult() => Ultimate(),
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

@kwdef struct DEBModel{LS,CC}
    lifestages::LS
    chemicalcomposition::CC
end

lifestages(model::DEBModel) = model.lifestages
chemicalcomposition(model::DEBModel) = model.chemicalcomposition

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

# Should we have the old model definitions ?
std() = DEBModel(Standard())
stf() = DEBModel(FoetalDevelopment())
stx() = DEBModel(FoetalDevelopmentX())
sbp() = DEBModel(GrowthCeasesAtPuberty())
hax() = DEBModel(Holometabolous(NoFeeding()))
hex() = DEBModel(Holometabolous(NoFeeding()))

abstract type AbstractSynthesizingUnit end

struct ImplicitSU <: AbstractSynthesizingUnit end
struct SerialSU <: AbstractSynthesizingUnit end 
struct PreferenceSU <: AbstractSynthesizingUnit end
struct ProducerSU <: AbstractSynthesizingUnit end
struct AssimilationSU <: AbstractSynthesizingUnit end
struct MainenanceSU <: AbstractSynthesizingUnit end
struct GrowthSU <: AbstractSynthesizingUnit end

# TODO flesh these out
flux(::ImplicitSU, a) = a
function flux(::PreferenceSU, preferred, other) 
    # ???
end

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
#

struct Since{E<:AbstractEvent}
    event::E
end
Since{T}() where T = Since(T())

struct At{E<:AbstractEvent}
    event::E
end
At{T}() where T = At(T())

# Age is a convenience const for Since{Birth}
const Age = Since{Birth}
