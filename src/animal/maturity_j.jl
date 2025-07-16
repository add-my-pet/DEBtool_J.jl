## maturity_j
# Gets maturity as function of length for type M acceleration
  #  created 2024/07/12 by Bas Kooijman. modified 2024/10/07
  
  ## Syntax
  # [H, a, info] = <../maturity_j.m *maturity_j*> (L, f, p)
  
  ## Description
  # Life history events b (birth), j (and of acceleration), p (puberty).
  # Acceleration between b and j.
  # Calculates the scaled maturity U_H = M_H/ {J_EAm} = E_H/ {p_Am} at constant food
  #  density in the case of acceleration between UHb and UHj with UHb < UHj < UHp
  #
  # Input
  #
  # * L: n-vector with length 
  # * f: scalar with (constant) scaled functional response
  # * p: 10-vector with parameters: kap kapR g kJ kM LT v Hb Hj Hp
  #
  # Output
  #
  # * H: n-vector with scaled maturities: H = M_H/ {J_EAm} = E_H/ {p_Am}
  # * a: n-vector with ages at which lengths are reached 
  # * info: scalar for 1 for success, 0 otherwise
  
  ## Remarks
  # See <maturity.html *maturity*> in absence of acceleration and
  # <maturity_s.html *maturity_s*> if accleration is delayed

  ## Example of use
  # [H, a, info] = maturity_j(.4, 1, [.8,.95, .2, .002, .01, 0, .02, .2, .4, 2])
 
 function maturity_j(
    p,  # 1-13 DEB parameters
    f,          # scaled functional response
    lb,         # scaled length at birth
    lj         # scaled length at metamorphosis
)
    # Unpack parameters
    kap, kapR, g, kJ, kM, LT, v, UHb, UHj, UHp, ha, sG, Tb = p

    # compute scaled initial reserve
    Lb3 = lb^3
    uE0 = get_ue0([g, kJ, kM], f, lb)  # assuming get_ue0 returns a scalar

    # initial states
    vHb = UHb / (1 - kap)
    R = 0.0
    q = 0.0
    h_A = 0.0
    S = 1.0
    uE = uE0
    l = lb
    t = 0.0
    vH = vHb
    UE0 = uE0

    # Time integration parameters
    dt = 1e-3
    n = 10000
    info = true

    for i in 1:n
        r = (g * f / l - (1 + LT / l)) / (f + g)  # specific growth rate
        dl = l * r / 3
        SC = uE * (g / l + kM) / (uE + g)         # catabolic power

        if vH < UHb || l < lb
            duE = -SC
            dvH = (1 - kap) * SC - kJ * vH
        elseif vH < UHj || l < lj
            duE = -SC
            dvH = (1 - kap) * SC - kJ * vH
        else
            duE = -SC
            dvH = 0.0
            R += (1 - kap) * SC - kJ * UHp  # acc cumulated reprod buffer
        end

        dq = (ha * max(0, l - lb) + q * sG * dl / l) * (3 * dl / l - r)
        dh_A = q - r * h_A
        dS = -S * h_A

        if S < 1e-16
            info = false
            break
        end

        # Update state variables
        t += dt
        uE += dt * duE
        l += dt * dl
        vH += dt * dvH
        q += dt * dq
        h_A += dt * dh_A
        S += dt * dS
    end

    vHp = vH
    return R, UE0, vHp, info
end
