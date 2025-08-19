# Modes

# TODO: these act as markers for the life sequence,
# and are used in function dispatch. 
# Its not clear if they will be needed in the long term in this form.
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

abstract type AbstractDEBAnimal <: AbstractDEBOrganism end

# A DEBAnimal has one structure, itself
structures(a::AbstractDEBAnimal) = (a,)
# And no synthesizing units
synthesizingunits(::AbstractDEBAnimal) = ()

has(o::AbstractDEBAnimal, t::Union{AbstractTransition,AbstractLifeStage,Sex}) = has(lifecycle(o), t) 
temperatureresponse(model::AbstractDEBAnimal) = model.temperatureresponse

"""
    DEBAnimal

Animal object specifies lifestages, temperature response,
reproduction and other animal traits and structure.
"""
@kwdef struct DEBAnimal{M<:Mode,L<:AbstractLifeSequence,TR<:AbstractTemperatureResponse} <: AbstractDEBOrganism
    mode::M
    lifecycle::L
    temperatureresponse::TR
    # structures::M
    # reserves::E
    # chemicalcomposition::CC
end

mode(model::DEBAnimal) = model.mode
lifecycle(model::DEBAnimal) = model.lifecycle
# reproduction(model::DEBAnimal) = model.reproduction
# chemicalcomposition(model::DEBAnimal) = model.chemicalcomposition
# structures(model::DEBAnimal) = model.structures
# reserves(model::DEBAnimal) = model.reserves

# Define animal constructors for model types
std_animal(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBAnimal(; lifecycle, temperatureresponse, kw..., mode=std())
stf_animal(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Foetus() => Birth(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBAnimal(; lifecycle, temperatureresponse, kw..., mode=stf())
stx_animal(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Foetus() => Birth(),
        Baby() => Weaning(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBAnimal(; lifecycle, temperatureresponse, kw..., mode=stx())
ssj_animal(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        Juvenile(NonFeeding()) => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBAnimal(; lifecycle, temperatureresponse, kw..., mode=std())
sbp_animal(; 
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        Juvenile() => Puberty(),
        Adult(NonFeeding()) => Ultimate(),
    ),
    kw...
) = DEBAnimal(; lifecycle, temperatureresponse, kw..., mode=stx())
# TODO: define lifecycle
abj_animal(; kw...) = DEBAnimal(; kw..., mode=abj())
abp_animal(; kw...) = DEBAnimal(; kw..., mode=abp())
asj_animal(; kw...) = DEBAnimal(; kw..., mode=asj())
hax_animal(; kw...) = DEBAnimal(; kw..., mode=hax())
hex_animal(N::Int; kw...) = hex_animal(Val{N}(); kw...)
hex_animal(::Val{N}; 
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        ntuple(Val{N}()) do n
            Instar{n}() => Moult{n}()
        end...,
        Juvenile() => Metamorphosis(),
        Imago(NoFeeding()) => Ultimate(),
    ),
    kw...
) where N = DEBAnimal(; kw..., lifecycle, mode=hex())
hep_animal(; kw...) = DEBAnimal(; kw..., mode=hep())
