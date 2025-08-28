function [prdData, info] = predict_Bos_taurus_Angus(par, data, auxData)

%% compute temperature correction factors
TC = tempcorr(auxData.temp.tier_pars, par.T_ref, par.T_A);

% Set nitrogen of structure equal to nitrogen of reserve
% par.n_NE = par.n_NV;

%% Building female parameter set
female_pars = par;
female_pars.p_Am = par.p_Am_f;
%female_pars.E_Hx = par.E_Hx_f;
female_pars.E_Hp = par.E_Hp_f;

if ~filter_stx(female_pars)
    prdData = []; info = 0; return
end
vars_pull(female_pars); vars_pull(parscomp_st(female_pars));

%% Filters
% CO2, H2O, and N-waste must be produced in all reactions
% Chemical indices of reserve and structure must be positive
% Methane contribution to assimilation should not be negative or larger than 0.5
filterChecks = (n_NE < 0) || (n_NV < 0) || (xi_C > 0.5) || (xi_C < 0) || ...
    (any(eta_M([1, 2, 4], :) < 0, 'all'));
if filterChecks
    prdData = []; info = 0; return
end

% Upper bound on y_N_E
% Not all nitrogen expelled in the form of urine can come from assimilation
% Assumes that of the N in food, 4% is retained and 48% is expelled in the
% form of feces
% if y_N_E > 0.48 * y_X_E * n_NX / n_NN
%     prdData = []; info = 0; return
% end


%% Predictions for data on females

% stage transitions
pars_txf = [g k l_T v_Hb v_Hx v_Hp];
[t_pf, t_xf, t_bf, l_pf, l_xf, l_bf, info] = get_tx(pars_txf, [f_milk f]);
if ~info
    prdData = []; info = 0; return
end

% Predictions
L_bf = L_m * l_bf;                   % cm, structural length at birth at f
L_xf = L_m * l_xf;
L_pf = L_m * l_pf;
L_if = (f - l_T) * L_m;

aT_bf = t_0 + t_bf/ k_M/ TC;            % d, age at birth for females
tT_xf = (t_xf - t_bf)/ k_M/ TC;         % d, time since birth at weaning for females
tT_pf = (t_pf - t_bf)/ k_M/ TC;         % d, time since birth at puberty for females
Wwb_f = L_bf^3 * (1 + f * ome);         % g, wet weight at birth at f
Wwx_f = L_xf^3 * (1 + f * ome);         % g, wet weight at weaning at f
Wwp_f = L_pf^3 * (1 + f * ome);         % g, wet weight at puberty at f
Wwi_f = L_if^3 * (1 + f * ome);         % g, ultimate wet weight at f
Lhi_f = L_if / del_M;                   % cm, ultimate withers height at f

% Reproduction rate
Lb = l_bf * L_m; Lp = l_pf * L_m; % volumetric length at birth, puberty
UE0 = Lb^3 * (f + g)/ v * (1 + 3 * l_bf/ 4/ f); % d.cm^2, scaled cost per foetus
SC = f * L_m.^3 .* (g ./ L_m + (1 + L_T ./ L_m)/ L_m)/ (f + g);
SR = (1 - kap) * SC - k_J * E_Hp / p_Am;
RT_i = TC * kap_R .* SR/ UE0; % set reprod rate of juveniles to zero

% life span
pars_tm = [g; k; v_Hb; v_Hx; v_Hp; h_a; s_G];  % compose parameter vector at T_ref
t_m = get_tm_mod('stx', pars_tm, f);           % -, scaled mean life span at T_ref
aT_f = t_m/ k_M/ TC;                           % d, mean life span at T

%% Fetal development
tWwe_Mao_females = (1 + f * ome) * (v * TC * max(0, data.tWwe_Mao(:,1) - t_0)/ 3) .^ 3;
tWwe_Anthony_females = (1 + f * ome) * (v * TC * max(0, data.tWwe_Anthony(:,1) - t_0)/ 3) .^ 3;

%% IPCC nitrogen equations for females

L = nthroot(data.WN_feces_females(:,1)*1e3 / (1 + f * ome),3);
p_A = f * p_Am * TC * L.^2;
p_S = p_M * TC * L.^3;
p_C = (E_G * p_A + f * E_m * p_S) / (kap * f * E_m + E_G);
p_G = kap * p_C - p_S;
p_D = p_C - p_G;

pow = [p_A'; p_D'; p_G'];

N_out_urine = eta_M(4,:) * pow .* n_NN; % mol N / mol N-waste.d
prdData.WN_urine_females = N_out_urine' * 14 / 1e3;

N_out_feces = eta_O(4,1) * p_A .* n_NP; % mol N / mol P.d
prdData.WN_feces_females = N_out_feces * 14 / 1e3;

prdData.WN_ret_females = ((p_A - p_C) / mu_E * n_NE + kap_G * p_G / mu_V * n_NV) * 14 / 1e3;

%% Males
% Check validity of tier parameter set
if ~filter_stx(par)
    prdData = []; info = 0; return
end
% Set structure nitrogen equal to reserve nitrogen
vars_pull(par);  vars_pull(parscomp_st(par));

%% Predict group data
% stage transitions
pars_txf = [g k l_T v_Hb v_Hx v_Hp];
[t_pm, t_xm, t_bm, l_pm, l_xm, l_bm, info] = get_tx(pars_txf, [f_milk f]);
if ~info
    prdData = []; info = 0; return
end

% Predictions
L_bm = L_m * l_bm;                   % cm, structural length at birth at f
L_xm = L_m * l_xm;
L_pm = L_m * l_pm;
L_im = (f - l_T) * L_m;

aT_bm = t_0 + t_bm/ k_M/ TC;            % d, age at birth for females
tT_xm = (t_xm - t_bm)/ k_M/ TC;           % d, time since birth at weaning for males
tT_pm = (t_pm - t_bm)/ k_M/ TC;           % d, time since birth at puberty for males
Wwb_m = L_bm^3 * (1 + f * ome);         % g, wet weight at birth at f
Wwx_m = L_xm^3 * (1 + f * ome);         % g, wet weight at weaning at f
Wwp_m = L_pm^3 * (1 + f * ome);         % g, wet weight at puberty at f
Wwi_m = L_im^3 * (1 + f * ome);         % g, ultimate wet weight at f
Lhi_m = L_im / del_M;

% life span
pars_tm = [g; k; v_Hb; v_Hx; v_Hp; h_a; s_G];  % compose parameter vector at T_ref
t_m = get_tm_mod('stx', pars_tm, f);           % -, scaled mean life span at T_ref
aT_m = t_m/ k_M/ TC;                           % d, mean life span at T

% Fetal development
tWwe_Mao_males = (1 + f * ome) * (v * TC * max(0, data.tWwe_Mao(:,1) - t_0)/ 3) .^ 3;
tWwe_Anthony_males = (1 + f * ome) * (v * TC * max(0, data.tWwe_Anthony(:,1) - t_0)/ 3) .^ 3;

%% Fetal development
% Average values for both males and females
prdData.tWwe_Mao = 0.5*(tWwe_Mao_males + tWwe_Mao_females);
prdData.tWwe_Anthony = 0.5*(tWwe_Anthony_males + tWwe_Anthony_females);


%% IPCC equations for males

L = nthroot(data.WN_feces_males(:,1)*1e3 / (1 + f * ome),3);
p_A = f * p_Am * TC * L.^2;
p_S = p_M * TC * L.^3;
p_C = (E_G * p_A + f * E_m * p_S) / (kap * f * E_m + E_G);
p_G = kap * p_C - p_S;
p_D = p_C - p_G;

pow = [p_A'; p_D'; p_G'];

N_out_urine = eta_M(4,:) * pow .* n_NN; % mol N / mol N-waste.d
prdData.WN_urine_males = N_out_urine' * 14 / 1e3;

N_out_feces = eta_O(4,1) * p_A .* n_NP; % mol N / mol P.d
prdData.WN_feces_males = N_out_feces * 14 / 1e3;

prdData.WN_ret_males = ((p_A - p_C) / mu_E * n_NE + kap_G * p_G / mu_V * n_NV) * 14 / 1e3;


%% Herd et al. 2019 data from RFI trial
% Set composition parameters
diet_par = par;
dietName = 'Herd19_RFI';
dietCompParams = auxData.diets.diet_comp_params;
for c=1:numel(dietCompParams)
    compParam = dietCompParams{c};
    diet_par.(compParam) = par.([compParam '_' dietName]);
end
vars_pull(diet_par);  vars_pull(parscomp_st(diet_par));
% Check validity of tier parameter set
% Urea must be produced in the assimilation reaction
if ((y_X_E * n_NX - n_NE - y_P_E * n_NP) <= 0)
    prdData = []; info = 0; return
end

% Dry matter digestibility
prdData.DMD_Herd19_RFI = (w_X - w_P * y_P_E / y_X_E) / w_X;

% Growth curve parameters
rT_B = TC * p_M / 3 / (E_G + f * kap * p_Am / v);
L_inf = f * L_m - L_T;
% Weight
L_init = nthroot(auxData.init.tW_Herd19_RFI*1e3 / (1 + f * ome),3);
if L_init > L_inf  % Check for feasibility
    prdData = []; info = 0; return
end
t = data.tW_Herd19_RFI(:,1);
duration = t(end, 1);
L = L_inf - (L_inf - L_init) .* exp( - t * rT_B);
W = (1 + f * ome) * L.^3;
prdData.tW_Herd19_RFI = W ./ 1e3; % to kg

% Integral of L^2 over the duration of the trial
L2_integral = (L_inf^2 * 70 - 0.5*rT_B*((L_inf + L(end))^2 - (L_inf + L_init)^2));
% Daily feed intake
a_JX = f * w_X .* p_Am * TC / mu_X / kap_X;
TFI = a_JX * L2_integral;
prdData.DMI_Herd19_RFI = TFI / duration / 1e3; % to kg

% Feed conversion ratio
prdData.FCR_Herd19_RFI = TFI / (W(end) - W(1)); 

% Methane production
n_M_CH4 = n_M;
n_M_CH4(:,1) = [n_CM n_HM n_OM n_NM];
eta_M_CH4 = -inv(n_M_CH4)*n_O*eta_O;
w_CH4 = 16;
a_CH4 = f * p_Am * TC * eta_M_CH4(1,1) * w_CH4 * xi_C;
TMPR = a_CH4 * L2_integral;
prdData.MPR_Herd19_RFI = TMPR / duration;

prdData.MY_Herd19_RFI = TMPR / (TFI / 1e3); % g/kg

%% Herd et al. 2019 data from HP trial
% Set composition parameters
diet_par = par;
dietName = 'Herd19_HP';
dietCompParams = auxData.diets.diet_comp_params;
for c=1:numel(dietCompParams)
    compParam = dietCompParams{c};
    diet_par.(compParam) = par.([compParam '_' dietName]);
end
vars_pull(diet_par);  vars_pull(parscomp_st(diet_par));
% Check validity of tier parameter set
% Urea must be produced in the assimilation reaction
if ((y_X_E * n_NX - n_NE - y_P_E * n_NP) <= 0)
    prdData = []; info = 0; return
end

% Dry matter digestibility
prdData.DMD_Herd19_HP = (w_X - w_P * y_P_E / y_X_E) / w_X;

% Growth curve parameters
rT_B = TC * p_M / 3 / (E_G + f * kap * p_Am / v);
L_inf = f * L_m - L_T;
L = nthroot(auxData.init.DMI_Herd19_HP*1e3 / (1 + f * ome),3);
p_A = f * p_Am * TC * L.^2;

% Feed intake
DMI = w_X / mu_X / kap_X .* p_A;
prdData.DMI_Herd19_HP = DMI / 1e3; % to kg

% Methane production
n_M_CH4 = n_M;
n_M_CH4(:,1) = [n_CM n_HM n_OM n_NM];
eta_M_CH4 = -inv(n_M_CH4)*n_O*eta_O;
w_CH4 = 16;
MPR = eta_M_CH4(1,1) * w_CH4 * xi_C * p_A;
prdData.MPR_Herd19_HP = MPR;

prdData.MY_Herd19_HP = MPR / (DMI / 1e3); % g/kg

% CO2 production
eta_M_CO2 = -inv(n_M)*n_O*eta_O;
w_CO2 = 44;
p_S = p_M * TC * L.^3;
p_C = (E_G * p_A + f * E_m * p_S) / (kap * f * E_m + E_G);
p_G = kap * p_C - p_S;
p_D = p_C - p_G;
pow = [p_A' .* (1-xi_C)'; p_D'; p_G'];
% Carbon dioxide emissions
CO2 = w_CO2 * eta_M_CO2(1,:) * pow;
prdData.CPR_Fed_Herd19_HP = CO2;

CO2_unfed = w_CO2 * eta_M_CO2(1,:) * [0.25*p_A; p_D; p_G];
prdData.CPR_Unfed_Herd19_HP = CO2_unfed;

%% Bunting et al. 1989 data from high protein diet
% Set composition parameters
diet_par = par;
dietName = 'Bunt89_HP';
dietCompParams = auxData.diets.diet_comp_params;
for c=1:numel(dietCompParams)
    compParam = dietCompParams{c};
    diet_par.(compParam) = par.([compParam '_' dietName]);
end
vars_pull(diet_par);  vars_pull(parscomp_st(diet_par));
% Check validity of tier parameter set
% Urea must be produced in the assimilation reaction
if ((y_X_E * n_NX - n_NE - y_P_E * n_NP) <= 0)
    prdData = []; info = 0; return
end

% Dry matter digestibility
prdData.DMD_Bunt89_HighProt = (w_X - w_P * y_P_E / y_X_E) / w_X;

% State and powers 
L = nthroot(auxData.init.DMI_Bunt89_HighProt*1e3 / (1 + f * ome),3);
p_A = f * p_Am * TC * L.^2;
p_S = p_M * TC * L.^3;
p_C = (E_G * p_A + f * E_m * p_S) / (kap * f * E_m + E_G);
p_G = kap * p_C - p_S;
p_D = p_C - p_G;
pow = [p_A'; p_D'; p_G'];
eta_M = -inv(n_M)*n_O*eta_O;

% Feed intake
DMI = w_X / mu_X / kap_X .* p_A;
prdData.DMI_Bunt89_HighProt = DMI;

% N intake
N_intake = 14 * n_NX / mu_X / kap_X .* p_A;
prdData.N_intake_Bunt89_HighProt = N_intake;

% N excreted in feces
N_feces = 14 * n_NP * y_P_E / mu_E .* p_A;
prdData.N_feces_Bunt89_HighProt = N_feces;

% N excrete in urine
N_urine = 14 * n_NN * eta_M(4, :) * pow;
prdData.N_urine_Bunt89_HighProt = N_urine;

% N retention
N_ret_E = n_NE / mu_E * (p_A - p_C);
N_ret_V = n_NV * kap_G / mu_V * p_G;
prdData.N_retention_Bunt89_HighProt = 14 * (N_ret_E + N_ret_V);

%% Bunting et al. 1989 data from low protein diet
% Set composition parameters
diet_par = par;
dietName = 'Bunt89_LP';
dietCompParams = auxData.diets.diet_comp_params;
for c=1:numel(dietCompParams)
    compParam = dietCompParams{c};
    diet_par.(compParam) = par.([compParam '_' dietName]);
end
vars_pull(diet_par);  vars_pull(parscomp_st(diet_par));
% Check validity of tier parameter set
% Urea must be produced in the assimilation reaction
if ((y_X_E * n_NX - n_NE - y_P_E * n_NP) <= 0)
    prdData = []; info = 0; return
end

% Dry matter digestibility
prdData.DMD_Bunt89_LowProt = (w_X - w_P * y_P_E / y_X_E) / w_X;

% State and powers 
L = nthroot(auxData.init.DMI_Bunt89_LowProt*1e3 / (1 + f * ome),3);
p_A = f * p_Am * TC * L.^2;
p_S = p_M * TC * L.^3;
p_C = (E_G * p_A + f * E_m * p_S) / (kap * f * E_m + E_G);
p_G = kap * p_C - p_S;
p_D = p_C - p_G;
pow = [p_A'; p_D'; p_G'];
eta_M = -inv(n_M)*n_O*eta_O;

% Feed intake
DMI = w_X / mu_X / kap_X .* p_A;
prdData.DMI_Bunt89_LowProt = DMI;

% N intake
N_intake = 14 * n_NX / mu_X / kap_X .* p_A;
prdData.N_intake_Bunt89_LowProt = N_intake;

% N excreted in feces
N_feces = 14 * n_NP * y_P_E / mu_E .* p_A;
prdData.N_feces_Bunt89_LowProt = N_feces;

% N excrete in urine
N_urine = 14 * n_NN * eta_M(4, :) * pow;
prdData.N_urine_Bunt89_LowProt = N_urine;

% N retention
N_ret_E = n_NE / mu_E * (p_A - p_C);
N_ret_V = n_NV * kap_G / mu_V * p_G;
prdData.N_retention_Bunt89_LowProt = 14 * (N_ret_E + N_ret_V);


%% Greenbeef data

% Initialize group data
for g=1:length(auxData.tiers.group_list)
    group_id = auxData.tiers.group_list{g};
    
    tJX_grp_varname = ['tJX_grp_' group_id];
    if isfield(data, tJX_grp_varname)
        prdData.(tJX_grp_varname) = 0;
    end
end

greenbeefDietNames = fieldnames(auxData.diets.inds_of_diet);
for d=1:numel(greenbeefDietNames)
    dietName = greenbeefDietNames{d};
    
    % Set composition parameters
    diet_par = par;
    dietCompParams = auxData.diets.diet_comp_params;
    for c=1:numel(dietCompParams)
        compParam = dietCompParams{c};
        diet_par.(compParam) = par.([compParam '_' dietName]);
    end
    vars_pull(diet_par);  vars_pull(parscomp_st(diet_par));
    % Check validity of tier parameter set
    % Urea must be produced in the assimilation reaction
    if ((y_X_E * n_NX - n_NE - y_P_E * n_NP) <= 0)
        prdData = []; info = 0; return
    end

    %% Compute prediction parameters
    % Growth curve parameters
    rT_B = TC * p_M / 3 / (E_G + f * kap * p_Am / v);
    L_inf = f * L_m - L_T;
    % Food consumption parameters
    a_JX = f * w_X .* p_Am * TC / mu_X / kap_X;
    % Methane emissions parameters
    n_M_CH4 = n_M;
    n_M_CH4(:,1) = [n_CM n_HM n_OM n_NM];
    eta_M_CH4 = -inv(n_M_CH4)*n_O*eta_O;
    w_CH4 = 16;
    % Carbon dioxide emissions parameters
    eta_M_CO2 = -inv(n_M)*n_O*eta_O;
    w_CO2 = 44;

    %% Predict individual data
    indList = {auxData.diets.inds_of_diet.(dietName)};
    for i=1:length(indList)
        ind_id = indList{i};

        % Weight predictions
        tW_varname = ['tW_' ind_id];
        if isfield(data, tW_varname)
            % Length at start of test
            L_init = nthroot(auxData.init.(tW_varname)*1e3 / (1 + f * ome),3);
            if L_init > L_inf  % Check for feasibility
                prdData = []; info = 0; return
            end
            % Time
            t = data.(tW_varname)(:,1);
            % Weight
            W = (1 + f * ome) * (L_inf - (L_inf - L_init) .* exp( - t * rT_B)).^3;
            prdData.(tW_varname) = W ./ 1e3; % to kg
        end

        % Methane emissions predictions
        tCH4_varname = ['tCH4_' ind_id];
        if isfield(data, tCH4_varname)
            % Weight at the start of the test
            L_init = nthroot(auxData.init.(tCH4_varname)*1e3 / (1 + f * ome), 3);
            if L_init > L_inf % Check for feasibility
                prdData = []; info = 0; return
            end
            % Time
            t = data.(tCH4_varname)(:,1);
            % Methane emissions
            L = (L_inf - (L_inf - L_init) .* exp( - t * rT_B));
            p_A = f * p_Am * TC .* L.^2;
            CH4 = eta_M_CH4(1,1) * w_CH4 * xi_C .* p_A;
            prdData.(tCH4_varname) = CH4;
        end

        % Carbon dioxide emissions predictions
        tCO2_varname = ['tCO2_' ind_id];
        if isfield(data, tCO2_varname)
            % Length at the start of the test
            L_init = nthroot(auxData.init.(tCO2_varname)*1e3 / (1 + f * ome), 3);
            if L_init > L_inf % Check for feasibility
                prdData = []; info = 0; return
            end
            % Time
            t = data.(tCO2_varname)(:,1);
            % Computing powers
            L = (L_inf - (L_inf - L_init) .* exp( - t * rT_B));
            p_A = f * p_Am * TC * L.^2;
            p_S = p_M * TC * L.^3;
            p_C = (E_G * p_A + f * E_m * p_S) / (kap * f * E_m + E_G);
            p_G = kap * p_C - p_S;
            p_D = p_C - p_G;
            pow = [p_A' .* (1-xi_C)'; p_D'; p_G'];
            % Carbon dioxide emissions
            CO2 = w_CO2 * eta_M_CO2(1,:) * pow;
            prdData.(tCO2_varname) = CO2';
        end

        %% Predict group data ind_id is part of
        for g=1:length(auxData.tiers.groups_of_ind.(ind_id))
            group_id = auxData.tiers.groups_of_ind.(ind_id){g};

            % Group feed consumption predictions
            tJX_grp_varname = ['tJX_grp_' group_id];
            if isfield(data, tJX_grp_varname)
                t = data.(tJX_grp_varname)(:,1);
                L_init = nthroot(auxData.init.(tJX_grp_varname).(ind_id)*1e3 / (1 + f * ome),3);
                if L_init > L_inf  % Check for feasibility
                    prdData = []; info = 0; return
                end
                % Food consumption during test
                L = (L_inf - (L_inf - L_init) .* exp( - t * rT_B));
                JX = a_JX * L.^2 ./ 1e3;
                prdData.(tJX_grp_varname) = prdData.(tJX_grp_varname) + JX;
            end
        end
    end
end

%% Set predictions for the dummy variables
prdData.group_list = 10;
prdData.ind_list = 10;
prdData.groups_of_ind = 10;
prdData.tier_sample_list = 10;
prdData.tier_sample_inds = 10;
prdData.tier_pars = 10;
prdData.inds_of_diet = 10;
prdData.diet_comp_params = 10;

%% pack to output

% % Zero-variate data
% Females
prdData.Wwb_f = Wwb_f;
prdData.tx_f = tT_xf;
prdData.Wwx_f = Wwx_f;
prdData.tp_f = tT_pf;
prdData.Wwp_f = Wwp_f;
prdData.Wwi_f = Wwi_f;
prdData.Lhi_f = Lhi_f;
prdData.Ri = RT_i;

% Males
prdData.Wwb_m = Wwb_m;
prdData.tx_m = tT_xm;
prdData.Wwx_m = Wwx_m;
prdData.tp_m = tT_pm;
prdData.Wwp_m = Wwp_m;
prdData.Wwi_m = Wwi_m;
prdData.Lhi_m = Lhi_m;

% Common data
prdData.ab = 0.5*(aT_bf + aT_bm);     % equal for males and females
prdData.am = 0.5*(aT_f + aT_m);

end
