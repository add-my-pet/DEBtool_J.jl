
"""
    materialize(query::TraitQuery, src) → EstimationData

Execute `query` against `src` and return an [`EstimationData`](@ref) ready for
[`estimate`](@ref).

Scalar traits are mapped to `EstimationData` fields using the `deb_field`,
`deb_transition`, and `deb_sex` columns in the Arrow database (derived from
`traits.yml`).  Univariate traits are assembled as inline `Univariate` objects.

Temperature wrapping: observations where `deb_temperature_required == true` (times and
rates) are always wrapped in `AtTemperature(measurement_T, value)`.  Non-time/rate
traits (lengths, weights) are never wrapped.  `EstimationData.temperature` is always
set to the DEB reference temperature 293.15 K so that `tempcorr` returns 1.0 and
each wrapped observation supplies its own correction.  When `temperature` is missing
from a row, the fallback is T_ref = 293.15 K (not T_typical — that is post-estimation
reporting only).

Food level wrapping: observations with `f < 1.0` are wrapped in `AtFoodLevel(f,
value)` — pending full `AtFoodLevel` implementation in prediction/loss code.

Per-row database weights are summed per dataset; override with `query.weights`.

# Example
```julia
db   = DEBTraitDB()
data = materialize(TraitQuery("Emydura_macquarii"), db)
data = materialize(TraitQuery("Emydura_macquarii"; exclude=(:LJO,)), db)
```
"""
function materialize(q::TraitQuery, src)
    rows = _query_rows(q, src)
    isempty(rows) && error("No data found in database for species: \"$(q.species)\"")

    # T_ref = 293.15 K always: DEB reference temperature.
    # tempcorr(T_ref, T_ref) = 1.0 so the model baseline is at the reference;
    # each AtTemperature-wrapped observation provides its own correction.
    temp = 293.15u"K"

    selected = _select_traits(q, rows)
    scalars  = filter(t -> _is_scalar(t, rows), selected)
    variates = filter(t -> !_is_scalar(t, rows), selected)

    field_map = _build_scalar_fields(rows, scalars)
    var_tuple = _build_variates(rows, variates, q.weights)

    isempty(var_tuple) || (field_map = merge(field_map, (; variate=var_tuple)))

    pseudo = merge(defaultpseudodata(), q.pseudo)

    EstimationData(; temperature=temp, field_map..., pseudo)
end

# ── Internal helpers ───────────────────────────────────────────────────────────

function _query_rows(q::TraitQuery, src)
    gettraits(src; taxon=q.species, submitter=q.submitter)
end

function _select_traits(q::TraitQuery, rows)
    all_traits = Tuple(Symbol.(unique(rows.trait_name)))
    selected   = q.traits === nothing ? all_traits : q.traits
    filter(t -> t ∉ q.exclude, selected)
end

# A trait is scalar when deb_field != "variate".
function _is_scalar(trait::Symbol, rows)
    trows = filter(r -> r.trait_name == string(trait), rows)
    isempty(trows) && return true
    _coerce_str(first(trows.deb_field)) != "variate"
end

# ── Scalar field assembly ──────────────────────────────────────────────────────

function _build_scalar_fields(rows, scalar_traits)
    field_accumulator = Dict{Symbol, Vector{Any}}()

    for t in scalar_traits
        trows = filter(r -> r.trait_name == string(t), rows)
        isempty(trows) && continue

        deb_field_str = _coerce_str(first(trows.deb_field))
        if isempty(deb_field_str)
            @warn "No deb_field for scalar trait :$t — skipping. Update traits.yml."
            continue
        end
        field          = Symbol(deb_field_str)
        TransitionType = get(_TRANSITION_TYPE_MAP, _coerce_str(first(trows.deb_transition)), nothing)
        SexType        = get(_SEX_TYPE_MAP,        _coerce_str(first(trows.deb_sex)),        nothing)
        temp_required  = _coerce_bool(first(trows.deb_temperature_required))

        unit_str = _coerce_str(first(trows.unit))
        unit     = parse_deb_unit(unit_str)

        for row in eachrow(trows)
            val = _apply_unit(Float64(row.value), unit)

            # Time/rate traits: always wrap with the measurement temperature.
            # Fallback: measurement temperature → 293.15 K (T_ref).
            # T_typical is NOT used here — it is post-estimation reporting only.
            if temp_required
                T_obs = coalesce(row.temperature, 293.15)
                val   = AtTemperature(Float64(T_obs) * u"K", val)
            end

            # Sub-maximal food level: wrap with AtFoodLevel.
            f_val = Float64(row.f)
            if f_val < 1.0
                val = AtFoodLevel(f_val, val)
            end

            val = TransitionType === nothing ? val : TransitionType(val)
            val = SexType        === nothing ? val : SexType(val)

            push!(get!(field_accumulator, field, Vector{Any}()), val)
        end
    end

    NamedTuple(k => Tuple(v) for (k, v) in field_accumulator)
end

# Apply a Unitful unit (or NoUnits) to a bare Float64 value.
_apply_unit(v::Float64, ::typeof(NoUnits)) = v
_apply_unit(v::Float64, unit)              = v * unit

# Coerce a possibly-missing boolean column value to Bool.
_coerce_bool(x) = !ismissing(x) && x !== nothing && Bool(x)

# ── Univariate assembly ────────────────────────────────────────────────────────

function _build_variates(rows, variate_traits, weight_overrides)
    result = Any[]
    for t in variate_traits
        v = _build_one_variate(rows, t, weight_overrides)
        isnothing(v) || push!(result, v)
    end
    Tuple(result)
end

function _build_one_variate(rows, t::Symbol, weight_overrides)
    trait_str = string(t)
    trows = filter(r -> r.trait_name == trait_str, rows)
    isempty(trows) && return nothing

    trows = sort(trows, :x_value)

    deb_x_str   = _coerce_str(first(trows.deb_x_type))
    deb_y_str   = _coerce_str(first(trows.deb_y_type))
    deb_sex_str = _coerce_str(first(trows.deb_sex))
    x_unit_str  = _coerce_str(first(trows.x_unit))
    y_unit_str  = _coerce_str(first(trows.unit))

    SexType = get(_SEX_TYPE_MAP, deb_sex_str, nothing)

    x_builder = get(_VARIATE_TYPE_MAP, deb_x_str, nothing)
    if isnothing(x_builder)
        @warn "Unsupported deb_x_type \"$deb_x_str\" for trait :$t — skipping"
        return nothing
    end
    independent = x_builder(x_unit_str)

    y_builder = get(_VARIATE_TYPE_MAP, deb_y_str, nothing)
    if isnothing(y_builder)
        @warn "Unsupported deb_y_type \"$deb_y_str\" for trait :$t — skipping"
        return nothing
    end
    dep_base = y_builder(y_unit_str)

    dependent_template = SexType === nothing ? dep_base : SexType(dep_base)

    db_weight    = sum(coalesce.(trows.weights, 1.0))
    user_weight  = _override_weight(weight_overrides, t)
    total_weight = isnothing(user_weight) ? db_weight : user_weight
    dependent    = Weighted(total_weight, dependent_template)

    x_vals  = Float64.(trows.x_value)
    y_vals  = Float64.(trows.value)
    mat_raw = hcat(x_vals, y_vals)
    mat     = SMatrix{size(mat_raw)...}(mat_raw)

    uv = Univariate(independent, dependent, mat)

    # Wrap at temperature when the x-axis is time (deb_temperature_required == true).
    # Fallback: T_ref = 293.15 K (same fallback as scalar traits).
    temp_required = _coerce_bool(first(trows.deb_temperature_required))
    result = if temp_required
        T_obs = coalesce(first(trows.temperature), 293.15)
        AtTemperature(Float64(T_obs) * u"K", uv)
    else
        uv
    end

    # Wrap entire dataset at food level if sub-maximal (all rows share same f).
    f_val = Float64(first(trows.f))
    f_val < 1.0 ? AtFoodLevel(f_val, result) : result
end

function _override_weight(overrides::Tuple, t::Symbol)
    for ov in overrides
        haskey(ov, :trait) && ov.trait == t && return Float64(ov.weight)
    end
    nothing
end
