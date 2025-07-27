"""
    AbstractMorph

Abstract supertype for organism shape morphs.
"""
abstract type AbstractMorph end

struct Isomorph <: AbstractMorph end
struct V0Morph <: AbstractMorph end
struct V1Morph <: AbstractMorph end
struct NoGrowth <: AbstractMorph end
# struct VHalf <: AbstractMorph end

"""
    AbstractFeeding

Abstract supertype for feeding modes.
"""
abstract type AbstractFeeding end
struct Feeding end
struct NoFeeding end

"""
    AbstractLifeStage

Abstract supertype for organism life stages.
"""
abstract type AbstractLifeStage{M,F} end

# Get morph and lifestage singletons from type parameters
morph(::AbstractLifeStage{M}) where M = M()
feeding(::AbstractLifeStage{<:Any,F}) where F = F()

# Defin lifestages that must be feeding
abstract type AbstractLifeStageFeeding{M} <: AbstractLifeStage{M,Feeding} end
(::Type{T})() where T<:AbstractLifeStageFeeding = T(Feeding())
(::Type{T})() where T<:AbstractLifeStageFeeding{M} where M  = T(M())

# Defin lifestages with optional feeding
abstract type AbstractLifeStageOptionalFeeding{M,F} <: AbstractLifeStage{M,F} end
# Default is Isomorph() Feeding()
(::Type{T})() where T<:AbstractLifeStageOptionalFeeding= T(Isomorph(), Feeding())
# Allow constructing from type parameters
(::Type{T})() where T<:AbstractLifeStageOptionalFeeding{M,F} where {M,F} = T(M(), F())
# Allow only morph
(::Type{T})(morph::AbstractMorph) where T<:AbstractLifeStageOptionalFeeding = T(morph, Feeding())
# Allow only feeding
(::Type{T})(feeding::AbstractFeeding) where T<:AbstractLifeStageOptionalFeeding = T(Isomorph(), feeding)
# Allow any order
(::Type{T})(feeding::AbstractFeeding, morph::AbstractMorph) where T<:AbstractLifeStageOptionalFeeding = T(morph, feeding)

struct Embryo{M} <: AbstractLifeStageFeeding{M}
    morph::M
end
struct Foetus{M} <: AbstractLifeStageFeeding{M}
    morph::M
end
struct Baby{M} <: AbstractLifeStageFeeding{M}
    morph::M
end
struct Juvenile{M,F} <: AbstractLifeStageOptionalFeeding{M,F}
    morph::M
    feeding::F
end
struct Adult{M,F} <: AbstractLifeStageOptionalFeeding{M,F}
    morph::M
    feeding::F
end
struct Pupa{M,F} <: AbstractLifeStageOptionalFeeding{M,F}
    morph::M
    feeding::F
end
struct Imago{M,F} <: AbstractLifeStageOptionalFeeding{M,F}
    morph::M
    feeding::F
end

# TODO put this in a better place?
struct Gestation{M} <: AbstractLifeStage{M,Feeding}
    morph::M
end

"""
    AbstractEvent

Abstract supertype for all life events
"""
abstract type AbstractEvent end

struct Since{E<:AbstractEvent}
    event::E
end
Since{T}() where T = Since(T())

struct At{E<:AbstractEvent}
    event::E
end
At{T}() where T = At(T())

"""
    AbstractTransition

Abstract supertype for events that are transitions between life stages.
"""
abstract type AbstractTransition{T} <: AbstractEvent end
(::Type{T})() where T<:AbstractTransition = T(nothing)

struct Init{T} <: AbstractTransition{T}
    val::T
end
struct Conception{T} <: AbstractTransition{T}
    val::T
end
struct Birth{T} <: AbstractTransition{T}
    val::T
end
struct MaturityLevel{T} <: AbstractTransition{T}
    val::T
end
struct Weaning{T} <: AbstractTransition{T}
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
# TODO are these the same? the language is mixed
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

const StageAndTransition = Pair{<:AbstractLifeStage,<:Union{<:AbstractTransition,<:Dimorphic,<:Sex}}


abstract type AbstractLifeSequence end

Base.values(ls::AbstractLifeSequence) = ls.sequence
Base.length(ls::AbstractLifeSequence) = Base.length(Base.values(ls))

hastransition(t::AbstractTransition, model::AbstractLifeSequence) = 
    !isnothing(model[t])

@kwdef struct Life{S<:Tuple{Vararg{StageAndTransition}}} <: AbstractLifeSequence
    sequence::S = ()
end
Life(args::StageAndTransition...) = Life(args)
@kwdef struct Transitions{S<:Tuple{Vararg{Union{<:AbstractTransition,<:Dimorphic,<:Sex}}}} <: AbstractLifeSequence
    sequence::S = ()
end
Transitions(args::Union{Dimorphic,Sex,AbstractTransition}...) = Transitions(args)

"""
    LifeStages <: AbstractLifeSequence

A wrapper that holds a sequence of `AbstractLifeStage` and `AbstractTransition` pairs.

Its still not clear if we need to specify both life stage and transition, 
or if we can just use one or the other.

Crucially, getindex works by lifestage:

`life[Puberty()]` will return the object wrapped by the `Puberty` transition.
`life[Male(Puberty())]` may be required for `Dimorphic` transitions.
"""
@kwdef struct LifeStages{S<:Tuple{Vararg{AbstractLifeStage}}} <: AbstractLifeSequence
    sequence::S = ()
end
LifeStages(args::AbstractLifeStage...) = LifeStages(args)

function Base.getindex(stages::Union{AbstractLifeSequence,Dimorphic,Sex}, stage)
    out = _get(stages, stage)
    isnothing(out) && throw(ArgumentError("No object found matching $(basetypeof(stage))"))
    return out
end
function Base.get(stages::Union{AbstractLifeSequence,Dimorphic,Sex}, stage, default)
    out = _get(stages, stage)
    if isnothing(out) 
        return default
    else
        return out
    end
end
# LifeStage indexing
# This allows us to get lifestage data by type
# e.g. `lifestages[Birth()]`
Base.@assume_effects :foldable function _get(stages::AbstractLifeSequence, stage::Int)
    values(stages)[stage]
end
Base.@assume_effects :foldable function _get(stages::AbstractLifeSequence, stage::Union{AbstractLifeStage,AbstractTransition,Sex,Dimorphic})
    # Get the stage in stages matching `stage`
    out = foldl(values(stages); init=nothing) do acc, x
        if isnothing(acc)
            _match(x, stage)
        else
            acc # found just return it
        end
    end
    return out
end
Base.@assume_effects :foldable function _get(stages::T, sex::Sex{Nothing}) where T<:AbstractLifeSequence 
    map(values(stages)) do stage
        stage isa Dimorphic ? stage[sex] : stage
    end |> Base.typename(T).wrapper 
end
_get(x, y) = _match(x, y)

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
@inline function _match(x::Sex, stage::Sex)
    if x isa basetypeof(stage) 
        isnothing(stage.val) ? x : _match(x.val, stage.val) 
    else
        nothing
    end
end
@inline _match(x, stage) = x isa basetypeof(stage) ? x.val : nothing
