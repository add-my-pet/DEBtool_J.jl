
# Maps transition type name strings (from deb_transition Arrow column) to Julia types.
const _TRANSITION_TYPE_MAP = Dict{String, Any}(
    "Birth"         => Birth,
    "Weaning"       => Weaning,
    "Puberty"       => Puberty,
    "Metamorphosis" => Metamorphosis,
    "Ultimate"      => Ultimate,
    "Emergence"     => Emergence,
    "Maturity"      => Maturity,
    "Moult"         => Moult,
)

# Maps sex name strings (from deb_sex Arrow column) to Julia types.
const _SEX_TYPE_MAP = Dict{String, Any}(
    "Female" => Female,
    "Male"   => Male,
)

# Maps variate type name strings (from deb_x_type / deb_y_type Arrow columns)
# to wrapper constructors. Each entry is a function (unit_string) -> Data instance.
const _VARIATE_TYPE_MAP = Dict{String, Any}(
    "Time"               => u -> Time(1.0 * parse_deb_unit(u)),
    "Length"             => u -> Length(1.0 * parse_deb_unit(u)),
    "WetWeight"          => u -> WetWeight(1.0 * parse_deb_unit(u)),
    "DryWeight"          => u -> DryWeight(1.0 * parse_deb_unit(u)),
    "Temperature"        => u -> Temperature(1.0 * parse_deb_unit(u)),
    "Food"               => u -> Food(1.0 * parse_deb_unit(u)),
    "FunctionalResponse" => _ -> FunctionalResponse(1.0),
)

# Maps database unit strings to Unitful units.
# Annotation in braces (e.g. {wet}, {offspring}) is dimension metadata only.
const _UNIT_MAP = Dict{String, Any}(
    "d"                 => u"d",
    "cm"                => u"cm",
    "cm/d"              => u"cm/d",
    "cm3"               => u"cm^3",
    "cm2"               => u"cm^2",
    "g"                 => u"g",
    "g{wet}"            => u"g",
    "g{dry}"            => u"g",
    "g{C}"              => u"g",
    "g{N}"              => u"g",
    "g{food}"           => u"g",
    "g{food}/d"         => u"g/d",
    "g/d"               => u"g/d",
    "J"                 => u"J",
    "J{content}"        => u"J",
    "J{ingested}"       => u"J",
    "J{assimilated}"    => u"J",
    "J/d"               => u"J/d",
    "J{assimilated}/d"  => u"J/d",
    "J{ingested}/d"     => u"J/d",
    "K"                 => u"K",
    "ml/d"              => u"mL/d",
    "mL/d"              => u"mL/d",
    "mL{O2}/d"          => u"mL/d",
    "mmol/d"            => u"mmol/d",
    "#"                 => NoUnits,
    "#{offspring}"      => NoUnits,
    "#{offspring}/d"    => u"d^-1",
    "#/d"               => u"d^-1",
    "1/d"               => u"d^-1",
    "1{filtered}/d"     => u"d^-1",
    "-"                 => NoUnits,
    ""                  => NoUnits,
    "dpf"               => u"d",
    "mo"                => u"d" * 30.44,
    "wk"                => u"d" * 7,
)

function parse_deb_unit(s::AbstractString)
    u = get(_UNIT_MAP, s, missing)
    if ismissing(u)
        stripped = replace(String(s), r"\{[^}]*\}" => "")
        u = get(_UNIT_MAP, stripped, missing)
    end
    ismissing(u) && error("Unknown DEB unit string: \"$s\". Add it to _UNIT_MAP in trait_map.jl")
    u
end

# Coerce a possibly-missing column value to a plain String (empty string if missing).
_coerce_str(x) = ismissing(x) || x === nothing ? "" : string(x)
