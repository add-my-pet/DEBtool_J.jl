# These are very preliminary ideas...
# abstract type DEBData end
# abstract type AbstractPseudoData <: DEBData end
# abstract type AbstractUniVariate <: DEBData end
# abstract type AbstractZeroVariate <: DEBData end

abstract type Data end
abstract type AuxData end
abstract type MetaData end
abstract type Weights end
# abstract type TxtData end

# struct EcoCode <: MetaData end
# struct TemperatureData <: AuxData end
# struct PseudoData <: AbstractPseudoData end

struct Lengths{T} <: Data
    val::T
end
Lengths() = Lengths(nothing)

struct Times{T} <: Data
    val::T
end
Times() = Times(nothing)
struct Food{T} <: Data
    val::T
end
Food() = Food(nothing)

basetypeof(::Type{T}) where T = T.name.wrapper
basetypeof(::T) where T = basetypeof(T)
rebuild(::T, x) where T = basetypeof(T)(x)

abstract type AbstractMorph end

struct Isomorph <: AbstractMorph end
struct V0Morph <: AbstractMorph end
struct V1Morph <: AbstractMorph end
# struct VHalf <: AbstractMorph end

abstract type AbstractLifeStage end

(::Type{T})() where T<:AbstractLifeStage = T(nothing)

abstract type AbstractEmbryo <: AbstractLifeStage end
abstract type AbstractJuvenile <: AbstractLifeStage end
abstract type AbstractAdult <: AbstractLifeStage end
abstract type AbstractInstar{N} <: AbstractLifeStage end

struct Embryo{T} <: AbstractEmbryo 
    val::T
end
struct Juvenile{T} <: AbstractJuvenile
    val::T
end
struct Instar{N,T} <: AbstractInstar{N} 
    val::T
end
struct Adult{T} <: AbstractAdult
    val::T
end
struct AdultNoFeeding{T} <: AbstractAdult
    val::T
end

abstract type AbstractEvent end
abstract type AbstractTransition <: AbstractEvent end

(::Type{T})() where T<:AbstractTransition = T(nothing)

struct Init{T} <: AbstractTransition 
    val::T
end
struct Birth{T} <: AbstractTransition
    val::T
end
struct Puberty{T} <: AbstractTransition
    val::T
end
struct Metamorphosis{T} <: AbstractTransition
    val::T
end
struct Maturity{T} <: AbstractTransition
    val::T
end
struct Ultimate{T} <: AbstractTransition
    val::T
end
struct Death{T} <: AbstractTransition
    val::T
end

abstract type Sex{T} end
struct Male{T} <: Sex{T}
    val::T
end
struct Female{T} <: Sex{T}
    val::T
end
(::Type{T})() where T<:Sex = T(nothing)

@kwdef struct Dimorphic{A,B}
    a::A
    b::B
end

abstract type AbstractLifeStages end

@kwdef struct LifeStages{LS<:Tuple}
    lifestages::LS
end
LifeStages(args::Pair...) = LifeStages(args)

Base.values(ls::LifeStages) = ls.lifestages

Base.@assume_effects :foldable function Base.getindex(stages::LifeStages, stage::Int)
    stages.lifestages[i]
end
Base.@assume_effects :foldable function Base.getindex(stages::LifeStages, stage::Union{AbstractLifeStage,AbstractTransition,Sex,Dimorphic}) 
    # Get the stage in stages matching `stage`
    out = foldl(values(stages); init=nothing) do acc, x
        if isnothing(acc)
            _match(x, stage)
        else
            acc # found just return it
        end
    end 
    isnothing(out) && throw(ArgumentError("No object found matching $(basetypeof(stage))"))
    return out
end
Base.@assume_effects :foldable function Base.getindex(stages::LifeStages, sex::Sex{Nothing}) 
    map(stages.lifestages) do stage
        stage isa Dimorphic ? stage[sex] : stage
    end |> LifeStages
end

Base.@assume_effects :foldable function Base.getindex(x::Dimorphic, sex::Sex) 
    if x.a isa basetypeof(sex)
        x.a
    else
        x.b isa basetypeof(sex) ? x.b : throw(ArgumentError("$sex not found in $x"))
    end
end

@inline function _match(x::Dimorphic, stage::Sex) 
    m = _match(x.a, stage)
    if isnothing(m)
        _match(x.b, stage)
    else
        m
    end
end
@inline function _match(x::Pair, stage) 
    m = _match(x[1], stage)
    if isnothing(m)
        _match(x[2], stage)
    else
        m
    end
end
@inline _match(x::Sex, stage::Sex) =
    x isa basetypeof(stage) ? _match(x.val, stage.val) : nothing
@inline _match(x, stage) = x isa basetypeof(stage) ? x.val : nothing

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

@kwdef struct DEBOrganism{LS,TR}
    # structures::M
    # reserves::E
    # chemicalcomposition::CC
    lifestages::LS
    temperatureresponse::TR
end

lifestages(model::DEBOrganism) = model.lifestages
chemicalcomposition(model::DEBOrganism) = model.chemicalcomposition

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

struct AtTemperature{T,X}
    t::T
    x::X
end

