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

"""
    Feeding <: AbstractFeeding

Specifies that an `AbstractLifeStage` feeds.
"""
struct Feeding <: AbstractFeeding end
"""
    NoFeeding <: AbstractFeeding

Specifies that an `AbstractLifeStage` does not feed.
"""
struct NoFeeding <: AbstractFeeding end

"""
    AbstractLifeStage

Abstract supertype for organism life stages.
"""
abstract type AbstractLifeStage{M<:AbstractMorph,F<:AbstractFeeding} end

# Get morph and lifestage singletons from type parameters
morph(::AbstractLifeStage{M}) where M = M()
feeding(::AbstractLifeStage{<:Any,F}) where F = F()

"""
    AbstractLifeStageFeeding <: AbstractLifeStage
   
Supertype for lifes tages that always feed.
"""
abstract type AbstractLifeStageFeeding{M} <: AbstractLifeStage{M,Feeding} end
(::Type{T})() where T<:AbstractLifeStageFeeding = T(Isomorph())
(::Type{T})() where T<:AbstractLifeStageFeeding{M} where M<:AbstractMorph = T(M())

"""
    AbstractLifeStageFeeding <: AbstractLifeStage
   
Supertype for lifestages that never feed, such as `Pupa`.
"""
abstract type AbstractLifeStageNoFeeding{M} <: AbstractLifeStage{M,NoFeeding} end
(::Type{T})() where T<:AbstractLifeStageNoFeeding = T(Isomorph())
(::Type{T})() where T<:AbstractLifeStageNoFeeding{M} where M<:AbstractMorph = T(M())

"""
    AbstractLifeStageOptionalFeeding <: AbstractLifeStage
   
Supertype for lifes tages that may or may not feed.
"""
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

"""
    Embryo <: AbstractLifeStageFeeding
    Embryo(; morph)
   
Life stage before birth.
"""
struct Embryo{M} <: AbstractLifeStageFeeding{M}
    morph::M
end
# Used for mammals with support from mother... 
# but maybe another term should be used??
struct Foetus{M} <: AbstractLifeStageFeeding{M}
    morph::M
end
"""
    Baby <: AbstractLifeStageFeeding
    Baby(; morph)
   
First life stage after birth, that depends on mother for food.
"""
struct Baby{M} <: AbstractLifeStageFeeding{M}
    morph::M
end
"""
    Juvenile <: AbstractLifeStageFeeding
    Juvenile(; morph, feeding)
   
First life stage that finds its own food. 
May be after either `Birth` or `Weaning`.
"""
struct Juvenile{M,F} <: AbstractLifeStageOptionalFeeding{M,F}
    morph::M
    feeding::F
end
"""
    Adult <: AbstractLifeStageOptionalFeeding
    Adult(; morph, feeding)
   
Life stage after `Puberty`. May or may not feed, 
depending on `feeding` keyword as `Feeding()` or `NoFeeding()`.
"""
struct Adult{M,F} <: AbstractLifeStageOptionalFeeding{M,F}
    morph::M
    feeding::F
end
"""
    Pupa <: AbstractLifeStageNoFeeding
    Pupa(; morph, feeding)
   
Non-feeding life stage of an insect before `Emergence` as an `Imago`.
"""
struct Pupa{M,F} <: AbstractLifeStageNoFeeding{M}
    morph::M
end
struct Imago{M,F} <: AbstractLifeStageOptionalFeeding{M,F}
    morph::M
    feeding::F
end
"""
    Instar{N} <: AbstractLifeStageFeeding
    Instar{N}(; morph)
   
A numbered lifestage for insect instars.
"""
struct Instar{N,M} <: AbstractLifeStageFeeding{M}
    morph::M
end
Instar{N}(; morph::M=Isomorph()) where {N,M} = Instar{N,M}(morph)

basetypeof(::Instar{N}) where N = Instar{N}

# TODO put this in a better place
struct Gestation{T}
    val::T
end

"""
    AbstractEvent

Abstract supertype for all life events
"""
abstract type AbstractEvent end

"""
    Since(event::AbstractEvent)

A wrapper type to specify the time since an `AbstractEvent`
"""
struct Since{E<:AbstractEvent}
    event::E
end
Since{T}() where T = Since(T())


"""
    AbstractTransition <: AbstractEvent

Abstract supertype for events that are transitions between life stages.
"""
abstract type AbstractTransition{T} <: AbstractEvent end
(::Type{Tr})() where Tr<:AbstractTransition = Tr(nothing)

"""
    Conception <: AbstractTransition

Fertilisation. TODO: should this be `Fertilisation` instead?
"""
struct Conception{T} <: AbstractTransition{T}
    val::T
end
"""
    Birth <: AbstractTransition

Transition from `Embryo` or `Foetus` in an egg or inside
the mothers body to a `Baby`, `Juvenile`, `Instar`.
"""
struct Birth{T} <: AbstractTransition{T}
    val::T
end
struct MaturityLevel{T} <: AbstractTransition{T}
    val::T
end
"""
    Weaning <: AbstractTransition

Transition from a `Baby` with direct support by the 
mother to foraging for food directly.
"""
struct Weaning{T} <: AbstractTransition{T}
    val::T
end
"""
    Puberty <: AbstractTransition

Transition from `Juvenile` to sexually mature `Adult`.
"""
struct Puberty{T} <: AbstractTransition{T}
    val::T
end
"""
    Metamorphosis <: AbstractTransition

A transition of morphological change, often during puberty (??)
"""
struct Metamorphosis{T} <: AbstractTransition{T}
    val::T
end
# What is this for...
struct Maturity{T} <: AbstractTransition{T}
    val::T
end
"""
    Ultimate <: AbstractTransition

Transition to ultimate size - no growth occurs after this transition
but it may not be synomymous with `Death`, which may occur before
or afterwards.
"""
struct Ultimate{T} <: AbstractTransition{T}
    val::T
end
# TODO is this a transition... its more probabilistic?
struct Death{T} <: AbstractTransition{T}
    val::T
end
"""
    Emergence <: AbstractTransition

    Emergence([val])

Emergence of insects from `Pupa` to become an `Imago`.
"""
struct Emergence{T} <: AbstractTransition{T}
    val::T
end
"""
    Moult{N} <: AbstractTransition

    Mount{N}([val])

Numbered moulting transition between insects `Instar`s.
"""
struct Moult{N,T} <: AbstractTransition{T}
    val::T
end
Moult{N}() where N = Moult{N,Nothing}(nothing)

"""
    Sex

Abstract supertype for sexes.
"""
abstract type Sex{T} end
(::Type{T})() where T<:Sex = T(nothing)

"""
    Male <: Sex

    Male([val])

A wrapper that specifies values related to a male organism.
"""
struct Male{T} <: Sex{T}
    val::T
end
"""
    Female <: Sex

    Female([val])

A wrapper that specifies values related to a female organism.
"""
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


"""
    AbstractLifeSequence

Supertype for all sequences of life stages or transitions.
"""
abstract type AbstractLifeSequence end

Base.values(ls::AbstractLifeSequence) = ls.sequence
Base.length(ls::AbstractLifeSequence) = Base.length(Base.values(ls))

"""
    has(s::AbstractLifeSequence, x::Union{AbstractTransition,AbstractLifeStage,Sex})

Returns `true` if transition or life-stage `x` occurs in sequence `s`, otherwise `false`.
"""
has(model::AbstractLifeSequence, x::Union{AbstractTransition,AbstractLifeStage,Sex}) = 
    !isnothing(model[x])

"""
    LifeCycle <: AbstractLifeSequence

    LifeCycle(sequence::Tuple)

Holds an ordered tuple of stages and transition pairs.

Crucially, `getindex` works by lifestage:

`life[Puberty()]` will return the object wrapped by the `Puberty` transition.
`life[Male(Puberty())]` may be required for `Dimorphic` transitions.
"""
@kwdef struct LifeCycle{S<:Tuple{Vararg{StageAndTransition}}} <: AbstractLifeSequence
    sequence::S = ()
end
LifeCycle(args::StageAndTransition...) = LifeCycle(args)

"""
    Transitions <: AbstractLifeSequence

    Transitions(sequence::Tuple)

Holds an ordered tuple of `AbstractTransition`s.
"""
@kwdef struct Transitions{S<:Tuple{Vararg{Union{<:AbstractTransition,<:Dimorphic,<:Sex}}}} <: AbstractLifeSequence
    sequence::S = ()
end
Transitions(args::Union{Dimorphic,Sex,AbstractTransition}...) = Transitions(args)

"""
    LifeStages <: AbstractLifeSequence

Holds a sequence of `AbstractLifeStage`.
"""
@kwdef struct LifeStages{S<:Tuple{Vararg{AbstractLifeStage}}} <: AbstractLifeSequence
    sequence::S = ()
end
LifeStages(args::AbstractLifeStage...) = LifeStages(args)

function Base.getindex(stages::Union{AbstractLifeSequence,Dimorphic,Sex}, stage)
    out = _get(stages, stage)
    isnothing(out) || return out
    if stage isa Female 
        out = _get(stages, stage.val)
        isnothing(out) || return out
    end
    throw(ArgumentError("No object found matching $(basetypeof(stage))"))
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
Base.@assume_effects :foldable function _get(stages::AbstractLifeSequence, stage::Union{AbstractLifeStage,AbstractTransition})
    # Get the stage in stages matching `stage`
    out = foldl(values(stages); init=nothing) do acc, x
        if isnothing(acc)
            _match(x, stage)
        else
            acc # found just return it
        end
    end
    if isnothing(out)
        return _get(stages, Female(stage))
    else
        return out
    end
end
Base.@assume_effects :foldable function _get(stages::AbstractLifeSequence, stage::Union{Sex,Dimorphic})
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
