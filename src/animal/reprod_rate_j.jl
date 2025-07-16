## reprod_rate_j
# gets reproduction rate as function time for type M acceleration
  # created 2009/03/24 by Bas Kooijman, modified 2014/02/26
  # modified 2018/09/10 (fixed typos in description) Nina Marn
  
  ## Syntax
  # [R, UE0, Lb, Lj, Lp, info] = <../reprod_rate_j.m *reprod_rate_j*> (L, f, p, Lf)
  
  ## Description
  # Calculates the reproduction rate in number of eggs per time 
  # in the case of acceleration between events b and j
  # for an individual of length L and scaled reserve density f
  #
  # Input
  #
  # * L: n-vector with length
  # * f: scalar with functional response
  # * p: 10-vector with parameters: kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hj, U_Hp
  #
  #     g and v refer to the values for embryo; scaling is always with respect to embryo values
  #     V1-morphic juvenile between events b and j with E_Hb > E_Hj > E_Hp
  #
  # * Lf: optional scalar with length at birth (initial value only)
  #
  #     or optional 2-vector with length, L, and scaled functional response f0
  #     for a juvenile that is now exposed to f, but previously at another f
  #  
  # Output
  #
  #  R: n-vector with reproduction rates
  #  UE0: scalar with scaled initial reserve
  #  info: indicator with 1 for success, 0 otherwise
  
  ## Remarks
  # Theory is given in comments to DEB3 section 7.8.2
  # See also <reprod_rate.html *reprod_rate*>, <reprod_rate_s.html *reprod_rate_s*>, 
  #  <reprod_rate_foetus.html *reprod_rate_foetus*>.
  # For cumulative reproduction, see <cum_reprod.html *cum_reprod*>, 
  #  <cum_reprod_j.html *cum_reprod_j*>, <cum_reprod_s.html *cum_reprod_s*>
  
  ## Example of use
  # See <../mydata_reprod_rate *mydata_reprod_rate*>
  
  #  Explanation of variables:
  #  R = kap_R * pR/ E0
  #  pR = (1 - kap) pC - k_J * EHp
  #  [pC] = [Em] (v/ L + k_M (1 + L_T/L)) f g/ (f + g); pC = [pC] L^3
  #  [Em] = {pAm}/ v
  # 
  #  remove energies; now in lengths, time only
  # 
  #  U0 = E0/{pAm}; U_Hp = EHp/{pAm}; SC = pC/{pAm}; SR = pR/{pAm}
  #  R = kap_R SR/ U0
  #  SR = (1 - kap) SC - k_J * U_Hp
  #  SC = f (g/ L + (1 + L_T/L)/ Lm)/ (f + g); Lm = v/ (k_M g)
  #
  # unpack parameters; parameter sequence, cf get_pars_r
function reprod_rate_j(L, f, p, Lf=nothing)
    (; kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hj, U_Hp) = p
    Lm = v / (k_M * g)
    k = k_J / k_M

    V_Hb, V_Hj, V_Hp = U_Hb / (1 - kap), U_Hj / (1 - kap), U_Hp / (1 - kap)
    v_Hb = V_Hb * g^2 * k_M^3 / v^2
    v_Hj = V_Hj * g^2 * k_M^3 / v^2
    v_Hp = V_Hp * g^2 * k_M^3 / v^2

    p_UE0 = (; VHb=V_Hb, g, kJ=k_J, kM=k_M, v)
    p_lj = (; g, k, l_T=L_T / Lm, v_Hb, v_Hj, v_Hp)
    p_mat = (; kap, kap_R, g, k_J, k_M, L_T, v, U_Hb, U_Hj, U_Hp)

    if Lf === nothing || length(Lf) <= 1
        lb0 = (Lf === nothing) ? nothing : Lf / Lm
        lj, lp, lb, info_lj = get_lj(p_lj, f, lb0)
        if info_lj != 1
            @warn "lp could not be obtained in reprod_rate_j"
            return zeros(length(L)), missing, missing, missing, missing, info_lj
        end
        Lb, Lj, Lp = lb * Lm, lj * Lm, lp * Lm
    else
        L0, f0 = Lf
        UH0, _, info_mat = maturity_j(L0, f0, p_mat)
        if info_mat != 1
            @warn "maturity could not be obtained in reprod_rate_j"
            return zeros(length(L)), missing, missing, missing, missing, info_mat
        end
        lj, lp, lb, info_lj = get_lj(p_lj, f)
        Lb, Lj = lb * Lm, lj * Lm
        sol = DifferentialEquations.solve(
            DifferentialEquations.ODEProblem(
                (dUH, tL, _) -> dget_tL_jp(dUH, tL, f, g, v, kap, k_J, Lb, Lj, Lm, L_T),
                [0.0, L0],
                (UH0, U_Hp)
            ),
            saveat=U_Hp
        )
        Lp = sol[end][2]
    end

    UE0, _, info = initial_scaled_reserve(f, p_UE0, Lb)

    SC = L .^ 2 .* ((g + L_T / Lm) * Lj / Lb .+ L / Lm) ./ (1 + g / f)
    SR = (1 - kap) .* SC .- k_J * U_Hp
    R = @. (L >= Lp) * kap_R * SR / UE0

    return R, UE0, Lb, Lj, Lp, info
end

function dget_tL_jp(UH, tL, f, g, v, kap, k_J, Lb, Lj, Lm, L_T)
    L = tL[2]
    sM = min(L, Lj) / Lb
    r = v * (f * sM - (L + L_T * sM) / Lm) / (L * (f + g))
    dL = L * r / 3
    dUH = (1 - kap) * L^3 * f * (sM / L - r / v) - k_J * UH
    return [1 / dUH, dL / dUH]
end
