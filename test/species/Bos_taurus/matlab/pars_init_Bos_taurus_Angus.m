function [par, metaPar, txtPar] = pars_init_Bos_taurus_Angus(metaData)

metaPar.model = 'stx'; 

%% reference parameter (not to be changed) 
par.T_ref = 293.15;   free.T_ref = 0;   units.T_ref = 'K';        label.T_ref = 'Reference temperature'; 

%% core primary parameters 
par.p_Am  = 5467;           free.p_Am   = 1;   units.p_Am = 'J/d.cm^2';  label.p_Am  = 'Surface-specific maximum assimilation rate';
par.kap_X = 0.1354;         free.kap_X  = 1;   units.kap_X = '-';        label.kap_X = 'digestion efficiency of food to reserve'; 
par.v = 0.02057;            free.v      = 1;   units.v = 'cm/d';         label.v = 'energy conductance'; 
par.kap = 0.9716;           free.kap    = 1;   units.kap = '-';          label.kap = 'allocation fraction to soma'; 
par.p_M = 100.68;           free.p_M    = 1;   units.p_M = 'J/d.cm^3';   label.p_M = '[p_M], vol-spec somatic maint'; 
par.E_G = 7829;             free.E_G    = 1;   units.E_G = 'J/cm^3';     label.E_G = '[E_G], spec cost for structure'; 
par.E_Hb = 2e4;             free.E_Hb   = 1;   units.E_Hb = 'J';         label.E_Hb = 'maturity at birth'; 
par.E_Hx = 2e5;             free.E_Hx   = 1;   units.E_Hx = 'J';         label.E_Hx = 'maturity at weaning'; 
par.E_Hp = 2e6;             free.E_Hp   = 1;   units.E_Hp = 'J';         label.E_Hp = 'maturity at puberty'; 
par.h_a = 5e-10;            free.h_a    = 1;   units.h_a = '1/d^2';      label.h_a = 'Weibull aging acceleration'; 
par.t_0 = 80;               free.t_0    = 1;   units.t_0 = 'd';          label.t_0 = 'time at start development'; 
par.del_M = 0.154;          free.del_M  = 1;   units.del_M = '-';        label.del_M = 'shape coefficent';
par.kap_P = 0.2649;         free.kap_P  = 1;   units.kap_P = '-';        label.kap_P = 'faecation efficiency of food to faeces'; 
par.xi_C = 0.1354;          free.xi_C   = 1;   units.xi_C = '-';         label.xi_C = 'contribution of methane subtransformation to assimilation';
par.rho_xi = 0.05;          free.rho_xi = 0;   units.rho_xi = '-';       label.rho_xi = 'reduction in xi_C due to the effect of the seaweed additive';
par.lambda = 2;             free.lambda = 0;   units.lambda = '-';       label.lambda = 'slope parameter of sigmoid in transition between effect/no effect of the seaweed additive';

% females
par.p_Am_f  = par.p_Am;     free.p_Am_f  = 1; units.p_Am_f = 'J/d.cm^2';  label.p_Am_f = 'Surface-specific maximum assimilation rate for females';
%par.E_Hx_f = par.E_Hx;     free.E_Hx_f  = 1; units.E_Hx_f = 'J';         label.E_Hx_f = 'maturity at weaning for females'; 
par.E_Hp_f = par.E_Hp;      free.E_Hp_f  = 1; units.E_Hp_f = 'J';         label.E_Hp_f = 'maturity at puberty for females'; 

%% Standard parameters
par.T_A = 8000;         free.T_A   = 0;   units.T_A = 'K';          label.T_A = 'Arrhenius temperature'; 
par.z = 13;             free.z     = 0;   units.z = '-';            label.z = 'zoom factor'; 
par.F_m = 6.5;          free.F_m   = 0;   units.F_m = 'l/d.cm^2';   label.F_m = '{F_m}, max spec searching rate'; 
par.kap_R = 0.95;       free.kap_R = 0;   units.kap_R = '-';        label.kap_R = 'reproduction efficiency'; 
par.p_T = 0;            free.p_T   = 0;   units.p_T = 'J/d.cm^2';   label.p_T = '{p_T}, surf-spec somatic maint'; 
par.k_J = 0.002;        free.k_J   = 0;   units.k_J = '1/d';        label.k_J = 'maturity maint rate coefficient'; 
par.s_G = 0.1;          free.s_G   = 0;   units.s_G = '-';          label.s_G = 'Gompertz stress coefficient'; 

%% other parameters 
par.f = 1;              free.f      = 0;  units.f = '-';            label.f = 'scaled functional response for 0-var data'; 
par.f_milk = 1;         free.f_milk = 1;  units.f_milk = '-';       label.f_milk = 'scaled functional response between birth and weaning'; 

%% set chemical parameters from Kooy2010 
[par, units, label, free] = addchem(par, units, label, free, metaData.phylum, metaData.class);

%% Methane chemical parameters
par.mu_M = 816000;  free.mu_M = 0;  units.mu_M = 'J/mol';    label.mu_M = 'chemical potential of methane';
par.n_CM = 1;       free.n_CM = 0;  units.n_CM = '-';        label.n_CM = 'chem. index of carbon in methane';
par.n_HM = 4;       free.n_HM = 0;  units.n_HM = '-';        label.n_HM = 'chem. index of hydrogen in methane';
par.n_OM = 0;       free.n_OM = 0;  units.n_OM = '-';        label.n_OM = 'chem. index of oxygen in methane';
par.n_NM = 0;       free.n_NM = 0;  units.n_NM = '-';        label.n_NM = 'chem. index of nitrogen in methane';

%% Diet composition 
par.n_HX = 1.85;    free.n_HX = 0;  units.n_HX = '-';        label.n_HX = 'chem. index of hydrogen in food';
par.n_OX = 0.752;    free.n_OX = 0;  units.n_OX = '-';        label.n_OX = 'chem. index of oxygen in food';
par.n_NX = 0.044;   free.n_NX = 0;  units.n_NX = '-';        label.n_NX = 'chem. index of nitrogen in food';
par.mu_X = 525000; free.mu_X = 0;  units.mu_X = 'J/ mol';   label.mu_X = 'chemical potential of food'; 

dietCompositions = struct();
dietCompositions.CTRL_2022 = struct('mu_X', 518844, 'n_HX', 1.869, 'n_OX', 0.732, 'n_NX', 0.040);
dietCompositions.TMR_2022 = struct('mu_X', 510716, 'n_HX', 1.844, 'n_OX', 0.752, 'n_NX', 0.050);
dietCompositions.TMR_2023 = struct('mu_X', 509550, 'n_HX', 1.839, 'n_OX', 0.755, 'n_NX', 0.047);
dietCompositions.OIL_2023 = struct('mu_X', 513071, 'n_HX', 1.852, 'n_OX', 0.746, 'n_NX', 0.047);
dietCompositions.Herd19_RFI = struct('mu_X', 529743, 'n_HX', 1.880, 'n_OX', 0.793, 'n_NX', 0.047);
dietCompositions.Herd19_HP = struct('mu_X', 546064, 'n_HX', 1.841, 'n_OX', 0.752, 'n_NX', 0.034);
dietCompositions.Bunt89_LP = struct('mu_X', 532521, 'n_HX', 1.825, 'n_OX', 0.764, 'n_NX', 0.029);
dietCompositions.Bunt89_HP = struct('mu_X', 543457, 'n_HX', 1.852, 'n_OX', 0.725, 'n_NX', 0.058);

% Set compositions in par struct
dietNames = fieldnames(dietCompositions);
for d=1:numel(dietNames)
    diet = dietNames{d};
    dietParamNames = fieldnames(dietCompositions.(diet));
    for p=1:numel(dietParamNames)
        paramName = dietParamNames{p};
        dietParam = [paramName '_' diet];
        par.(dietParam) = dietCompositions.(diet).(paramName); 
        free.(dietParam) = 0; 
        units.(dietParam) = units.(paramName);
        label.(dietParam) = [label.(paramName) 'for diet ' diet];
    end
end


%% Feces and N-waste composition
% Fajobi et al. 2022
par.mu_P = 390318;  free.mu_P = 0;  units.mu_P = 'J/ mol';   label.mu_P = 'chemical potential of faeces'; 
par.n_HP = 2.192;   free.n_HP = 0;  units.n_HP = '-';        label.n_HP = 'chem. index of hydrogen in faeces';
par.n_OP = 0.819;   free.n_OP = 0;  units.n_OP = '-';        label.n_OP = 'chem. index of oxygen in faeces';
par.n_NP = 0.030;   free.n_NP = 0;  units.n_NP = '-';        label.n_NP = 'chem. index of nitrogen in faeces';  

% Derived from Bristow et al. 1992
par.mu_N = 518181;  free.mu_N = 0;  units.mu_N = 'J/ mol';  label.mu_N = 'chemical potential of N-waste'; 
par.n_HN = 2.216;   free.n_HN = 0;  units.n_HN = '-';       label.n_HN = 'chem. index of hydrogen in N-waste';
par.n_ON = 0.594;   free.n_ON = 0;  units.n_ON = '-';       label.n_ON = 'chem. index of oxygen in N-waste';
par.n_NN = 0.897;   free.n_NN = 0;  units.n_NN = '-';       label.n_NN = 'chem. index of nitrogen in N-waste';


% Estimate composition of reserve and structure
par.n_NE = 0.10;   free.n_NE = 1;  units.n_NE = '-';        label.n_NE = 'chem. index of nitrogen in reserve';
par.n_NV = 0.10;   free.n_NV = 1;  units.n_NV = '-';        label.n_NV = 'chem. index of nitrogen in structure';
% par.mu_E = 550000; free.mu_E = 1;  units.mu_E = 'J/ mol';   label.mu_E = 'chemical potential of reserve'; 
% par.mu_V = 500000; free.mu_V = 1;  units.mu_V = 'J/ mol';   label.mu_V = 'chemical potential of structure'; 

%% Pack output:
txtPar.units = units; txtPar.label = label; par.free = free; 

