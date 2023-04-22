## get_tp
# Gets scaled age at puberty

##
function get_tp(p, f, lb0)
  # created at 2008/06/04 by Bas Kooijman, 
  # modified 2014/03/04 Starrlight Augustine, 2015/01/18 Bas Kooijman
  # modified 2018/09/10 (t -> tau) Nina Marn
  # modified 2021/11/24 Bas Kooijman
  
  ## Syntax
  # [tau_p, tau_b, lp, lb, info] = <../get_tp.m *get_tp*>(p, f, lb0)
  
  ## Description
  # Obtains scaled age at puberty.
  # Food density is assumed to be constant.
  # Multiply the result with the somatic maintenance rate coefficient to arrive at age at puberty. 
  #
  # Input
  #
  # * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  # * f: optional scalar with functional response (default f = 1)
  # * lb0: optional scalar with scaled length at birth
  #
  #      or optional 2-vector with scaled length, l, and scaled maturity, vH
  #      for a juvenile that is now exposed to f, but previously at another f
  #
  # Output
  #
  # * tau_p: scaled with age at puberty \tau_p = a_p k_M
  #
  #      if length(lb0)==2, tp is the scaled time till puberty
  #
  # * tau_b: scaled with age at birth \tau_b = a_b k_M
  # * lp: scaler length at puberty
  # * lb: scaler length at birth
  # * info: indicator equals 1 if successful
  
  ## Remarks
  # Function <get_tp_foetus.html *get_tp_foetus*> does the same for foetal development; the result depends on embryonal development. 

  ## Example of use
  # get_tp([.5, .1, .1, .01, .2])

  #  unpack pars
  g   = p[1]; # energy investment ratio
  k   = p[2]; # k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p[3]; # scaled heating length {p_T}/[p_M]Lm
  vHb = p[4]; # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHp = p[5]; # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}

  if !@isdefined(f)
    f = 1;
  elseif isempty(f)
    f = 1;
  end
  if !@isdefined(lb0)
    lb0 = [;];
  end

  if vHp < vHb
    println("Warning from get_tp: vHp < vHb\n")
    tau_b, l_b = get_tb(p([1 2 4]), f);
    tau_p = [;]; l_p = [;];
    info = false;
    return
  end

  if k == 1 && f * (f - lT)^2 > vHp * k
    lb = vHb^(1/3); 
    tau_b = get_tb(p([1 2 4]), f, lb);
    lp = vHp^(1/3);
    li = f - lT;
    rB = 1 / 3/ (1 + f/g);
    tau_p = tau_b + log((li - lb)/ (li - lp))/ rB;
    info = true;
  elseif f * (f - lT)^2 <= vHp * k # reproduction is not possible
    pars_lb = p[1 2 4];
    tau_b, lb = get_tb(pars_lb, f); 
    tau_p = 1e20; # tau_p is never reached
    lp = 1;    # lp is never reached
    info = false;
  else # reproduction is possible
    if length(lb0) != 2 # lb0 = l_b 
      tau_b, lb, info = get_tb([g, k, vHb], f)
      cb = ContinuousCallback(event_puberty,terminate_affect!)
      u0 = [vHb, lb]
      tspan = (0, 1e8)
      s_M = 1.0
      prob = ODEProblem(dget_l_ISO_t, u0, tspan, [k, lT, g, f, s_M, vHp])
      #sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9, callback=cb)
      sol = solve(prob, DP5(), reltol=1e-9, abstol=1e-9, callback=cb)
      t = sol.t
      vHl = sol.u
      tp = t[end]
      vHlp = vHl[end]
      #options = odeset('Events',@event_puberty, 'NonNegative',ones(2,1), 'AbsTol',1e-9, 'RelTol',1e-9); s_M = 1;
      #[t, vHl, tp, vHlp] = ode45(@dget_l_ISO_t, [0; 1e8], [vHb; lb], options, k, lT, g, f, s_M, vHp);
      tau_p = tau_b + tp; lp = vHlp[2];

    else # lb0 = l and t for a juvenile
      tau_b = NaN;
      #[lp, lb, info] = get_lp(p, f, lb0);
      l = lb0(1);
      li = f - lT;
      irB = 3 * (1 + f/ g); # k_M/ r_B
      tau_p = irB * log((li - l)/ (li - lp));
    end
  end
 
  if !isreal(tau_p) # tp must be real and positive
      info = false;
  elseif tau_p < 0
      info = false;
  end
  (tau_p, tau_b, lp, lb, info)
end

function get_tp(p, f)
  # created at 2008/06/04 by Bas Kooijman, 
  # modified 2014/03/04 Starrlight Augustine, 2015/01/18 Bas Kooijman
  # modified 2018/09/10 (t -> tau) Nina Marn
  # modified 2021/11/24 Bas Kooijman
  
  ## Syntax
  # [tau_p, tau_b, lp, lb, info] = <../get_tp.m *get_tp*>(p, f)
  
  ## Description
  # Obtains scaled age at puberty.
  # Food density is assumed to be constant.
  # Multiply the result with the somatic maintenance rate coefficient to arrive at age at puberty. 
  #
  # Input
  #
  # * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  # * f: optional scalar with functional response (default f = 1)
  #
  #      or optional 2-vector with scaled length, l, and scaled maturity, vH
  #      for a juvenile that is now exposed to f, but previously at another f
  #
  # Output
  #
  # * tau_p: scaled with age at puberty \tau_p = a_p k_M
  #
  #
  # * tau_b: scaled with age at birth \tau_b = a_b k_M
  # * lp: scaler length at puberty
  # * lb: scaler length at birth
  # * info: indicator equals 1 if successful
  
  ## Remarks
  # Function <get_tp_foetus.html *get_tp_foetus*> does the same for foetal development; the result depends on embryonal development. 

  ## Example of use
  # get_tp([.5, .1, .1, .01, .2])

  #  unpack pars
  g   = p[1]; # energy investment ratio
  k   = p[2]; # k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p[3]; # scaled heating length {p_T}/[p_M]Lm
  vHb = p[4]; # v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHp = p[5]; # v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}

  if !@isdefined(f)
    f = 1;
  elseif isempty(f)
    f = 1;
  end
  # if !@isdefined(lb0)
  #   lb0 = [;];
  # end

  if vHp < vHb
    println("Warning from get_tp: vHp < vHb\n")
    tau_b, l_b = get_tb(p([1 2 4]), f);
    tau_p = [;]; l_p = [;];
    info = false;
    return
  end

  if k == 1 && f * (f - lT)^2 > vHp * k
    lb = vHb^(1/3); 
    tau_b = get_tb(p([1 2 4]), f, lb);
    lp = vHp^(1/3);
    li = f - lT;
    rB = 1 / 3/ (1 + f/g);
    tau_p = tau_b + log((li - lb)/ (li - lp))/ rB;
    info = true;
  elseif f * (f - lT)^2 <= vHp * k # reproduction is not possible
    pars_lb = p[1 2 4];
    tau_b, lb = get_tb(pars_lb, f); 
    tau_p = 1e20; # tau_p is never reached
    lp = 1;    # lp is never reached
    info = false;
  else # reproduction is possible
    #if length(lb0) != 2 # lb0 = l_b 
      tau_b, lb, info = get_tb([g, k, vHb], f)
      cb = ContinuousCallback(event_puberty,terminate_affect!)
      u0 = [vHb, lb]
      tspan = (0, 1e8)
      s_M = 1.0
      prob = ODEProblem(dget_l_ISO_t, u0, tspan, [k, lT, g, f, s_M, vHp])
      #sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9, callback=cb)
      sol = solve(prob, DP5(), reltol=1e-9, abstol=1e-9, callback=cb)
      t = sol.t
      vHl = sol.u
      tp = t[end]
      vHlp = vHl[end]
      #options = odeset('Events',@event_puberty, 'NonNegative',ones(2,1), 'AbsTol',1e-9, 'RelTol',1e-9); s_M = 1;
      #[t, vHl, tp, vHlp] = ode45(@dget_l_ISO_t, [0; 1e8], [vHb; lb], options, k, lT, g, f, s_M, vHp);
      tau_p = tau_b + tp; lp = vHlp[2];

    # else # lb0 = l and t for a juvenile
    #   tau_b = NaN;
    #   #[lp, lb, info] = get_lp(p, f, lb0);
    #   l = lb0(1);
    #   li = f - lT;
    #   irB = 3 * (1 + f/ g); # k_M/ r_B
    #   tau_p = irB * log((li - l)/ (li - lp));
    # end
  end
 
  if !isreal(tau_p) # tp must be real and positive
      info = false;
  elseif tau_p < 0
      info = false;
  end
  (tau_p, tau_b, lp, lb, info)
end

function event_puberty(vHl, t, integrator)
  # vHl: 2-vector with [vH; l]
  vHp = integrator.p[6]
  vHp - vHl[1]
end

terminate_affect!(integrator) = terminate!(integrator)