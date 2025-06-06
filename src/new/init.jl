
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
function init_scaled_reserve(p::NamedTuple, l_b::Number)
    (; v_Hb, g, k_J, k_M, v, f) = p

    q = (; g, k=k_J / k_M, v_Hb)
    info = true

    # lb, info = get_lb(q, f)
    # @assert lb == l_b
    ## try get_lb1 or get_lb2 for higher accuracy
    Lb = l_b * v / k_M / g
    (; uE0, info) = get_ue0(q, f, l_b)
    UE0 = uE0 * v^2 / g^2 / k_M^3

    return (; UE0, Lb, info)
end
