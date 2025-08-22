"""
    Sex

Abstract supertype for sexes.
"""
abstract type Sex{T} end
(::Type{T})() where T<:Sex = T(nothing)

inner_val(s::Sex) = inner_val(s.val)
rebuild_inner(s::Sex, val) = rebuild(s, rebuild_inner(s.val,  val))
rebuild(s::Sex, val) = basetypeof(s)(rebuild_inner(s.val,  val))

"""
    Male <: Sex

    Male([val])

A wrapper that specifies values related to a male organism.
"""
struct Male{T} <: Sex{T}
    val::T
end
"""
    Female <: Sex

    Female([val])

A wrapper that specifies values related to a female organism.
"""
struct Female{T} <: Sex{T}
    val::T
end

"""
    Dimorphic

    Dimorphic(a, b)

A wrapper for diomorphic life stage.
`a` and `b` are usually `Female` and `Male`.
"""
@kwdef struct Dimorphic{A<:Female,B<:Male}
    a::A
    b::B
end
