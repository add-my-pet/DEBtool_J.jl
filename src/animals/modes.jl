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
@kwdef struct DEBOrganism{M<:Mode,L<:AbstractLifeSequence,TR<:AbstractTemperatureResponse}
    mode::M
    life::L
    temperatureresponse::TR
    # structures::M
    # reserves::E
    # chemicalcomposition::CC
end

mode(model::DEBOrganism) = model.mode
life(model::DEBOrganism) = model.life
temperatureresponse(model::DEBOrganism) = model.temperatureresponse
reproduction(model::DEBOrganism) = model.reproduction
has(t::AbstractTransition, o::DEBOrganism) = has(t, life(o)) 

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
    life=Life(
        Foetus() => Birth(),
        Juvenile() => Puberty(),
        Adult() => Ultimate(),
    ),
    kw...
) = DEBOrganism(; life, temperatureresponse, kw..., mode=stf())
stx_organism(;
    temperatureresponse = Arrhenius1parTemperatureResponse(),
    life=Life(
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
