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

"""
    DEBOrganism

Organism object specifies lifestages, temperature response,
reproduction and other organism traits and structure.
"""
@kwdef struct DEBOrganism{M<:Mode,L<:AbstractLifeSequence,TR<:AbstractTemperatureResponse}
    mode::M
    lifecycle::L
    temperatureresponse::TR
    # structures::M
    # reserves::E
    # chemicalcomposition::CC
end

mode(model::DEBOrganism) = model.mode
lifecycle(model::DEBOrganism) = model.lifecycle
temperatureresponse(model::DEBOrganism) = model.temperatureresponse
reproduction(model::DEBOrganism) = model.reproduction
has(o::DEBOrganism, t::Union{AbstractTransition,AbstractLifeStage,Sex}) = has(lifecycle(o), t) 
reproduction(model::DEBOrganism) = model.reproduction
# chemicalcomposition(model::DEBOrganism) = model.chemicalcomposition
# structures(model::DEBOrganism) = model.structures
# reserves(model::DEBOrganism) = model.reserves

# Define organism constructors for model types
std_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; lifecycle, temperatureresponse, kw..., mode=std())
stf_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Foetus() => Birth(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; lifecycle, temperatureresponse, kw..., mode=stf())
stx_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Foetus() => Birth(),
        Baby() => Weaning(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; lifecycle, temperatureresponse, kw..., mode=stx())
ssj_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        Juvenile(NonFeeding()) => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; lifecycle, temperatureresponse, kw..., mode=std())
sbp_organism(; 
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        Juvenile() => Puberty(),
        Adult(NonFeeding()) => Ultimate(),
    ),
    kw...
) = DEBOrganism(; lifecycle, temperatureresponse, kw..., mode=stx())
# TODO: define lifecycle
abj_organism(; kw...) = DEBOrganism(; kw..., mode=abj())
abp_organism(; kw...) = DEBOrganism(; kw..., mode=abp())
asj_organism(; kw...) = DEBOrganism(; kw..., mode=asj())
hax_organism(; kw...) = DEBOrganism(; kw..., mode=hax())
hex_organism(N::Int; kw...) = hex_organism(Val{N}(); kw...)
hex_organism(::Val{N}; 
    lifecycle=LifeCycle(
        Embryo() => Birth(),
        ntuple(Val{N}()) do n
            Instar{n}() => Moult{n}()
        end...,
        Juvenile() => Metamorphosis(),
        Imago(NonFeeding()) => Ultimate(),
    ),
    kw...
) where N = DEBOrganism(; kw..., mode=hex())
hep_organism(; kw...) = DEBOrganism(; kw..., mode=hep())
