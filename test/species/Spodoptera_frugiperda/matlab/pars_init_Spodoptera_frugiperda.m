function [par, metaPar, txtPar] = pars_init_Spodoptera_frugiperda(metaData)

metaPar.model = 'hex'; 

%% reference parameter (not to be changed) 
par.T_ref = 293.15;   free.T_ref = 0;   units.T_ref = 'K';        label.T_ref = 'Reference temperature'; 

%% core primary parameters 
par.T_A = 8355.6733;  free.T_A   = 1;   units.T_A = 'K';          label.T_A = 'Arrhenius temperature'; 
par.z = 0.89985;      free.z     = 1;   units.z = '-';            label.z = 'zoom factor'; 
par.F_m = 6.5;        free.F_m   = 0;   units.F_m = 'l/d.cm^2';   label.F_m = '{F_m}, max spec searching rate'; 
par.kap_X = 0.8;      free.kap_X = 0;   units.kap_X = '-';        label.kap_X = 'digestion efficiency of food to reserve'; 
par.kap_P = 0.1;      free.kap_P = 0;   units.kap_P = '-';        label.kap_P = 'faecation efficiency of food to faeces'; 
par.v = 0.01029;      free.v     = 1;   units.v = 'cm/d';         label.v = 'energy conductance'; 
par.kap = 0.78329;    free.kap   = 1;   units.kap = '-';          label.kap = 'allocation fraction to soma'; 
par.kap_R = 0.95;     free.kap_R = 0;   units.kap_R = '-';        label.kap_R = 'reproduction efficiency'; 
par.kap_V = 0.01;     free.kap_V = 0;   units.kap_V = '-';        label.kap_V = 'conversion efficient E -> V -> E'; 
par.p_M = 34.8023;    free.p_M   = 1;   units.p_M = 'J/d.cm^3';   label.p_M = '[p_M], vol-spec somatic maint'; 
par.p_T = 0;          free.p_T   = 0;   units.p_T = 'J/d.cm^2';   label.p_T = '{p_T}, surf-spec somatic maint'; 
par.k_J = 0.002;      free.k_J   = 0;   units.k_J = '1/d';        label.k_J = 'maturity maint rate coefficient'; 
par.E_G = 4400;       free.E_G   = 0;   units.E_G = 'J/cm^3';     label.E_G = '[E_G], spec cost for structure'; 
par.E_Hb = 1.926e-03; free.E_Hb  = 1;   units.E_Hb = 'J';         label.E_Hb = 'maturity at birth'; 
par.s_j = 0.9999;     free.s_j   = 0;   units.s_j = '-';          label.s_j = 'reprod buffer/structure at pupation as fraction of max'; 
par.E_He = 4.518e-01; free.E_He  = 1;   units.E_He = 'J';         label.E_He = 'maturity at emergence'; 
par.h_a = 3.270e-02;  free.h_a   = 1;   units.h_a = '1/d^2';      label.h_a = 'Weibull aging acceleration'; 
par.s_G = 0.0001;     free.s_G   = 0;   units.s_G = '-';          label.s_G = 'Gompertz stress coefficient'; 

%% other parameters 
par.T_A1 = 6668;      free.T_A1  = 0;   units.T_A1 = 'K';         label.T_A1 = 'Arrhenius temperature for 1st instar'; 
par.T_AH = 300000;    free.T_AH  = 0;   units.T_AH = 'K';         label.T_AH = 'Arrhenius temperature at lower boundary temperature'; 
par.T_AL = 17800;     free.T_AL  = 0;   units.T_AL = 'K';         label.T_AL = 'Arrhenius temperature at lower boundary temperature'; 
par.T_As = 12610;     free.T_As  = 0;   units.T_As = 'K';         label.T_As = 'Arrhenius temperature for larval mortality'; 
par.T_H = 304.6;      free.T_H   = 0;   units.T_H = 'K';          label.T_H = 'upper boundary temperature'; 
par.T_L = 289.4;      free.T_L   = 0;   units.T_L = 'K';          label.T_L = 'lower boundary temperature'; 
par.del_M = 0.37458;  free.del_M = 1;   units.del_M = '-';        label.del_M = 'shape coefficient for head capsule of larva'; 
par.f = 1;            free.f     = 0;   units.f = '-';            label.f = 'scaled functional response for 0-var data'; 
par.h_b = 0.026977;   free.h_b   = 1;   units.h_b = '1/d';        label.h_b = 'background hazard during larval stage'; 
par.s_1 = 3.1494;     free.s_1   = 1;   units.s_1 = '-';          label.s_1 = 'stress at instar 1: L_1^2/ L_b^2'; 
par.s_2 = 2.2664;     free.s_2   = 1;   units.s_2 = '-';          label.s_2 = 'stress at instar 2: L_2^2/ L_1^2'; 
par.s_3 = 2.2905;     free.s_3   = 1;   units.s_3 = '-';          label.s_3 = 'stress at instar 3: L_3^2/ L_2^2'; 
par.s_4 = 2.6563;     free.s_4   = 1;   units.s_4 = '-';          label.s_4 = 'stress at instar 4: L_4^2/ L_3^2'; 
par.s_5 = 2.891;      free.s_5   = 1;   units.s_5 = '-';          label.s_5 = 'stress at instar 5: L_5^2/ L_4^2'; 

%% set chemical parameters from Kooy2010 
[par, units, label, free] = addchem(par, units, label, free, metaData.phylum, metaData.class); 

%% Pack output: 
txtPar.units = units; txtPar.label = label; par.free = free; 
