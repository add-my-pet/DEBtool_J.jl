
"""
    TraitQuery

Declarative specification of which trait data to pull from a `DEBTraitDB` for
parameter estimation.  Pass to [`materialize`](@ref) to obtain an
[`EstimationData`](@ref).

# Fields
- `species`: taxon name in underscore format (e.g. `"Emydura_macquarii"`)
- `traits`: `nothing` (use all available) or a tuple of trait symbols
- `exclude`: tuple of trait symbols to skip (only used when `traits=nothing`)
- `temperature`: `:T_typical` (use the species' typical temperature from the DB),
  or an explicit `Unitful` temperature quantity
- `weights`: tuple of `(trait=:name, weight=value)` overrides; by default the
  per-point weights stored in the database are summed to give a dataset weight
- `submitter`: `nothing` (all submitters) or a string to filter `entry_author`
- `pseudo`: NamedTuple of pseudo-data overrides merged over [`defaultpseudodata`](@ref)

# Examples
```julia
# Use every trait available for this species
q = TraitQuery("Emydura_macquarii")

# Explicit selection with a weight override
q = TraitQuery("Emydura_macquarii";
    traits  = (:ab, :am, :Lb, :Lp, :Lpm, :Li, :Lim, :Wwb, :Wwi, :Wwim, :Ri, :tL),
    weights = ((trait=:tL, weight=2.0),),
)

# Everything except O2 data, with a custom pseudo-data override
q = TraitQuery("Emydura_macquarii";
    exclude = (:LJO,),
    pseudo  = (; k=Weighted(0.1, 0.3), k_J=Weighted(0.0, 0.002u"d^-1")),
)

# Filter to one submitter when multiple researchers contributed data
q = TraitQuery("Emydura_macquarii"; submitter="Kearney")
```
"""
@kwdef struct TraitQuery
    species::String
    traits::Union{Nothing, Tuple{Vararg{Symbol}}} = nothing
    exclude::Tuple{Vararg{Symbol}}                = ()
    temperature::Union{Symbol, Number}            = :T_typical
    weights::Tuple{Vararg{NamedTuple}}            = ()
    submitter::Union{Nothing, String}             = nothing
    pseudo::NamedTuple                            = (;)
end

TraitQuery(species::String; kw...) = TraitQuery(; species, kw...)
