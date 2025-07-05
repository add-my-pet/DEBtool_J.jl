"""
    AbstractTemperatureResponse

Lifespans are used in `lifespan`
"""
abstract type AbstractTemperatureResponse end
abstract type Data end

"""
    Sequence <: Data

Abstract supertype for a sequence of data points,
usually wrapping a vector.
"""
abstract type Sequence <: Data end
(::Type{T})() where T<:Sequence = T(nothing)

struct Temperatures{T} <: Sequence
    val::T
end
struct Lengths{T} <: Sequence
    val::T
end
struct Food{T} <: Sequence
    val::T
end
struct FunctionalResponses{T} <: Sequence
    val::T
end
struct Times{T} <: Sequence
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

abstract type AbstractEnvironment end

"""
    Environment <: AbstractEnvironment


"""
struct Environment{Ti,Te,TC,FR,I<:NamedTuple}
    times::Ti
    temperatures::Te
    tempcorrections::TC
    functionalresponses::FR
    interpolators::I
end
function Environment(; 
    times,
    temperatures=nothing,
    functionalresponses=nothing,
    interpolation=CubicSpline, 
    temperatureresponse=nothing
)
    tempcorrections = if isnothing(temperatureresponse) || isnothing(temperatures)
        nothing
    else
        tempcorr(temperatureresponse, temperatures)
    end
    interpolators = if isnothing(interpolation)
        nothing
    else
        map((; temperatures, tempcorrections, functionalresponses)) do d
            isnothing(d) ? nothing : interpolation(d, times)
        end
    end
    return Environment(times, temperatures, tempcorrections, functionalresponses, interpolators)
end


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

@kwdef struct Life{S<:Tuple{Vararg{StageAndTransition}}} <: AbstractLifeSequence
    sequence::S
end
Life(args::StageAndTransition...) = Life(args)
Life() = Life(())
@kwdef struct Transitions{S<:Tuple{Vararg{Union{<:AbstractTransition,<:Dimorphic,<:Sex}}}} <: AbstractLifeSequence
    sequence::S
end
Transitions(args::Union{Dimorphic,Sex,AbstractTransition}...) = Transitions(args)
Transitions() = Transitions(())

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
    sequence::S
end
LifeStages(args::AbstractLifeStage...) = LifeStages(args)
LifeStages() = LifeStages(())

# LifeStage indexing
# This allows us to get lifestage data by type
# e.g. `lifestages[Birth()]`
Base.@assume_effects :foldable function Base.getindex(stages::AbstractLifeSequence, stage::Int)
    values(stages)[i]
end
Base.@assume_effects :foldable function Base.getindex(stages::AbstractLifeSequence, stage::Union{AbstractLifeStage,AbstractTransition,Sex,Dimorphic})
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
Base.@assume_effects :foldable function Base.getindex(stages::T, sex::Sex{Nothing}) where T<:AbstractLifeSequence 
    map(values(stages)) do stage
        stage isa Dimorphic ? stage[sex] : stage
    end |> Base.typename(T).wrapper 
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


# Modes

abstract type Mode end
# std
struct Standard <: Mode end
abstract type AbstractStandardFoetalMode <: Mode end
# stf
struct StandardFoetal <: AbstractStandardFoetalMode end
# stx
struct StandardFoetalDiapause <: AbstractStandardFoetalMode end
# ssj
struct StandardNonFeedingJuvenile <: Mode end
# sbp
struct StandardGrowthCeasesAtPuberty <: Mode end
# abj/asj/abp
struct Accelerated{B<:AbstractMorph,St<:AbstractEvent,Sp<:AbstractEvent,A<:AbstractMorph} <: Mode
    before::B
    startevent::St
    stopevent::Sp
    after::A
end

"""
    Hemimetabolous(feeding::AbstractFeeding)

abp = Hemimetabolous{Feeding}
hep = Hemimetabolous{NotFeeding}
"""
struct Hemimetabolous{F} <: Mode
    feeding::F
end

"""
    Holometabolous(feeding::AbstractFeeding)

unnamed = Holometabolous{Feeding}
hax = Holometabolous{NoFeeding}
hex = Holometabolous{NoFeeding} (but maybe its not worth converting)
"""
struct Holometabolous{F} <: Mode
    feeding::F
end

# Here we map old model definitions to new types with clearer names
std() = Standard()
stf() = StandardFoetal()
stx() = StandardFoetalDiapause()
ssj() = StandardNonFeedingJuvenile()
sbp() = StandardGrowthCeasesAtPuberty()
abj() = Accelerated(Isomorph(), Birth(), Metamorphosis(), Isomorph())
abp() = Accelerated(Isomorph(), Birth(), Puberty(), NoGrowth())
asj() = Accelerated(Isomorph(), MaturityLevel(), Metamorphosis(), Isomorph())
# TODO clarify these
hep() = Hemimetabolous(NoFeeding())
hex() = Holometabolous(NoFeeding())
hax() = Holometabolous(Feeding())

"""
    DEBOrganism

Organism object specifies lifestages, temperature response,
reproduction and other organism traits and structure.
"""
@kwdef struct DEBOrganism{M<:Mode,L<:AbstractLifeSequence,TR<:AbstractTemperatureResponse,R<:AbstractReproduction}
    mode::M
    life::L
    temperatureresponse::TR
    reproduction::R = StandardReproduction()
    # structures::M
    # reserves::E
    # chemicalcomposition::CC
end

mode(model::DEBOrganism) = model.mode
life(model::DEBOrganism) = model.life
temperatureresponse(model::DEBOrganism) = model.temperatureresponse
reproduction(model::DEBOrganism) = model.reproduction

# Define organism constructors for model types
std_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    life=Life(
        Embryo() => Birth(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; life, temperatureresponse, kw..., mode=std())
stf_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    life=LifeStages(
        Foetus() => Birth(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; life, temperatureresponse, kw..., mode=stf())
stx_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    life=LifeStages(
        Foetus() => Birth(),
        Baby() => Weaning(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; life, temperatureresponse, kw..., mode=stx())
ssj_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    life=Life(
        Embryo() => Birth(),
        Juvenile(NonFeeding()) => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; life, temperatureresponse, kw..., mode=std())
sbp_organism(; 
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    life=Life(
        Embryo() => Birth(),
        Juvenile() => Puberty(),
        Adult(NonFeeding()) => Ultimate(),
    ),
    kw...
) = DEBOrganism(; life, temperatureresponse, kw..., mode=stx())
# TODO: define life
abj_organism(; kw...) = DEBOrganism(; kw..., mode=abj())
abp_organism(; kw...) = DEBOrganism(; kw..., mode=abp())
asj_organism(; kw...) = DEBOrganism(; kw..., mode=asj())
hax_organism(; kw...) = DEBOrganism(; kw..., mode=hax())
hex_organism(; kw...) = DEBOrganism(; kw..., mode=hex())
hep_organism(; kw...) = DEBOrganism(; kw..., mode=hep())


# chemicalcomposition(model::DEBOrganism) = model.chemicalcomposition

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
# Object/type utilities copied from DimensionalData.jl

basetypeof(::Type{T}) where T = T.name.wrapper
basetypeof(::T) where T = basetypeof(T)
rebuild(::T, x) where T = basetypeof(T)(x)



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

