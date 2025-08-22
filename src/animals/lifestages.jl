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
abstract type AbstractLifeStage{M<:AbstractMorph,F<:AbstractFeeding,T} end

# Get morph and lifestage singletons from type parameters
morph(::AbstractLifeStage{M}) where M = M()
feeding(::AbstractLifeStage{<:Any,F}) where F = F()

"""
    AbstractLifeStageFeeding <: AbstractLifeStage

Supertype for lifes tages that always feed.
"""
abstract type AbstractLifeStageFeeding{M,T} <: AbstractLifeStage{M,Feeding,T} end
(::Type{L})(val::V=nothing) where {L<:AbstractLifeStageFeeding,V} = L{Isomorph,V}(val)
(::Type{L})(val::V=nothing) where {L<:AbstractLifeStageFeeding{M},V} where M<:AbstractMorph =
    ConstructionBase.constructorof(L){V}(val)
ConstructionBase.constructorof(::Type{L}) where L<:AbstractLifeStageFeeding{M} where {M} =
    Base.typename(L).wrapper{M}

"""
    AbstractLifeStageFeeding <: AbstractLifeStage

Supertype for lifestages that never feed, such as `Pupa`.
"""
abstract type AbstractLifeStageNoFeeding{M,T} <: AbstractLifeStage{M,NoFeeding,T} end
(::Type{L})(val::V=nothing) where {L<:AbstractLifeStageNoFeeding,V} = L{Isomorph,V}(val)
(::Type{L})(val::V=nothing) where {L<:AbstractLifeStageNoFeeding{M},V} where M<:AbstractMorph =
    ConstructionBase.constructorof(L){V}(val)
ConstructionBase.constructorof(::Type{L}) where L<:AbstractLifeStageNoFeeding{M} where {M} =
    Base.typename(L).wrapper{M}

"""
    AbstractLifeStageOptionalFeeding <: AbstractLifeStage

Supertype for lifes tages that may or may not feed.
"""
abstract type AbstractLifeStageOptionalFeeding{M,F,T} <: AbstractLifeStage{M,F,T} end
# Default is Isomorph() Feeding()
(::Type{L})(val::V=nothing) where {L<:AbstractLifeStageOptionalFeeding,V} = L{Isomorph,Feeding,V}(val)
# Allow constructing from type parameters
(::Type{L})(val::V=nothing) where {L<:AbstractLifeStageOptionalFeeding{M,F},V} where {M,F} =
    ConstructionBase.constructorof(L){V}(val)
ConstructionBase.constructorof(::Type{L}) where L<:AbstractLifeStageOptionalFeeding{M,F} where {M,F} =
    Base.typename(L).wrapper{M,F}

"""
    Embryo <: AbstractLifeStageFeeding

    Embryo([val])
    Embryo{Morph=Isomorph}([val])

Life stage before birth.
"""
struct Embryo{M,T} <: AbstractLifeStageFeeding{M,T}
    val::T
end
# Used for mammals with support from mother...
# but maybe another term should be used??
struct Foetus{M,T} <: AbstractLifeStageFeeding{M,T}
    val::T
end
"""
    Baby <: AbstractLifeStageFeeding

    Baby{Morph=Isomorph}([val])

First life stage after birth, that depends on mother for food.
"""
struct Baby{M,T} <: AbstractLifeStageFeeding{M,T}
    val::T
end
"""
    Juvenile <: AbstractLifeStageFeeding
    Juvenile{Morph,Feeding}([val])

First life stage that finds its own food.
May be after either `Birth` or `Weaning`.
"""
struct Juvenile{M,F,T} <: AbstractLifeStageOptionalFeeding{M,F,T}
    val::T
end
"""
    Adult <: AbstractLifeStageOptionalFeeding
    Adult(; morph, feeding)

Life stage after `Puberty`. May or may not feed,
depending on `feeding` keyword as `Feeding()` or `NoFeeding()`.
"""
struct Adult{M,F,T} <: AbstractLifeStageOptionalFeeding{M,F,T}
    val::T
end
"""
    Pupa <: AbstractLifeStageNoFeeding
    Pupa(; morph, feeding)

Non-feeding life stage of an insect before `Emergence` as an `Imago`.
"""
struct Pupa{M,T} <: AbstractLifeStageNoFeeding{M,T}
    val::T
end
struct Imago{M,F,T} <: AbstractLifeStageOptionalFeeding{M,F,T}
    val::T
end
"""
    Instar{N} <: AbstractLifeStageFeeding
    Instar{N}(; morph)

A numbered lifestage for insect instars.
"""
struct Instar{N,M,T} <: AbstractLifeStageFeeding{M,T}
    val::T
end
Instar{N,M}(val=nothing) where {N,M} = Instar{N,M}(val)

ConstructionBase.constructorof(::Type{<:Instar{N,M}}) where {N,M} = Instar{N}

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
    Fertilisation <: AbstractTransition

Fertilisation event.
"""
struct Fertilisation{T} <: AbstractTransition{T}
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
    Moult{N} <: AbstractTransition

    Mount{N}([val])

Numbered moulting transition between insects `Instar`s.
"""
struct Moult{N,T} <: AbstractTransition{T}
    val::T
end
Moult{N}(val::V=nothing) where {N,V} = Moult{N,V}(val)

"""
    Emergence <: AbstractTransition

    Emergence([val])

Emergence of insects from `Pupa` to become an `Imago`.
"""
struct Emergence{T} <: AbstractTransition{T}
    val::T
end

ConstructionBase.constructorof(::Type{<:Moult{N}}) where {N} = Moult{N}

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
Transitions(fc::LifeCycle) = Transitions(map(last, values(fc)))

"""
    LifeStages <: AbstractLifeSequence

Holds a sequence of `AbstractLifeStage`.
"""
@kwdef struct LifeStages{S<:Tuple{Vararg{AbstractLifeStage}}} <: AbstractLifeSequence
    sequence::S = ()
end
LifeStages(args::AbstractLifeStage...) = LifeStages(args)
LifeStages(fc::LifeCycle) = LifeStages(map(first, values(fc)))

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
