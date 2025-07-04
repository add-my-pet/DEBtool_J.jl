
# Utilities copied from DimensionalData.jl

basetypeof(::Type{T}) where T = T.name.wrapper
basetypeof(::T) where T = basetypeof(T)
rebuild(::T, x) where T = basetypeof(T)(x)

abstract type Data end

"""
    Sequence <: Data

Abstract supertype for a sequence of data points, 
usually wrapping a vector.
"""
abstract type Sequence <: Data end
(::Type{T})() where T<:Sequence = T(nothing)

struct Lengths{T} <: Sequence
    val::T
end
struct Times{T} <: Sequence
    val::T
end
struct Food{T} <: Sequence
    val::T
end
struct FunctionalResponses{T} <: Sequence
    val::T
end

struct Univariate{I<:Sequence,D<:Sequence} <: Data
    independent::I
    dependent::D
end

struct Multivariate{I<:Sequence,D<:Tuple{<:Sequence,Vararg}} <: Data
    independent::I
    dependents::D
end

"""
    AbstractMorph

Abstract supertype for organism shape morphs.
"""
abstract type AbstractMorph end

struct Isomorph <: AbstractMorph end
struct V0Morph <: AbstractMorph end
struct V1Morph <: AbstractMorph end
# struct VHalf <: AbstractMorph end


"""
    AbstractSynthesizingUnit

Abstract supertype for synthesizing units.
"""
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

"""
    AbstractLifeStage

Abstract supertype for organism life stages.
"""
abstract type AbstractLifeStage end
(::Type{T})() where T<:AbstractLifeStage = T(nothing)

# TODO is this layer of abstract types needed?
# The idea is to allow extending them for e.g. custom Emryo behabiour
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

"""
    AbstractEvent 

Abstract supertype for all life events
"""
abstract type AbstractEvent end

"""
    AbstractTransition 

Abstract supertype for events that are transitions between life stages.
"""
abstract type AbstractTransition{T} <: AbstractEvent end
(::Type{T})() where T<:AbstractTransition = T(nothing)

struct Init{T} <: AbstractTransition{T}
    val::T
end
struct Birth{T} <: AbstractTransition{T}
    val::T
end
struct Puberty{T} <: AbstractTransition{T}
    val::T
end
struct Metamorphosis{T} <: AbstractTransition{T}
    val::T
end
struct Maturity{T} <: AbstractTransition{T}
    val::T
end
struct Ultimate{T} <: AbstractTransition{T}
    val::T
end
struct Death{T} <: AbstractTransition{T}
    val::T
end

"""
    Sex

Abstract supertype for sexes.
"""
abstract type Sex{T} end
(::Type{T})() where T<:Sex = T(nothing)

struct Male{T} <: Sex{T}
    val::T
end
struct Female{T} <: Sex{T}
    val::T
end

"""
    Dimorphic

    Dimorphic(a, b)

A wrapper for diomorphic life stage. 
`a` and `b` are usually `Female` and `Male`.
"""
@kwdef struct Dimorphic{A,B}
    a::A
    b::B
end

abstract type AbstractLifeStages end

"""
    LifeStages <: AbstractLifeStages

A wrapper that holds a sequence of `AbstractLifeStage` and `AbstractTransition` pairs.

Crucially, getindex works by lifestage:

`lifestage[Puberty()]` will return the object wrapped by the `Puberty` transition. 
`lifestages[Male(Puberty())]` may be required for `Dimorphic` transitions.
"""
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

struct StandardReproduction <: AbstractReproduction end

"""
    AbstractBehavior

Abstract supertype for organism behaviors.

Behaviors respond to physiological state and external stimuli, 
to either control *exposure* to the external stimuli, or modify 
physiological parameters to change the *effect* of the external stimuli.
"""
abstract type AbstractBehavior end

"""
    AbstractMetabolicBehavior

Abstract supertype behaviors that modify metabolism based
on inforation from the environment, such as diapause or hibernation.
"""
abstract type AbstractMetabolicBehavior <: AbstractBehavior end

"""
    AbstractMovementBehavior

Abstract supertype behaviors that modify location based
on inforation from the environment, such as moving up into
cooler air or moving underground into a warmer/cooler burror.
"""
abstract type AbstractMovementBehavior <: AbstractBehavior end

"""
    DEBOrganism

Organism object specifies lifestages, temperature response,
reproduction and other organism traits and structure.
"""
@kwdef struct DEBOrganism{LS,TR,R}
    # structures::M
    # reserves::E
    # chemicalcomposition::CC
    lifestages::LS
    temperatureresponse::TR
    reproduction::R = StandardReproduction()
end

lifestages(model::DEBOrganism) = model.lifestages
temperatureresponse(model::DEBOrganism) = model.temperatureresponse
reproduction(model::DEBOrganism) = model.reproduction
# chemicalcomposition(model::DEBOrganism) = model.chemicalcomposition



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


# abstract type FeedingMode end
# struct Feeding end
# struct NoFeeding end

# abstract type Mode end
# # std
# struct Standard <: Mode end 
# # stf
# struct FoetalDevelopment <: Mode end 
# # stx
# struct FoetalDevelopmentX <: Mode end 
# # ssj?
# # sbp
# struct GrowthCeasesAtPuberty <: Mode end 
# struct Accelerated{A<:AbstractEvent,B<:AbstractEvent} <: Mode
#     startevent::A
#     stopevent::B
# end

# """
#     Hemimetabolous(feeding::FeedingMode)

# # abp = Hemimetabolous{Feeding}
# # hep = Hemimetabolous{NotFeeding}
# """
# struct Hemimetabolous{F} <: Mode
#     feeding::F
# end

# """
#     Holometabolous(feeding::FeedingMode)

# # unnamed = Holometabolous{Feeding}
# # hax = Holometabolous{NoFeeding}
# # hex = Holometabolous{NoFeeding} (but maybe its not worth converting)
# """
# struct Holometabolous{F} <: Mode
#     feeding::F
# end

# # Should we have the old model definitions ?
# std(; kw...) = DEBModel(Standard())
# stf(; kw...) = DEBModel(FoetalDevelopment())
# stx(; kw...) = DEBModel(FoetalDevelopmentX())
# sbp(; kw...) = DEBModel(GrowthCeasesAtPuberty())
# hax(; kw...) = DEBModel(Holometabolous(NoFeeding()))
# hex(; kw...) = DEBModel(Holometabolous(NoFeeding()))

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
