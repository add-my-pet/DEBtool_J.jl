function [prdData, info] = predict_Chortoicetes_terminifera(par, data, auxData)
  
  % unpack par, data, auxData
  
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);
  
  if T_L > T_ref || T_H < T_ref
      prdData = []; info = 0; return
  end
  s_2 = s_1;
  s_3 = s_1;
  s_4 = s_1;
  if s_1 < 1 || s_2 < 1 || s_3 < 1 || s_4 < 1
     prdData = []; info = 0; return
  end
  
  % compute temperature correction factors
  pars_TRi = [T_A5; T_L; T_H; T_AL; T_AH5];
  pars_Tab = [T_A0; T_L; T_H; T_AL; T_AH0];
  pars_TtW = [T_A; T_L; T_H; T_AL; T_AH];

  TC_ab = tempcorr(temp.ab, T_ref, pars_Tab);
  TC_tp = tempcorr(temp.tp, T_ref, pars_TtW);
  TC_am = tempcorr(temp.am, T_ref, pars_TtW);
  TC_Ri = tempcorr(temp.Ri, T_ref, pars_TRi);
  TC_26 = tempcorr(temp.tW_26, T_ref, pars_TtW);
  TC_27 = tempcorr(temp.tW_27, T_ref, pars_TtW);
  TC_29 = tempcorr(temp.tW_29, T_ref, pars_TtW);
  TC_Tab = tempcorr(C2K(Tab(:,1)), T_ref, pars_Tab);

  % zero-variate data

  % life cycle
  pars_tj = [g k l_T v_Hb v_Hp v_Hp+1e-8];
  [t_p, ~, t_b, l_p, ~, l_b, l_i, rho_j, rho_B, info] = get_tj(pars_tj, f);
  if info == 0
    prdData = []; return
  end
  
  % initial
  pars_UE0 = [V_Hb; g; k_J; k_M; v]; % compose parameter vector
  E_0 = p_Am * initial_scaled_reserve(f, pars_UE0); % d.cm^2, initial scaled reserve

  % birth
  L_b = L_m * l_b;                  % cm, structural length at birth at f
  Lw_b = L_b/ del_M;                % cm, total length at birth at f
  Wd_b = L_b^3 * d_V * (1 + f * w); % g, dry weight at birth
  a_b = t_0 + t_b/ k_M;             % d, age at birth at f and T
  aT_b = a_b/ TC_ab;                % d, age at birth at f and T
  
  % puberty 
  L_p = L_m * l_p;                  % cm, structural length at puberty at f
  Lw_p = L_p/ del_M;                % cm, total length at puberty at f
  Wd_p = L_p^3 * d_V * (1 + f * w); % g, dry weight at puberty 
  tT_p = (t_p - t_b)/ k_M/ TC_tp;   % d, time since birth at puberty at f and T
  s_M = l_p/ l_b;                   % -, acceleration factor
  
  % instar weight
  L_2 = L_b * s_1^0.5;  % cm, struct length at start of instar 2
  L_3 = L_2 * s_2^0.5;  % cm, struct length at start of instar 3
  L_4 = L_3 * s_3^0.5;  % cm, struct length at start of instar 4
  L_5 = L_4 * s_4^0.5;  % cm, struct length at start of instar 5
  Wd_2 = L_2^3 * d_V * (1 + f * w); % g, dry weight at start of instar 2
  Wd_3 = L_3^3 * d_V * (1 + f * w); % g, dry weight at start of instar 3
  Wd_4 = L_4^3 * d_V * (1 + f * w); % g, dry weight at start of instar 4
  Wd_5 = L_5^3 * d_V * (1 + f * w); % g, dry weight at start of instar 5

  % reproduction
  RT_i = TC_Ri * kap_R * ((1 - kap) * f * p_Am * s_M * L_p^2 - k_J * E_Hp)/ E_0; % #/d, ultimate reproduction rate at T

  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC_am;               % d, mean life span at T
  
  % pack to output
  prdData.ab = aT_b;
  prdData.tp = tT_p;
  prdData.am = aT_m;
  prdData.Lp = Lw_p;
  prdData.Lb = Lw_b;
  prdData.Wdb = Wd_b;
  prdData.Wd2 = Wd_2;
  prdData.Wd3 = Wd_3;
  prdData.Wd4 = Wd_4;
  prdData.Wd5 = Wd_5;
  prdData.Wdp = Wd_p;
  prdData.Ri = RT_i;
  
  % uni-variate data
  
  Eab = a_b ./ TC_Tab; % age at birth at different temperatures
  
  % time-weight 
  EWd_26 = min(L_p, L_b * exp((tW_26(:,1)) * TC_26 * k_M * rho_j/ 3)).^3 * d_V * (1 + f * w);
  EWd_27 = min(L_p, L_b * exp((tW_27(:,1)) * TC_27 * k_M * rho_j/ 3)).^3 * d_V * (1 + f * w);
  EWd_29 = min(L_p, L_b * exp((tW_29(:,1)) * TC_29 * k_M * rho_j/ 3)).^3 * d_V * (1 + f * w);
  
  % pack to output
  prdData.Tab = Eab;
  prdData.tW_26 = EWd_26;
  prdData.tW_27 = EWd_27;
  prdData.tW_29 = EWd_29; 
