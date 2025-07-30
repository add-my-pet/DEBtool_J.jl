function [par, metaPar, txtPar] = pars_init_Chortoicetes_terminifera(metaData)

metaPar.model = 'abp'; 

%% reference parameter (not to be changed) 
par.T_ref = 293.15;   free.T_ref = 0;   units.T_ref = 'K';        label.T_ref = 'Reference temperature'; 

%% core primary parameters 
par.T_A = 12545.34;   free.T_A   = 0;   units.T_A = 'K';          label.T_A = 'Arrhenius temperature'; 
par.z = 4.671;        free.z     = 1;   units.z = '-';            label.z = 'zoom factor'; 
par.F_m = 6.5;        free.F_m   = 0;   units.F_m = 'l/d.cm^2';   label.F_m = '{F_m}, max spec searching rate'; 
par.kap_X = 0.8;      free.kap_X = 0;   units.kap_X = '-';        label.kap_X = 'digestion efficiency of food to reserve'; 
par.kap_P = 0.1;      free.kap_P = 0;   units.kap_P = '-';        label.kap_P = 'faecation efficiency of food to faeces'; 
par.v = 0.01051;      free.v     = 1;   units.v = 'cm/d';         label.v = 'energy conductance'; 
par.kap = 0.8756;     free.kap   = 1;   units.kap = '-';          label.kap = 'allocation fraction to soma'; 
par.kap_R = 0.95;     free.kap_R = 0;   units.kap_R = '-';        label.kap_R = 'reproduction efficiency'; 
par.p_M = 17.4;       free.p_M   = 1;   units.p_M = 'J/d.cm^3';   label.p_M = '[p_M], vol-spec somatic maint'; 
par.p_T = 0;          free.p_T   = 0;   units.p_T = 'J/d.cm^2';   label.p_T = '{p_T}, surf-spec somatic maint'; 
par.k_J = 0.002;      free.k_J   = 0;   units.k_J = '1/d';        label.k_J = 'maturity maint rate coefficient'; 
par.E_G = 6523;       free.E_G   = 1;   units.E_G = 'J/cm^3';     label.E_G = '[E_G], spec cost for structure'; 
par.E_Hb = 1.518;     free.E_Hb  = 1;   units.E_Hb = 'J';         label.E_Hb = 'maturity at birth'; 
par.E_Hp = 163.4;     free.E_Hp  = 1;   units.E_Hp = 'J';         label.E_Hp = 'maturity at puberty'; 
par.h_a = 1.898e-05;  free.h_a   = 1;   units.h_a = '1/d^2';      label.h_a = 'Weibull aging acceleration'; 
par.s_G = 0.0001;     free.s_G   = 0;   units.s_G = '-';          label.s_G = 'Gompertz stress coefficient'; 

%% other parameters 
par.T_A0 = 10597.34;  free.T_A0  = 0;   units.T_A0 = 'K';         label.T_A0 = 'Arrhenius temperature egg'; 
par.T_A5 = 13777.3;   free.T_A5  = 0;   units.T_A5 = 'K';         label.T_A5 = 'Arrhenius temperature 5th instar and higher'; 
par.T_AH = 16000;     free.T_AH  = 0;   units.T_AH = 'K';         label.T_AH = 'Arrhenius temperature at upper boundary'; 
par.T_AH0 = 16000;    free.T_AH0 = 0;   units.T_AH0 = 'K';        label.T_AH0 = 'Arrhenius temperature at upper boundary egg'; 
par.T_AH5 = 16000;    free.T_AH5 = 0;   units.T_AH5 = 'K';        label.T_AH5 = 'Arrhenius temperature at upper boundary 5th instar and higher'; 
par.T_AL = 18720;     free.T_AL  = 0;   units.T_AL = 'K';         label.T_AL = 'Arrhenius temperature at lower boundary'; 
par.T_H = 310.06;     free.T_H   = 0;   units.T_H = 'K';          label.T_H = 'upper boundary'; 
par.T_H0 = 311.15;    free.T_H0  = 0;   units.T_H0 = 'K';         label.T_H0 = 'upper boundary egg'; 
par.T_H5 = 308.15;    free.T_H5  = 0;   units.T_H5 = 'K';         label.T_H5 = 'upper boundary 5th instar and higher'; 
par.T_L = 261.15;     free.T_L   = 0;   units.T_L = 'K';          label.T_L = 'lower boundary'; 
par.del_M = 0.1744;   free.del_M = 1;   units.del_M = '-';        label.del_M = 'shape coefficient'; 
par.f = 1;            free.f     = 0;   units.f = '-';            label.f = 'scaled functional response for 0-var data'; 
par.s_1 = 1.788;      free.s_1   = 1;   units.s_1 = '-';          label.s_1 = 'stress at instar 1: L_1^2/ L_b^2'; 
%par.s_2 = 1.5374;     free.s_2   = 1;   units.s_2 = '-';          label.s_2 = 'stress at instar 1: L_2^2/ L_1^2'; 
%par.s_3 = 1.6226;     free.s_3   = 1;   units.s_3 = '-';          label.s_3 = 'stress at instar 1: L_3^2/ L_2^2'; 
%par.s_4 = 2.2073;     free.s_4   = 1;   units.s_4 = '-';          label.s_4 = 'stress at instar 1: L_4^2/ L_3^2'; 
par.t_0 = 1;     free.t_0   = 0;   units.t_0 = 'd';          label.t_0 = 'time of start development at 20 C'; 

%% set chemical parameters from Kooy2010 
[par, units, label, free] = addchem(par, units, label, free, metaData.phylum, metaData.class); 
par.d_V = 0.25;       free.d_V   = 0;   units.d_V = 'g/cm^3';     label.d_V = 'specific density of structure'; 
par.d_E = 0.25;       free.d_E   = 0;   units.d_E = 'g/cm^3';     label.d_E = 'specific density of reserve'; 

%% Pack output: 
txtPar.units = units; txtPar.label = label; par.free = free; 
