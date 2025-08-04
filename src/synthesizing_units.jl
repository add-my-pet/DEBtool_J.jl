"""
    AbstractSynthesizingUnit

Abstract supertype for synthesizing units.

Synthesizing units bind multiple substrates to synthesize compounds, 
depending on their availability.
"""
abstract type AbstractSynthesizingUnit end

"""
    synthesize(::AbstractSynthesizingUnit, v, w)

Apply a synthesizing unit formulation to substrates
`v` and `w`, returning the amount of compound.
"""
function synthesize end

"""
    ParallelComplementarySU(k)

0-parameter synthesizing unit that merges two compounds stoichiometrically.

See Ledder et al 2019. for details.
"""
struct ParallelComplementarySU <: AbstractSynthesizingUnit end

synthesize(::ParallelComplementarySU, v, w) = v * w * (v + w) / (v^2 + w^2 + v * w)


"""
    MinimumRuleSU(k)

0-parameter synthesizing unit where law of the minimum controls
the production of one compound form two other compounds.
"""
struct MinimumRuleSU <: AbstractSynthesizingUnit end

synthesize(::MinimumRuleSU, v, w) = min(v, w)

"""
    KfamilySU(k)

Flexible 1-parameter synthesizing unit with variable curve. Both `MinimumRuleSU`
and `ParallelComplementarySU` can be approximated with this rule.
"""
@kwdef struct KfamilySU{K} <: AbstractSynthesizingUnit 
    k::K = Param(1.0; bounds=(0.0, 10.0), description="Synthesizing unit parameter. Effiency = 2^-1/k")
end

synthesize(f::KfamilySU, v, w) = (v^-f.k + w^-f.k)^(-1/f.k)

"""
    stoich_merge(su::AbstractSynthesizingUnit, Jv, Jw, yv, yw)

Merge fluxes stoichiometrically into general reserve Evw based on yield
fractions yv and yw. An unmixed proportion is returned as unmixed reserves Ev and Ew.
"""
function stoich_merge(su, Jv, Jw, yv, yw)
    JEvw = synthesize(su, Jv * yv, Jw * yw)
    (Jv - JEvw / yv), (Jw - JEvw / yw), JEvw
end

# struct ImplicitSU <: AbstractSynthesizingUnit end
# struct SerialSU <: AbstractSynthesizingUnit end
# struct PreferenceSU <: AbstractSynthesizingUnit end
# struct ProducerSU <: AbstractSynthesizingUnit end
# struct AssimilationSU <: AbstractSynthesizingUnit end
# struct MainenanceSU <: AbstractSynthesizingUnit end
# struct GrowthSU <: AbstractSynthesizingUnit end
