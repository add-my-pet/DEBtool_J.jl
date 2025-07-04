
## Description
# Gets initial scaled reserve
#
# Input
#
# * f: n-vector with scaled functional responses
# * p: 5-vector with parameters: VHb, g, kJ, kM, v
#
# Output
#
# * U0: n-vector with initial scaled reserve: M_E^0/ {J_EAm} or E^0/ {p_Am}
# * Lb: n-vector with length at birth
# * info: n-vector with 1's if successful, 0's otherwise

## Remarks
# Like <get_ue0.html *get_ue0*>, but allows for vector arguments and
# input and output is not downscaled to dimensionless quantities,

## Example of use 
# p = [.8 .42 1.7 1.7 3.24 .012]; initial_scaled_reserve(1, p)
function initial_scaled_reserve(mode::AbstractStandardFoetalMode, p::NamedTuple, l_b::Number)
    error("Not tested")
    q = (; g, k=k_J / k_M, v_Hb)
    (; l_b, info) = get_lb(mode, q)
    (; l_b, info)
end

function initial_scaled_reserve(mode::Mode, p::NamedTuple, l_b::Number)
    (; v_Hb, g, k_M, v, f) = p

    info = true
    Lb = l_b * v / k_M / g
    uE0 = get_ue0(mode, p, f, l_b)
    UE0 = uE0 * v^2 / g^2 / k_M^3
    return (; UE0, Lb, info)
end

function get_ue0(::Mode, p::NamedTuple, eb, l_b)
    (; g) = p  # energy investment ratio
    # TODO: explain math here
    xb = g / (eb + g)
    return (3 * g / (3 * g * xb^(1 / 3) / l_b - real(beta0(zero(xb), xb))))^3
end
function get_ue0(::AbstractStandardFoetalMode, p, eb, l_b)
    (; g) = p
    # TODO: explain math here
    uEb = eb * l_b^3 / g
    return uEb + l_b^3 + 3 * l_b^4 / 4 / g
end
