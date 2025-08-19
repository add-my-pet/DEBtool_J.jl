"""
    AbstractDEBOrganism

Abstract type for all organisms.

Must define `structures` and `synthesizingunits`
"""
abstract type AbstractDEBOrganism end

abstract type AbstractDEBStructure <: AbstractDEBOrganism end

"""
    structures(::AbstractDEBOrganism)

Returns a `Tuple` of `AbstractDEBOrganism`, which may be whole
organisms or subcomponents of organisms.

Length of the `Tuple` must be larger than zero.
"""
structures(::T) where T<:AbstractDEBOrganism = error("structures` method not defined for $T")

"""
    structures(::AbstractDEBOrganism)

Returns a `Tuple` of `AbstractSynthesingUnit`.
"""
synthesizingunits(::T) where T<:AbstractDEBOrganism = error("synthesizingunits` method not defined for $T")

"""
    structures(::AbstractDEBOrganism)

Returns synthesizingunit => structures pairs for the organims.

Structures may be paired with multiple synthesizing units.

By default the order of structures and order of synthesizing units
is assumed to match, and both are assumed to be a linear graph
where only direct neighbors may be connected.

If other network structures are needed, define custom functions for a custom `AbstractDEBOrganism` type.
"""
function sus_and_structures(o::AbstractDEBOrganism)
    reduce(synthesizingunits(o); init=((), structures(o))) do (pairs, structures), su
        su => (structures[1], structures[2])
    end
end

"""
    synthesize_flux

Returns the net flux to each structure.
"""
function synthesize_flux(su_structure_pairs::Tuple)
    map(su_structure_pairs) do su, (sv, sw)
        # TODO get rate of flux
        v = flux(sv)
        w = flux(sw)
        synthesize(su, v, w)
    end
end
