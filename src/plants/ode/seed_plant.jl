
# Germination state initialisation for the Plant DEB model.
#
# _plant_germination_state(p) returns a NamedTuple of state variables at germination
# (the moment Birth fires: V_R = M_VRb, V_S = M_VSb), with reserves set to the
# equilibrium densities computed in compound_parameters (m_Cm, m_Nm).
#
# This is the plant analogue of _iso221_birth_state: we start the simulation from
# germination rather than from seed, so the Birth() callback fires at t=0 and the
# Juvenile stage begins immediately with physically reasonable reserve levels.

"""
    _plant_germination_state(p)

Return the plant state at germination.

Structure at germination:
  - `V_S = M_VSb` (shoot structural mass at germination)
  - `V_R = M_VRb` (root structural mass at germination, triggers Birth callback)
  - `C_S = m_Cm * V_S`, `N_S = m_Nm * V_S` (reserves at equilibrium density)
  - `C_R = m_Cm * V_R`, `N_R = m_Nm * V_R`

where `m_Cm` and `m_Nm` are maximum reserve densities computed in `compound_parameters`
from photosynthesis/N-uptake evaluated at reference environmental conditions (TC = 1).
"""
function _plant_germination_state(p)
    V_S = p.M_VSb
    V_R = p.M_VRb
    m_Cm = p.m_Cm   # from compound_parameters
    m_Nm = p.m_Nm
    return (;
        V_S,
        C_S = m_Cm * V_S,
        N_S = m_Nm * V_S,
        V_R,
        C_R = m_Cm * V_R,
        N_R = m_Nm * V_R,
    )
end
