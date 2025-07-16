## get_lj
# Gets scaled length at metamorphosis
  #  created at 2010/02/10 by Bas Kooijman, 
  #  modified 2014/03/03 Starrlight Augustine, 2015/01/18, 2023/02/15 Bas Kooijman;
  
  ## Syntax
  # [lj, lp, lb, info] = <../get_lj.m *get_lj*>(p, f, lb0)
  
  ## Description
  # Type M-acceleration: Isomorph, but V1-morph between v_Hb and v_Hj
  # This routine obtains scaled length at metamorphosis lj given scaled maturity at metamorphosis v_Hj. 
  # The theory behind get_lj, is discussed in the comments to DEB3. 
  # If scaled length at birth (third input) is not specified, it is computed (using automatic initial estimate); 
  #  if it is specified. however, is it just copied to the (third) output. 
  # The code assumes v_Hb < v_Hj < v_Hp (see first input). 
  #
  # Input
  #
  # * p: 6-vector with parameters: g, k, l_T, v_H^b, v_H^j, v_H^p
  #
  #     if p is a 5-vector, output lp is empty
  #
  # * f: optional scalar with scaled functional responses (defaul_T 1)
  # * lb0: optional scalar with scaled length at birth
  #
  # Output
  #
  # * lj: scalar with scaled length at metamorphosis
  # * lp: scalar with scaled length at puberty
  # * lb: scalar with scaled length at birth
  # * info: indicator equals 1 if successful
  
  ## Remarks
  # Similar to <get_lj1.html get_lj1>, which uses root finding, rather than integration
  # Scaled length l = L/ L_m with L_m = kap {p_Am}/ [p_M] where {p_Am} is of embryo, 
  #  because the amount of acceleration is food-dependent so the value after metamorphosis is not a parameter.
  # {p_Am} and v increase between maturities v_H^b and v_H^j till
  #    {p_Am} l_j/ l_b  and v l_j/ l_b at metamorphosis.
  # After metamorphosis l increases from l_j till l_i = f l_j/ l_b - l_T.
  # Scaled length l can thus be larger than 1.
  # See <get_lj_foetus.html *get_lj_foetus*> for foetal development. 
  
  ## Example of use
  # get_lj([.5, .1, .1, .01, .2, .3])
function get_lj(p, f, lb0=nothing)
    # Get scaled length at metamorphosis
    # Parameters:
    # p: vector with parameters [g, k, l_T, v_Hb, v_Hj, (optional) v_Hp]
    # f: scaled functional response (defaul_T 1)
    # lb0: optional scalar or vector with scaled length at birth and possibly v_Hb
    
    np = length(p)
    (; g, k, l_T, v_Hb, v_Hj, v_Hp) = p
    v_Hp = np > 5 ? p[6] : nothing
    
    # Get lb
    if lb0 === nothing || isempty(lb0)
        lb, info_lb = get_lb((; g, k, v_Hb), f)
    else
        lb = lb0 isa Number ? lb0 : lb0[1]
        info_lb = true
    end
    
    if l_T > f - lb
        return (nothing, nothing, nothing, false)
    end

    if v_Hb == v_Hj
        if np == 5
            lb, info_lb = get_lb((; g, k, v_Hb), f)
            return (lb, nothing, lb, info_lb)
        else
            lp, lb, info_tp = get_tp((; g, k, l_T, v_Hb, v_Hp), f, lb)
            return (lb, lp, lb, info_tp)
        end
    end

    # sM and lj from root finding
    rj = (f - l_T - lb) / lb / (1 + f / g)
    get_sM(sM) = f * lb^3 * (1/lb - rj/g) / (k + rj) * (sM^3 - sM^(-3*k/rj)) -
                 v_Hj + v_Hb * sM^(-3*k/rj)

    resul_T = find_zero(get_sM, (1.0, 500.0), Bisection(), verbose=false)
    sM = resul_T
    lj = sM * lb
    info_sM = !isnan(sM)

    # Fallback integration if fzero failed
    if !info_sM
        if lb0 isa Vector{Float64} && length(lb0) == 3
            lb, v_Hb = lb0[1], lb0[2]
        end
        function dget_l_V1_t!(du, u, p, t)
            vH, l = u
            k, l_T, g, f, lb, v_Hj = p
            r = (f - l_T - l) / (l + g)
            du[1] = (1 - k) * l^3 * r - k * vH
            du[2] = r * l
        end
        function end_of_accel(u, t, integrator)
            vH = u[1]
            return vH - v_Hj
        end
        u0 = [v_Hb, lb]
        tspan = (0.0, 1e6)
        p_accel = (k, l_T, g, f, lb, v_Hj)
        prob = ODEProblem(dget_l_V1_t!, u0, tspan, p_accel, callback=DiscreteCallback(end_of_accel, terminate!),
                          rel_Tol=1e-9, abstol=1e-9)
        sol = solve(prob, AutoTsit5(Rosenbrock23()), stop_at_consistent=true)
        lj = sol[end][2]
        sM = lj / lb
    end

    if np > 5
        p_lp1 = (g = p[1], k = p[2], l_T = p[3], v_Hb = p[4], v_Hp = p[5], sM = sM)
        lp, _, info_lp = get_lp1(p_lp1, f, lj)
    else
        lp, info_lp = nothing, true
    end

    info = info_sM && info_lp
    return (lj, lp, lb, info)
end