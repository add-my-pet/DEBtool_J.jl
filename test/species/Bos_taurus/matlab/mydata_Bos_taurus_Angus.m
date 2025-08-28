
% The data was obtained with funding by Fundo Europeu de Desenvolvimento Regional through project 
% ‘‘GreenBeef - Towards carbon neutral Angus beef production in Portugal’’ (POCI-01-0247-FEDER-047050)."

function [data, auxData, metaData, txtData, weights] = mydata_Bos_taurus_Angus

%% set metaData
metaData.phylum     = 'Chordata';
metaData.class      = 'Mammalia';
metaData.order      = 'Artiodactyla';
metaData.family     = 'Bovidae';
metaData.species    = 'Bos_taurus_Angus';
metaData.species_en = 'Angus cattle';
metaData.T_typical  = C2K(38.6);
metaData.data_0     = {};
metaData.data_1     = {};

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Diogo Oliveira', 'Goncalo Marques'};
% metaData.date_subm = [2024 02 02];
% metaData.email    = {''};
% metaData.address  = {''};

%% Group data
% Both
data.ab = 282.5;        units.ab = 'd';     label.ab = 'age at birth';    bibkey.ab = 'LiveBee1945';
data.am = 32.5*365;     units.am = 'd';     label.am = 'life span';                         bibkey.am = 'DakaMart2006';
data.Ri  =  1/436.7;    units.Ri  = '#/d';  label.Ri  = 'maximum reprod rate';  bibkey.Ri  = 'Bastos2022'; comment.Ri = 'inverse of the interval between parturitions';

% Females
data.tx_f = 200;        units.tx_f = 'd';   label.tx_f = 'time since birth at weaning for females'; bibkey.tx_f = 'Bastos2022';  
data.tp_f = 307;        units.tp_f = 'd';   label.tp_f = 'time since birth at puberty for females'; bibkey.tp_f = 'BeltButt1992';

data.Lhi_f = 135;       units.Lhi_f = 'cm'; label.Lhi_f = 'ultimate withers height for females';   bibkey.Lhi_f = 'FAO2024';

data.Wwb_f = 34.9e3;    units.Wwb_f = 'g';  label.Wwb_f = 'wet weight at birth for females'; bibkey.Wwb_f = 'Bastos2022';
data.Wwx_f = 251.2e3;   units.Wwx_f = 'g';  label.Wwx_f = 'wet weight at weaning for females'; bibkey.Wwx_f = 'Bastos2022';
data.Wwp_f = 301.5e3;   units.Wwp_f = 'g';  label.Wwp_f = 'wet weight at puberty for males'; bibkey.Wwp_f = 'Bastos2022';
data.Wwi_f = 650e3;     units.Wwi_f = 'g';  label.Wwi_f = 'ultimate wet weight for females';   bibkey.Wwi_f = 'FAO2024';

% Males
data.tx_m = 200;        units.tx_m = 'd';   label.tx_m = 'time since birth at weaning for males'; bibkey.tx_m = 'Bastos2022'; 
data.tp_m = 295;        units.tp_m = 'd';   label.tp_m = 'time since birth at puberty for males'; bibkey.tp_m = 'Luns1982';

data.Lhi_m = 145;       units.Lhi_m = 'cm'; label.Lhi_m = 'ultimate withers height for males';   bibkey.Lhi_m = 'FAO2024';

data.Wwb_m = 37.4e3;    units.Wwb_m = 'g';  label.Wwb_m = 'wet weight at birth for males';      bibkey.Wwb_m = 'Bastos2022';
data.Wwx_m = 264.1e3;   units.Wwx_m = 'g';  label.Wwx_m = 'wet weight at weaning for males';    bibkey.Wwx_m = 'Bastos2022';
data.Wwp_m = 374.1e3;   units.Wwp_m = 'g';  label.Wwp_m = 'wet weight at puberty for males';    bibkey.Wwp_m = 'Bastos2022';
data.Wwi_m = 1000e3;    units.Wwi_m = 'g';  label.Wwi_m = 'ultimate wet weight for males';      bibkey.Wwi_m = 'FAO2024';


%% Fetal development
data.tWwe_Mao = [90 0.22; 180 8.70; 270 34.17;]; 
data.tWwe_Mao(:, 2) = data.tWwe_Mao(:, 2) * 1000; % Convert 'kg' to 'g 
units.tWwe_Mao = {'d', 'g'}; label.tWwe_Mao = {'Gestation day', 'Fetal wet weight'}; bibkey.tWwe_Mao = 'Mao2008';
comment.tWwe_Mao = 'Data is from German Angus, a breed which is Aberdeen-Angus crossbred with German breeds';

data.tWwe_Anthony = [200 9.2; 200 11.0; 215 15.8; 215 15.0; 230 18.8; 230 22.0; 245 24.3; 245 28.8; 260 29.9; 260 32.7; 278 32.7; 278 35.4];
data.tWwe_Anthony(:, 2) = data.tWwe_Anthony(:, 2) * 1000; % Convert 'kg' to 'g 
units.tWwe_Anthony = {'d', 'g'}; label.tWwe_Anthony = {'Gestation day', 'Fetal wet weight'}; bibkey.tWwe_Anthony = 'Anthony1986';
comment.tWwe_Anthony = 'Data is from crossbred animals with Angus sires, one with low birth weight genetic value and another with high genetic value';


%% Herd et al. 2019 data from RFI Trial
data.DMD_Herd19_RFI = 0.696; 
units.DMD_Herd19_RFI = '-'; label.DMD_Herd19_RFI = 'dry matter digestibility of feed'; bibkey.DMD_Herd19_RFI = 'Herd2019'; 
comment.DMD_Herd19_RFI = 'Data from RFI trial';

data.tW_Herd19_RFI = [0 410; 35 454; 70 504];
units.tW_Herd19_RFI = {'d', 'kg'}; label.tW_Herd19_RFI = {'time since start', 'weight'}; bibkey.tW_Herd19_RFI = 'Herd2019';
comment.tW_Herd19_RFI = 'Data from RFI trial';
init.tW_Herd19_RFI = 410; units.init.tW_Herd19_RFI = 'kg'; label.init.tW_Herd19_RFI = 'Initial weight';

data.DMI_Herd19_RFI = 12.0;
units.DMI_Herd19_RFI = 'kg/d'; label.DMI_Herd19_RFI = 'dry matter intake per day'; bibkey.DMI_Herd19_RFI = 'Herd2019';
comment.DMI_Herd19_RFI = 'Data from RFI trial';
init.DMI_Herd19_RFI = 410; units.init.DMI_Herd19_RFI = 'kg'; label.init.DMI_Herd19_RFI = 'Initial weight';

data.FCR_Herd19_RFI = 8.9;
units.FCR_Herd19_RFI = '-'; label.FCR_Herd19_RFI = 'Feed conversion ratio'; bibkey.FCR_Herd19_RFI = 'Herd2019';
comment.FCR_Herd19_RFI = 'Data from RFI trial';
init.FCR_Herd19_RFI = 410; units.init.FCR_Herd19_RFI = 'kg'; label.init.FCR_Herd19_RFI = 'Initial weight';

data.MPR_Herd19_RFI = 144;
units.MPR_Herd19_RFI = 'g/d'; label.MPR_Herd19_RFI = ''; bibkey.MPR_Herd19_RFI = 'Herd2019';
comment.MPR_Herd19_RFI = 'Data from RFI trial';
init.MPR_Herd19_RFI = 410; units.init.MPR_Herd19_RFI = 'kg'; label.init.MPR_Herd19_RFI = 'Initial weight';

data.MY_Herd19_RFI = 12;
units.MY_Herd19_RFI = 'g/kg'; label.MY_Herd19_RFI = ''; bibkey.MY_Herd19_RFI = 'Herd2019';
comment.MY_Herd19_RFI = 'Data from RFI trial';
init.MY_Herd19_RFI = 410; units.init.MY_Herd19_RFI = 'kg'; label.init.MY_Herd19_RFI = 'Initial weight';


%% Herd et al. 2019 data from HP Trial
data.DMD_Herd19_HP = 0.712; 
units.DMD_Herd19_HP = '-'; label.DMD_Herd19_HP = 'dry matter digestibility of feed'; bibkey.DMD_Herd19_HP = 'Herd2019'; 
comment.DMD_Herd19_HP = 'Data from RFI trial';

data.DMI_Herd19_HP = 7.59;
units.DMI_Herd19_HP = 'g/d'; label.DMI_Herd19_HP = 'dry matter intake per day'; bibkey.DMI_Herd19_HP = 'Herd2019';
comment.DMI_Herd19_HP = 'Data from HP trial';
init.DMI_Herd19_HP = 544; units.init.DMI_Herd19_HP = 'kg'; label.init.DMI_Herd19_HP = 'Initial weight';

data.MPR_Herd19_HP = 144;
units.MPR_Herd19_HP = 'g/d'; label.MPR_Herd19_HP = ''; bibkey.MPR_Herd19_HP = 'Herd2019';
comment.MPR_Herd19_HP = 'Data from HP trial';
init.MPR_Herd19_HP = 544; units.init.MPR_Herd19_HP = 'kg'; label.init.MPR_Herd19_HP = 'Initial weight';

data.MY_Herd19_HP = 19;
units.MY_Herd19_HP = 'g/kg'; label.MY_Herd19_HP = ''; bibkey.MY_Herd19_HP = 'Herd2019';
comment.MY_Herd19_HP = 'Data from HP trial';
init.MY_Herd19_HP = 544; units.init.MY_Herd19_HP = 'kg'; label.init.MY_Herd19_HP = 'Initial weight';

data.CPR_Fed_Herd19_HP = 4399;
units.CPR_Fed_Herd19_HP = 'g/d'; label.CPR_Fed_Herd19_HP = ''; bibkey.CPR_Fed_Herd19_HP = 'Herd2019';
comment.CPR_Fed_Herd19_HP = 'Data from HP trial';
init.CPR_Fed_Herd19_HP = 544; units.init.CPR_Fed_Herd19_HP = 'kg'; label.init.CPR_Fed_Herd19_HP = 'Initial weight';

data.CPR_Unfed_Herd19_HP = 3027;
units.CPR_Unfed_Herd19_HP = '-'; label.CPR_Unfed_Herd19_HP = ''; bibkey.CPR_Unfed_Herd19_HP = 'Herd2019';
comment.CPR_Unfed_Herd19_HP = 'Data from HP trial';
init.CPR_Unfed_Herd19_HP = 544; units.init.CPR_Unfed_Herd19_HP = 'kg'; label.init.CPR_Unfed_Herd19_HP = 'Initial weight';

%% Bunting et al. 1989, data from high protein diet
data.DMI_Bunt89_HighProt = 4200;
units.DMI_Bunt89_HighProt = '-'; label.DMI_Bunt89_HighProt = 'dry matter intake per day'; bibkey.DMI_Bunt89_HighProt = 'Bunt89';
comment.DMI_Bunt89_HighProt = 'Data from Bunt89_HighProt trial, high protein diet.';
init.DMI_Bunt89_HighProt = 234; units.init.DMI_Bunt89_HighProt = 'kg'; label.init.DMI_Bunt89_HighProt = 'Initial weight';

data.DMD_Bunt89_HighProt = 0.835;
units.DMD_Bunt89_HighProt = '-'; label.DMD_Bunt89_HighProt = 'dry matter digestibility of feed'; bibkey.DMD_Bunt89_HighProt = 'Bunt89';
comment.DMD_Bunt89_HighProt = 'Data from Bunt89_HighProt trial, high protein diet.';
init.DMD_Bunt89_HighProt = 234; units.init.DMD_Bunt89_HighProt = 'kg'; label.init.DMD_Bunt89_HighProt = 'Initial weight';

data.N_intake_Bunt89_HighProt = 126.1;
units.N_intake_Bunt89_HighProt = 'g/d'; label.N_intake_Bunt89_HighProt = 'Nitrogen intake per day'; bibkey.N_intake_Bunt89_HighProt = 'Bunt89';
comment.N_intake_Bunt89_HighProt = 'Data from Bunt89_HighProt trial, high protein diet.';
init.N_intake_Bunt89_HighProt = 234; units.init.N_intake_Bunt89_HighProt = 'kg'; label.init.N_intake_Bunt89_HighProt = 'Initial weight';

data.N_feces_Bunt89_HighProt = 22.1;
units.N_feces_Bunt89_HighProt = 'g/d'; label.N_feces_Bunt89_HighProt = 'Nitrogen excreted in the form of feces per day'; bibkey.N_feces_Bunt89_HighProt = 'Bunt89';
comment.N_feces_Bunt89_HighProt = 'Data from Bunt89_HighProt trial, high protein diet.';
init.N_feces_Bunt89_HighProt = 234; units.init.N_feces_Bunt89_HighProt = 'kg'; label.init.N_feces_Bunt89_HighProt = 'Initial weight';

data.N_urine_Bunt89_HighProt = 47.1;
units.N_urine_Bunt89_HighProt = 'g/d'; label.N_urine_Bunt89_HighProt = 'Nitrogen excreted in the form of urine per day'; bibkey.N_urine_Bunt89_HighProt = 'Bunt89';
comment.N_urine_Bunt89_HighProt = 'Data from Bunt89_HighProt trial, high protein diet.';
init.N_urine_Bunt89_HighProt = 234; units.init.N_urine_Bunt89_HighProt = 'kg'; label.init.N_urine_Bunt89_HighProt = 'Initial weight';

data.N_retention_Bunt89_HighProt = 56.9;
units.N_retention_Bunt89_HighProt = 'g/d'; label.N_retention_Bunt89_HighProt = 'Nitrogen retention per day'; bibkey.N_retention_Bunt89_HighProt = 'Bunt89';
comment.N_retention_Bunt89_HighProt = 'Data from Bunt89_HighProt trial, high protein diet.';
init.N_retention_Bunt89_HighProt = 234; units.init.N_retention_Bunt89_HighProt = 'kg'; label.init.N_retention_Bunt89_HighProt = 'Initial weight';

%% Bunting et al. 1989, data from low protein diet
data.DMI_Bunt89_LowProt = 4065;
units.DMI_Bunt89_LowProt = '-'; label.DMI_Bunt89_LowProt = 'dry matter intake per day'; bibkey.DMI_Bunt89_LowProt = 'Bunt89';
comment.DMI_Bunt89_LowProt = 'Data from Bunt89_LowProt trial, low protein diet.';
init.DMI_Bunt89_LowProt = 234; units.init.DMI_Bunt89_LowProt = 'kg'; label.init.DMI_Bunt89_LowProt = 'Initial weight';

data.DMD_Bunt89_LowProt = 0.823;
units.DMD_Bunt89_LowProt = '-'; label.DMD_Bunt89_LowProt = 'dry matter digestibility of feed'; bibkey.DMD_Bunt89_LowProt = 'Bunt89';
comment.DMD_Bunt89_LowProt = 'Data from Bunt89_LowProt trial, low protein diet.';
init.DMD_Bunt89_LowProt = 234; units.init.DMD_Bunt89_LowProt = 'kg'; label.init.DMD_Bunt89_LowProt = 'Initial weight';

data.N_intake_Bunt89_LowProt = 66.5;
units.N_intake_Bunt89_LowProt = 'g/d'; label.N_intake_Bunt89_LowProt = 'Nitrogen intake per day'; bibkey.N_intake_Bunt89_LowProt = 'Bunt89';
comment.N_intake_Bunt89_LowProt = 'Data from Bunt89_LowProt trial, low protein diet.';
init.N_intake_Bunt89_LowProt = 234; units.init.N_intake_Bunt89_LowProt = 'kg'; label.init.N_intake_Bunt89_LowProt = 'Initial weight';

data.N_feces_Bunt89_LowProt = 19.2;
units.N_feces_Bunt89_LowProt = 'g/d'; label.N_feces_Bunt89_LowProt = 'Nitrogen excreted in the form of feces per day'; bibkey.N_feces_Bunt89_LowProt = 'Bunt89';
comment.N_feces_Bunt89_LowProt = 'Data from Bunt89_LowProt trial, low protein diet.';
init.N_feces_Bunt89_LowProt = 234; units.init.N_feces_Bunt89_LowProt = 'kg'; label.init.N_feces_Bunt89_LowProt = 'Initial weight';

data.N_urine_Bunt89_LowProt = 22.3;
units.N_urine_Bunt89_LowProt = 'g/d'; label.N_urine_Bunt89_LowProt = 'Nitrogen excreted in the form of urine per day'; bibkey.N_urine_Bunt89_LowProt = 'Bunt89';
comment.N_urine_Bunt89_LowProt = 'Data from Bunt89_LowProt trial, low protein diet.';
init.N_urine_Bunt89_LowProt = 234; units.init.N_urine_Bunt89_LowProt = 'kg'; label.init.N_urine_Bunt89_LowProt = 'Initial weight';

data.N_retention_Bunt89_LowProt = 25.1;
units.N_retention_Bunt89_LowProt = 'g/d'; label.N_retention_Bunt89_LowProt = 'Nitrogen retention per day'; bibkey.N_retention_Bunt89_LowProt = 'Bunt89';
comment.N_retention_Bunt89_LowProt = 'Data from Bunt89_LowProt trial, low protein diet.';
init.N_retention_Bunt89_LowProt = 234; units.init.N_retention_Bunt89_LowProt = 'kg'; label.init.N_retention_Bunt89_LowProt = 'Initial weight';

%% IPCC approximations

% Nitrogen excretion and retention for females
IPCC_data_weight_values = linspace(data.Wwp_f, 0.75*data.Wwi_f)/1e3; % kg
IPCC_N_out = 0.42 .* IPCC_data_weight_values ./ 1e3; 

data.WN_feces_females = [IPCC_data_weight_values' IPCC_N_out'./2];
units.WN_feces_females = {'kg', 'kg N/d'}; label.WN_feces_females = {'Weight', 'Nitrogen excretion rate in feces'}; bibkey.WN_feces_females = 'IPCC';
comment.WN_feces_females = '50% of IPCC Tier 1 approximation for N excretion rate';

data.WN_urine_females = [IPCC_data_weight_values' IPCC_N_out'./2];
units.WN_urine_females = {'kg', 'kg N/d'}; label.WN_urine_females = {'Weight', 'Nitrogen excretion rate in urine'}; bibkey.WN_urine_females = 'IPCC';
comment.WN_urine_females = '50% of IPCC Tier 1 approximation for N excretion rate';

weight_gain = 1.0; %kg/d
net_energy_for_growth = 22.02 .* (IPCC_data_weight_values ./ 0.8 ./ (data.Wwi_f / 1e3)).^0.75 * weight_gain^1.097;
IPCC_WN_ret = weight_gain * (268 - 7.03 * net_energy_for_growth / weight_gain) / 1000 / 6.25;

data.WN_ret_females = [IPCC_data_weight_values' IPCC_WN_ret'];
units.WN_ret_females = {'kg', 'kg N/d'}; label.WN_ret_females = {'Weight', 'Nitrogen retention rate'}; bibkey.WN_ret_females = 'IPCC';
comment.WN_ret_females = 'IPCC Tier 2 approximation for N retention';

% Nitrogen excretion and retention for males
IPCC_data_weight_values = linspace(data.Wwp_m, 0.75*data.Wwi_m)/1e3; % kg
IPCC_N_out = 0.42 .* IPCC_data_weight_values ./ 1e3; 

data.WN_feces_males = [IPCC_data_weight_values' IPCC_N_out'./2];
units.WN_feces_males = {'kg', 'kg N/d'}; label.WN_feces_males = {'Weight', 'Nitrogen excretion rate in feces'}; bibkey.WN_feces_males = 'IPCC';
comment.WN_feces_males = '50% of IPCC Tier 1 approximation for N excretion rate';

data.WN_urine_males = [IPCC_data_weight_values' IPCC_N_out'./2];
units.WN_urine_males = {'kg', 'kg N/d'}; label.WN_urine_males = {'Weight', 'Nitrogen excretion rate in urine'}; bibkey.WN_urine_males = 'IPCC';
comment.WN_urine_males = '50% of IPCC Tier 1 approximation for N excretion rate';

weight_gain = 1.3; %kg/d
net_energy_for_growth = 22.02 .* (IPCC_data_weight_values ./ 1 ./ (data.Wwi_m / 1e3)).^0.75 * weight_gain^1.097;
IPCC_WN_ret = weight_gain * (268 - 7.03 * net_energy_for_growth / weight_gain) / 1000 / 6.25;

data.WN_ret_males = [IPCC_data_weight_values' IPCC_WN_ret'];
units.WN_ret_males = {'kg', 'kg N/d'}; label.WN_ret_males = {'Weight', 'Nitrogen retention rate'}; bibkey.WN_ret_males = 'IPCC';
comment.WN_ret_males = 'IPCC Tier 2 approximation for N retention';



%% Time vs Group daily feed consumption data

data.tJX_grp_T1_2 = [0 45.43; 1 43.88; 2 26.68; 3 46.87; 4 40.24; 5 41.11; 6 41.15; 7 44.57; 8 45.67; 9 47.08; 10 41.6; 11 33.54; 12 47.22; 13 40.4; 14 38.04; 15 40.91; 16 36.2; 17 38.47; 18 38.95; 19 38.89; 20 40.95; 21 30.58; 22 37.61; 23 48.26; 24 41.03; 25 44.06; 26 43.23; 27 47.73; 28 41.82; 29 43.78; 30 29.79; 31 37.26; 32 29.83; 33 39.34; 34 45.31; 35 36.18; 36 44.02; 37 41.3; 38 43.11; 39 49.12; 40 42.88; 41 41.72; 42 45.65; 43 45.49; 44 44.04; 45 47.26; 46 45.33; 47 49.18; 48 46.08; 49 45.88; 50 47.81; 51 48.36; 52 50.03; 53 51.46; 54 44.68; 55 44.68; 56 39.02; 57 41.58; 58 48.02; 59 42.64; 60 48.65; 61 48.65; 62 45.12; 63 45.12; 64 48.69; 65 55.53; 66 48.89; 67 50.85; 68 54.41; 69 43.74; 70 43.74; 71 53.53; 72 56.51; 73 52.39; 74 54.31; 75 48.46; 76 56.28; 77 57.18; 78 55.06; 79 51.8; 80 59.42; 81 53.68; 82 56.02; 83 56.02];
init.tJX_grp_T1_2 = struct('PT424401157', 469, 'PT433843806', 507, 'PT624139868', 464, 'PT833653644', 548, 'PT933843912', 545); units.init.tJX_grp_T1_2 = {'kg'}; label.init.tJX_grp_T1_2 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T1_2 = {'d', 'kg'}; label.tJX_grp_T1_2 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T1_2 = 'Daily feed consumption of pen T1_2'; comment.tJX_grp_T1_2 = 'Data from GreenBeef trial 1, pen T1_2'; bibkey.tJX_grp_T1_2 = 'GreenBeefTrial1';

data.tJX_grp_T1_3 = [0 44.62; 1 44.22; 2 49.87; 3 51.94; 4 50.32; 5 48.06; 6 50.56; 7 43.44; 8 44.01; 9 44.13; 10 45.3; 11 46.98; 12 46.89; 13 48.1; 14 43.96; 15 44.82; 16 49.82; 17 49.13; 18 49.63; 19 46.79; 20 57.49; 21 45.73; 22 45.38; 23 53.4; 24 47.63; 25 53.92; 26 48.62; 27 43.62; 28 51.38; 29 46.98; 30 45.08; 31 52.75; 32 49.09; 33 46.85; 34 47.37; 35 54.65; 36 45.94; 37 47.15; 38 49.74; 39 52.24; 40 50.86; 41 53.62; 42 53.62; 43 56.46; 44 54.56; 45 53.27; 46 54.22; 47 56.37; 48 57.15; 49 52.06; 50 55.25; 51 62.5; 52 62.06; 53 56.63; 54 57.67; 55 57.67; 56 57.58; 57 56.2; 58 55.34; 59 55.17; 60 59.48; 61 59.48; 62 64.91; 63 64.91; 64 50.94; 65 51.89; 66 53.96; 67 60.25; 68 49.69; 69 52.41; 70 52.41; 71 55.43; 72 62.32; 73 56.12; 74 56.29; 75 56.37; 76 57.15; 77 58.44; 78 55.6; 79 52.06; 80 56.72; 81 55.25; 82 55.99; 83 55.99];
init.tJX_grp_T1_3 = struct('PT333842562', 515, 'PT524401180', 496, 'PT533987885', 436, 'PT833653649', 535, 'PT933843894', 508); units.init.tJX_grp_T1_3 = {'kg'}; label.init.tJX_grp_T1_3 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T1_3 = {'d', 'kg'}; label.tJX_grp_T1_3 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T1_3 = 'Daily feed consumption of pen T1_3'; comment.tJX_grp_T1_3 = 'Data from GreenBeef trial 1, pen T1_3'; bibkey.tJX_grp_T1_3 = 'GreenBeefTrial1';

data.tJX_grp_T1_4 = [0 45.31; 1 46.38; 2 50.99; 3 50.73; 4 49.98; 5 53.4; 6 48.49; 7 48.1; 8 50.04; 9 49.82; 10 47.02; 11 45.17; 12 49.82; 13 47.07; 14 46.72; 15 45.43; 16 47.58; 17 46.2; 18 48.43; 19 43.6; 20 57.75; 21 51.5; 22 50.64; 23 60.38; 24 51.42; 25 56.16; 26 54.31; 27 55.86; 28 53.79; 29 49.39; 30 49.22; 31 55.94; 32 53.4; 33 52.88; 34 47.28; 35 56.2; 36 58.18; 37 54.39; 38 53.7; 39 61.2; 40 56.03; 41 54.22; 42 53.36; 43 54.65; 44 47.93; 45 50.25; 46 51.98; 47 54.74; 48 55.86; 49 53.36; 50 54.65; 51 62.84; 52 66.72; 53 57.88; 54 56.72; 55 56.72; 56 55.17; 57 58.44; 58 55.34; 59 56.63; 60 65.77; 61 65.77; 62 54.82; 63 54.82; 64 60.08; 65 55.51; 66 65.08; 67 60.86; 68 58.92; 69 60.94; 70 60.94; 71 52.32; 72 52.24; 73 52.06; 74 50.08; 75 54.82; 76 57.58; 77 56.81; 78 58.27; 79 59.39; 80 56.37; 81 62.93; 82 59.74; 83 59.74];
init.tJX_grp_T1_4 = struct('PT224401177', 562, 'PT524956505', 542, 'PT533843896', 480, 'PT924401183', 510, 'PT933602927', 426); units.init.tJX_grp_T1_4 = {'kg'}; label.init.tJX_grp_T1_4 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T1_4 = {'d', 'kg'}; label.tJX_grp_T1_4 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T1_4 = 'Daily feed consumption of pen T1_4'; comment.tJX_grp_T1_4 = 'Data from GreenBeef trial 1, pen T1_4'; bibkey.tJX_grp_T1_4 = 'GreenBeefTrial1';

data.tJX_grp_T1_5 = [0 50.54; 1 49.18; 2 54.16; 3 50.4; 4 44.68; 5 46.69; 6 54.78; 7 52.23; 8 49.56; 9 52.82; 10 51.15; 11 36.73; 12 46.9; 13 40.68; 14 40.71; 15 43.31; 16 50.74; 17 43.98; 18 44.84; 19 50.21; 20 51.84; 21 33.68; 22 45.75; 23 43.31; 24 41.66; 25 50.81; 26 46.53; 27 47.02; 28 50.54; 29 42.52; 30 28.06; 31 41.5; 32 39.5; 33 41.42; 34 38.32; 35 40.07; 36 40.48; 37 37.73; 38 38.55; 39 43.31; 40 41.5; 41 46.63; 42 43.37; 43 51.62; 44 37.83; 45 49.38; 46 45.57; 47 49.42; 48 40.54; 49 43.49; 50 39.56; 51 43.29; 52 43.23; 53 47.51; 54 45.82; 55 45.82; 56 52.58; 57 51.76; 58 43.07; 59 53.37; 60 53.68; 61 53.68; 62 52.31; 63 52.31; 64 56.4; 65 50.15; 66 56.28; 67 54.39; 68 55.59; 69 49.16; 70 49.16; 71 55.49; 72 57.54; 73 55.22; 74 53.57; 75 52.54; 76 56.79; 77 48.34; 78 49.64; 79 42.56; 80 48.77; 81 42.09; 82 48.34; 83 48.34];
init.tJX_grp_T1_5 = struct('PT033634130', 453, 'PT233843883', 506, 'PT333653651', 536, 'PT533358890', 477, 'PT724523831', 485); units.init.tJX_grp_T1_5 = {'kg'}; label.init.tJX_grp_T1_5 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T1_5 = {'d', 'kg'}; label.tJX_grp_T1_5 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T1_5 = 'Daily feed consumption of pen T1_5'; comment.tJX_grp_T1_5 = 'Data from GreenBeef trial 1, pen T1_5'; bibkey.tJX_grp_T1_5 = 'GreenBeefTrial1';


%% Time vs Group daily feed consumption data

data.tJX_grp_T2_2 = [1 35.43; 2 40.9; 3 39.07; 4 43.93; 5 35.93; 6 34.01; 7 36.12; 8 33.21; 9 43.2; 10 43.89; 11 44.62; 12 42.78; 13 38.99; 14 38.91; 15 41.63; 16 42.59; 17 39.41; 18 38.68; 19 46.8; 20 40.98; 21 42.05; 22 31.98; 23 38.72; 24 34.97; 25 30.68; 26 31.79; 27 34.78; 28 42.36; 29 40.9; 30 36.61; 31 40.41; 32 42.93; 33 42.97; 34 37.5; 35 35.81; 36 31.79; 37 35.04; 38 40.6; 39 36.46; 40 40.44; 41 43.39; 42 45.69; 43 32.44; 44 40.75; 45 47.15; 46 40.37; 47 35.43; 48 38.72; 49 36.61; 50 31.52; 51 25.78; 52 32.59; 53 27.69; 54 33.63; 55 37.19; 56 40.75; 57 34.58; 58 42.09; 59 33.59; 60 31.52; 61 33.97];
init.tJX_grp_T2_2 = struct('PT334023118', 587, 'PT433677425', 475, 'PT434164528', 450, 'PT733677452', 458, 'PT733677556', 477); units.init.tJX_grp_T2_2 = {'kg'}; label.init.tJX_grp_T2_2 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T2_2 = {'d', 'kg'}; label.tJX_grp_T2_2 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T2_2 = 'Daily feed consumption of pen T2_2'; comment.tJX_grp_T2_2 = 'Data from GreenBeef trial 2, pen T2_2'; bibkey.tJX_grp_T2_2 = 'GreenBeefTrial2';

data.tJX_grp_T2_3 = [1 48.45; 2 42.45; 3 43.67; 4 49.24; 5 41.51; 6 48.84; 7 42.96; 8 46.18; 9 51.39; 10 49.51; 11 51.47; 12 50.57; 13 49.67; 14 46.33; 15 51.74; 16 47.0; 17 52.76; 18 52.65; 19 49.12; 20 40.96; 21 44.81; 22 47.51; 23 45.35; 24 48.29; 25 48.06; 26 45.16; 27 42.53; 28 43.79; 29 34.42; 30 39.12; 31 44.26; 32 45.55; 33 41.04; 34 39.47; 35 42.96; 36 48.02; 37 45.55; 38 49.12; 39 41.16; 40 48.95; 41 50.22; 42 47.71; 43 43.08; 44 46.3; 45 50.45; 46 45.82; 47 50.29; 48 47.2; 49 49.47; 50 48.33; 51 41.43; 52 48.69; 53 44.06; 54 47.86; 55 51.04; 56 42.53; 57 39.98; 58 36.85; 59 39.04; 60 48.33; 61 50.76];
init.tJX_grp_T2_3 = struct('PT233677506', 525, 'PT333677539', 509, 'PT433677524', 519, 'PT634052553', 556, 'PT834052552', 459); units.init.tJX_grp_T2_3 = {'kg'}; label.init.tJX_grp_T2_3 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T2_3 = {'d', 'kg'}; label.tJX_grp_T2_3 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T2_3 = 'Daily feed consumption of pen T2_3'; comment.tJX_grp_T2_3 = 'Data from GreenBeef trial 2, pen T2_3'; bibkey.tJX_grp_T2_3 = 'GreenBeefTrial2';

data.tJX_grp_T2_4 = [1 53.08; 2 46.33; 3 49.24; 4 52.76; 5 46.92; 6 43.51; 7 44.81; 8 45.79; 9 41.75; 10 42.77; 11 44.53; 12 46.3; 13 46.92; 14 45.51; 15 45.55; 16 45.28; 17 49.9; 18 51.08; 19 47.67; 20 44.3; 21 44.18; 22 49.51; 23 43.75; 24 45.2; 25 46.22; 26 43.04; 27 43.24; 28 44.88; 29 40.3; 30 41.59; 31 46.88; 32 45.9; 33 45.47; 34 46.73; 35 39.47; 36 41.87; 37 36.26; 38 44.61; 39 39.71; 40 37.83; 41 46.45; 42 39.32; 43 37.0; 44 39.75; 45 46.45; 46 46.22; 47 49.16; 48 48.45; 49 46.53; 50 47.59; 51 46.14; 52 49.0; 53 44.53; 54 48.33; 55 50.61; 56 43.98; 57 45.82; 58 44.61; 59 43.98; 60 47.59; 61 39.55];
init.tJX_grp_T2_4 = struct('PT334023113', 489, 'PT434052554', 498, 'PT533677434', 509, 'PT733602904', 495, 'PT733677513', 514); units.init.tJX_grp_T2_4 = {'kg'}; label.init.tJX_grp_T2_4 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T2_4 = {'d', 'kg'}; label.tJX_grp_T2_4 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T2_4 = 'Daily feed consumption of pen T2_4'; comment.tJX_grp_T2_4 = 'Data from GreenBeef trial 2, pen T2_4'; bibkey.tJX_grp_T2_4 = 'GreenBeefTrial2';

data.tJX_grp_T2_5 = [1 49.29; 2 47.19; 3 45.35; 4 48.83; 5 39.45; 6 30.49; 7 34.85; 8 43.66; 9 43.47; 10 41.33; 11 43.05; 12 43.66; 13 41.52; 14 39.95; 15 35.31; 16 35.12; 17 35.85; 18 26.92; 19 39.18; 20 31.83; 21 33.05; 22 42.67; 23 43.09; 24 45.77; 25 37.3; 26 37.73; 27 39.3; 28 39.56; 29 38.91; 30 38.07; 31 39.1; 32 43.2; 33 45.16; 34 40.52; 35 38.03; 36 43.66; 37 38.84; 38 39.3; 39 40.33; 40 40.37; 41 45.04; 42 28.8; 43 28.76; 44 37.8; 45 31.75; 46 32.25; 47 32.25; 48 35.66; 49 37.5; 50 39.95; 51 39.37; 52 40.44; 53 40.02; 54 42.13; 55 44.58; 56 42.59; 57 41.59; 58 44.73; 59 44.2; 60 39.95; 61 38.95];
init.tJX_grp_T2_5 = struct('PT034067821', 453, 'PT433677444', 493, 'PT433677562', 497, 'PT834023120', 526, 'PT933677550', 525); units.init.tJX_grp_T2_5 = {'kg'}; label.init.tJX_grp_T2_5 = {'Initial weights for the individuals in the group'};
units.tJX_grp_T2_5 = {'d', 'kg'}; label.tJX_grp_T2_5 = {'Time since start', 'Daily food consumption of group during test'}; txtData.title.tJX_grp_T2_5 = 'Daily feed consumption of pen T2_5'; comment.tJX_grp_T2_5 = 'Data from GreenBeef trial 2, pen T2_5'; bibkey.tJX_grp_T2_5 = 'GreenBeefTrial2';



% group data types
metaData.group_data_types = {'tJX_grp'}; 


% Cell array of group_ids
data.group_list = 10; units.group_list = '-'; label.group_list = 'Dummy variable'; comment.group_list = 'List of group ids'; bibkey.group_list = '-'; 
tiers.group_list = {'T1_2', 'T1_3', 'T1_4', 'T1_5', 'T2_2', 'T2_3', 'T2_4', 'T2_5'}; units.tiers.group_list = '-'; label.tiers.group_list = 'List of groups ids'; 


%% Individual data
%% Time vs Weight data 

data.tW_PT933843912 = [0 545; 14 561; 21 565; 35 581; 50 616; 63 649; 83 668];
init.tW_PT933843912 = 545; units.init.tW_PT933843912 = 'kg'; label.init.tW_PT933843912 = 'Initial weight';
units.tW_PT933843912 = {'d', 'kg'}; label.tW_PT933843912 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT933843912 = 'Growth curve of individual PT933843912'; comment.tW_PT933843912 = 'Data from GreenBeef trial 1, individual PT933843912'; bibkey.tW_PT933843912 = 'GreenBeefTrial1';

data.tW_PT533987885 = [0 436; 14 449; 21 460; 35 486; 50 502; 63 515; 83 542];
init.tW_PT533987885 = 436; units.init.tW_PT533987885 = 'kg'; label.init.tW_PT533987885 = 'Initial weight';
units.tW_PT533987885 = {'d', 'kg'}; label.tW_PT533987885 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT533987885 = 'Growth curve of individual PT533987885'; comment.tW_PT533987885 = 'Data from GreenBeef trial 1, individual PT533987885'; bibkey.tW_PT533987885 = 'GreenBeefTrial1';

data.tW_PT624139868 = [0 464; 14 470; 21 480; 35 508; 50 542; 63 558; 83 582];
init.tW_PT624139868 = 464; units.init.tW_PT624139868 = 'kg'; label.init.tW_PT624139868 = 'Initial weight';
units.tW_PT624139868 = {'d', 'kg'}; label.tW_PT624139868 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT624139868 = 'Growth curve of individual PT624139868'; comment.tW_PT624139868 = 'Data from GreenBeef trial 1, individual PT624139868'; bibkey.tW_PT624139868 = 'GreenBeefTrial1';

data.tW_PT424401157 = [0 469; 14 482; 21 486; 35 512; 50 540; 63 549; 83 571];
init.tW_PT424401157 = 469; units.init.tW_PT424401157 = 'kg'; label.init.tW_PT424401157 = 'Initial weight';
units.tW_PT424401157 = {'d', 'kg'}; label.tW_PT424401157 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT424401157 = 'Growth curve of individual PT424401157'; comment.tW_PT424401157 = 'Data from GreenBeef trial 1, individual PT424401157'; bibkey.tW_PT424401157 = 'GreenBeefTrial1';

data.tW_PT533358890 = [0 477; 14 493; 21 498; 35 529; 50 551; 63 586; 83 621];
init.tW_PT533358890 = 477; units.init.tW_PT533358890 = 'kg'; label.init.tW_PT533358890 = 'Initial weight';
units.tW_PT533358890 = {'d', 'kg'}; label.tW_PT533358890 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT533358890 = 'Growth curve of individual PT533358890'; comment.tW_PT533358890 = 'Data from GreenBeef trial 1, individual PT533358890'; bibkey.tW_PT533358890 = 'GreenBeefTrial1';

data.tW_PT533843896 = [0 480; 14 492; 21 506; 35 536; 50 551; 63 574; 83 586];
init.tW_PT533843896 = 480; units.init.tW_PT533843896 = 'kg'; label.init.tW_PT533843896 = 'Initial weight';
units.tW_PT533843896 = {'d', 'kg'}; label.tW_PT533843896 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT533843896 = 'Growth curve of individual PT533843896'; comment.tW_PT533843896 = 'Data from GreenBeef trial 1, individual PT533843896'; bibkey.tW_PT533843896 = 'GreenBeefTrial1';

data.tW_PT833653644 = [0 548; 14 544; 21 553; 35 579; 50 603; 63 623; 83 652];
init.tW_PT833653644 = 548; units.init.tW_PT833653644 = 'kg'; label.init.tW_PT833653644 = 'Initial weight';
units.tW_PT833653644 = {'d', 'kg'}; label.tW_PT833653644 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT833653644 = 'Growth curve of individual PT833653644'; comment.tW_PT833653644 = 'Data from GreenBeef trial 1, individual PT833653644'; bibkey.tW_PT833653644 = 'GreenBeefTrial1';

data.tW_PT433843806 = [0 507; 14 532; 21 532; 35 568; 50 600; 63 607; 83 628];
init.tW_PT433843806 = 507; units.init.tW_PT433843806 = 'kg'; label.init.tW_PT433843806 = 'Initial weight';
units.tW_PT433843806 = {'d', 'kg'}; label.tW_PT433843806 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT433843806 = 'Growth curve of individual PT433843806'; comment.tW_PT433843806 = 'Data from GreenBeef trial 1, individual PT433843806'; bibkey.tW_PT433843806 = 'GreenBeefTrial1';

data.tW_PT224401177 = [0 562; 14 589; 21 597; 35 632; 50 660; 63 697; 83 723];
init.tW_PT224401177 = 562; units.init.tW_PT224401177 = 'kg'; label.init.tW_PT224401177 = 'Initial weight';
units.tW_PT224401177 = {'d', 'kg'}; label.tW_PT224401177 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT224401177 = 'Growth curve of individual PT224401177'; comment.tW_PT224401177 = 'Data from GreenBeef trial 1, individual PT224401177'; bibkey.tW_PT224401177 = 'GreenBeefTrial1';

data.tW_PT833653649 = [0 535; 14 546; 21 557; 35 586; 50 613; 63 641; 83 656];
init.tW_PT833653649 = 535; units.init.tW_PT833653649 = 'kg'; label.init.tW_PT833653649 = 'Initial weight';
units.tW_PT833653649 = {'d', 'kg'}; label.tW_PT833653649 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT833653649 = 'Growth curve of individual PT833653649'; comment.tW_PT833653649 = 'Data from GreenBeef trial 1, individual PT833653649'; bibkey.tW_PT833653649 = 'GreenBeefTrial1';

data.tW_PT524401180 = [0 496; 14 503; 21 508; 35 532; 50 560; 63 586; 83 610];
init.tW_PT524401180 = 496; units.init.tW_PT524401180 = 'kg'; label.init.tW_PT524401180 = 'Initial weight';
units.tW_PT524401180 = {'d', 'kg'}; label.tW_PT524401180 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT524401180 = 'Growth curve of individual PT524401180'; comment.tW_PT524401180 = 'Data from GreenBeef trial 1, individual PT524401180'; bibkey.tW_PT524401180 = 'GreenBeefTrial1';

data.tW_PT933843894 = [0 508; 14 521; 21 534; 35 563; 50 583; 63 610; 83 639];
init.tW_PT933843894 = 508; units.init.tW_PT933843894 = 'kg'; label.init.tW_PT933843894 = 'Initial weight';
units.tW_PT933843894 = {'d', 'kg'}; label.tW_PT933843894 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT933843894 = 'Growth curve of individual PT933843894'; comment.tW_PT933843894 = 'Data from GreenBeef trial 1, individual PT933843894'; bibkey.tW_PT933843894 = 'GreenBeefTrial1';

data.tW_PT033634130 = [0 453; 14 468; 21 471; 35 500; 50 517; 63 526; 83 556];
init.tW_PT033634130 = 453; units.init.tW_PT033634130 = 'kg'; label.init.tW_PT033634130 = 'Initial weight';
units.tW_PT033634130 = {'d', 'kg'}; label.tW_PT033634130 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT033634130 = 'Growth curve of individual PT033634130'; comment.tW_PT033634130 = 'Data from GreenBeef trial 1, individual PT033634130'; bibkey.tW_PT033634130 = 'GreenBeefTrial1';

data.tW_PT233843883 = [0 506; 14 525; 21 533; 35 561; 50 583; 63 592; 83 620];
init.tW_PT233843883 = 506; units.init.tW_PT233843883 = 'kg'; label.init.tW_PT233843883 = 'Initial weight';
units.tW_PT233843883 = {'d', 'kg'}; label.tW_PT233843883 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT233843883 = 'Growth curve of individual PT233843883'; comment.tW_PT233843883 = 'Data from GreenBeef trial 1, individual PT233843883'; bibkey.tW_PT233843883 = 'GreenBeefTrial1';

data.tW_PT333842562 = [0 515; 14 535; 21 539; 35 566; 50 594; 63 630; 83 652];
init.tW_PT333842562 = 515; units.init.tW_PT333842562 = 'kg'; label.init.tW_PT333842562 = 'Initial weight';
units.tW_PT333842562 = {'d', 'kg'}; label.tW_PT333842562 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT333842562 = 'Growth curve of individual PT333842562'; comment.tW_PT333842562 = 'Data from GreenBeef trial 1, individual PT333842562'; bibkey.tW_PT333842562 = 'GreenBeefTrial1';

data.tW_PT933602927 = [0 426; 14 450; 21 462; 35 482; 50 497; 63 524; 83 539];
init.tW_PT933602927 = 426; units.init.tW_PT933602927 = 'kg'; label.init.tW_PT933602927 = 'Initial weight';
units.tW_PT933602927 = {'d', 'kg'}; label.tW_PT933602927 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT933602927 = 'Growth curve of individual PT933602927'; comment.tW_PT933602927 = 'Data from GreenBeef trial 1, individual PT933602927'; bibkey.tW_PT933602927 = 'GreenBeefTrial1';

data.tW_PT524956505 = [0 542; 14 567; 21 577; 35 603; 50 638; 63 664; 83 707];
init.tW_PT524956505 = 542; units.init.tW_PT524956505 = 'kg'; label.init.tW_PT524956505 = 'Initial weight';
units.tW_PT524956505 = {'d', 'kg'}; label.tW_PT524956505 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT524956505 = 'Growth curve of individual PT524956505'; comment.tW_PT524956505 = 'Data from GreenBeef trial 1, individual PT524956505'; bibkey.tW_PT524956505 = 'GreenBeefTrial1';

data.tW_PT724523831 = [0 485; 14 505; 21 510; 35 474; 50 504; 63 581; 83 565];
init.tW_PT724523831 = 485; units.init.tW_PT724523831 = 'kg'; label.init.tW_PT724523831 = 'Initial weight';
units.tW_PT724523831 = {'d', 'kg'}; label.tW_PT724523831 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT724523831 = 'Growth curve of individual PT724523831'; comment.tW_PT724523831 = 'Data from GreenBeef trial 1, individual PT724523831'; bibkey.tW_PT724523831 = 'GreenBeefTrial1';

data.tW_PT333653651 = [0 536; 14 548; 21 561; 35 589; 50 603; 63 615; 83 632];
init.tW_PT333653651 = 536; units.init.tW_PT333653651 = 'kg'; label.init.tW_PT333653651 = 'Initial weight';
units.tW_PT333653651 = {'d', 'kg'}; label.tW_PT333653651 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT333653651 = 'Growth curve of individual PT333653651'; comment.tW_PT333653651 = 'Data from GreenBeef trial 1, individual PT333653651'; bibkey.tW_PT333653651 = 'GreenBeefTrial1';

data.tW_PT924401183 = [0 510; 14 543; 21 555; 35 587; 50 624; 63 648; 83 685];
init.tW_PT924401183 = 510; units.init.tW_PT924401183 = 'kg'; label.init.tW_PT924401183 = 'Initial weight';
units.tW_PT924401183 = {'d', 'kg'}; label.tW_PT924401183 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT924401183 = 'Growth curve of individual PT924401183'; comment.tW_PT924401183 = 'Data from GreenBeef trial 1, individual PT924401183'; bibkey.tW_PT924401183 = 'GreenBeefTrial1';


%% Time vs Daily methane (CH4) emissions data

data.tCH4_PT933843912 = [0.40 142.76; 0.62 184.0; 0.99 207.08; 1.07 207.08; 1.35 231.62; 1.62 235.27; 1.87 232.59; 2.11 217.0; 2.33 207.16; 2.58 205.82; 3.00 199.17; 3.30 250.52; 3.57 264.7; 3.79 253.21; 4.00 238.54; 4.08 256.43; 4.30 239.58; 4.57 226.0; 4.80 230.7; 5.02 233.99; 5.35 187.83; 5.61 199.86; 5.90 215.83; 6.05 215.83; 6.33 221.81; 6.35 221.81; 27.39 233.71; 27.51 220.35; 27.61 228.86; 27.73 228.86; 27.85 220.46; 27.96 215.28; 28.08 214.68; 28.30 215.96; 28.39 215.85; 28.53 226.24; 28.67 217.92; 28.78 213.88; 29.07 208.3; 29.21 241.06; 29.32 236.06; 29.57 232.18; 29.78 242.81; 30.05 238.42; 30.29 217.11; 30.51 240.3; 30.75 247.72; 30.79 269.68; 32.42 99.22; 32.69 107.72; 32.90 104.45; 32.95 105.2; 33.39 124.94; 33.67 123.2; 33.97 122.21; 34.05 122.21; 34.30 109.61; 34.61 165.86; 34.88 183.03; 35.00 183.03; 35.28 206.8; 56.52 179.65; 56.60 202.66; 56.73 202.66; 56.95 208.09; 57.02 234.12; 57.28 270.49; 57.76 256.32; 57.99 260.64; 58.07 260.64; 58.30 247.82; 58.57 265.51; 58.79 251.72; 59.02 251.51; 59.28 251.39; 59.53 193.69; 60.35 269.33; 60.56 273.68; 60.78 273.68; 61.04 269.89; 61.29 261.24; 61.51 263.14; 61.80 275.68; 62.04 270.51; 62.27 236.32; 62.55 221.74; 63.00 232.99; 63.07 266.06; 63.28 266.06];
init.tCH4_PT933843912 = 545; units.init.tCH4_PT933843912 = 'kg'; label.init.tCH4_PT933843912 = 'Initial weight';
units.tCH4_PT933843912 = {'d', 'g/d'}; label.tCH4_PT933843912 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT933843912 = 'Daily CH4 emissions of individual PT933843912'; comment.tCH4_PT933843912 = 'Data from GreenBeef trial 1, individual PT933843912'; bibkey.tCH4_PT933843912 = 'GreenBeefTrial1';

data.tCH4_PT533987885 = [6.48 86.57; 6.72 82.8; 7.01 103.02; 7.40 106.25; 7.71 121.74; 8.41 106.48; 8.65 106.48; 9.41 110.62; 9.69 110.62; 10.31 42.21; 11.40 161.1; 12.36 141.04; 12.67 141.04; 13.33 101.48; 35.37 117.33; 35.60 120.88; 35.93 136.52; 36.15 137.31; 36.43 153.1; 36.50 159.39; 36.82 136.68; 37.30 130.79; 37.57 127.47; 37.82 142.33; 38.29 142.26; 38.61 110.24; 39.31 101.72; 39.55 106.76; 39.92 95.28; 40.09 102.03; 40.32 103.66; 40.68 102.26; 40.98 97.9; 41.06 97.9; 41.33 91.29; 41.56 73.77; 63.45 104.08; 63.67 116.3; 64.03 117.33; 64.30 123.93; 64.54 118.33; 64.78 118.75; 65.08 124.78; 65.34 125.61; 65.71 128.4; 66.26 92.93; 66.97 85.06; 67.28 96.86; 67.56 116.76; 67.83 136.06; 68.33 141.78; 68.62 154.04; 68.96 163.74; 69.06 163.74; 69.62 113.7; 70.09 113.7];
init.tCH4_PT533987885 = 436; units.init.tCH4_PT533987885 = 'kg'; label.init.tCH4_PT533987885 = 'Initial weight';
units.tCH4_PT533987885 = {'d', 'g/d'}; label.tCH4_PT533987885 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT533987885 = 'Daily CH4 emissions of individual PT533987885'; comment.tCH4_PT533987885 = 'Data from GreenBeef trial 1, individual PT533987885'; bibkey.tCH4_PT533987885 = 'GreenBeefTrial1';

data.tCH4_PT624139868 = [0.43 163.28; 0.66 167.74; 0.89 166.28; 1.00 170.22; 1.24 175.14; 1.50 182.08; 1.71 180.49; 1.93 179.31; 2.07 181.3; 2.29 178.43; 2.60 195.77; 2.84 194.45; 3.08 194.45; 3.31 190.03; 3.68 166.42; 3.90 171.12; 4.05 171.12; 4.29 172.27; 4.60 170.71; 4.75 170.71; 4.89 179.04; 5.03 179.04; 5.29 165.77; 5.63 163.76; 5.67 163.76; 5.91 152.38; 6.06 152.38; 6.34 167.79; 27.40 203.33; 27.43 203.33; 27.62 202.17; 27.78 202.17; 27.86 202.17; 28.10 188.1; 28.38 203.87; 28.55 215.38; 28.68 221.86; 28.95 228.87; 29.09 242.06; 29.42 220.84; 29.67 189.52; 29.93 186.51; 30.06 186.51; 30.08 185.74; 30.30 187.67; 30.56 190.85; 30.90 195.07; 31.06 201.81; 31.29 213.77; 31.51 208.28; 31.70 213.58; 31.73 213.58; 31.95 199.59; 32.15 195.22; 32.38 182.22; 32.43 189.55; 32.63 198.33; 32.91 195.45; 33.03 211.6; 33.32 214.59; 33.57 199.8; 33.80 199.8; 34.05 190.84; 34.33 167.74; 34.35 167.74; 34.62 177.0; 34.91 183.08; 35.01 183.08; 56.43 315.77; 56.94 234.01; 57.31 227.6; 57.64 236.46; 57.93 245.39; 58.01 245.39; 58.58 233.7; 58.80 207.13; 59.04 207.13; 59.28 241.58; 59.56 212.61; 59.77 212.61; 60.04 227.36; 60.31 204.64; 60.54 208.23; 60.77 232.98; 61.05 254.19; 61.26 251.23; 61.60 238.22; 61.95 230.85; 62.03 230.85; 62.28 215.67; 62.55 210.08; 62.79 188.85; 63.15 192.47];
init.tCH4_PT624139868 = 464; units.init.tCH4_PT624139868 = 'kg'; label.init.tCH4_PT624139868 = 'Initial weight';
units.tCH4_PT624139868 = {'d', 'g/d'}; label.tCH4_PT624139868 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT624139868 = 'Daily CH4 emissions of individual PT624139868'; comment.tCH4_PT624139868 = 'Data from GreenBeef trial 1, individual PT624139868'; bibkey.tCH4_PT624139868 = 'GreenBeefTrial1';

data.tCH4_PT424401157 = [0.41 168.3; 0.88 168.3; 1.48 198.36; 1.70 192.69; 2.00 195.48; 2.29 200.88; 2.58 205.32; 2.96 207.99; 3.01 207.99; 3.28 175.3; 3.57 174.82; 3.79 179.17; 4.00 179.17; 4.23 193.86; 4.56 188.66; 4.81 164.71; 5.00 164.71; 5.29 158.22; 5.53 137.97; 5.77 141.99; 6.05 155.54; 6.26 155.54; 27.44 162.01; 27.78 157.29; 28.08 152.07; 28.32 166.93; 28.54 166.93; 28.78 169.1; 29.08 183.88; 29.31 174.7; 29.56 191.11; 29.80 209.44; 30.05 215.85; 30.28 220.06; 30.51 240.22; 30.75 242.18; 30.80 240.68; 31.01 251.08; 32.56 43.72; 33.11 107.68; 33.35 120.3; 33.56 116.83; 33.78 121.95; 34.06 109.02; 34.31 90.38; 34.61 119.65; 34.93 130.18; 35.04 130.18; 35.28 145.65; 56.42 222.12; 56.52 221.98; 56.66 221.98; 56.74 209.11; 57.01 199.68; 57.22 184.7; 57.44 158.32; 57.68 137.13; 57.97 135.0; 58.12 136.75; 58.30 143.6; 58.57 150.56; 58.79 148.36; 59.05 159.8; 59.30 156.58; 59.54 156.58; 59.76 159.05; 60.34 170.12; 60.57 145.72; 60.78 145.72; 61.06 130.64; 61.28 107.55; 61.60 156.6; 61.83 159.01; 62.05 162.43; 62.28 175.45; 62.34 172.74; 62.55 168.88; 62.78 176.1; 63.06 156.49; 63.31 147.48];
init.tCH4_PT424401157 = 469; units.init.tCH4_PT424401157 = 'kg'; label.init.tCH4_PT424401157 = 'Initial weight';
units.tCH4_PT424401157 = {'d', 'g/d'}; label.tCH4_PT424401157 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT424401157 = 'Daily CH4 emissions of individual PT424401157'; comment.tCH4_PT424401157 = 'Data from GreenBeef trial 1, individual PT424401157'; bibkey.tCH4_PT424401157 = 'GreenBeefTrial1';

data.tCH4_PT533358890 = [20.49 193.2; 20.71 178.05; 20.94 173.74; 20.96 173.74; 21.11 173.41; 21.12 167.46; 21.25 167.76; 21.33 167.76; 21.34 167.76; 21.58 160.7; 21.60 160.7; 21.61 161.24; 21.88 165.4; 22.07 164.9; 22.31 181.51; 22.57 179.3; 22.78 182.82; 23.01 191.52; 23.26 200.07; 23.49 200.99; 23.70 196.82; 23.91 184.3; 24.05 175.45; 24.32 165.72; 24.89 204.16; 25.04 203.21; 25.26 203.21; 25.51 178.98; 25.78 188.76; 26.07 166.3; 26.32 175.18; 26.54 173.09; 26.77 167.65; 27.01 174.74; 27.26 179.66; 48.69 172.94; 48.71 172.94; 48.89 162.18; 48.96 162.18; 49.01 167.25; 49.23 157.47; 49.30 157.47; 49.49 163.26; 49.54 164.18; 49.69 164.18; 49.70 164.18; 49.93 179.95; 50.00 174.04; 50.24 206.17; 50.46 196.93; 50.71 189.36; 50.93 179.88; 51.04 183.58; 51.05 178.68; 51.27 165.9; 51.54 181.46; 51.78 188.01; 52.02 187.84; 52.27 190.34; 52.48 189.08; 52.49 189.08; 52.69 197.68; 52.97 205.14; 53.01 208.33; 53.08 208.33; 53.25 215.93; 53.49 212.99; 53.71 189.71; 53.96 201.52; 54.02 204.66; 54.27 201.4; 54.54 211.31; 54.76 211.31; 55.03 192.15; 55.27 196.75; 55.54 203.72; 55.76 203.72; 55.99 208.92; 56.04 208.92; 56.29 207.68; 76.40 166.99; 76.45 166.99; 76.57 177.71; 76.63 175.34; 76.71 175.34; 76.85 176.1; 77.00 183.55; 77.07 186.36; 77.24 203.72; 77.46 200.74; 77.71 202.27; 77.94 212.56; 78.04 209.35; 78.26 214.26; 78.47 228.99; 78.69 239.63; 78.91 239.44; 79.06 228.67; 79.27 229.71; 79.55 198.78; 79.80 170.2; 80.01 170.2; 80.26 172.43; 80.52 176.82; 80.73 179.14; 80.84 178.89; 81.02 176.61; 81.23 172.1; 81.45 174.71; 81.67 173.74; 81.94 182.07; 82.04 178.23; 82.30 189.48; 82.32 189.48; 82.52 193.24; 82.73 193.04; 82.98 190.75; 83.07 211.17; 83.29 209.72; 83.51 199.3];
init.tCH4_PT533358890 = 477; units.init.tCH4_PT533358890 = 'kg'; label.init.tCH4_PT533358890 = 'Initial weight';
units.tCH4_PT533358890 = {'d', 'g/d'}; label.tCH4_PT533358890 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT533358890 = 'Daily CH4 emissions of individual PT533358890'; comment.tCH4_PT533358890 = 'Data from GreenBeef trial 1, individual PT533358890'; bibkey.tCH4_PT533358890 = 'GreenBeefTrial1';

data.tCH4_PT533843896 = [13.62 80.38; 14.28 91.71; 14.57 91.71; 14.60 91.71; 15.31 85.18; 15.61 120.64; 15.91 119.66; 16.10 108.72; 16.37 108.82; 16.60 106.88; 16.90 101.62; 17.31 120.33; 17.53 116.24; 17.76 116.24; 18.66 147.29; 18.98 153.62; 19.41 138.61; 19.64 142.57; 19.89 124.49; 20.01 114.04; 20.25 107.04; 41.78 184.74; 41.86 184.74; 42.37 74.99; 42.40 74.99; 42.60 100.65; 42.93 83.23; 43.29 90.97; 43.53 95.02; 43.90 114.24; 44.04 115.66; 44.35 120.14; 44.49 106.21; 44.56 113.32; 44.78 113.32; 45.32 80.2; 45.62 86.12; 46.02 91.38; 46.29 83.93; 46.58 83.97; 46.96 97.1; 47.04 97.1; 47.33 82.03; 47.65 80.77; 47.86 72.16; 48.03 72.16; 48.26 74.89; 48.62 61.27; 70.37 127.44; 70.41 127.44; 70.60 127.44; 70.82 140.48; 71.12 122.75; 71.36 126.74; 71.70 104.77; 71.73 104.77; 72.28 126.72; 72.58 126.72; 73.51 117.0; 73.73 117.0; 74.26 74.9; 74.54 114.5; 74.81 123.86; 75.27 147.18; 75.67 130.09; 76.07 138.08; 76.38 128.14];
init.tCH4_PT533843896 = 480; units.init.tCH4_PT533843896 = 'kg'; label.init.tCH4_PT533843896 = 'Initial weight';
units.tCH4_PT533843896 = {'d', 'g/d'}; label.tCH4_PT533843896 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT533843896 = 'Daily CH4 emissions of individual PT533843896'; comment.tCH4_PT533843896 = 'Data from GreenBeef trial 1, individual PT533843896'; bibkey.tCH4_PT533843896 = 'GreenBeefTrial1';

data.tCH4_PT833653644 = [0.42 180.42; 4.74 229.65; 5.75 173.73; 27.49 176.78; 27.74 168.52; 28.01 162.84; 28.29 170.5; 28.54 176.67; 28.76 178.42; 29.19 175.52; 29.41 161.37; 29.66 169.47; 29.92 172.26; 30.07 177.24; 30.32 196.32; 30.54 202.71; 30.78 229.84; 31.05 192.32; 31.31 167.14; 31.55 167.14; 31.77 134.81; 32.18 152.16; 32.33 152.09; 32.40 152.09; 32.62 156.85; 33.02 161.76; 33.28 165.33; 33.67 165.92; 34.10 173.38; 34.35 169.76; 34.57 164.06; 34.96 156.09; 35.11 148.24; 56.43 151.28; 56.64 185.02; 56.93 180.84; 57.07 180.84; 57.32 187.72; 57.66 188.98; 57.92 192.14; 58.04 192.14; 58.29 181.31; 58.56 182.18; 58.84 200.79; 59.15 206.74; 59.47 206.58; 59.78 193.85; 60.00 193.28; 60.08 189.57; 60.30 179.97; 60.54 187.39; 60.77 188.54; 61.00 188.14; 61.31 176.94; 61.59 187.42; 61.82 199.52; 62.00 199.52; 62.29 211.54; 62.51 205.47; 62.73 208.45; 62.96 206.96; 63.05 210.05; 63.29 202.26];
init.tCH4_PT833653644 = 548; units.init.tCH4_PT833653644 = 'kg'; label.init.tCH4_PT833653644 = 'Initial weight';
units.tCH4_PT833653644 = {'d', 'g/d'}; label.tCH4_PT833653644 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT833653644 = 'Daily CH4 emissions of individual PT833653644'; comment.tCH4_PT833653644 = 'Data from GreenBeef trial 1, individual PT833653644'; bibkey.tCH4_PT833653644 = 'GreenBeefTrial1';

data.tCH4_PT433843806 = [1.28 203.4; 2.42 239.0; 2.74 220.86; 3.07 216.86; 3.29 207.03; 3.72 219.69; 4.01 228.22; 4.27 218.77; 4.69 203.67; 5.10 198.56; 5.33 178.3; 5.64 197.07; 5.95 196.1; 6.07 196.1; 6.36 203.72; 27.42 253.32; 27.73 236.83; 28.07 230.27; 28.30 214.28; 28.52 214.28; 28.73 217.75; 29.32 226.1; 29.58 224.61; 29.81 218.49; 30.02 215.06; 30.29 214.48; 30.52 213.61; 30.84 234.34; 31.09 248.45; 31.33 226.21; 31.64 210.23; 31.91 210.22; 32.01 210.22; 32.37 223.54; 32.75 199.89; 33.07 174.4; 33.30 167.15; 33.55 182.01; 33.76 188.47; 34.01 196.2; 34.32 210.63; 34.63 225.9; 34.97 228.12; 35.05 228.12; 35.30 231.28; 56.41 264.3; 56.72 253.72; 57.02 204.37; 57.31 192.34; 57.61 194.88; 57.90 217.65; 58.37 220.32; 58.72 212.06; 59.02 192.97; 59.30 225.77; 59.52 229.22; 59.75 214.92; 60.05 205.73; 60.32 171.15; 60.59 205.68; 60.94 224.14; 61.29 258.29; 61.55 252.53; 61.78 244.93; 62.14 278.96; 62.36 277.13; 62.59 260.8; 62.94 237.94; 63.19 203.89];
init.tCH4_PT433843806 = 507; units.init.tCH4_PT433843806 = 'kg'; label.init.tCH4_PT433843806 = 'Initial weight';
units.tCH4_PT433843806 = {'d', 'g/d'}; label.tCH4_PT433843806 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT433843806 = 'Daily CH4 emissions of individual PT433843806'; comment.tCH4_PT433843806 = 'Data from GreenBeef trial 1, individual PT433843806'; bibkey.tCH4_PT433843806 = 'GreenBeefTrial1';

data.tCH4_PT224401177 = [13.50 169.78; 13.77 159.11; 14.19 142.65; 14.55 136.3; 14.87 116.44; 15.06 116.6; 15.29 130.8; 15.68 132.07; 16.68 151.71; 17.32 81.64; 17.70 89.74; 17.96 132.34; 18.34 127.67; 18.61 136.54; 18.91 99.81; 19.31 107.79; 19.68 95.42; 20.32 136.19; 41.98 88.84; 42.14 100.56; 42.40 100.64; 42.63 109.6; 42.87 102.51; 43.14 108.2; 43.39 110.62; 43.64 106.23; 43.92 101.94; 44.01 101.94; 44.30 100.17; 44.56 100.52; 44.77 100.52; 45.47 140.1; 45.69 127.08; 45.98 134.33; 46.10 134.33; 46.36 119.84; 46.63 119.12; 46.92 105.81; 47.40 121.49; 47.66 122.02; 47.90 122.06; 48.02 124.93; 48.40 108.48; 48.63 114.34; 70.36 163.19; 70.57 163.19; 70.81 151.97; 71.15 168.33; 71.37 151.14; 71.79 154.44; 71.95 176.35; 72.13 176.35; 72.36 171.44; 73.36 157.0; 73.73 128.98; 73.99 124.94; 74.21 128.68; 74.52 137.08; 74.75 141.15; 74.97 152.02; 75.13 155.04; 75.35 152.45; 75.72 152.95; 76.01 128.71; 76.30 129.99];
init.tCH4_PT224401177 = 562; units.init.tCH4_PT224401177 = 'kg'; label.init.tCH4_PT224401177 = 'Initial weight';
units.tCH4_PT224401177 = {'d', 'g/d'}; label.tCH4_PT224401177 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT224401177 = 'Daily CH4 emissions of individual PT224401177'; comment.tCH4_PT224401177 = 'Data from GreenBeef trial 1, individual PT224401177'; bibkey.tCH4_PT224401177 = 'GreenBeefTrial1';

data.tCH4_PT833653649 = [6.58 68.95; 6.86 67.47; 7.03 66.73; 7.28 79.02; 7.51 80.01; 7.75 83.4; 8.00 86.68; 8.31 84.05; 8.61 82.85; 8.90 76.72; 9.15 72.37; 9.46 83.76; 9.75 85.5; 10.12 92.75; 10.99 85.06; 11.39 105.61; 11.68 102.45; 11.92 99.6; 12.15 90.02; 12.59 86.77; 13.00 90.39; 35.39 158.67; 35.65 157.94; 35.92 149.64; 36.01 149.64; 36.29 135.32; 36.62 122.02; 36.99 109.29; 37.08 109.29; 37.32 106.96; 37.61 146.87; 37.95 155.93; 38.14 171.71; 38.41 160.94; 38.67 148.03; 38.91 130.15; 39.01 124.27; 39.30 103.88; 39.56 86.28; 39.98 92.73; 40.26 104.21; 40.52 106.31; 40.76 113.76; 41.10 135.99; 41.45 145.58; 41.70 150.33; 63.40 120.0; 63.86 105.12; 64.04 113.09; 64.26 113.09; 64.50 104.49; 64.79 119.16; 65.09 104.31; 65.40 101.67; 65.63 125.64; 65.97 136.26; 66.02 136.26; 66.28 142.96; 66.60 129.24; 66.92 102.44; 67.14 90.99; 67.39 95.19; 67.67 95.12; 67.90 96.42; 68.05 97.94; 68.29 95.48; 68.52 100.56; 68.82 117.56; 69.03 113.65; 69.35 105.2; 70.06 105.54; 70.28 105.54];
init.tCH4_PT833653649 = 535; units.init.tCH4_PT833653649 = 'kg'; label.init.tCH4_PT833653649 = 'Initial weight';
units.tCH4_PT833653649 = {'d', 'g/d'}; label.tCH4_PT833653649 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT833653649 = 'Daily CH4 emissions of individual PT833653649'; comment.tCH4_PT833653649 = 'Data from GreenBeef trial 1, individual PT833653649'; bibkey.tCH4_PT833653649 = 'GreenBeefTrial1';

data.tCH4_PT524401180 = [6.45 119.48; 6.68 109.2; 7.01 84.52; 7.33 83.8; 7.63 79.78; 8.01 88.21; 8.30 85.71; 8.56 112.31; 8.99 117.18; 9.05 117.18; 9.33 109.87; 9.60 85.4; 10.35 85.65; 10.67 81.75; 11.01 89.78; 11.48 103.06; 11.75 112.29; 12.07 112.9; 12.31 93.78; 12.57 107.0; 12.88 118.9; 13.11 129.82; 13.33 129.82; 35.36 107.06; 35.59 129.38; 35.94 127.85; 36.02 127.85; 36.30 145.17; 36.52 148.55; 36.74 141.43; 36.96 146.04; 37.02 143.89; 37.31 144.53; 37.56 145.98; 37.78 133.65; 38.14 144.56; 38.37 127.22; 38.62 121.9; 38.92 124.63; 39.15 121.8; 39.31 121.8; 39.47 128.38; 39.92 121.21; 40.09 130.44; 40.42 135.5; 40.68 148.64; 40.96 149.25; 41.47 129.94; 41.71 129.94; 63.35 162.36; 63.56 152.14; 63.79 140.65; 64.02 147.01; 64.28 146.55; 64.53 126.48; 64.76 115.59; 65.00 120.81; 65.22 119.34; 65.55 129.14; 65.96 130.39; 66.00 130.39; 66.29 142.82; 66.58 138.93; 66.84 149.15; 67.07 143.85; 67.29 138.52; 67.54 139.24; 67.79 145.67; 68.06 134.2; 68.31 97.86; 68.64 104.28; 68.95 102.53; 69.05 102.53; 69.28 127.15; 69.68 124.43; 69.98 135.78; 70.11 135.78; 70.34 126.03];
init.tCH4_PT524401180 = 496; units.init.tCH4_PT524401180 = 'kg'; label.init.tCH4_PT524401180 = 'Initial weight';
units.tCH4_PT524401180 = {'d', 'g/d'}; label.tCH4_PT524401180 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT524401180 = 'Daily CH4 emissions of individual PT524401180'; comment.tCH4_PT524401180 = 'Data from GreenBeef trial 1, individual PT524401180'; bibkey.tCH4_PT524401180 = 'GreenBeefTrial1';

data.tCH4_PT933843894 = [6.45 159.98; 6.73 171.56; 7.19 150.95; 7.68 133.78; 8.42 116.22; 8.66 132.86; 8.98 115.04; 9.14 115.04; 9.38 128.86; 10.09 111.64; 10.72 196.69; 11.34 177.26; 12.11 154.0; 12.39 144.99; 12.67 124.08; 12.97 135.56; 13.11 135.56; 35.38 113.14; 35.66 107.45; 35.95 121.6; 36.33 136.09; 36.64 150.93; 37.01 123.33; 37.35 143.88; 37.77 132.13; 37.98 136.25; 38.02 136.25; 38.35 119.38; 38.67 111.46; 38.77 111.46; 38.89 113.33; 39.01 113.33; 39.33 96.3; 39.61 113.1; 39.87 124.65; 40.11 124.65; 40.33 132.32; 40.66 118.07; 40.96 102.05; 41.35 119.31; 41.67 133.98; 63.38 111.48; 63.60 109.72; 63.91 103.59; 64.05 103.59; 64.33 112.88; 64.71 96.67; 65.02 104.75; 65.30 100.02; 65.62 137.27; 65.83 137.51; 66.17 145.2; 67.92 121.89; 68.06 121.94; 68.47 113.4; 68.73 92.35; 69.07 79.54; 69.35 90.28; 69.67 107.93; 70.00 120.08];
init.tCH4_PT933843894 = 508; units.init.tCH4_PT933843894 = 'kg'; label.init.tCH4_PT933843894 = 'Initial weight';
units.tCH4_PT933843894 = {'d', 'g/d'}; label.tCH4_PT933843894 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT933843894 = 'Daily CH4 emissions of individual PT933843894'; comment.tCH4_PT933843894 = 'Data from GreenBeef trial 1, individual PT933843894'; bibkey.tCH4_PT933843894 = 'GreenBeefTrial1';

data.tCH4_PT033634130 = [20.96 161.3; 20.99 161.3; 21.64 132.46; 22.10 132.46; 22.61 141.57; 24.54 142.64; 24.80 143.6; 25.04 137.49; 25.29 140.56; 25.52 162.9; 25.81 169.27; 26.06 182.18; 26.33 153.14; 26.79 162.17; 27.28 167.34; 48.72 115.68; 49.52 202.67; 50.06 133.47; 50.29 133.47; 50.55 147.89; 50.88 152.24; 51.06 154.23; 51.32 150.89; 51.57 143.89; 51.79 143.89; 52.06 141.3; 52.31 153.59; 52.53 149.41; 52.76 146.58; 52.98 142.21; 53.12 146.38; 53.42 126.7; 53.67 125.12; 53.95 128.57; 54.13 128.57; 54.40 129.46; 54.66 140.68; 54.91 132.6; 55.00 133.23; 55.24 141.58; 55.49 142.66; 55.73 144.59; 55.96 151.35; 56.07 155.25; 56.30 151.57; 76.43 176.63; 76.66 195.04; 76.94 191.01; 77.06 185.89; 77.28 173.53; 77.54 161.92; 77.76 146.92; 78.28 149.79; 78.50 149.79; 78.74 143.48; 79.04 149.44; 79.25 136.68; 79.49 159.42; 79.72 166.56; 79.94 156.63; 80.03 155.57; 80.26 163.2; 80.50 141.4; 80.76 134.88; 81.01 150.46; 81.76 146.24; 82.09 187.24; 82.48 173.71; 82.73 208.39; 83.00 163.8; 83.28 181.0; 83.50 181.0];
init.tCH4_PT033634130 = 453; units.init.tCH4_PT033634130 = 'kg'; label.init.tCH4_PT033634130 = 'Initial weight';
units.tCH4_PT033634130 = {'d', 'g/d'}; label.tCH4_PT033634130 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT033634130 = 'Daily CH4 emissions of individual PT033634130'; comment.tCH4_PT033634130 = 'Data from GreenBeef trial 1, individual PT033634130'; bibkey.tCH4_PT033634130 = 'GreenBeefTrial1';

data.tCH4_PT233843883 = [22.97 186.01; 23.02 186.01; 24.10 202.08; 24.65 180.89; 24.94 187.93; 25.06 187.93; 25.07 187.93; 25.28 178.21; 25.58 191.95; 25.79 189.91; 26.09 195.32; 26.32 198.86; 26.54 194.89; 26.77 191.12; 27.01 186.88; 27.34 196.64; 48.74 236.82; 49.02 236.82; 49.63 228.69; 49.90 214.57; 50.06 208.33; 50.28 217.76; 50.54 192.3; 50.87 182.76; 51.06 182.56; 51.30 174.37; 51.59 182.09; 51.80 186.36; 52.05 195.57; 52.35 216.0; 52.59 220.19; 52.81 220.19; 53.07 206.87; 53.32 208.59; 53.54 194.9; 53.80 189.1; 54.00 180.58; 54.28 191.4; 54.49 176.54; 54.75 175.03; 54.97 176.73; 55.11 178.46; 55.35 160.42; 55.62 167.71; 55.92 159.27; 56.01 159.27; 56.30 163.6; 76.44 177.06; 76.70 177.06; 77.25 152.52; 77.53 175.38; 77.76 174.32; 78.04 205.16; 78.28 189.78; 78.56 194.05; 78.79 186.09; 79.11 202.41; 79.53 211.6; 79.77 210.77; 80.04 186.88; 80.30 179.2; 80.52 188.93; 80.75 178.65; 81.01 169.26; 81.24 185.16; 81.48 183.13; 81.76 199.72; 82.03 186.68; 82.29 194.39; 82.50 192.52; 82.76 177.87; 82.99 176.18; 83.09 177.43; 83.33 168.18; 83.62 166.77];
init.tCH4_PT233843883 = 506; units.init.tCH4_PT233843883 = 'kg'; label.init.tCH4_PT233843883 = 'Initial weight';
units.tCH4_PT233843883 = {'d', 'g/d'}; label.tCH4_PT233843883 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT233843883 = 'Daily CH4 emissions of individual PT233843883'; comment.tCH4_PT233843883 = 'Data from GreenBeef trial 1, individual PT233843883'; bibkey.tCH4_PT233843883 = 'GreenBeefTrial1';

data.tCH4_PT333842562 = [6.44 96.62; 6.66 89.38; 6.70 89.38; 6.92 85.88; 7.11 89.4; 7.35 81.31; 7.62 95.65; 7.87 95.59; 8.20 87.11; 8.55 76.31; 8.94 87.13; 9.10 92.22; 9.37 92.22; 9.59 110.9; 9.94 127.9; 10.62 116.0; 10.99 107.53; 11.06 107.01; 11.33 107.87; 11.56 105.68; 12.06 112.82; 12.29 112.82; 12.51 121.45; 12.99 133.21; 13.07 130.0; 13.31 130.0; 13.35 130.0; 35.37 117.53; 35.64 110.93; 35.86 101.43; 36.00 90.57; 36.31 97.31; 36.60 111.24; 36.81 127.18; 37.08 140.24; 37.38 147.63; 37.59 160.13; 37.86 145.95; 38.15 158.01; 38.40 134.43; 38.66 141.43; 38.90 122.91; 39.40 121.42; 39.68 111.2; 39.90 109.09; 40.05 111.05; 40.32 112.2; 40.56 109.84; 40.79 102.86; 41.03 103.4; 41.27 112.3; 41.56 112.28; 63.36 88.07; 63.40 90.94; 63.61 99.78; 63.89 92.2; 64.02 95.53; 64.29 116.42; 64.51 120.64; 64.76 115.81; 65.38 158.84; 65.79 154.89; 66.10 154.44; 66.68 141.27; 66.95 141.27; 67.16 145.88; 67.60 124.88; 67.97 114.57; 68.09 114.57; 68.34 99.18; 68.61 91.97; 68.96 108.38; 69.08 110.65; 69.29 118.61; 69.51 118.87; 69.75 125.55; 69.99 115.42; 70.08 114.34; 70.33 106.46];
init.tCH4_PT333842562 = 515; units.init.tCH4_PT333842562 = 'kg'; label.init.tCH4_PT333842562 = 'Initial weight';
units.tCH4_PT333842562 = {'d', 'g/d'}; label.tCH4_PT333842562 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT333842562 = 'Daily CH4 emissions of individual PT333842562'; comment.tCH4_PT333842562 = 'Data from GreenBeef trial 1, individual PT333842562'; bibkey.tCH4_PT333842562 = 'GreenBeefTrial1';

data.tCH4_PT933602927 = [13.53 60.68; 13.61 60.68; 13.69 58.61; 13.78 58.61; 13.91 58.61; 14.18 56.7; 14.41 45.45; 15.37 70.4; 15.70 72.52; 16.01 91.31; 16.31 64.9; 16.52 60.94; 16.74 54.14; 17.15 44.22; 17.60 40.02; 17.98 46.87; 18.31 54.83; 18.38 54.83; 18.55 63.65; 18.77 63.65; 18.99 67.77; 19.00 67.77; 19.28 63.05; 19.55 57.21; 19.98 50.45; 20.17 49.54; 41.75 107.9; 42.00 105.58; 42.32 96.94; 42.62 98.67; 42.98 107.35; 43.18 106.83; 43.41 104.83; 43.47 104.83; 43.72 103.93; 44.01 96.57; 44.30 93.94; 44.61 90.57; 44.95 82.24; 45.32 78.5; 45.60 74.43; 45.99 76.98; 46.11 87.99; 46.61 100.27; 46.94 97.32; 47.03 96.65; 47.29 93.13; 47.53 80.82; 48.05 92.2; 48.30 95.48; 48.59 92.24; 70.37 119.18; 70.66 132.83; 70.99 110.85; 71.26 143.01; 71.51 134.18; 71.96 120.45; 72.10 99.77; 72.28 99.77; 72.49 88.48; 73.52 118.65; 74.15 90.03; 74.74 176.42; 74.95 176.42; 75.11 176.42; 75.98 109.46; 76.09 109.46; 76.31 109.46];
init.tCH4_PT933602927 = 426; units.init.tCH4_PT933602927 = 'kg'; label.init.tCH4_PT933602927 = 'Initial weight';
units.tCH4_PT933602927 = {'d', 'g/d'}; label.tCH4_PT933602927 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT933602927 = 'Daily CH4 emissions of individual PT933602927'; comment.tCH4_PT933602927 = 'Data from GreenBeef trial 1, individual PT933602927'; bibkey.tCH4_PT933602927 = 'GreenBeefTrial1';

data.tCH4_PT524956505 = [13.51 190.44; 13.70 174.75; 13.77 174.75; 13.97 161.3; 14.07 149.81; 14.09 153.32; 14.29 150.02; 14.33 150.02; 14.58 154.05; 14.78 157.37; 14.87 162.75; 15.03 153.15; 15.15 157.82; 15.29 152.67; 15.41 145.2; 15.60 160.37; 15.95 182.72; 16.03 182.72; 16.30 177.3; 16.33 177.3; 16.53 164.72; 16.75 167.09; 16.99 163.28; 17.09 159.99; 17.32 159.52; 17.56 161.81; 17.77 152.22; 17.91 153.33; 18.16 168.49; 18.39 158.44; 18.61 161.84; 18.92 161.91; 19.10 161.91; 19.37 184.76; 19.67 202.84; 19.77 202.84; 20.00 196.35; 20.31 150.08; 41.74 172.79; 41.99 153.81; 42.02 153.81; 42.30 152.94; 42.42 152.94; 42.52 157.68; 42.73 157.68; 42.97 162.93; 42.98 162.93; 43.38 160.2; 43.66 134.23; 43.91 129.28; 44.02 129.28; 44.31 107.25; 44.60 98.8; 44.95 99.41; 45.01 99.41; 45.30 128.34; 45.60 151.7; 45.79 151.7; 45.91 160.49; 45.96 160.49; 46.09 160.49; 46.32 151.4; 46.39 151.4; 46.65 135.15; 46.93 105.6; 47.10 110.08; 47.32 114.6; 47.54 131.42; 47.92 133.68; 48.00 133.68; 48.05 135.1; 48.31 143.38; 48.58 145.61; 48.64 145.61; 70.36 212.58; 70.45 212.58; 70.58 208.22; 70.69 208.22; 70.81 196.57; 70.83 196.57; 71.05 181.94; 71.27 170.58; 71.37 155.83; 71.45 155.83; 71.50 155.75; 71.65 156.32; 71.71 156.32; 71.99 161.12; 72.07 151.03; 72.29 143.74; 72.54 140.88; 72.58 125.65; 73.38 155.86; 73.59 155.86; 73.66 155.86; 74.25 126.95; 74.58 144.07; 74.96 152.64; 75.01 152.64; 75.29 180.03; 75.78 184.5; 76.05 203.96];
init.tCH4_PT524956505 = 542; units.init.tCH4_PT524956505 = 'kg'; label.init.tCH4_PT524956505 = 'Initial weight';
units.tCH4_PT524956505 = {'d', 'g/d'}; label.tCH4_PT524956505 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT524956505 = 'Daily CH4 emissions of individual PT524956505'; comment.tCH4_PT524956505 = 'Data from GreenBeef trial 1, individual PT524956505'; bibkey.tCH4_PT524956505 = 'GreenBeefTrial1';

data.tCH4_PT724523831 = [49.64 165.26; 50.04 173.52; 50.31 208.69; 50.57 214.16; 50.79 214.16; 51.04 217.37; 51.29 211.67; 51.57 219.18; 52.05 199.75; 52.30 238.65; 52.56 238.73; 52.78 241.44; 53.11 226.56; 53.29 218.92; 53.41 218.92; 53.70 227.76; 54.01 234.39; 54.28 238.76; 54.54 223.37; 54.77 234.11; 55.10 249.35; 55.39 221.71; 55.62 225.34; 55.91 238.38; 56.08 238.38; 56.33 255.5; 76.41 291.5; 76.68 291.5; 76.75 291.5; 77.28 246.22; 77.53 246.22; 77.75 266.06; 78.06 283.54; 78.26 295.56; 78.36 277.14; 78.58 265.02; 78.80 260.63; 79.08 243.27; 79.30 259.4; 79.52 245.68; 79.73 235.0; 80.01 223.44; 80.31 210.22; 80.52 216.67; 80.74 220.22; 81.02 247.66; 81.15 247.66; 81.49 247.72; 81.74 259.28; 81.97 245.96; 82.08 243.26; 82.30 242.51; 82.53 237.75; 82.74 233.78; 83.29 230.1; 83.52 230.1];
init.tCH4_PT724523831 = 485; units.init.tCH4_PT724523831 = 'kg'; label.init.tCH4_PT724523831 = 'Initial weight';
units.tCH4_PT724523831 = {'d', 'g/d'}; label.tCH4_PT724523831 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT724523831 = 'Daily CH4 emissions of individual PT724523831'; comment.tCH4_PT724523831 = 'Data from GreenBeef trial 1, individual PT724523831'; bibkey.tCH4_PT724523831 = 'GreenBeefTrial1';

data.tCH4_PT333653651 = [48.70 171.91; 48.82 171.91; 49.03 171.91; 49.59 185.94; 49.80 190.22; 50.01 190.22; 50.30 203.65; 50.56 198.19; 50.78 198.19; 51.03 192.36; 51.38 186.0; 51.64 193.24; 51.88 184.72; 52.06 168.7; 52.29 171.21; 52.52 162.27; 52.74 170.55; 52.98 169.52; 53.06 180.66; 53.30 173.02; 53.53 162.11; 53.75 156.14; 53.97 162.35; 54.06 162.87; 54.31 168.14; 54.57 181.12; 54.81 182.74; 55.08 190.52; 55.29 192.01; 55.52 178.88; 55.73 175.2; 55.95 175.81; 56.07 180.64; 56.28 174.86; 76.42 195.9; 76.69 210.64; 76.93 204.72; 77.02 204.72; 77.28 195.36; 77.73 199.0; 77.94 225.32; 78.01 218.14; 78.27 227.26; 78.50 228.24; 78.74 224.12; 79.05 185.53; 79.26 170.64; 79.50 185.34; 79.76 194.49; 80.02 220.0; 81.83 40.48; 82.32 49.69; 82.72 62.47; 83.04 76.79; 83.30 79.69; 83.54 79.69];
init.tCH4_PT333653651 = 536; units.init.tCH4_PT333653651 = 'kg'; label.init.tCH4_PT333653651 = 'Initial weight';
units.tCH4_PT333653651 = {'d', 'g/d'}; label.tCH4_PT333653651 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT333653651 = 'Daily CH4 emissions of individual PT333653651'; comment.tCH4_PT333653651 = 'Data from GreenBeef trial 1, individual PT333653651'; bibkey.tCH4_PT333653651 = 'GreenBeefTrial1';

data.tCH4_PT924401183 = [44.54 43.12; 70.45 162.71; 70.68 162.71; 71.44 91.17; 71.65 101.0; 71.94 97.4; 72.00 97.4; 72.52 185.64; 73.35 172.06; 73.37 172.06; 73.69 158.59; 73.71 158.59; 73.81 149.63; 73.98 143.96; 74.07 147.07; 74.30 141.71; 74.39 140.22; 74.53 142.45; 74.81 140.17; 75.11 156.58; 75.26 161.76; 75.41 157.82; 75.49 157.82; 75.71 169.63; 76.24 107.23];
init.tCH4_PT924401183 = 510; units.init.tCH4_PT924401183 = 'kg'; label.init.tCH4_PT924401183 = 'Initial weight';
units.tCH4_PT924401183 = {'d', 'g/d'}; label.tCH4_PT924401183 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT924401183 = 'Daily CH4 emissions of individual PT924401183'; comment.tCH4_PT924401183 = 'Data from GreenBeef trial 1, individual PT924401183'; bibkey.tCH4_PT924401183 = 'GreenBeefTrial1';


%% Time vs Daily carbon dioxide (CO2) emissions data

data.tCO2_PT933843912 = [0.40 8707.14; 0.62 9504.12; 0.99 9713.96; 1.07 9713.96; 1.35 10242.35; 1.62 10198.84; 1.87 10160.22; 2.11 9727.7; 2.33 9609.15; 2.58 9238.61; 3.00 8804.1; 3.30 9882.59; 3.57 10515.96; 3.79 10303.57; 4.00 10178.13; 4.08 10464.25; 4.30 10257.11; 4.57 9952.34; 4.80 10076.93; 5.02 9906.01; 5.35 9342.76; 5.61 9829.08; 5.90 10843.15; 6.05 10843.15; 6.33 11075.23; 6.35 11075.23; 27.39 9988.13; 27.51 9716.02; 27.61 9764.79; 27.73 9764.79; 27.85 9535.25; 27.96 9341.08; 28.08 9449.27; 28.30 9155.11; 28.39 8833.57; 28.53 8913.24; 28.67 9046.62; 28.78 8935.49; 29.07 9235.55; 29.21 9737.86; 29.32 10215.66; 29.57 9920.72; 29.78 10333.72; 30.05 9984.6; 30.29 9911.81; 30.51 10397.16; 30.75 10650.71; 30.79 10772.84; 32.42 8354.9; 32.69 8463.4; 32.90 8387.31; 32.95 8681.91; 33.39 8805.82; 33.67 8892.1; 33.97 8961.73; 34.05 8961.73; 34.30 8686.56; 34.61 9143.22; 34.88 8956.08; 35.00 8956.08; 35.28 9249.41; 56.52 8878.04; 56.60 9522.59; 56.73 9522.59; 56.95 9576.38; 57.02 9913.12; 57.28 10516.06; 57.76 9649.77; 57.99 9599.36; 58.07 9599.36; 58.30 9682.12; 58.57 9832.68; 58.79 9659.65; 59.02 9663.63; 59.28 10005.08; 59.53 9049.75; 60.35 10759.53; 60.56 10917.02; 60.78 10917.02; 61.04 10980.75; 61.29 10718.38; 61.51 10915.33; 61.80 11179.81; 62.04 11266.93; 62.27 11005.72; 62.55 10668.24; 63.00 10975.56; 63.07 11226.71; 63.28 11226.71];
init.tCO2_PT933843912 = 545; units.init.tCO2_PT933843912 = 'kg'; label.init.tCO2_PT933843912 = 'Initial weight';
units.tCO2_PT933843912 = {'d', 'g/d'}; label.tCO2_PT933843912 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT933843912 = 'Daily CO2 emissions of individual PT933843912'; comment.tCO2_PT933843912 = 'Data from GreenBeef trial 1, individual PT933843912'; bibkey.tCO2_PT933843912 = 'GreenBeefTrial1';

data.tCO2_PT533987885 = [6.48 7653.18; 6.72 7652.59; 7.01 8021.63; 7.40 8194.44; 7.71 8465.96; 8.41 8164.52; 8.65 8164.52; 9.41 7554.53; 9.69 7554.53; 10.31 6239.78; 11.40 7689.93; 12.36 7648.7; 12.67 7648.7; 13.33 6259.75; 35.37 8082.34; 35.60 7952.37; 35.93 7869.56; 36.15 8203.13; 36.43 8535.48; 36.50 8746.23; 36.82 8017.2; 37.30 8157.71; 37.57 7656.85; 37.82 8257.64; 38.29 8219.1; 38.61 8147.51; 39.31 7423.3; 39.55 7730.52; 39.92 7366.78; 40.09 7610.25; 40.32 7568.02; 40.68 7298.77; 40.98 7361.37; 41.06 7361.37; 41.33 7395.15; 41.56 7195.41; 63.45 7373.04; 63.67 7727.0; 64.03 7659.51; 64.30 7987.34; 64.54 7838.15; 64.78 8108.32; 65.08 8366.48; 65.34 7963.14; 65.71 7485.3; 66.26 6652.72; 66.97 8066.5; 67.28 7910.38; 67.56 7785.81; 67.83 7760.69; 68.33 7801.27; 68.62 7878.62; 68.96 8047.03; 69.06 8047.03; 69.62 7442.33; 70.09 7442.33];
init.tCO2_PT533987885 = 436; units.init.tCO2_PT533987885 = 'kg'; label.init.tCO2_PT533987885 = 'Initial weight';
units.tCO2_PT533987885 = {'d', 'g/d'}; label.tCO2_PT533987885 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT533987885 = 'Daily CO2 emissions of individual PT533987885'; comment.tCO2_PT533987885 = 'Data from GreenBeef trial 1, individual PT533987885'; bibkey.tCO2_PT533987885 = 'GreenBeefTrial1';

data.tCO2_PT624139868 = [0.43 7048.22; 0.66 7250.75; 0.89 7369.2; 1.00 7187.44; 1.24 7472.97; 1.50 7436.76; 1.71 7534.71; 1.93 7378.02; 2.07 7804.84; 2.29 7558.11; 2.60 8232.67; 2.84 8490.78; 3.08 8490.78; 3.31 8473.13; 3.68 7700.41; 3.90 7620.71; 4.05 7620.71; 4.29 7621.1; 4.60 7646.48; 4.75 7646.48; 4.89 7455.09; 5.03 7455.09; 5.29 6726.93; 5.63 6723.31; 5.67 6723.31; 5.91 6710.85; 6.06 6710.85; 6.34 7546.89; 27.40 7845.56; 27.43 7845.56; 27.62 8075.74; 27.78 8075.74; 27.86 8075.74; 28.10 7939.24; 28.38 8103.44; 28.55 8309.16; 28.68 8211.18; 28.95 8191.9; 29.09 8553.22; 29.42 8268.96; 29.67 7563.62; 29.93 7737.08; 30.06 7737.08; 30.08 7793.66; 30.30 7833.26; 30.56 8032.11; 30.90 8466.54; 31.06 8237.38; 31.29 7952.3; 31.51 7827.52; 31.70 8017.93; 31.73 8017.93; 31.95 7590.66; 32.15 7699.53; 32.38 7858.64; 32.43 7958.03; 32.63 8075.84; 32.91 7983.42; 33.03 8222.8; 33.32 8245.59; 33.57 8379.26; 33.80 8379.26; 34.05 7903.23; 34.33 7604.96; 34.35 7604.96; 34.62 7834.08; 34.91 8409.51; 35.01 8409.51; 56.43 7243.95; 56.94 9214.91; 57.31 9025.4; 57.64 9548.28; 57.93 9573.58; 58.01 9573.58; 58.58 9664.13; 58.80 9288.85; 59.04 9288.85; 59.28 9814.58; 59.56 9747.53; 59.77 9747.53; 60.04 10013.54; 60.31 9556.75; 60.54 9223.35; 60.77 9013.28; 61.05 9114.37; 61.26 9120.55; 61.60 8919.17; 61.95 9283.66; 62.03 9283.66; 62.28 9172.02; 62.55 9827.88; 62.79 9399.45; 63.15 9752.91];
init.tCO2_PT624139868 = 464; units.init.tCO2_PT624139868 = 'kg'; label.init.tCO2_PT624139868 = 'Initial weight';
units.tCO2_PT624139868 = {'d', 'g/d'}; label.tCO2_PT624139868 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT624139868 = 'Daily CO2 emissions of individual PT624139868'; comment.tCO2_PT624139868 = 'Data from GreenBeef trial 1, individual PT624139868'; bibkey.tCO2_PT624139868 = 'GreenBeefTrial1';

data.tCO2_PT424401157 = [0.41 7716.88; 0.88 7716.88; 1.48 8294.1; 1.70 8489.94; 2.00 8619.14; 2.29 8639.31; 2.58 8801.63; 2.96 8709.51; 3.01 8709.51; 3.28 8310.41; 3.57 8199.64; 3.79 8326.12; 4.00 8326.12; 4.23 8737.0; 4.56 8613.49; 4.81 8296.03; 5.00 8296.03; 5.29 7920.38; 5.53 7456.25; 5.77 7742.73; 6.05 8126.21; 6.26 8126.21; 27.44 7660.26; 27.78 7994.02; 28.08 7751.62; 28.32 8046.68; 28.54 8046.68; 28.78 7942.88; 29.08 8326.67; 29.31 7941.06; 29.56 8199.42; 29.80 8225.03; 30.05 8021.27; 30.28 8462.52; 30.51 8894.56; 30.75 8974.66; 30.80 9124.74; 31.01 9601.2; 32.56 6314.88; 33.11 7359.86; 33.35 7549.82; 33.56 7631.61; 33.78 7673.14; 34.06 7661.95; 34.31 7408.98; 34.61 7900.82; 34.93 7782.36; 35.04 7782.36; 35.28 8063.14; 56.42 8496.64; 56.52 8835.9; 56.66 8835.9; 56.74 8754.72; 57.01 8617.74; 57.22 8705.73; 57.44 8470.97; 57.68 8273.36; 57.97 8196.26; 58.12 8230.06; 58.30 7839.9; 58.57 8103.58; 58.79 7805.49; 59.05 8074.6; 59.30 8821.05; 59.54 8821.05; 59.76 8528.64; 60.34 9106.08; 60.57 8893.42; 60.78 8893.42; 61.06 9012.48; 61.28 8468.08; 61.60 9014.11; 61.83 8962.23; 62.05 8779.62; 62.28 8954.21; 62.34 8880.45; 62.55 8659.3; 62.78 8844.41; 63.06 8814.18; 63.31 8834.4];
init.tCO2_PT424401157 = 469; units.init.tCO2_PT424401157 = 'kg'; label.init.tCO2_PT424401157 = 'Initial weight';
units.tCO2_PT424401157 = {'d', 'g/d'}; label.tCO2_PT424401157 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT424401157 = 'Daily CO2 emissions of individual PT424401157'; comment.tCO2_PT424401157 = 'Data from GreenBeef trial 1, individual PT424401157'; bibkey.tCO2_PT424401157 = 'GreenBeefTrial1';

data.tCO2_PT533358890 = [20.49 8021.41; 20.71 7986.48; 20.94 7734.74; 20.96 7734.74; 21.11 7639.8; 21.12 7519.6; 21.25 7480.36; 21.33 7480.36; 21.34 7480.36; 21.58 7578.06; 21.60 7578.06; 21.61 7506.38; 21.88 7679.87; 22.07 7671.97; 22.31 8304.61; 22.57 8161.06; 22.78 8260.47; 23.01 8396.44; 23.26 8638.86; 23.49 8599.2; 23.70 8745.53; 23.91 8497.66; 24.05 8495.7; 24.32 8382.02; 24.89 7974.36; 25.04 8125.62; 25.26 8125.62; 25.51 8056.98; 25.78 8257.47; 26.07 7661.08; 26.32 8227.09; 26.54 8249.12; 26.77 8069.89; 27.01 8289.8; 27.26 8632.71; 48.69 9030.08; 48.71 9030.08; 48.89 8782.38; 48.96 8782.38; 49.01 8776.28; 49.23 8135.3; 49.30 8135.3; 49.49 8069.81; 49.54 8106.01; 49.69 8106.01; 49.70 8106.01; 49.93 8350.41; 50.00 8274.46; 50.24 9122.47; 50.46 9236.76; 50.71 8951.72; 50.93 8573.38; 51.04 8647.67; 51.05 8464.91; 51.27 8291.32; 51.54 8314.41; 51.78 8556.0; 52.02 8021.52; 52.27 8154.22; 52.48 8434.87; 52.49 8434.87; 52.69 8595.32; 52.97 8769.0; 53.01 9408.85; 53.08 9408.85; 53.25 9507.49; 53.49 9281.3; 53.71 8955.43; 53.96 9054.87; 54.02 9074.79; 54.27 9089.66; 54.54 9231.8; 54.76 9231.8; 55.03 9075.23; 55.27 9375.7; 55.54 9717.85; 55.76 9717.85; 55.99 9774.28; 56.04 9774.28; 56.29 9860.4; 76.40 8442.19; 76.45 8442.19; 76.57 8735.95; 76.63 8715.2; 76.71 8715.2; 76.85 8732.65; 77.00 8742.56; 77.07 8857.02; 77.24 9249.58; 77.46 9423.97; 77.71 9672.66; 77.94 9975.5; 78.04 10198.22; 78.26 10101.1; 78.47 9823.69; 78.69 9749.48; 78.91 9517.0; 79.06 9356.1; 79.27 9523.22; 79.55 9140.52; 79.80 8766.49; 80.01 8766.49; 80.26 8490.23; 80.52 8357.75; 80.73 8842.67; 80.84 8790.34; 81.02 8767.75; 81.23 8688.06; 81.45 9344.79; 81.67 9396.13; 81.94 9185.84; 82.04 9192.7; 82.30 9544.19; 82.32 9544.19; 82.52 9444.45; 82.73 9487.85; 82.98 9875.89; 83.07 10140.68; 83.29 10076.22; 83.51 10014.29];
init.tCO2_PT533358890 = 477; units.init.tCO2_PT533358890 = 'kg'; label.init.tCO2_PT533358890 = 'Initial weight';
units.tCO2_PT533358890 = {'d', 'g/d'}; label.tCO2_PT533358890 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT533358890 = 'Daily CO2 emissions of individual PT533358890'; comment.tCO2_PT533358890 = 'Data from GreenBeef trial 1, individual PT533358890'; bibkey.tCO2_PT533358890 = 'GreenBeefTrial1';

data.tCO2_PT533843896 = [13.62 6534.45; 14.28 6549.72; 14.57 6549.72; 14.60 6549.72; 15.31 7685.44; 15.61 7821.38; 15.91 7536.29; 16.10 7274.58; 16.37 7108.5; 16.60 7338.74; 16.90 7482.04; 17.31 8181.86; 17.53 8200.08; 17.76 8200.08; 18.66 8120.72; 18.98 8206.22; 19.41 8526.78; 19.64 8614.24; 19.89 8494.7; 20.01 8524.06; 20.25 8609.87; 41.78 9310.55; 41.86 9310.55; 42.37 7644.32; 42.40 7644.32; 42.60 8181.95; 42.93 8558.25; 43.29 9077.37; 43.53 8614.39; 43.90 8620.01; 44.04 8753.71; 44.35 9245.01; 44.49 9412.83; 44.56 9336.23; 44.78 9336.23; 45.32 7536.74; 45.62 8060.49; 46.02 8160.29; 46.29 8642.22; 46.58 8600.8; 46.96 8736.51; 47.04 8736.51; 47.33 8587.39; 47.65 9234.47; 47.86 9077.99; 48.03 9077.99; 48.26 9066.48; 48.62 8046.53; 70.37 8703.1; 70.41 8703.1; 70.60 8703.1; 70.82 9120.58; 71.12 9555.08; 71.36 8667.25; 71.70 7959.51; 71.73 7959.51; 72.28 8614.33; 72.58 8614.33; 73.51 7832.34; 73.73 7832.34; 74.26 8276.49; 74.54 8748.75; 74.81 8964.77; 75.27 9401.87; 75.67 9413.09; 76.07 9150.27; 76.38 9035.46];
init.tCO2_PT533843896 = 480; units.init.tCO2_PT533843896 = 'kg'; label.init.tCO2_PT533843896 = 'Initial weight';
units.tCO2_PT533843896 = {'d', 'g/d'}; label.tCO2_PT533843896 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT533843896 = 'Daily CO2 emissions of individual PT533843896'; comment.tCO2_PT533843896 = 'Data from GreenBeef trial 1, individual PT533843896'; bibkey.tCO2_PT533843896 = 'GreenBeefTrial1';

data.tCO2_PT833653644 = [0.42 8157.8; 4.74 10224.1; 5.75 9038.84; 27.49 9173.56; 27.74 8903.52; 28.01 8786.53; 28.29 8919.83; 28.54 9105.29; 28.76 9092.01; 29.19 8638.07; 29.41 8257.96; 29.66 8128.09; 29.92 7637.17; 30.07 7715.4; 30.32 8103.95; 30.54 8148.06; 30.78 8612.03; 31.05 8634.8; 31.31 8216.65; 31.55 8216.65; 31.77 7721.81; 32.18 7832.24; 32.33 7766.66; 32.40 7766.66; 32.62 8094.12; 33.02 8314.29; 33.28 8312.08; 33.67 7961.86; 34.10 7914.66; 34.35 7926.93; 34.57 8130.52; 34.96 8171.64; 35.11 8408.17; 56.43 7405.18; 56.64 8262.18; 56.93 8564.81; 57.07 8564.81; 57.32 8653.51; 57.66 8867.14; 57.92 9049.2; 58.04 9049.2; 58.29 9054.07; 58.56 8864.15; 58.84 8929.2; 59.15 8885.19; 59.47 9633.56; 59.78 9415.06; 60.00 9419.18; 60.08 9319.28; 60.30 8956.73; 60.54 9178.07; 60.77 9267.61; 61.00 9318.25; 61.31 9185.44; 61.59 9556.24; 61.82 9731.4; 62.00 9731.4; 62.29 10009.31; 62.51 9695.62; 62.73 9662.36; 62.96 9433.02; 63.05 9242.86; 63.29 8979.88];
init.tCO2_PT833653644 = 548; units.init.tCO2_PT833653644 = 'kg'; label.init.tCO2_PT833653644 = 'Initial weight';
units.tCO2_PT833653644 = {'d', 'g/d'}; label.tCO2_PT833653644 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT833653644 = 'Daily CO2 emissions of individual PT833653644'; comment.tCO2_PT833653644 = 'Data from GreenBeef trial 1, individual PT833653644'; bibkey.tCO2_PT833653644 = 'GreenBeefTrial1';

data.tCO2_PT433843806 = [1.28 8733.75; 2.42 9420.35; 2.74 9189.7; 3.07 9198.3; 3.29 9040.97; 3.72 9180.39; 4.01 9372.32; 4.27 9242.03; 4.69 9256.5; 5.10 9271.53; 5.33 8713.21; 5.64 8576.6; 5.95 8663.78; 6.07 8663.78; 6.36 8871.74; 27.42 10088.62; 27.73 9791.88; 28.07 9780.82; 28.30 9756.97; 28.52 9756.97; 28.73 9943.17; 29.32 9473.27; 29.58 9341.51; 29.81 9373.04; 30.02 9125.92; 30.29 9155.61; 30.52 9656.17; 30.84 9690.23; 31.09 9866.46; 31.33 9576.08; 31.64 9136.46; 31.91 9260.65; 32.01 9260.65; 32.37 9690.52; 32.75 9810.22; 33.07 9055.73; 33.30 9314.33; 33.55 9229.88; 33.76 9273.26; 34.01 9448.26; 34.32 8920.14; 34.63 8979.04; 34.97 9252.45; 35.05 9252.45; 35.30 9298.3; 56.41 9915.27; 56.72 9998.55; 57.02 9765.47; 57.31 9334.35; 57.61 9521.43; 57.90 9538.75; 58.37 9851.83; 58.72 9620.84; 59.02 9652.86; 59.30 9706.47; 59.52 9597.51; 59.75 9500.8; 60.05 9433.94; 60.32 8714.35; 60.59 9046.37; 60.94 9075.64; 61.29 9917.18; 61.55 9820.67; 61.78 9846.84; 62.14 10047.24; 62.36 9443.79; 62.59 9374.06; 62.94 9207.59; 63.19 9153.84];
init.tCO2_PT433843806 = 507; units.init.tCO2_PT433843806 = 'kg'; label.init.tCO2_PT433843806 = 'Initial weight';
units.tCO2_PT433843806 = {'d', 'g/d'}; label.tCO2_PT433843806 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT433843806 = 'Daily CO2 emissions of individual PT433843806'; comment.tCO2_PT433843806 = 'Data from GreenBeef trial 1, individual PT433843806'; bibkey.tCO2_PT433843806 = 'GreenBeefTrial1';

data.tCO2_PT224401177 = [13.50 9014.9; 13.77 8905.94; 14.19 8440.23; 14.55 8213.92; 14.87 8326.74; 15.06 8841.88; 15.29 8919.09; 15.68 8495.61; 16.68 8468.94; 17.32 7883.79; 17.70 8133.57; 17.96 9048.53; 18.34 9033.88; 18.61 9285.59; 18.91 8367.96; 19.31 8553.94; 19.68 8136.8; 20.32 9392.68; 41.98 10117.44; 42.14 10000.63; 42.40 10097.91; 42.63 10132.79; 42.87 9788.17; 43.14 10510.6; 43.39 10518.47; 43.64 10531.42; 43.92 10419.76; 44.01 10419.76; 44.30 10426.65; 44.56 10343.85; 44.77 10343.85; 45.47 10127.97; 45.69 10353.81; 45.98 10490.03; 46.10 10490.03; 46.36 9936.43; 46.63 9282.96; 46.92 9036.41; 47.40 9757.46; 47.66 10212.82; 47.90 10496.44; 48.02 10379.33; 48.40 10089.43; 48.63 10089.56; 70.36 10250.29; 70.57 10250.29; 70.81 10278.28; 71.15 10906.82; 71.37 10785.35; 71.79 11104.94; 71.95 11315.93; 72.13 11315.93; 72.36 11193.27; 73.36 8886.4; 73.73 9197.21; 73.99 9493.92; 74.21 9537.38; 74.52 9750.72; 74.75 9874.96; 74.97 9859.92; 75.13 9907.96; 75.35 9678.69; 75.72 9558.96; 76.01 9817.52; 76.30 10405.45];
init.tCO2_PT224401177 = 562; units.init.tCO2_PT224401177 = 'kg'; label.init.tCO2_PT224401177 = 'Initial weight';
units.tCO2_PT224401177 = {'d', 'g/d'}; label.tCO2_PT224401177 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT224401177 = 'Daily CO2 emissions of individual PT224401177'; comment.tCO2_PT224401177 = 'Data from GreenBeef trial 1, individual PT224401177'; bibkey.tCO2_PT224401177 = 'GreenBeefTrial1';

data.tCO2_PT833653649 = [6.58 8164.99; 6.86 7860.79; 7.03 7921.86; 7.28 8231.45; 7.51 8380.19; 7.75 8475.24; 8.00 8729.72; 8.31 8645.65; 8.61 8402.77; 8.90 8377.68; 9.15 8188.16; 9.46 8958.88; 9.75 9361.93; 10.12 10086.72; 10.99 8020.83; 11.39 8520.57; 11.68 8342.66; 11.92 8378.38; 12.15 7948.58; 12.59 7579.98; 13.00 7464.48; 35.39 9434.14; 35.65 9580.48; 35.92 9183.65; 36.01 9183.65; 36.29 9074.92; 36.62 8727.54; 36.99 8521.73; 37.08 8521.73; 37.32 8544.62; 37.61 8481.41; 37.95 8872.08; 38.14 9053.23; 38.41 9146.8; 38.67 9197.72; 38.91 8951.29; 39.01 8934.36; 39.30 8701.75; 39.56 9230.48; 39.98 9199.63; 40.26 9062.61; 40.52 8393.02; 40.76 8717.63; 41.10 9206.47; 41.45 9348.12; 41.70 9176.46; 63.40 8310.96; 63.86 8496.62; 64.04 8410.4; 64.26 8410.4; 64.50 9414.38; 64.79 10293.3; 65.09 9914.22; 65.40 8843.87; 65.63 9172.97; 65.97 9543.82; 66.02 9543.82; 66.28 9989.89; 66.60 9877.33; 66.92 9320.15; 67.14 9392.61; 67.39 9386.2; 67.67 9689.13; 67.90 9916.72; 68.05 9769.67; 68.29 9870.34; 68.52 9831.08; 68.82 9891.61; 69.03 9887.06; 69.35 9697.94; 70.06 10019.65; 70.28 10019.65];
init.tCO2_PT833653649 = 535; units.init.tCO2_PT833653649 = 'kg'; label.init.tCO2_PT833653649 = 'Initial weight';
units.tCO2_PT833653649 = {'d', 'g/d'}; label.tCO2_PT833653649 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT833653649 = 'Daily CO2 emissions of individual PT833653649'; comment.tCO2_PT833653649 = 'Data from GreenBeef trial 1, individual PT833653649'; bibkey.tCO2_PT833653649 = 'GreenBeefTrial1';

data.tCO2_PT524401180 = [6.45 6323.22; 6.68 6928.93; 7.01 6880.36; 7.33 8277.31; 7.63 7999.94; 8.01 7886.3; 8.30 6958.22; 8.56 7132.55; 8.99 7037.52; 9.05 7037.52; 9.33 7132.76; 9.60 6783.62; 10.35 7407.25; 10.67 7587.18; 11.01 7554.64; 11.48 7907.39; 11.75 8038.64; 12.07 8149.38; 12.31 7896.82; 12.57 8520.01; 12.88 8233.92; 13.11 8418.55; 13.33 8418.55; 35.36 8035.32; 35.59 8672.2; 35.94 8506.85; 36.02 8506.85; 36.30 8782.39; 36.52 8748.16; 36.74 8784.19; 36.96 9042.01; 37.02 9198.78; 37.31 9069.62; 37.56 8907.0; 37.78 8757.46; 38.14 8424.52; 38.37 8275.77; 38.62 8370.58; 38.92 8254.58; 39.15 8186.62; 39.31 8186.62; 39.47 8232.78; 39.92 8158.41; 40.09 8469.51; 40.42 8403.3; 40.68 9126.38; 40.96 9339.65; 41.47 8157.03; 41.71 8157.03; 63.35 10281.93; 63.56 10179.42; 63.79 10067.92; 64.02 9949.07; 64.28 10019.9; 64.53 9801.21; 64.76 9508.43; 65.00 9480.06; 65.22 9513.46; 65.55 9771.12; 65.96 9710.72; 66.00 9710.72; 66.29 9700.83; 66.58 9600.81; 66.84 9789.51; 67.07 9565.56; 67.29 9708.94; 67.54 9503.24; 67.79 9300.76; 68.06 9081.2; 68.31 8695.9; 68.64 9101.66; 68.95 9097.36; 69.05 9097.36; 69.28 9289.45; 69.68 9033.55; 69.98 9142.41; 70.11 9142.41; 70.34 9027.59];
init.tCO2_PT524401180 = 496; units.init.tCO2_PT524401180 = 'kg'; label.init.tCO2_PT524401180 = 'Initial weight';
units.tCO2_PT524401180 = {'d', 'g/d'}; label.tCO2_PT524401180 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT524401180 = 'Daily CO2 emissions of individual PT524401180'; comment.tCO2_PT524401180 = 'Data from GreenBeef trial 1, individual PT524401180'; bibkey.tCO2_PT524401180 = 'GreenBeefTrial1';

data.tCO2_PT933843894 = [6.45 10455.05; 6.73 10208.01; 7.19 10082.45; 7.68 9618.79; 8.42 8212.67; 8.66 9160.06; 8.98 9031.25; 9.14 9031.25; 9.38 9717.34; 10.09 9578.58; 10.72 9211.96; 11.34 9856.66; 12.11 9126.57; 12.39 9061.07; 12.67 8606.68; 12.97 8749.93; 13.11 8749.93; 35.38 9382.61; 35.66 10367.87; 35.95 10284.61; 36.33 10713.84; 36.64 9917.73; 37.01 9503.56; 37.35 9991.25; 37.77 10021.74; 37.98 10143.8; 38.02 10143.8; 38.35 9805.18; 38.67 9647.14; 38.77 9647.14; 38.89 9688.97; 39.01 9688.97; 39.33 9098.58; 39.61 9409.98; 39.87 9634.41; 40.11 9634.41; 40.33 10028.77; 40.66 9724.19; 40.96 9117.53; 41.35 8970.36; 41.67 8667.46; 63.38 10784.69; 63.60 10542.54; 63.91 10154.98; 64.05 10154.98; 64.33 10061.71; 64.71 9826.56; 65.02 9785.63; 65.30 9672.93; 65.62 10425.14; 65.83 10848.26; 66.17 11230.24; 67.92 10555.53; 68.06 10597.26; 68.47 10401.1; 68.73 10050.6; 69.07 9205.68; 69.35 9031.88; 69.67 9325.32; 70.00 9915.0];
init.tCO2_PT933843894 = 508; units.init.tCO2_PT933843894 = 'kg'; label.init.tCO2_PT933843894 = 'Initial weight';
units.tCO2_PT933843894 = {'d', 'g/d'}; label.tCO2_PT933843894 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT933843894 = 'Daily CO2 emissions of individual PT933843894'; comment.tCO2_PT933843894 = 'Data from GreenBeef trial 1, individual PT933843894'; bibkey.tCO2_PT933843894 = 'GreenBeefTrial1';

data.tCO2_PT033634130 = [20.96 8452.75; 20.99 8452.75; 21.64 7219.39; 22.10 7219.39; 22.61 7188.85; 24.54 7464.52; 24.80 7413.68; 25.04 7185.38; 25.29 7367.59; 25.52 7505.5; 25.81 7644.03; 26.06 8370.02; 26.33 8407.65; 26.79 8316.01; 27.28 8248.94; 48.72 10713.03; 49.52 7724.5; 50.06 7864.04; 50.29 7864.04; 50.55 8244.27; 50.88 8219.57; 51.06 8307.99; 51.32 8187.53; 51.57 8259.28; 51.79 8259.28; 52.06 8098.04; 52.31 8725.67; 52.53 8812.49; 52.76 9012.33; 52.98 8918.15; 53.12 9416.8; 53.42 8736.73; 53.67 8188.73; 53.95 8154.84; 54.13 8154.84; 54.40 8132.44; 54.66 8225.14; 54.91 8363.94; 55.00 8308.88; 55.24 8664.72; 55.49 8670.04; 55.73 8556.25; 55.96 8482.08; 56.07 8580.45; 56.30 8308.79; 76.43 8436.58; 76.66 9075.55; 76.94 8781.74; 77.06 8706.73; 77.28 9251.65; 77.54 8948.72; 77.76 8943.06; 78.28 8678.33; 78.50 8678.33; 78.74 8808.43; 79.04 9115.85; 79.25 9194.25; 79.49 9322.29; 79.72 9226.64; 79.94 9070.41; 80.03 8798.32; 80.26 8937.97; 80.50 8713.85; 80.76 8756.84; 81.01 9390.04; 81.76 9367.69; 82.09 9188.3; 82.48 8921.34; 82.73 9047.68; 83.00 8922.74; 83.28 9058.05; 83.50 9058.05];
init.tCO2_PT033634130 = 453; units.init.tCO2_PT033634130 = 'kg'; label.init.tCO2_PT033634130 = 'Initial weight';
units.tCO2_PT033634130 = {'d', 'g/d'}; label.tCO2_PT033634130 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT033634130 = 'Daily CO2 emissions of individual PT033634130'; comment.tCO2_PT033634130 = 'Data from GreenBeef trial 1, individual PT033634130'; bibkey.tCO2_PT033634130 = 'GreenBeefTrial1';

data.tCO2_PT233843883 = [22.97 9409.32; 23.02 9409.32; 24.10 9761.71; 24.65 9064.02; 24.94 9176.51; 25.06 9176.51; 25.07 9176.51; 25.28 8967.96; 25.58 9068.68; 25.79 9066.88; 26.09 9344.94; 26.32 9592.5; 26.54 9553.11; 26.77 9536.11; 27.01 9606.73; 27.34 9867.79; 48.74 10951.22; 49.02 10951.22; 49.63 9712.17; 49.90 9493.98; 50.06 9208.45; 50.28 9544.65; 50.54 9255.12; 50.87 9167.06; 51.06 9533.97; 51.30 9053.54; 51.59 9115.2; 51.80 9214.95; 52.05 9235.43; 52.35 9712.22; 52.59 9620.28; 52.81 9620.28; 53.07 9707.97; 53.32 9771.09; 53.54 9435.11; 53.80 9383.39; 54.00 8952.64; 54.28 9088.97; 54.49 8945.09; 54.75 9084.27; 54.97 8873.88; 55.11 9089.74; 55.35 8666.82; 55.62 8878.62; 55.92 8997.5; 56.01 8997.5; 56.30 9269.54; 76.44 7934.94; 76.70 7934.94; 77.25 8284.15; 77.53 8668.15; 77.76 9276.29; 78.04 9959.21; 78.28 9609.77; 78.56 9142.59; 78.79 9214.24; 79.11 9348.58; 79.53 9343.65; 79.77 9101.93; 80.04 8864.97; 80.30 9015.34; 80.52 9235.24; 80.75 9295.37; 81.01 9056.48; 81.24 9641.02; 81.48 9233.34; 81.76 8751.57; 82.03 8938.64; 82.29 9314.92; 82.50 9543.65; 82.76 9589.23; 82.99 9601.54; 83.09 9685.94; 83.33 9227.34; 83.62 8732.16];
init.tCO2_PT233843883 = 506; units.init.tCO2_PT233843883 = 'kg'; label.init.tCO2_PT233843883 = 'Initial weight';
units.tCO2_PT233843883 = {'d', 'g/d'}; label.tCO2_PT233843883 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT233843883 = 'Daily CO2 emissions of individual PT233843883'; comment.tCO2_PT233843883 = 'Data from GreenBeef trial 1, individual PT233843883'; bibkey.tCO2_PT233843883 = 'GreenBeefTrial1';

data.tCO2_PT333842562 = [6.44 8639.62; 6.66 8546.49; 6.70 8546.49; 6.92 8567.46; 7.11 8583.63; 7.35 8664.2; 7.62 8468.46; 7.87 8274.77; 8.20 8229.5; 8.55 8302.72; 8.94 8487.01; 9.10 8620.4; 9.37 8620.4; 9.59 9074.55; 9.94 9583.55; 10.62 8288.03; 10.99 8271.19; 11.06 8423.23; 11.33 8677.28; 11.56 8825.79; 12.06 9044.43; 12.29 9044.43; 12.51 9054.87; 12.99 8620.65; 13.07 8319.61; 13.31 8319.61; 13.35 8319.61; 35.37 9453.42; 35.64 9086.85; 35.86 8824.78; 36.00 8317.73; 36.31 8657.32; 36.60 9330.78; 36.81 9848.87; 37.08 9983.01; 37.38 9799.36; 37.59 9787.67; 37.86 9543.5; 38.15 9628.29; 38.40 9423.11; 38.66 9824.72; 38.90 9539.48; 39.40 9771.56; 39.68 9464.74; 39.90 9338.41; 40.05 9392.43; 40.32 9198.22; 40.56 9142.13; 40.79 8916.15; 41.03 8936.91; 41.27 9298.33; 41.56 9034.73; 63.36 9217.95; 63.40 9225.38; 63.61 9699.25; 63.89 9470.07; 64.02 9597.34; 64.29 10163.81; 64.51 10392.84; 64.76 9992.21; 65.38 10680.19; 65.79 10560.14; 66.10 10823.96; 66.68 10715.07; 66.95 10715.07; 67.16 10712.22; 67.60 10822.43; 67.97 10124.92; 68.09 10124.92; 68.34 9756.19; 68.61 9214.89; 68.96 9680.29; 69.08 9810.3; 69.29 10124.19; 69.51 10135.91; 69.75 10048.81; 69.99 9731.59; 70.08 9581.9; 70.33 9176.47];
init.tCO2_PT333842562 = 515; units.init.tCO2_PT333842562 = 'kg'; label.init.tCO2_PT333842562 = 'Initial weight';
units.tCO2_PT333842562 = {'d', 'g/d'}; label.tCO2_PT333842562 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT333842562 = 'Daily CO2 emissions of individual PT333842562'; comment.tCO2_PT333842562 = 'Data from GreenBeef trial 1, individual PT333842562'; bibkey.tCO2_PT333842562 = 'GreenBeefTrial1';

data.tCO2_PT933602927 = [13.53 6576.53; 13.61 6576.53; 13.69 6533.72; 13.78 6533.72; 13.91 6533.72; 14.18 6450.63; 14.41 6012.48; 15.37 7308.03; 15.70 7245.18; 16.01 7819.93; 16.31 7243.88; 16.52 7285.35; 16.74 7217.33; 17.15 6895.85; 17.60 6925.96; 17.98 6967.85; 18.31 7143.68; 18.38 7143.68; 18.55 7244.61; 18.77 7244.61; 18.99 7206.13; 19.00 7206.13; 19.28 7021.49; 19.55 6849.67; 19.98 6847.64; 20.17 6750.62; 41.75 8872.3; 42.00 8404.91; 42.32 7458.71; 42.62 7210.3; 42.98 7194.95; 43.18 7203.22; 43.41 7280.73; 43.47 7280.73; 43.72 7610.82; 44.01 8002.21; 44.30 7957.78; 44.61 7993.34; 44.95 7735.95; 45.32 7534.46; 45.60 7372.58; 45.99 7384.37; 46.11 7913.75; 46.61 8045.74; 46.94 7824.81; 47.03 7541.26; 47.29 7316.28; 47.53 6983.38; 48.05 7605.4; 48.30 7715.14; 48.59 7745.41; 70.37 9056.56; 70.66 9307.95; 70.99 8478.22; 71.26 8713.44; 71.51 8743.01; 71.96 8390.78; 72.10 8251.93; 72.28 8251.93; 72.49 7702.76; 73.52 7149.01; 74.15 7623.34; 74.74 8883.74; 74.95 8883.74; 75.11 8883.74; 75.98 8539.89; 76.09 8539.89; 76.31 8539.89];
init.tCO2_PT933602927 = 426; units.init.tCO2_PT933602927 = 'kg'; label.init.tCO2_PT933602927 = 'Initial weight';
units.tCO2_PT933602927 = {'d', 'g/d'}; label.tCO2_PT933602927 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT933602927 = 'Daily CO2 emissions of individual PT933602927'; comment.tCO2_PT933602927 = 'Data from GreenBeef trial 1, individual PT933602927'; bibkey.tCO2_PT933602927 = 'GreenBeefTrial1';

data.tCO2_PT524956505 = [13.51 8181.99; 13.70 7873.73; 13.77 7873.73; 13.97 7550.65; 14.07 7384.24; 14.09 7525.57; 14.29 7510.38; 14.33 7510.38; 14.58 7812.6; 14.78 8007.78; 14.87 8409.91; 15.03 8127.77; 15.15 8179.6; 15.29 8067.01; 15.41 7742.44; 15.60 8313.29; 15.95 9311.84; 16.03 9311.84; 16.30 9029.89; 16.33 9029.89; 16.53 8807.52; 16.75 8926.88; 16.99 8702.32; 17.09 8767.77; 17.32 8730.68; 17.56 8493.75; 17.77 8331.71; 17.91 8307.92; 18.16 8290.28; 18.39 8298.46; 18.61 8368.52; 18.92 8075.23; 19.10 8075.23; 19.37 8302.72; 19.67 8387.39; 19.77 8387.39; 20.00 8340.35; 20.31 7927.4; 41.74 10814.05; 41.99 10376.96; 42.02 10376.96; 42.30 9786.97; 42.42 9786.97; 42.52 9927.17; 42.73 9927.17; 42.97 9911.69; 42.98 9911.69; 43.38 10330.56; 43.66 10267.4; 43.91 9935.68; 44.02 9935.68; 44.31 9503.09; 44.60 9501.67; 44.95 9864.94; 45.01 9864.94; 45.30 9911.77; 45.60 9859.23; 45.79 9859.23; 45.91 9979.34; 45.96 9979.34; 46.09 9979.34; 46.32 9938.04; 46.39 9938.04; 46.65 10139.28; 46.93 9721.55; 47.10 9736.93; 47.32 9988.96; 47.54 10172.48; 47.92 9427.04; 48.00 9427.04; 48.05 9334.19; 48.31 9410.64; 48.58 8985.18; 48.64 8985.18; 70.36 10506.8; 70.45 10506.8; 70.58 10490.03; 70.69 10490.03; 70.81 10398.2; 70.83 10398.2; 71.05 10368.42; 71.27 10250.79; 71.37 9841.33; 71.45 9841.33; 71.50 9936.65; 71.65 10124.28; 71.71 10124.28; 71.99 9897.72; 72.07 9603.83; 72.29 9464.73; 72.54 9179.94; 72.58 8276.43; 73.38 9058.78; 73.59 9058.78; 73.66 9058.78; 74.25 9544.62; 74.58 10004.38; 74.96 10125.6; 75.01 10125.6; 75.29 10512.43; 75.78 10875.1; 76.05 11576.36];
init.tCO2_PT524956505 = 542; units.init.tCO2_PT524956505 = 'kg'; label.init.tCO2_PT524956505 = 'Initial weight';
units.tCO2_PT524956505 = {'d', 'g/d'}; label.tCO2_PT524956505 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT524956505 = 'Daily CO2 emissions of individual PT524956505'; comment.tCO2_PT524956505 = 'Data from GreenBeef trial 1, individual PT524956505'; bibkey.tCO2_PT524956505 = 'GreenBeefTrial1';

data.tCO2_PT724523831 = [49.64 8192.18; 50.04 8400.86; 50.31 9060.7; 50.57 9131.99; 50.79 9131.99; 51.04 8981.41; 51.29 8633.05; 51.57 8674.01; 52.05 8851.02; 52.30 9015.12; 52.56 8943.33; 52.78 9196.86; 53.11 9027.11; 53.29 8806.65; 53.41 8806.65; 53.70 8671.39; 54.01 8694.37; 54.28 8963.25; 54.54 8812.19; 54.77 9070.36; 55.10 9263.42; 55.39 8712.87; 55.62 8644.54; 55.91 8718.19; 56.08 8718.19; 56.33 8898.89; 76.41 8470.68; 76.68 8470.68; 76.75 8470.68; 77.28 8937.38; 77.53 8937.38; 77.75 9213.21; 78.06 9221.21; 78.26 9484.14; 78.36 9153.74; 78.58 8932.0; 78.80 9290.31; 79.08 8548.7; 79.30 8844.85; 79.52 8749.77; 79.73 8586.71; 80.01 8195.5; 80.31 7554.28; 80.52 7282.56; 80.74 7354.88; 81.02 7946.07; 81.15 7946.07; 81.49 8510.64; 81.74 9123.51; 81.97 8997.04; 82.08 8956.34; 82.30 9127.97; 82.53 8976.37; 82.74 9012.65; 83.29 9254.91; 83.52 9254.91];
init.tCO2_PT724523831 = 485; units.init.tCO2_PT724523831 = 'kg'; label.init.tCO2_PT724523831 = 'Initial weight';
units.tCO2_PT724523831 = {'d', 'g/d'}; label.tCO2_PT724523831 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT724523831 = 'Daily CO2 emissions of individual PT724523831'; comment.tCO2_PT724523831 = 'Data from GreenBeef trial 1, individual PT724523831'; bibkey.tCO2_PT724523831 = 'GreenBeefTrial1';

data.tCO2_PT333653651 = [48.70 8839.54; 48.82 8839.54; 49.03 8839.54; 49.59 9194.37; 49.80 9191.17; 50.01 9191.17; 50.30 9918.28; 50.56 9996.27; 50.78 9996.27; 51.03 9989.15; 51.38 9187.36; 51.64 9009.28; 51.88 8752.31; 52.06 8501.77; 52.29 8934.9; 52.52 8948.0; 52.74 8979.05; 52.98 8934.01; 53.06 9113.21; 53.30 8847.71; 53.53 8608.35; 53.75 8600.14; 53.97 8578.85; 54.06 8624.65; 54.31 8689.64; 54.57 8669.25; 54.81 9138.5; 55.08 9337.37; 55.29 9394.32; 55.52 9210.74; 55.73 9176.68; 55.95 8989.41; 56.07 9256.53; 56.28 9134.67; 76.42 8588.08; 76.69 9341.84; 76.93 9383.18; 77.02 9383.18; 77.28 9348.99; 77.73 9080.71; 77.94 9374.53; 78.01 9235.78; 78.27 9534.49; 78.50 9609.06; 78.74 9547.31; 79.05 8974.71; 79.26 8582.18; 79.50 8737.96; 79.76 8515.84; 80.02 8853.26; 81.83 8735.22; 82.32 8502.99; 82.72 8373.61; 83.04 7951.32; 83.30 7922.25; 83.54 7922.25];
init.tCO2_PT333653651 = 536; units.init.tCO2_PT333653651 = 'kg'; label.init.tCO2_PT333653651 = 'Initial weight';
units.tCO2_PT333653651 = {'d', 'g/d'}; label.tCO2_PT333653651 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT333653651 = 'Daily CO2 emissions of individual PT333653651'; comment.tCO2_PT333653651 = 'Data from GreenBeef trial 1, individual PT333653651'; bibkey.tCO2_PT333653651 = 'GreenBeefTrial1';

data.tCO2_PT924401183 = [44.54 9028.26; 70.45 10215.67; 70.68 10215.67; 71.44 8576.98; 71.65 8101.3; 71.94 7773.37; 72.00 7773.37; 72.52 9803.63; 73.35 9613.55; 73.37 9613.55; 73.69 9777.41; 73.71 9777.41; 73.81 9681.41; 73.98 10037.88; 74.07 10098.99; 74.30 10074.38; 74.39 10523.06; 74.53 10534.56; 74.81 10821.65; 75.11 11017.16; 75.26 11212.53; 75.41 10934.56; 75.49 10934.56; 75.71 10949.15; 76.24 10285.03];
init.tCO2_PT924401183 = 510; units.init.tCO2_PT924401183 = 'kg'; label.init.tCO2_PT924401183 = 'Initial weight';
units.tCO2_PT924401183 = {'d', 'g/d'}; label.tCO2_PT924401183 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT924401183 = 'Daily CO2 emissions of individual PT924401183'; comment.tCO2_PT924401183 = 'Data from GreenBeef trial 1, individual PT924401183'; bibkey.tCO2_PT924401183 = 'GreenBeefTrial1';


%% Time vs Weight data 

data.tW_PT333677539 = [0 509; 13 519; 27 537; 41 568; 61 580];
init.tW_PT333677539 = 509; units.init.tW_PT333677539 = 'kg'; label.init.tW_PT333677539 = 'Initial weight';
units.tW_PT333677539 = {'d', 'kg'}; label.tW_PT333677539 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT333677539 = 'Growth curve of individual PT333677539'; comment.tW_PT333677539 = 'Data from GreenBeef trial 2, individual PT333677539'; bibkey.tW_PT333677539 = 'GreenBeefTrial2';

data.tW_PT433677444 = [0 493; 13 526; 27 529; 41 536; 61 550];
init.tW_PT433677444 = 493; units.init.tW_PT433677444 = 'kg'; label.init.tW_PT433677444 = 'Initial weight';
units.tW_PT433677444 = {'d', 'kg'}; label.tW_PT433677444 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT433677444 = 'Growth curve of individual PT433677444'; comment.tW_PT433677444 = 'Data from GreenBeef trial 2, individual PT433677444'; bibkey.tW_PT433677444 = 'GreenBeefTrial2';

data.tW_PT334023113 = [0 489; 13 496; 27 510; 41 534; 61 562];
init.tW_PT334023113 = 489; units.init.tW_PT334023113 = 'kg'; label.init.tW_PT334023113 = 'Initial weight';
units.tW_PT334023113 = {'d', 'kg'}; label.tW_PT334023113 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT334023113 = 'Growth curve of individual PT334023113'; comment.tW_PT334023113 = 'Data from GreenBeef trial 2, individual PT334023113'; bibkey.tW_PT334023113 = 'GreenBeefTrial2';

data.tW_PT834023120 = [0 526; 13 532; 27 552; 41 559; 61 594];
init.tW_PT834023120 = 526; units.init.tW_PT834023120 = 'kg'; label.init.tW_PT834023120 = 'Initial weight';
units.tW_PT834023120 = {'d', 'kg'}; label.tW_PT834023120 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT834023120 = 'Growth curve of individual PT834023120'; comment.tW_PT834023120 = 'Data from GreenBeef trial 2, individual PT834023120'; bibkey.tW_PT834023120 = 'GreenBeefTrial2';

data.tW_PT434052554 = [0 498; 13 502; 27 515; 41 527; 61 556];
init.tW_PT434052554 = 498; units.init.tW_PT434052554 = 'kg'; label.init.tW_PT434052554 = 'Initial weight';
units.tW_PT434052554 = {'d', 'kg'}; label.tW_PT434052554 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT434052554 = 'Growth curve of individual PT434052554'; comment.tW_PT434052554 = 'Data from GreenBeef trial 2, individual PT434052554'; bibkey.tW_PT434052554 = 'GreenBeefTrial2';

data.tW_PT433677524 = [0 519; 13 530; 27 571; 41 577; 61 612];
init.tW_PT433677524 = 519; units.init.tW_PT433677524 = 'kg'; label.init.tW_PT433677524 = 'Initial weight';
units.tW_PT433677524 = {'d', 'kg'}; label.tW_PT433677524 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT433677524 = 'Growth curve of individual PT433677524'; comment.tW_PT433677524 = 'Data from GreenBeef trial 2, individual PT433677524'; bibkey.tW_PT433677524 = 'GreenBeefTrial2';

data.tW_PT433677425 = [0 475; 13 519; 27 541; 41 563; 61 591];
init.tW_PT433677425 = 475; units.init.tW_PT433677425 = 'kg'; label.init.tW_PT433677425 = 'Initial weight';
units.tW_PT433677425 = {'d', 'kg'}; label.tW_PT433677425 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT433677425 = 'Growth curve of individual PT433677425'; comment.tW_PT433677425 = 'Data from GreenBeef trial 2, individual PT433677425'; bibkey.tW_PT433677425 = 'GreenBeefTrial2';

data.tW_PT533677434 = [0 509; 13 506; 27 537; 41 546; 61 563];
init.tW_PT533677434 = 509; units.init.tW_PT533677434 = 'kg'; label.init.tW_PT533677434 = 'Initial weight';
units.tW_PT533677434 = {'d', 'kg'}; label.tW_PT533677434 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT533677434 = 'Growth curve of individual PT533677434'; comment.tW_PT533677434 = 'Data from GreenBeef trial 2, individual PT533677434'; bibkey.tW_PT533677434 = 'GreenBeefTrial2';

data.tW_PT634052553 = [0 556; 13 576; 27 606; 41 630; 61 656];
init.tW_PT634052553 = 556; units.init.tW_PT634052553 = 'kg'; label.init.tW_PT634052553 = 'Initial weight';
units.tW_PT634052553 = {'d', 'kg'}; label.tW_PT634052553 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT634052553 = 'Growth curve of individual PT634052553'; comment.tW_PT634052553 = 'Data from GreenBeef trial 2, individual PT634052553'; bibkey.tW_PT634052553 = 'GreenBeefTrial2';

data.tW_PT233677506 = [0 525; 13 547; 27 547; 41 582; 61 591];
init.tW_PT233677506 = 525; units.init.tW_PT233677506 = 'kg'; label.init.tW_PT233677506 = 'Initial weight';
units.tW_PT233677506 = {'d', 'kg'}; label.tW_PT233677506 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT233677506 = 'Growth curve of individual PT233677506'; comment.tW_PT233677506 = 'Data from GreenBeef trial 2, individual PT233677506'; bibkey.tW_PT233677506 = 'GreenBeefTrial2';

data.tW_PT834052552 = [0 459; 13 479; 27 510; 41 530; 61 557];
init.tW_PT834052552 = 459; units.init.tW_PT834052552 = 'kg'; label.init.tW_PT834052552 = 'Initial weight';
units.tW_PT834052552 = {'d', 'kg'}; label.tW_PT834052552 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT834052552 = 'Growth curve of individual PT834052552'; comment.tW_PT834052552 = 'Data from GreenBeef trial 2, individual PT834052552'; bibkey.tW_PT834052552 = 'GreenBeefTrial2';

data.tW_PT733677513 = [0 514; 13 557; 27 582; 41 608; 61 633];
init.tW_PT733677513 = 514; units.init.tW_PT733677513 = 'kg'; label.init.tW_PT733677513 = 'Initial weight';
units.tW_PT733677513 = {'d', 'kg'}; label.tW_PT733677513 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT733677513 = 'Growth curve of individual PT733677513'; comment.tW_PT733677513 = 'Data from GreenBeef trial 2, individual PT733677513'; bibkey.tW_PT733677513 = 'GreenBeefTrial2';

data.tW_PT433677562 = [0 497; 13 508; 27 524; 41 536; 61 556];
init.tW_PT433677562 = 497; units.init.tW_PT433677562 = 'kg'; label.init.tW_PT433677562 = 'Initial weight';
units.tW_PT433677562 = {'d', 'kg'}; label.tW_PT433677562 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT433677562 = 'Growth curve of individual PT433677562'; comment.tW_PT433677562 = 'Data from GreenBeef trial 2, individual PT433677562'; bibkey.tW_PT433677562 = 'GreenBeefTrial2';

data.tW_PT034067821 = [0 453; 13 460; 27 459; 41 474; 61 506];
init.tW_PT034067821 = 453; units.init.tW_PT034067821 = 'kg'; label.init.tW_PT034067821 = 'Initial weight';
units.tW_PT034067821 = {'d', 'kg'}; label.tW_PT034067821 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT034067821 = 'Growth curve of individual PT034067821'; comment.tW_PT034067821 = 'Data from GreenBeef trial 2, individual PT034067821'; bibkey.tW_PT034067821 = 'GreenBeefTrial2';

data.tW_PT733677556 = [0 477; 13 490; 27 505; 41 513; 61 540];
init.tW_PT733677556 = 477; units.init.tW_PT733677556 = 'kg'; label.init.tW_PT733677556 = 'Initial weight';
units.tW_PT733677556 = {'d', 'kg'}; label.tW_PT733677556 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT733677556 = 'Growth curve of individual PT733677556'; comment.tW_PT733677556 = 'Data from GreenBeef trial 2, individual PT733677556'; bibkey.tW_PT733677556 = 'GreenBeefTrial2';

data.tW_PT933677550 = [0 525; 13 528; 27 562; 41 579; 61 624];
init.tW_PT933677550 = 525; units.init.tW_PT933677550 = 'kg'; label.init.tW_PT933677550 = 'Initial weight';
units.tW_PT933677550 = {'d', 'kg'}; label.tW_PT933677550 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT933677550 = 'Growth curve of individual PT933677550'; comment.tW_PT933677550 = 'Data from GreenBeef trial 2, individual PT933677550'; bibkey.tW_PT933677550 = 'GreenBeefTrial2';

data.tW_PT733677452 = [0 458; 13 472; 27 482; 41 492; 61 539];
init.tW_PT733677452 = 458; units.init.tW_PT733677452 = 'kg'; label.init.tW_PT733677452 = 'Initial weight';
units.tW_PT733677452 = {'d', 'kg'}; label.tW_PT733677452 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT733677452 = 'Growth curve of individual PT733677452'; comment.tW_PT733677452 = 'Data from GreenBeef trial 2, individual PT733677452'; bibkey.tW_PT733677452 = 'GreenBeefTrial2';

data.tW_PT334023118 = [0 587; 13 584; 27 602; 41 622; 61 660];
init.tW_PT334023118 = 587; units.init.tW_PT334023118 = 'kg'; label.init.tW_PT334023118 = 'Initial weight';
units.tW_PT334023118 = {'d', 'kg'}; label.tW_PT334023118 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT334023118 = 'Growth curve of individual PT334023118'; comment.tW_PT334023118 = 'Data from GreenBeef trial 2, individual PT334023118'; bibkey.tW_PT334023118 = 'GreenBeefTrial2';

data.tW_PT434164528 = [0 450; 13 467; 27 487; 41 508; 61 530];
init.tW_PT434164528 = 450; units.init.tW_PT434164528 = 'kg'; label.init.tW_PT434164528 = 'Initial weight';
units.tW_PT434164528 = {'d', 'kg'}; label.tW_PT434164528 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT434164528 = 'Growth curve of individual PT434164528'; comment.tW_PT434164528 = 'Data from GreenBeef trial 2, individual PT434164528'; bibkey.tW_PT434164528 = 'GreenBeefTrial2';

data.tW_PT733602904 = [0 495; 13 504; 27 531; 41 558; 61 582];
init.tW_PT733602904 = 495; units.init.tW_PT733602904 = 'kg'; label.init.tW_PT733602904 = 'Initial weight';
units.tW_PT733602904 = {'d', 'kg'}; label.tW_PT733602904 = {'Time since start', 'Wet weight'}; txtData.title.tW_PT733602904 = 'Growth curve of individual PT733602904'; comment.tW_PT733602904 = 'Data from GreenBeef trial 2, individual PT733602904'; bibkey.tW_PT733602904 = 'GreenBeefTrial2';


%% Time vs Daily methane (CH4) emissions data

data.tCH4_PT333677539 = [0.54 209.07; 0.75 196.78; 0.77 196.78; 1.11 181.55; 1.36 173.27; 1.48 181.81; 1.68 190.41; 1.86 188.2; 1.89 197.48; 2.02 186.96; 2.26 189.49; 2.52 183.35; 2.74 173.1; 3.03 158.48; 3.31 153.12; 3.36 153.12; 3.69 159.82; 4.01 168.47; 4.26 170.19; 4.65 156.98; 5.01 154.58; 5.25 153.61; 5.49 153.61; 5.71 162.22; 6.02 171.11; 6.24 162.9; 6.56 160.69; 6.61 164.36; 6.79 169.52; 7.07 166.4; 7.30 151.59; 27.39 184.98; 27.40 184.98; 27.61 178.36; 27.71 178.36; 27.80 178.36; 27.83 178.36; 28.08 171.99; 28.35 151.07; 28.57 157.9; 28.81 152.69; 29.01 163.71; 29.29 163.68; 29.53 162.52; 29.70 163.56; 29.77 163.56; 30.04 161.42; 30.34 172.02; 30.60 166.17; 30.79 161.77; 30.83 161.77; 31.00 174.69; 31.28 170.56; 31.52 177.76; 31.74 169.5; 32.02 177.22; 32.10 177.22; 32.23 176.27; 32.46 172.82; 32.71 171.91; 33.02 147.58; 33.30 157.77; 33.52 152.32; 33.73 144.35; 33.99 145.76; 34.06 150.36; 34.28 134.88; 34.52 136.34; 55.48 188.32; 55.70 197.56; 55.71 197.56; 55.92 174.23; 56.02 171.61; 56.25 170.74; 56.31 170.74; 56.47 178.31; 56.69 171.26; 56.72 171.26; 56.95 189.17; 57.06 188.79; 57.34 185.06; 57.57 195.42; 57.79 195.42; 58.02 190.43; 58.04 190.43; 58.29 183.84; 58.55 163.57; 58.78 163.57; 59.00 159.74; 59.28 175.35; 59.52 162.38; 59.73 161.3; 59.98 167.96; 60.10 162.28; 60.40 170.52; 60.54 172.07; 60.59 172.07; 60.75 173.96; 60.77 173.96; 60.78 173.96; 60.89 168.54; 61.02 169.92; 61.28 152.42; 61.50 162.5; 61.72 168.62; 61.87 179.48; 61.88 179.48];
init.tCH4_PT333677539 = 509; units.init.tCH4_PT333677539 = 'kg'; label.init.tCH4_PT333677539 = 'Initial weight';
units.tCH4_PT333677539 = {'d', 'g/d'}; label.tCH4_PT333677539 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT333677539 = 'Daily CH4 emissions of individual PT333677539'; comment.tCH4_PT333677539 = 'Data from GreenBeef trial 2, individual PT333677539'; bibkey.tCH4_PT333677539 = 'GreenBeefTrial2';

data.tCH4_PT433677444 = [13.64 78.17; 13.88 82.12; 14.02 80.35; 14.10 80.35; 14.23 85.39; 14.24 85.39; 14.45 90.64; 14.67 104.78; 14.88 107.85; 15.01 107.82; 15.26 110.18; 15.35 110.18; 15.49 114.38; 15.72 111.84; 15.87 117.26; 15.97 117.26; 16.03 126.81; 16.30 119.61; 16.54 109.69; 16.81 111.86; 17.04 131.37; 17.26 129.8; 17.38 127.81; 17.48 125.64; 17.70 124.07; 17.95 113.99; 18.02 105.08; 18.25 92.02; 18.53 83.59; 18.80 91.53; 19.06 99.6; 19.31 96.88; 19.55 95.89; 19.78 98.35; 20.04 108.63; 20.26 111.74; 20.30 114.22; 20.34 114.22; 41.69 3.5; 41.92 3.22; 42.05 3.34; 42.27 3.59; 42.50 3.5; 42.72 3.53; 43.04 7.1; 43.26 8.1; 43.49 8.1; 43.73 9.95; 44.07 12.88; 44.28 17.58; 44.50 17.58; 44.75 23.22; 45.04 41.25; 45.09 41.25; 45.26 51.56; 45.51 66.07; 45.61 86.93; 45.62 86.93; 45.77 92.7; 45.99 91.25; 46.01 93.83; 46.28 109.62; 46.50 102.91; 46.72 100.0; 46.93 112.75; 47.00 117.7; 47.25 119.67; 47.26 119.67; 47.56 119.2; 47.77 115.08; 47.99 116.2; 48.03 116.62; 48.04 116.62; 48.27 113.54; 48.52 111.96; 48.77 102.68; 49.01 97.9; 49.26 90.83];
init.tCH4_PT433677444 = 493; units.init.tCH4_PT433677444 = 'kg'; label.init.tCH4_PT433677444 = 'Initial weight';
units.tCH4_PT433677444 = {'d', 'g/d'}; label.tCH4_PT433677444 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT433677444 = 'Daily CH4 emissions of individual PT433677444'; comment.tCH4_PT433677444 = 'Data from GreenBeef trial 2, individual PT433677444'; bibkey.tCH4_PT433677444 = 'GreenBeefTrial2';

data.tCH4_PT334023113 = [8.48 169.27; 8.58 169.27; 8.83 169.27; 9.34 152.4; 9.35 152.4; 9.42 162.46; 9.44 162.46; 9.44 162.46; 9.55 162.46; 9.63 162.46; 9.66 162.46; 9.82 161.32; 9.83 161.32; 9.87 168.74; 9.88 168.74; 10.28 190.68; 10.41 183.94; 10.50 183.67; 10.72 189.61; 10.97 191.86; 11.01 186.1; 11.29 168.77; 11.52 159.05; 11.82 151.21; 12.04 159.47; 12.28 159.47; 12.51 149.89; 12.80 154.83; 13.03 121.25; 13.30 99.04; 34.64 139.19; 34.66 139.19; 34.86 131.82; 35.08 135.12; 35.09 135.12; 35.30 139.42; 35.31 139.42; 35.52 129.96; 35.73 136.22; 35.76 136.22; 36.04 137.28; 36.37 125.36; 36.60 124.95; 36.74 124.95; 36.82 118.78; 37.04 119.17; 37.28 119.63; 37.54 117.22; 37.80 130.23; 38.05 153.31; 38.27 154.26; 38.50 155.27; 38.72 162.57; 38.98 167.63; 39.08 162.24; 39.31 155.81; 39.56 154.78; 39.79 146.5; 40.07 148.88; 40.28 148.88; 40.51 157.15; 40.81 172.83; 41.01 166.81; 41.28 166.81];
init.tCH4_PT334023113 = 489; units.init.tCH4_PT334023113 = 'kg'; label.init.tCH4_PT334023113 = 'Initial weight';
units.tCH4_PT334023113 = {'d', 'g/d'}; label.tCH4_PT334023113 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT334023113 = 'Daily CH4 emissions of individual PT334023113'; comment.tCH4_PT334023113 = 'Data from GreenBeef trial 2, individual PT334023113'; bibkey.tCH4_PT334023113 = 'GreenBeefTrial2';

data.tCH4_PT834023120 = [13.65 197.75; 13.86 197.75; 13.88 197.75; 14.66 180.38; 15.02 168.26; 15.04 168.26; 15.52 173.39; 15.61 177.02; 15.90 177.02; 16.43 193.22; 16.69 223.66; 16.72 223.66; 17.11 248.03; 17.37 280.48; 17.99 175.29; 18.05 175.29; 18.34 178.86; 18.55 151.14; 18.85 157.12; 19.33 140.9; 20.18 199.07; 41.53 107.04; 41.84 120.04; 42.08 119.96; 42.32 114.6; 42.34 114.6; 42.68 113.52; 43.07 174.52; 43.28 201.64; 43.53 207.65; 43.82 292.36; 44.45 133.26; 44.70 133.26; 45.47 168.26; 45.62 185.06; 45.88 199.08; 46.04 230.21; 46.29 243.01; 46.51 254.48; 46.73 252.42; 47.07 246.24; 47.29 238.86; 47.52 238.86; 47.74 219.59; 48.03 196.4; 48.40 233.64; 48.63 299.16; 49.06 274.75; 49.33 256.73];
init.tCH4_PT834023120 = 526; units.init.tCH4_PT834023120 = 'kg'; label.init.tCH4_PT834023120 = 'Initial weight';
units.tCH4_PT834023120 = {'d', 'g/d'}; label.tCH4_PT834023120 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT834023120 = 'Daily CH4 emissions of individual PT834023120'; comment.tCH4_PT834023120 = 'Data from GreenBeef trial 2, individual PT834023120'; bibkey.tCH4_PT834023120 = 'GreenBeefTrial2';

data.tCH4_PT434052554 = [8.52 222.88; 8.52 222.88; 8.83 222.88; 9.41 159.57; 10.41 124.83; 11.36 109.22; 12.03 198.28; 12.37 213.03; 12.80 227.82; 13.04 193.99; 13.31 169.72; 34.65 192.69; 34.87 174.88; 35.09 174.88; 35.31 149.28; 36.31 154.0; 36.53 154.0; 36.75 158.79; 37.05 172.88; 37.29 172.85; 37.59 160.94; 38.06 163.76; 38.29 140.2; 38.51 140.2; 38.74 153.94; 39.03 151.08; 39.27 152.69; 39.50 153.62; 39.76 149.36; 39.98 155.8; 40.07 171.53; 40.49 209.47; 40.82 178.77; 41.03 162.9; 41.31 162.9];
init.tCH4_PT434052554 = 498; units.init.tCH4_PT434052554 = 'kg'; label.init.tCH4_PT434052554 = 'Initial weight';
units.tCH4_PT434052554 = {'d', 'g/d'}; label.tCH4_PT434052554 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT434052554 = 'Daily CH4 emissions of individual PT434052554'; comment.tCH4_PT434052554 = 'Data from GreenBeef trial 2, individual PT434052554'; bibkey.tCH4_PT434052554 = 'GreenBeefTrial2';

data.tCH4_PT433677524 = [0.52 237.21; 0.56 237.21; 0.74 232.23; 0.76 227.08; 0.77 227.08; 0.79 227.08; 0.82 227.08; 0.85 221.56; 0.86 221.56; 0.98 221.56; 1.00 221.56; 1.10 219.63; 1.25 218.22; 1.33 217.95; 1.51 200.09; 1.59 195.6; 1.78 202.53; 1.85 203.05; 2.02 202.45; 2.07 201.31; 2.28 200.91; 2.40 199.55; 2.49 199.55; 2.52 198.95; 2.56 198.95; 2.60 203.93; 2.64 203.93; 2.64 203.93; 2.72 201.21; 3.18 204.97; 3.36 209.75; 3.41 209.75; 3.43 217.55; 3.50 217.55; 3.56 213.45; 3.69 216.51; 3.72 216.51; 3.83 216.51; 3.84 210.89; 3.91 212.96; 4.01 206.72; 4.02 206.72; 4.33 224.11; 4.44 212.44; 4.55 221.05; 4.64 213.22; 4.77 213.22; 5.06 209.71; 5.32 198.04; 5.39 201.27; 5.59 220.84; 5.64 220.84; 5.73 220.84; 5.83 217.83; 6.01 224.64; 6.25 198.2; 6.52 198.94; 6.67 193.79; 6.73 193.79; 6.78 198.44; 6.94 197.57; 7.05 205.64; 7.28 202.16; 27.39 215.03; 27.40 215.03; 27.41 215.03; 27.63 203.6; 27.63 203.6; 27.66 203.6; 27.78 195.82; 27.82 195.82; 27.86 191.29; 28.05 179.99; 28.09 181.23; 28.28 175.91; 28.34 162.02; 28.39 146.76; 28.56 150.45; 28.78 159.53; 29.05 159.46; 29.34 192.12; 29.56 198.57; 29.69 198.57; 29.80 191.22; 30.03 205.95; 30.28 224.14; 30.54 227.41; 30.76 227.41; 30.98 240.75; 31.03 240.75; 31.31 221.68; 31.56 207.8; 31.78 199.57; 32.03 192.3; 32.08 187.29; 32.29 188.04; 32.50 211.21; 32.55 235.57; 32.75 227.1; 32.79 233.35; 33.01 215.74; 33.23 221.62; 33.37 188.34; 33.47 188.34; 33.73 158.62; 33.73 168.87; 33.98 231.8; 34.27 246.22; 34.34 246.22; 34.50 272.07; 55.49 211.88; 55.59 230.6; 55.70 230.6; 55.93 240.91; 56.01 253.18; 56.24 257.62; 56.33 257.62; 56.46 263.04; 56.61 243.22; 56.68 243.22; 56.95 233.25; 57.05 225.22; 57.42 196.46; 57.74 198.97; 58.03 183.15; 58.35 202.36; 58.51 202.36; 58.74 210.45; 59.05 191.93; 59.29 186.6; 59.51 186.6; 59.78 170.12; 60.11 211.95; 60.39 241.27; 60.55 241.27; 60.63 235.46; 60.88 235.46; 61.07 239.35; 61.76 184.98];
init.tCH4_PT433677524 = 519; units.init.tCH4_PT433677524 = 'kg'; label.init.tCH4_PT433677524 = 'Initial weight';
units.tCH4_PT433677524 = {'d', 'g/d'}; label.tCH4_PT433677524 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT433677524 = 'Daily CH4 emissions of individual PT433677524'; comment.tCH4_PT433677524 = 'Data from GreenBeef trial 2, individual PT433677524'; bibkey.tCH4_PT433677524 = 'GreenBeefTrial2';

data.tCH4_PT433677425 = [20.41 124.74; 20.42 124.74; 20.63 122.87; 20.88 122.53; 21.01 129.0; 21.29 148.52; 21.43 152.68; 21.52 162.0; 21.78 163.03; 22.08 134.46; 22.28 135.03; 22.35 134.87; 22.58 133.54; 22.84 134.1; 23.08 129.42; 23.32 120.85; 23.46 118.18; 23.56 118.35; 23.80 109.93; 24.05 120.84; 24.27 98.62; 24.48 74.55; 24.73 63.37; 24.96 30.02; 25.27 5.46; 25.27 5.46; 25.50 3.88; 25.71 3.82; 25.99 6.57; 26.06 7.07; 26.33 7.57; 26.46 7.57; 27.02 2.96; 27.28 2.96; 49.39 5.4; 49.83 5.49; 50.02 5.34; 50.30 6.4; 50.52 9.74; 50.68 9.74; 50.75 9.74; 50.76 10.89; 50.96 11.7; 51.02 11.7; 51.25 13.53; 51.25 13.53; 51.52 11.87; 51.74 11.87; 51.80 11.06; 52.29 10.2; 52.51 12.5; 52.74 11.51; 52.96 11.91; 53.07 12.53; 53.30 13.53; 53.53 16.21; 53.74 20.5; 53.97 26.0; 54.07 28.32; 54.34 36.78; 54.58 46.93; 54.79 55.04; 55.02 57.74; 55.28 66.3];
init.tCH4_PT433677425 = 475; units.init.tCH4_PT433677425 = 'kg'; label.init.tCH4_PT433677425 = 'Initial weight';
units.tCH4_PT433677425 = {'d', 'g/d'}; label.tCH4_PT433677425 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT433677425 = 'Daily CH4 emissions of individual PT433677425'; comment.tCH4_PT433677425 = 'Data from GreenBeef trial 2, individual PT433677425'; bibkey.tCH4_PT433677425 = 'GreenBeefTrial2';

data.tCH4_PT634052553 = [1.38 151.41; 3.04 153.87; 3.35 169.19; 3.64 176.06; 3.86 184.13; 4.07 189.61; 4.32 187.06; 4.54 214.37; 4.88 210.69; 5.35 212.09; 5.60 181.23; 5.87 217.57; 6.62 227.52; 6.87 227.52; 27.45 174.28; 27.89 161.65; 28.37 198.92; 28.58 228.32; 28.83 201.59; 29.19 217.16; 29.45 203.34; 29.67 194.18; 29.92 191.73; 30.02 172.05; 30.35 167.36; 30.77 160.79; 30.99 162.28; 31.09 174.97; 31.33 172.64; 31.58 162.54; 31.83 178.26; 32.09 159.76; 32.41 188.76; 32.71 214.74; 33.08 217.57; 33.35 237.55; 33.67 209.98; 33.89 206.28; 34.05 206.28; 34.31 177.62; 34.56 174.36; 55.49 244.24; 55.56 210.45; 55.86 200.83; 56.05 191.98; 56.30 198.42; 56.60 209.92; 56.91 193.01; 57.08 193.01; 57.36 204.75; 57.60 175.36; 57.85 157.48; 57.97 170.03; 58.05 170.03; 58.32 148.3; 58.57 123.3; 59.03 138.63; 59.33 147.46; 59.54 157.88; 59.76 145.22; 60.08 182.15; 60.31 199.66; 60.53 199.66; 60.58 191.42; 60.77 208.26; 61.03 215.32; 61.37 152.39; 61.59 153.11; 61.84 153.11];
init.tCH4_PT634052553 = 556; units.init.tCH4_PT634052553 = 'kg'; label.init.tCH4_PT634052553 = 'Initial weight';
units.tCH4_PT634052553 = {'d', 'g/d'}; label.tCH4_PT634052553 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT634052553 = 'Daily CH4 emissions of individual PT634052553'; comment.tCH4_PT634052553 = 'Data from GreenBeef trial 2, individual PT634052553'; bibkey.tCH4_PT634052553 = 'GreenBeefTrial2';

data.tCH4_PT233677506 = [0.53 243.26; 0.62 227.86; 0.68 227.86; 0.82 227.86; 1.10 225.62; 1.34 199.5; 1.45 205.39; 1.52 205.39; 1.59 199.46; 1.61 202.78; 1.63 202.78; 1.80 197.54; 1.87 202.88; 2.07 200.42; 2.08 200.42; 2.29 206.74; 2.51 206.52; 2.52 206.52; 2.65 217.77; 2.74 217.77; 2.78 206.46; 3.26 183.16; 3.32 173.99; 3.47 186.79; 3.68 210.88; 3.71 210.88; 3.87 209.29; 3.97 197.13; 4.02 193.92; 4.08 209.9; 4.25 205.14; 4.30 205.14; 4.34 205.14; 4.44 211.03; 4.46 211.03; 4.56 204.56; 4.66 195.81; 4.68 195.81; 4.70 195.81; 4.89 201.97; 5.01 204.92; 5.26 195.16; 5.45 166.63; 5.48 166.63; 5.63 155.27; 5.70 155.27; 5.84 157.9; 6.04 162.46; 6.27 165.3; 6.48 176.36; 6.57 182.23; 6.66 179.8; 6.72 179.8; 6.86 165.84; 6.87 165.84; 6.95 165.84; 7.06 165.59; 7.08 164.61; 7.27 152.61; 7.31 152.61; 7.35 152.61; 27.40 177.58; 27.43 177.58; 27.46 177.58; 27.53 180.14; 27.59 174.91; 27.63 174.57; 27.70 174.57; 27.73 174.57; 27.75 174.57; 27.80 169.12; 27.85 166.77; 27.85 166.77; 27.97 150.12; 28.08 149.54; 28.10 147.77; 28.26 142.57; 28.31 142.62; 28.36 142.27; 28.39 142.27; 28.41 142.27; 28.53 138.46; 28.57 138.04; 28.59 139.77; 28.63 138.01; 28.71 136.79; 28.75 136.79; 28.77 139.7; 28.79 140.99; 28.85 149.99; 28.96 160.67; 29.04 157.31; 29.06 157.31; 29.21 151.11; 29.27 152.53; 29.31 153.9; 29.38 152.52; 29.42 152.52; 29.45 151.5; 29.47 151.82; 29.50 154.83; 29.52 154.83; 29.53 154.83; 29.57 157.37; 29.62 157.37; 29.70 157.37; 29.77 157.91; 29.93 151.73; 30.00 152.83; 30.26 167.03; 30.31 177.64; 30.33 177.64; 30.36 177.64; 30.50 189.64; 30.54 183.87; 30.62 183.87; 30.71 183.87; 30.77 195.96; 30.93 181.27; 30.99 183.95; 31.01 176.88; 31.22 181.88; 31.27 180.42; 31.29 180.42; 31.34 180.42; 31.36 180.42; 31.44 178.82; 31.52 181.64; 31.57 181.64; 31.67 181.64; 31.74 174.46; 31.89 187.48; 31.90 187.48; 31.98 182.0; 32.02 182.0; 32.27 180.34; 32.42 176.75; 32.52 170.81; 32.72 179.07; 32.74 179.07; 33.00 181.21; 33.05 186.68; 33.26 172.22; 33.42 172.22; 33.48 172.22; 33.74 163.66; 33.99 154.24; 34.05 148.83; 34.28 162.05; 34.51 164.25; 34.60 147.04; 55.71 273.73; 55.77 240.0; 55.82 225.06; 55.95 225.06; 56.01 229.28; 56.25 225.06; 56.26 225.06; 56.30 231.37; 56.47 230.09; 56.69 218.3; 56.93 245.85; 56.96 245.85; 57.06 243.4; 57.26 249.53; 57.30 252.15; 57.37 252.15; 57.57 236.87; 57.75 236.87; 57.80 234.84; 58.01 258.66; 58.27 260.35; 58.41 258.22; 58.48 258.22; 58.70 252.53; 58.76 252.53; 59.00 231.36; 59.01 231.36; 59.27 217.96; 59.52 209.24; 59.53 209.24; 59.72 230.65; 59.74 230.65; 60.11 239.89; 60.40 283.38; 60.59 271.56; 60.62 263.29; 60.66 263.29; 60.77 263.29; 60.89 247.76; 60.90 247.76; 61.04 245.77; 61.29 219.25; 61.50 180.06; 61.73 180.82; 61.86 199.93];
init.tCH4_PT233677506 = 525; units.init.tCH4_PT233677506 = 'kg'; label.init.tCH4_PT233677506 = 'Initial weight';
units.tCH4_PT233677506 = {'d', 'g/d'}; label.tCH4_PT233677506 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT233677506 = 'Daily CH4 emissions of individual PT233677506'; comment.tCH4_PT233677506 = 'Data from GreenBeef trial 2, individual PT233677506'; bibkey.tCH4_PT233677506 = 'GreenBeefTrial2';

data.tCH4_PT834052552 = [1.83 186.17; 2.39 166.57; 2.71 166.57; 3.38 183.71; 3.82 182.68; 4.29 201.78; 4.51 216.28; 4.76 216.28; 5.29 196.06; 5.82 173.42; 6.33 229.96; 6.60 215.56; 6.84 192.06; 7.29 169.46; 27.51 193.2; 27.79 193.2; 28.33 176.19; 28.46 176.19; 28.55 176.19; 28.81 171.77; 29.30 181.68; 29.70 185.49; 30.11 201.47; 30.32 196.98; 30.59 197.24; 30.82 215.82; 31.01 208.93; 31.35 193.83; 31.62 233.07; 31.96 226.97; 32.06 215.36; 32.28 221.38; 32.54 187.54; 32.76 168.27; 32.79 170.97; 33.03 209.2; 33.27 212.88; 33.52 203.39; 33.85 222.08; 34.00 222.08; 34.29 161.18; 34.59 148.31; 55.53 238.65; 56.31 237.2; 56.56 234.96; 56.82 224.24; 56.86 224.24; 57.18 207.85; 57.54 218.6; 57.81 235.13; 58.08 243.68; 58.39 189.64; 58.75 191.33; 59.11 177.78; 59.36 227.22; 59.71 235.73; 60.01 246.04; 60.28 286.13; 60.51 295.03; 60.59 295.03; 60.76 275.9; 61.20 274.22; 61.46 209.28];
init.tCH4_PT834052552 = 459; units.init.tCH4_PT834052552 = 'kg'; label.init.tCH4_PT834052552 = 'Initial weight';
units.tCH4_PT834052552 = {'d', 'g/d'}; label.tCH4_PT834052552 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT834052552 = 'Daily CH4 emissions of individual PT834052552'; comment.tCH4_PT834052552 = 'Data from GreenBeef trial 2, individual PT834052552'; bibkey.tCH4_PT834052552 = 'GreenBeefTrial2';

data.tCH4_PT733677513 = [8.50 218.02; 9.16 198.76; 9.16 198.76; 9.44 198.76; 9.65 198.76; 10.43 191.58; 10.64 191.58; 10.72 191.58; 11.37 192.03; 11.38 192.03; 11.46 192.03; 11.53 196.13; 11.60 196.13; 11.65 196.13; 11.72 196.13; 11.83 199.71; 12.02 204.82; 12.29 222.59; 12.52 209.92; 12.75 194.15; 13.02 160.62; 13.26 145.08; 34.64 181.16; 34.66 181.16; 34.71 181.16; 34.86 159.1; 34.98 159.1; 35.09 166.39; 35.29 132.21; 35.35 130.75; 35.57 121.76; 35.68 116.45; 35.77 116.45; 35.78 116.45; 35.82 117.89; 35.99 117.14; 36.15 117.45; 36.31 150.18; 36.36 153.79; 36.52 163.83; 36.59 164.29; 36.75 168.74; 36.79 168.74; 36.81 164.08; 37.08 177.78; 37.29 172.95; 37.52 155.01; 37.55 155.01; 37.57 155.01; 37.77 157.76; 38.14 157.18; 38.32 155.74; 38.37 163.25; 38.39 163.25; 38.51 163.25; 38.51 163.25; 38.61 175.29; 38.62 175.29; 38.83 190.23; 39.05 209.74; 39.28 225.19; 39.49 224.23; 39.76 211.75; 39.97 204.97; 40.08 212.58; 40.32 207.93; 40.58 190.38; 40.79 193.58; 41.02 197.36; 41.27 189.09];
init.tCH4_PT733677513 = 514; units.init.tCH4_PT733677513 = 'kg'; label.init.tCH4_PT733677513 = 'Initial weight';
units.tCH4_PT733677513 = {'d', 'g/d'}; label.tCH4_PT733677513 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT733677513 = 'Daily CH4 emissions of individual PT733677513'; comment.tCH4_PT733677513 = 'Data from GreenBeef trial 2, individual PT733677513'; bibkey.tCH4_PT733677513 = 'GreenBeefTrial2';

data.tCH4_PT433677562 = [14.61 5.13; 15.37 4.89; 15.65 7.66; 15.88 8.05; 16.03 8.05; 16.31 6.71; 16.59 4.18; 16.82 3.6; 17.00 3.6; 17.24 6.07; 17.30 6.07; 17.56 8.03; 17.82 9.17; 18.03 9.17; 18.06 7.73; 18.31 6.2; 18.58 5.08; 18.81 4.4; 19.09 2.65; 19.33 2.3; 19.59 5.29; 19.64 4.56; 19.86 4.92; 20.11 5.73; 41.73 3.32; 41.98 3.91; 42.08 3.75; 42.30 4.42; 42.33 4.42; 42.58 4.57; 42.58 5.08; 42.79 5.08; 43.08 5.49; 43.31 5.2; 43.54 5.2; 43.79 5.32; 44.07 6.52; 44.29 9.09; 44.50 9.09; 44.76 10.24; 45.08 12.83; 45.32 14.82; 45.58 15.66; 45.63 15.66; 45.87 16.8; 46.02 16.25; 46.29 19.41; 46.50 20.17; 46.73 23.98; 47.01 38.0; 47.24 36.33; 47.29 35.23; 47.54 37.94; 47.78 42.97; 48.04 45.75; 48.28 53.55; 48.51 61.88; 48.77 66.72; 49.00 72.47; 49.28 82.14];
init.tCH4_PT433677562 = 497; units.init.tCH4_PT433677562 = 'kg'; label.init.tCH4_PT433677562 = 'Initial weight';
units.tCH4_PT433677562 = {'d', 'g/d'}; label.tCH4_PT433677562 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT433677562 = 'Daily CH4 emissions of individual PT433677562'; comment.tCH4_PT433677562 = 'Data from GreenBeef trial 2, individual PT433677562'; bibkey.tCH4_PT433677562 = 'GreenBeefTrial2';

data.tCH4_PT034067821 = [13.66 83.86; 13.66 83.86; 14.11 90.4; 14.28 102.97; 14.36 102.97; 14.60 113.09; 14.88 115.22; 15.05 115.22; 15.27 121.41; 15.60 127.1; 15.87 129.6; 16.02 129.6; 16.30 124.54; 16.56 106.99; 16.82 110.56; 17.11 105.51; 17.38 107.73; 17.66 119.49; 17.88 117.02; 18.05 121.26; 18.29 144.89; 18.63 137.65; 19.01 128.9; 19.26 111.27; 19.48 112.68; 19.89 104.75; 20.11 104.14; 20.23 104.14; 20.36 104.14; 41.45 12.18; 41.68 19.28; 42.07 28.32; 42.32 44.54; 42.57 48.24; 42.79 53.1; 43.08 55.76; 43.31 63.68; 43.54 68.75; 43.80 72.91; 44.01 72.96; 44.27 75.12; 44.49 79.27; 44.80 70.32; 45.09 82.06; 45.31 80.7; 45.56 79.12; 45.79 76.46; 46.02 72.47; 46.28 75.57; 46.60 79.64; 46.84 81.12; 47.03 74.65; 47.27 72.3; 47.52 67.81; 47.77 68.51; 48.02 69.37; 48.26 74.51; 48.50 71.32; 48.78 70.4; 49.07 73.89; 49.29 78.32];
init.tCH4_PT034067821 = 453; units.init.tCH4_PT034067821 = 'kg'; label.init.tCH4_PT034067821 = 'Initial weight';
units.tCH4_PT034067821 = {'d', 'g/d'}; label.tCH4_PT034067821 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT034067821 = 'Daily CH4 emissions of individual PT034067821'; comment.tCH4_PT034067821 = 'Data from GreenBeef trial 2, individual PT034067821'; bibkey.tCH4_PT034067821 = 'GreenBeefTrial2';

data.tCH4_PT733677556 = [20.43 9.57; 20.55 10.48; 20.65 10.48; 20.88 9.31; 20.88 9.31; 21.03 8.78; 21.29 6.38; 21.57 5.75; 21.87 5.68; 22.28 8.09; 22.50 6.56; 22.72 5.66; 23.07 5.78; 23.08 5.78; 23.46 7.56; 23.67 9.72; 23.90 8.07; 24.19 6.58; 24.50 2.59; 24.73 2.78; 24.98 2.74; 25.04 2.73; 25.28 2.97; 25.51 3.08; 26.02 1.25; 26.27 1.5; 26.57 2.34; 26.80 2.33; 27.03 2.33; 27.29 2.43; 49.87 12.24; 50.29 9.84; 50.53 11.67; 50.77 10.24; 51.27 8.0; 51.28 8.1; 51.52 8.1; 51.52 8.1; 51.75 8.14; 52.07 13.62; 52.52 12.06; 52.75 12.57; 53.12 10.08; 53.41 12.03; 53.66 12.75; 53.89 10.86; 54.18 9.91; 54.71 13.98; 54.95 13.98; 55.03 13.98; 55.28 16.19];
init.tCH4_PT733677556 = 477; units.init.tCH4_PT733677556 = 'kg'; label.init.tCH4_PT733677556 = 'Initial weight';
units.tCH4_PT733677556 = {'d', 'g/d'}; label.tCH4_PT733677556 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT733677556 = 'Daily CH4 emissions of individual PT733677556'; comment.tCH4_PT733677556 = 'Data from GreenBeef trial 2, individual PT733677556'; bibkey.tCH4_PT733677556 = 'GreenBeefTrial2';

data.tCH4_PT933677550 = [13.63 95.53; 14.10 116.08; 14.25 123.85; 14.27 123.85; 14.47 123.85; 14.51 123.85; 14.53 123.85; 14.68 129.41; 14.72 129.41; 15.06 137.74; 15.31 145.29; 15.63 161.87; 15.88 162.3; 16.04 167.53; 16.29 169.0; 16.51 164.64; 16.73 172.0; 17.34 170.89; 17.56 170.89; 17.71 159.87; 17.80 159.87; 18.10 144.73; 18.32 149.44; 18.57 153.07; 18.82 166.21; 19.07 164.41; 19.31 160.67; 19.60 157.41; 19.81 207.01; 20.03 207.01; 20.22 219.75; 20.31 219.75; 41.44 3.99; 41.66 4.9; 41.91 6.84; 42.04 8.13; 42.26 10.74; 42.30 10.74; 42.49 16.01; 42.75 24.5; 42.97 56.22; 43.03 75.88; 43.25 96.51; 43.49 114.5; 43.72 142.46; 43.94 141.45; 44.01 158.68; 44.23 165.17; 44.44 173.48; 44.65 167.21; 44.87 159.96; 45.03 151.38; 45.24 145.5; 45.46 140.56; 45.67 136.3; 45.89 142.54; 46.00 138.5; 46.27 151.8; 46.49 153.26; 46.72 154.52; 46.93 154.99; 47.03 149.42; 47.25 136.93; 47.48 128.32; 47.71 127.49; 47.95 127.98; 48.10 127.34; 48.32 123.84; 48.40 123.84; 48.58 125.95; 48.80 121.5; 49.04 112.7; 49.25 116.66];
init.tCH4_PT933677550 = 525; units.init.tCH4_PT933677550 = 'kg'; label.init.tCH4_PT933677550 = 'Initial weight';
units.tCH4_PT933677550 = {'d', 'g/d'}; label.tCH4_PT933677550 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT933677550 = 'Daily CH4 emissions of individual PT933677550'; comment.tCH4_PT933677550 = 'Data from GreenBeef trial 2, individual PT933677550'; bibkey.tCH4_PT933677550 = 'GreenBeefTrial2';

data.tCH4_PT733677452 = [20.45 16.71; 20.46 16.71; 20.48 16.71; 20.54 15.82; 20.79 15.22; 21.02 11.7; 21.24 12.83; 21.46 14.6; 21.68 13.32; 21.98 14.29; 22.73 6.78; 22.87 6.99; 23.01 6.99; 23.09 6.99; 23.31 7.6; 24.02 18.92; 24.50 12.78; 24.72 12.7; 24.95 11.55; 25.01 7.95; 25.26 8.66; 25.49 7.27; 25.99 3.18; 26.02 2.39; 26.24 2.11; 26.61 1.38; 49.39 15.29; 49.61 21.44; 49.83 21.44; 50.00 24.98; 50.80 19.15; 51.02 19.15; 51.24 19.6; 51.60 99.09; 51.84 127.23; 52.06 136.66; 52.46 134.43; 53.04 154.29; 53.32 117.98; 53.55 97.62; 53.76 95.87; 53.99 83.68; 54.07 92.69; 54.28 94.6; 54.76 105.22; 54.98 129.16; 55.01 129.16; 55.30 131.1];
init.tCH4_PT733677452 = 458; units.init.tCH4_PT733677452 = 'kg'; label.init.tCH4_PT733677452 = 'Initial weight';
units.tCH4_PT733677452 = {'d', 'g/d'}; label.tCH4_PT733677452 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT733677452 = 'Daily CH4 emissions of individual PT733677452'; comment.tCH4_PT733677452 = 'Data from GreenBeef trial 2, individual PT733677452'; bibkey.tCH4_PT733677452 = 'GreenBeefTrial2';

data.tCH4_PT334023118 = [20.48 7.3; 21.32 3.33; 21.52 4.21; 21.97 3.77; 22.29 3.45; 22.77 2.18; 23.32 2.08; 23.88 3.0; 24.00 3.0; 24.63 2.79; 25.33 3.36; 25.57 3.36; 26.25 2.99; 26.55 2.99; 27.30 7.89; 50.32 4.66; 50.55 4.66; 50.78 6.92; 51.28 6.72; 51.54 8.7; 53.01 12.94; 53.52 7.28; 54.27 10.76; 54.52 10.76; 54.77 11.17; 55.09 12.0];
init.tCH4_PT334023118 = 587; units.init.tCH4_PT334023118 = 'kg'; label.init.tCH4_PT334023118 = 'Initial weight';
units.tCH4_PT334023118 = {'d', 'g/d'}; label.tCH4_PT334023118 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT334023118 = 'Daily CH4 emissions of individual PT334023118'; comment.tCH4_PT334023118 = 'Data from GreenBeef trial 2, individual PT334023118'; bibkey.tCH4_PT334023118 = 'GreenBeefTrial2';

data.tCH4_PT434164528 = [21.43 107.66; 21.44 107.66; 21.66 109.52; 21.66 109.52; 21.82 108.52; 21.88 106.22; 22.01 108.24; 22.08 108.24; 22.24 106.74; 22.29 109.55; 22.36 111.94; 22.45 117.21; 22.61 119.68; 22.67 119.68; 22.78 118.68; 22.89 128.22; 23.06 129.02; 23.07 129.24; 23.27 133.51; 23.31 131.49; 23.48 128.02; 23.56 127.93; 23.57 127.66; 23.80 127.53; 24.05 121.72; 24.27 100.45; 24.35 96.66; 24.50 72.69; 24.72 51.16; 24.97 12.94; 24.98 12.94; 25.02 10.19; 25.03 10.19; 25.25 8.48; 25.48 7.06; 25.59 4.5; 25.73 4.5; 25.99 4.0; 26.01 4.0; 26.24 4.2; 26.45 3.68; 26.89 3.02; 27.01 3.28; 27.24 3.28; 49.40 110.26; 49.61 110.26; 50.26 136.2; 50.52 141.85; 50.74 141.85; 50.96 134.17; 51.01 130.78; 51.25 127.39; 51.47 127.81; 51.71 112.1; 52.29 123.12; 52.52 130.0; 52.75 149.54; 52.75 149.54; 52.98 143.45; 53.03 123.96; 53.26 153.12; 53.48 152.24; 53.48 141.34; 53.74 123.83; 53.98 128.95; 54.02 142.9; 54.24 146.81; 54.48 137.6; 54.70 133.45; 54.92 141.73; 54.95 141.73; 55.04 149.96; 55.27 145.86];
init.tCH4_PT434164528 = 450; units.init.tCH4_PT434164528 = 'kg'; label.init.tCH4_PT434164528 = 'Initial weight';
units.tCH4_PT434164528 = {'d', 'g/d'}; label.tCH4_PT434164528 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT434164528 = 'Daily CH4 emissions of individual PT434164528'; comment.tCH4_PT434164528 = 'Data from GreenBeef trial 2, individual PT434164528'; bibkey.tCH4_PT434164528 = 'GreenBeefTrial2';

data.tCH4_PT733602904 = [8.54 218.87; 8.70 214.0; 8.80 199.49; 9.14 171.48; 9.15 171.48; 9.29 155.86; 9.39 151.61; 9.41 164.3; 9.90 178.52; 10.23 227.67; 10.50 221.06; 10.70 210.55; 10.98 190.55; 11.07 185.68; 11.35 176.15; 11.58 174.13; 11.81 164.2; 12.01 176.46; 12.25 158.47; 12.50 154.93; 12.73 134.96; 13.01 134.13; 13.24 135.42; 34.72 199.0; 34.98 175.5; 35.04 179.17; 35.22 171.36; 35.28 174.19; 35.51 179.48; 35.60 177.37; 35.64 177.37; 35.73 185.8; 35.99 196.14; 36.30 177.51; 36.52 142.82; 36.73 134.57; 36.98 130.6; 37.01 130.6; 37.22 141.23; 37.48 140.81; 37.70 145.22; 37.93 164.53; 38.17 145.76; 38.40 150.73; 38.61 154.74; 38.64 154.74; 38.87 159.35; 39.07 152.81; 39.52 145.23; 39.67 134.92; 39.81 134.92; 40.10 153.27; 40.34 165.58; 40.55 167.43; 40.81 169.07; 41.04 174.8; 41.28 153.83];
init.tCH4_PT733602904 = 495; units.init.tCH4_PT733602904 = 'kg'; label.init.tCH4_PT733602904 = 'Initial weight';
units.tCH4_PT733602904 = {'d', 'g/d'}; label.tCH4_PT733602904 = {'Time since start', 'Daily methane (CH4) emissions'}; txtData.title.tCH4_PT733602904 = 'Daily CH4 emissions of individual PT733602904'; comment.tCH4_PT733602904 = 'Data from GreenBeef trial 2, individual PT733602904'; bibkey.tCH4_PT733602904 = 'GreenBeefTrial2';


%% Time vs Daily carbon dioxide (CO2) emissions data

data.tCO2_PT333677539 = [0.54 8682.66; 0.75 8702.67; 0.77 8702.67; 1.11 8189.37; 1.36 7943.64; 1.48 8009.86; 1.68 8213.25; 1.86 8444.09; 1.89 8575.54; 2.02 8753.43; 2.26 8854.9; 2.52 9338.36; 2.74 8926.38; 3.03 8078.62; 3.31 8126.0; 3.36 8126.0; 3.69 8281.96; 4.01 8741.23; 4.26 8725.42; 4.65 8572.75; 5.01 8611.48; 5.25 8426.94; 5.49 8426.94; 5.71 8644.14; 6.02 8647.8; 6.24 8099.22; 6.56 8016.97; 6.61 8241.84; 6.79 8174.36; 7.07 8504.58; 7.30 8891.15; 27.39 8544.06; 27.40 8544.06; 27.61 8519.81; 27.71 8519.81; 27.80 8519.81; 27.83 8519.81; 28.08 8021.43; 28.35 7974.4; 28.57 8034.32; 28.81 7868.81; 29.01 7852.09; 29.29 7871.63; 29.53 7927.31; 29.70 8120.86; 29.77 8120.86; 30.04 7907.97; 30.34 8178.29; 30.60 8138.55; 30.79 8150.47; 30.83 8150.47; 31.00 8294.1; 31.28 8357.02; 31.52 8401.24; 31.74 8290.92; 32.02 8485.62; 32.10 8485.62; 32.23 8342.46; 32.46 8342.72; 32.71 8568.73; 33.02 8614.33; 33.30 9092.33; 33.52 8954.6; 33.73 8853.66; 33.99 8924.42; 34.06 8815.45; 34.28 8634.65; 34.52 8711.63; 55.48 8588.67; 55.70 8767.86; 55.71 8767.86; 55.92 8460.81; 56.02 8510.66; 56.25 8367.56; 56.31 8367.56; 56.47 8611.81; 56.69 8554.5; 56.72 8554.5; 56.95 8766.56; 57.06 8623.78; 57.34 8763.8; 57.57 8764.83; 57.79 8764.83; 58.02 8829.21; 58.04 8829.21; 58.29 9022.55; 58.55 9018.39; 58.78 9018.39; 59.00 8985.26; 59.28 9080.0; 59.52 8665.89; 59.73 8801.41; 59.98 8911.48; 60.10 8696.39; 60.40 8829.36; 60.54 8908.66; 60.59 8908.66; 60.75 8854.3; 60.77 8854.3; 60.78 8854.3; 60.89 8930.79; 61.02 8940.9; 61.28 8672.96; 61.50 8773.41; 61.72 8765.54; 61.87 8571.26; 61.88 8571.26];
init.tCO2_PT333677539 = 509; units.init.tCO2_PT333677539 = 'kg'; label.init.tCO2_PT333677539 = 'Initial weight';
units.tCO2_PT333677539 = {'d', 'g/d'}; label.tCO2_PT333677539 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT333677539 = 'Daily CO2 emissions of individual PT333677539'; comment.tCO2_PT333677539 = 'Data from GreenBeef trial 2, individual PT333677539'; bibkey.tCO2_PT333677539 = 'GreenBeefTrial2';

data.tCO2_PT433677444 = [13.64 8347.67; 13.88 8387.21; 14.02 8188.46; 14.10 8188.46; 14.23 8044.59; 14.24 8044.59; 14.45 7887.25; 14.67 7841.65; 14.88 7490.51; 15.01 7433.95; 15.26 7460.14; 15.35 7460.14; 15.49 7538.84; 15.72 7499.94; 15.87 7555.96; 15.97 7555.96; 16.03 7735.82; 16.30 7488.43; 16.54 7108.12; 16.81 7188.34; 17.04 7542.87; 17.26 7632.25; 17.38 7560.42; 17.48 7702.63; 17.70 7772.38; 17.95 7669.41; 18.02 7848.56; 18.25 7503.62; 18.53 7065.04; 18.80 7230.22; 19.06 7207.36; 19.31 6881.48; 19.55 7151.25; 19.78 7280.23; 20.04 7369.05; 20.26 7587.6; 20.30 7823.43; 20.34 7823.43; 41.69 7783.58; 41.92 7804.68; 42.05 7627.33; 42.27 7691.6; 42.50 7560.67; 42.72 7071.55; 43.04 7181.15; 43.26 7353.68; 43.49 7353.68; 43.73 7802.84; 44.07 7678.29; 44.28 7630.09; 44.50 7630.09; 44.75 7665.98; 45.04 8211.92; 45.09 8211.92; 45.26 7444.18; 45.51 7446.61; 45.61 7467.55; 45.62 7467.55; 45.77 7253.74; 45.99 7308.87; 46.01 7189.7; 46.28 7808.6; 46.50 7750.03; 46.72 7560.81; 46.93 7637.63; 47.00 7590.9; 47.25 7693.85; 47.26 7693.85; 47.56 8072.07; 47.77 8168.63; 47.99 8042.66; 48.03 7941.66; 48.04 7941.66; 48.27 7935.29; 48.52 8058.04; 48.77 7706.31; 49.01 7779.69; 49.26 7927.68];
init.tCO2_PT433677444 = 493; units.init.tCO2_PT433677444 = 'kg'; label.init.tCO2_PT433677444 = 'Initial weight';
units.tCO2_PT433677444 = {'d', 'g/d'}; label.tCO2_PT433677444 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT433677444 = 'Daily CO2 emissions of individual PT433677444'; comment.tCO2_PT433677444 = 'Data from GreenBeef trial 2, individual PT433677444'; bibkey.tCO2_PT433677444 = 'GreenBeefTrial2';

data.tCO2_PT334023113 = [8.48 7495.41; 8.58 7495.41; 8.83 7495.41; 9.34 8250.75; 9.35 8250.75; 9.42 8308.79; 9.44 8308.79; 9.44 8308.79; 9.55 8308.79; 9.63 8308.79; 9.66 8308.79; 9.82 8312.53; 9.83 8312.53; 9.87 8748.87; 9.88 8748.87; 10.28 9448.14; 10.41 9635.58; 10.50 9455.58; 10.72 9425.23; 10.97 9633.4; 11.01 9262.36; 11.29 8868.38; 11.52 8977.05; 11.82 8717.14; 12.04 8488.21; 12.28 8488.21; 12.51 8206.28; 12.80 8173.07; 13.03 7830.95; 13.30 7576.93; 34.64 8338.05; 34.66 8338.05; 34.86 8068.75; 35.08 7999.38; 35.09 7999.38; 35.30 7721.15; 35.31 7721.15; 35.52 7410.38; 35.73 7746.16; 35.76 7746.16; 36.04 7895.54; 36.37 8866.73; 36.60 8770.82; 36.74 8770.82; 36.82 8662.55; 37.04 8913.07; 37.28 8378.9; 37.54 8353.72; 37.80 8217.01; 38.05 8595.0; 38.27 8539.57; 38.50 8433.2; 38.72 8565.08; 38.98 8694.64; 39.08 8657.06; 39.31 8530.2; 39.56 8432.05; 39.79 8034.26; 40.07 7970.38; 40.28 7970.38; 40.51 7911.43; 40.81 8302.96; 41.01 8145.73; 41.28 8145.73];
init.tCO2_PT334023113 = 489; units.init.tCO2_PT334023113 = 'kg'; label.init.tCO2_PT334023113 = 'Initial weight';
units.tCO2_PT334023113 = {'d', 'g/d'}; label.tCO2_PT334023113 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT334023113 = 'Daily CO2 emissions of individual PT334023113'; comment.tCO2_PT334023113 = 'Data from GreenBeef trial 2, individual PT334023113'; bibkey.tCO2_PT334023113 = 'GreenBeefTrial2';

data.tCO2_PT834023120 = [13.65 9445.48; 13.86 9445.48; 13.88 9445.48; 14.66 8063.25; 15.02 7766.27; 15.04 7766.27; 15.52 7590.26; 15.61 7521.87; 15.90 7521.87; 16.43 9640.55; 16.69 9478.28; 16.72 9478.28; 17.11 9893.04; 17.37 9849.16; 17.99 8463.39; 18.05 8463.39; 18.34 8739.83; 18.55 8122.75; 18.85 8711.51; 19.33 8282.68; 20.18 9361.16; 41.53 8223.3; 41.84 8408.66; 42.08 8532.94; 42.32 8191.27; 42.34 8191.27; 42.68 7802.22; 43.07 7789.85; 43.28 8111.6; 43.53 8585.23; 43.82 9356.52; 44.45 7379.84; 44.70 7379.84; 45.47 8039.63; 45.62 8349.49; 45.88 8402.23; 46.04 8944.92; 46.29 8855.04; 46.51 8952.56; 46.73 8891.15; 47.07 9399.82; 47.29 9473.92; 47.52 9473.92; 47.74 9420.3; 48.03 9142.49; 48.40 9218.37; 48.63 9448.9; 49.06 9458.14; 49.33 9718.62];
init.tCO2_PT834023120 = 526; units.init.tCO2_PT834023120 = 'kg'; label.init.tCO2_PT834023120 = 'Initial weight';
units.tCO2_PT834023120 = {'d', 'g/d'}; label.tCO2_PT834023120 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT834023120 = 'Daily CO2 emissions of individual PT834023120'; comment.tCO2_PT834023120 = 'Data from GreenBeef trial 2, individual PT834023120'; bibkey.tCO2_PT834023120 = 'GreenBeefTrial2';

data.tCO2_PT434052554 = [8.52 9668.08; 8.52 9668.08; 8.83 9668.08; 9.41 7509.86; 10.41 8768.39; 11.36 7732.38; 12.03 9865.16; 12.37 10264.39; 12.80 10599.55; 13.04 9948.15; 13.31 9390.79; 34.65 9215.56; 34.87 9132.39; 35.09 9132.39; 35.31 8627.53; 36.31 8510.78; 36.53 8510.78; 36.75 8608.33; 37.05 8784.66; 37.29 9003.04; 37.59 9143.27; 38.06 9471.1; 38.29 8869.83; 38.51 8869.83; 38.74 9085.81; 39.03 8991.72; 39.27 9406.44; 39.50 9434.67; 39.76 9177.94; 39.98 9339.87; 40.07 9540.8; 40.49 9756.21; 40.82 9244.93; 41.03 8692.83; 41.31 8692.83];
init.tCO2_PT434052554 = 498; units.init.tCO2_PT434052554 = 'kg'; label.init.tCO2_PT434052554 = 'Initial weight';
units.tCO2_PT434052554 = {'d', 'g/d'}; label.tCO2_PT434052554 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT434052554 = 'Daily CO2 emissions of individual PT434052554'; comment.tCO2_PT434052554 = 'Data from GreenBeef trial 2, individual PT434052554'; bibkey.tCO2_PT434052554 = 'GreenBeefTrial2';

data.tCO2_PT433677524 = [0.52 8483.8; 0.56 8483.8; 0.74 8491.19; 0.76 8411.69; 0.77 8411.69; 0.79 8411.69; 0.82 8411.69; 0.85 8311.64; 0.86 8311.64; 0.98 8311.64; 1.00 8311.64; 1.10 8328.12; 1.25 8288.24; 1.33 8443.88; 1.51 8310.78; 1.59 8490.18; 1.78 8625.92; 1.85 8774.55; 2.02 8628.68; 2.07 8378.83; 2.28 8478.24; 2.40 8514.84; 2.49 8514.84; 2.52 8390.23; 2.56 8390.23; 2.60 8380.79; 2.64 8380.79; 2.64 8380.79; 2.72 8451.28; 3.18 8615.21; 3.36 8479.75; 3.41 8479.75; 3.43 8713.51; 3.50 8713.51; 3.56 8646.05; 3.69 8609.4; 3.72 8609.4; 3.83 8609.4; 3.84 8567.34; 3.91 8541.89; 4.01 8337.29; 4.02 8337.29; 4.33 8513.1; 4.44 8153.61; 4.55 8105.06; 4.64 8113.19; 4.77 8113.19; 5.06 8044.15; 5.32 8175.65; 5.39 8347.25; 5.59 8616.06; 5.64 8616.06; 5.73 8616.06; 5.83 8508.53; 6.01 8857.56; 6.25 8671.66; 6.52 8426.88; 6.67 8432.36; 6.73 8432.36; 6.78 8456.75; 6.94 8448.4; 7.05 8663.73; 7.28 8686.57; 27.39 9038.12; 27.40 9038.12; 27.41 9038.12; 27.63 8770.38; 27.63 8770.38; 27.66 8770.38; 27.78 8624.03; 27.82 8624.03; 27.86 8490.21; 28.05 8160.76; 28.09 8176.11; 28.28 7952.15; 28.34 7647.88; 28.39 7303.99; 28.56 7246.81; 28.78 7371.7; 29.05 7264.05; 29.34 7940.13; 29.56 8113.64; 29.69 8113.64; 29.80 8178.58; 30.03 8430.08; 30.28 9126.6; 30.54 9180.41; 30.76 9180.41; 30.98 9312.65; 31.03 9312.65; 31.31 8991.1; 31.56 9012.03; 31.78 9080.07; 32.03 8926.88; 32.08 8763.42; 32.29 8666.71; 32.50 8605.15; 32.55 8633.32; 32.75 8518.28; 32.79 8440.0; 33.01 8054.09; 33.23 8373.57; 33.37 7971.7; 33.47 7971.7; 33.73 7856.26; 33.73 7718.12; 33.98 8588.24; 34.27 8923.23; 34.34 8923.23; 34.50 9140.54; 55.49 8648.08; 55.59 8800.71; 55.70 8800.71; 55.93 8858.32; 56.01 9216.68; 56.24 9258.49; 56.33 9258.49; 56.46 9353.12; 56.61 9271.93; 56.68 9271.93; 56.95 9558.13; 57.05 9251.43; 57.42 9193.95; 57.74 8970.44; 58.03 8095.86; 58.35 8248.99; 58.51 8248.99; 58.74 8065.22; 59.05 7386.47; 59.29 7007.44; 59.51 7007.44; 59.78 6962.82; 60.11 7666.3; 60.39 8252.13; 60.55 8252.13; 60.63 8305.14; 60.88 8305.14; 61.07 8501.54; 61.76 8380.61];
init.tCO2_PT433677524 = 519; units.init.tCO2_PT433677524 = 'kg'; label.init.tCO2_PT433677524 = 'Initial weight';
units.tCO2_PT433677524 = {'d', 'g/d'}; label.tCO2_PT433677524 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT433677524 = 'Daily CO2 emissions of individual PT433677524'; comment.tCO2_PT433677524 = 'Data from GreenBeef trial 2, individual PT433677524'; bibkey.tCO2_PT433677524 = 'GreenBeefTrial2';

data.tCO2_PT433677425 = [20.41 8878.1; 20.42 8878.1; 20.63 8672.36; 20.88 8727.32; 21.01 8471.46; 21.29 8975.19; 21.43 8985.52; 21.52 9269.55; 21.78 9514.22; 22.08 8724.51; 22.28 9114.08; 22.35 9285.97; 22.58 9200.65; 22.84 9407.85; 23.08 9454.46; 23.32 9226.41; 23.46 9076.98; 23.56 9035.84; 23.80 8810.47; 24.05 9238.03; 24.27 9200.13; 24.48 9125.24; 24.73 9199.01; 24.96 8771.0; 25.27 8915.64; 25.27 8915.64; 25.50 8793.34; 25.71 8810.9; 25.99 9328.58; 26.06 9151.71; 26.33 9086.08; 26.46 9086.08; 27.02 9171.9; 27.28 9171.9; 49.39 10602.04; 49.83 10368.52; 50.02 10364.92; 50.30 10385.07; 50.52 10621.19; 50.68 10621.19; 50.75 10621.19; 50.76 10425.77; 50.96 10341.83; 51.02 10341.83; 51.25 10465.05; 51.25 10465.05; 51.52 10399.46; 51.74 10399.46; 51.80 10646.62; 52.29 10082.09; 52.51 10268.31; 52.74 10153.69; 52.96 10166.14; 53.07 10131.32; 53.30 10256.07; 53.53 10055.4; 53.74 10289.21; 53.97 10018.3; 54.07 9938.5; 54.34 10011.06; 54.58 9503.52; 54.79 9388.38; 55.02 9540.35; 55.28 9778.9];
init.tCO2_PT433677425 = 475; units.init.tCO2_PT433677425 = 'kg'; label.init.tCO2_PT433677425 = 'Initial weight';
units.tCO2_PT433677425 = {'d', 'g/d'}; label.tCO2_PT433677425 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT433677425 = 'Daily CO2 emissions of individual PT433677425'; comment.tCO2_PT433677425 = 'Data from GreenBeef trial 2, individual PT433677425'; bibkey.tCO2_PT433677425 = 'GreenBeefTrial2';

data.tCO2_PT634052553 = [1.38 8779.58; 3.04 8022.34; 3.35 8441.49; 3.64 8921.66; 3.86 9310.34; 4.07 9362.7; 4.32 9383.43; 4.54 9790.71; 4.88 9455.85; 5.35 8938.58; 5.60 8451.03; 5.87 9039.22; 6.62 8615.41; 6.87 8615.41; 27.45 8740.38; 27.89 8589.15; 28.37 8913.98; 28.58 9335.34; 28.83 8893.12; 29.19 9466.83; 29.45 9507.02; 29.67 9559.48; 29.92 9598.39; 30.02 9543.18; 30.35 9492.25; 30.77 9455.07; 30.99 9514.6; 31.09 9677.02; 31.33 9630.37; 31.58 9414.65; 31.83 9412.59; 32.09 8704.88; 32.41 9377.39; 32.71 9527.09; 33.08 9792.75; 33.35 9499.21; 33.67 9403.54; 33.89 9528.17; 34.05 9528.17; 34.31 9276.56; 34.56 9304.28; 55.49 10035.24; 55.56 9498.32; 55.86 9525.97; 56.05 9342.03; 56.30 9639.78; 56.60 9894.56; 56.91 9494.04; 57.08 9494.04; 57.36 9992.26; 57.60 9413.55; 57.85 9213.22; 57.97 9448.96; 58.05 9448.96; 58.32 8982.92; 58.57 8735.99; 59.03 9184.86; 59.33 9339.68; 59.54 9533.14; 59.76 9182.06; 60.08 9079.99; 60.31 9365.06; 60.53 9365.06; 60.58 9445.46; 60.77 9708.79; 61.03 10334.73; 61.37 10102.29; 61.59 10187.23; 61.84 10187.23];
init.tCO2_PT634052553 = 556; units.init.tCO2_PT634052553 = 'kg'; label.init.tCO2_PT634052553 = 'Initial weight';
units.tCO2_PT634052553 = {'d', 'g/d'}; label.tCO2_PT634052553 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT634052553 = 'Daily CO2 emissions of individual PT634052553'; comment.tCO2_PT634052553 = 'Data from GreenBeef trial 2, individual PT634052553'; bibkey.tCO2_PT634052553 = 'GreenBeefTrial2';

data.tCO2_PT233677506 = [0.53 9407.09; 0.62 9419.46; 0.68 9419.46; 0.82 9419.46; 1.10 8743.76; 1.34 7830.05; 1.45 8061.4; 1.52 8061.4; 1.59 8019.65; 1.61 7874.72; 1.63 7874.72; 1.80 7834.97; 1.87 7846.11; 2.07 8130.52; 2.08 8130.52; 2.29 8573.4; 2.51 8554.45; 2.52 8554.45; 2.65 8795.35; 2.74 8795.35; 2.78 8780.03; 3.26 8292.1; 3.32 8294.09; 3.47 8452.05; 3.68 8789.22; 3.71 8789.22; 3.87 8777.8; 3.97 8490.78; 4.02 8374.59; 4.08 8366.04; 4.25 8257.78; 4.30 8257.78; 4.34 8257.78; 4.44 8393.18; 4.46 8393.18; 4.56 8190.28; 4.66 8022.82; 4.68 8022.82; 4.70 8022.82; 4.89 7825.58; 5.01 7938.29; 5.26 8036.02; 5.45 7536.75; 5.48 7536.75; 5.63 7451.65; 5.70 7451.65; 5.84 7883.32; 6.04 8059.91; 6.27 8010.96; 6.48 8276.95; 6.57 8412.03; 6.66 8363.81; 6.72 8363.81; 6.86 8205.31; 6.87 8205.31; 6.95 8205.31; 7.06 8196.52; 7.08 8232.7; 7.27 8211.88; 7.31 8211.88; 7.35 8211.88; 27.40 8252.38; 27.43 8252.38; 27.46 8252.38; 27.53 8219.91; 27.59 8271.05; 27.63 8180.62; 27.70 8180.62; 27.73 8180.62; 27.75 8180.62; 27.80 8073.12; 27.85 8043.2; 27.85 8043.2; 27.97 7901.85; 28.08 7926.73; 28.10 7815.6; 28.26 7610.27; 28.31 7643.29; 28.36 7480.8; 28.39 7480.8; 28.41 7480.8; 28.53 7515.88; 28.57 7540.08; 28.59 7462.54; 28.63 7494.77; 28.71 7453.07; 28.75 7453.07; 28.77 7511.46; 28.79 7536.52; 28.85 7664.2; 28.96 7655.13; 29.04 7655.32; 29.06 7655.32; 29.21 7670.85; 29.27 7721.81; 29.31 7734.61; 29.38 7699.81; 29.42 7699.81; 29.45 7717.85; 29.47 7676.16; 29.50 7765.27; 29.52 7765.27; 29.53 7765.27; 29.57 7767.7; 29.62 7767.7; 29.70 7767.7; 29.77 7840.6; 29.93 7747.77; 30.00 7814.8; 30.26 8045.56; 30.31 8244.5; 30.33 8244.5; 30.36 8244.5; 30.50 8503.82; 30.54 8408.86; 30.62 8408.86; 30.71 8408.86; 30.77 8454.05; 30.93 8178.41; 30.99 8284.29; 31.01 8180.92; 31.22 8225.69; 31.27 8188.21; 31.29 8188.21; 31.34 8188.21; 31.36 8188.21; 31.44 8282.82; 31.52 8342.15; 31.57 8342.15; 31.67 8342.15; 31.74 8324.23; 31.89 8903.05; 31.90 8903.05; 31.98 8749.99; 32.02 8749.99; 32.27 9041.41; 32.42 8827.86; 32.52 8953.11; 32.72 9013.46; 32.74 9013.46; 33.00 9048.02; 33.05 9014.81; 33.26 8973.57; 33.42 8973.57; 33.48 8973.57; 33.74 8851.58; 33.99 8907.7; 34.05 8862.44; 34.28 8817.92; 34.51 8739.15; 34.60 8411.74; 55.71 8721.51; 55.77 8451.16; 55.82 8193.04; 55.95 8193.04; 56.01 8245.88; 56.25 8209.78; 56.26 8209.78; 56.30 8287.09; 56.47 8486.13; 56.69 8469.41; 56.93 8654.11; 56.96 8654.11; 57.06 8652.04; 57.26 8615.92; 57.30 8759.97; 57.37 8759.97; 57.57 8398.67; 57.75 8398.67; 57.80 8285.83; 58.01 8738.4; 58.27 9126.27; 58.41 8995.25; 58.48 8995.25; 58.70 9004.23; 58.76 9004.23; 59.00 9044.74; 59.01 9044.74; 59.27 8732.83; 59.52 8582.76; 59.53 8582.76; 59.72 8702.99; 59.74 8702.99; 60.11 8569.58; 60.40 9581.83; 60.59 9489.27; 60.62 9512.41; 60.66 9512.41; 60.77 9512.41; 60.89 9319.76; 60.90 9319.76; 61.04 9481.39; 61.29 9247.96; 61.50 8522.5; 61.73 8465.92; 61.86 8695.05];
init.tCO2_PT233677506 = 525; units.init.tCO2_PT233677506 = 'kg'; label.init.tCO2_PT233677506 = 'Initial weight';
units.tCO2_PT233677506 = {'d', 'g/d'}; label.tCO2_PT233677506 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT233677506 = 'Daily CO2 emissions of individual PT233677506'; comment.tCO2_PT233677506 = 'Data from GreenBeef trial 2, individual PT233677506'; bibkey.tCO2_PT233677506 = 'GreenBeefTrial2';

data.tCO2_PT834052552 = [1.83 7839.09; 2.39 7630.02; 2.71 7630.02; 3.38 8097.63; 3.82 7964.22; 4.29 8267.83; 4.51 8581.47; 4.76 8581.47; 5.29 7319.08; 5.82 8630.8; 6.33 8531.49; 6.60 8203.21; 6.84 8023.45; 7.29 7377.34; 27.51 7939.62; 27.79 7939.62; 28.33 7039.48; 28.46 7039.48; 28.55 7039.48; 28.81 7193.42; 29.30 7657.58; 29.70 7502.34; 30.11 7710.53; 30.32 7468.06; 30.59 7910.21; 30.82 8726.59; 31.01 8477.95; 31.35 8287.88; 31.62 8145.35; 31.96 8020.22; 32.06 7902.8; 32.28 7749.12; 32.54 7343.3; 32.76 7199.91; 32.79 7101.9; 33.03 7261.57; 33.27 7103.31; 33.52 7423.25; 33.85 7998.25; 34.00 7998.25; 34.29 7829.26; 34.59 7582.32; 55.53 8809.08; 56.31 9238.42; 56.56 8678.97; 56.82 8341.89; 56.86 8341.89; 57.18 8419.1; 57.54 8828.07; 57.81 8865.26; 58.08 8696.9; 58.39 8322.63; 58.75 8276.68; 59.11 8187.74; 59.36 8769.97; 59.71 9023.74; 60.01 8767.78; 60.28 9191.62; 60.51 9236.48; 60.59 9236.48; 60.76 9075.14; 61.20 9335.65; 61.46 8650.16];
init.tCO2_PT834052552 = 459; units.init.tCO2_PT834052552 = 'kg'; label.init.tCO2_PT834052552 = 'Initial weight';
units.tCO2_PT834052552 = {'d', 'g/d'}; label.tCO2_PT834052552 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT834052552 = 'Daily CO2 emissions of individual PT834052552'; comment.tCO2_PT834052552 = 'Data from GreenBeef trial 2, individual PT834052552'; bibkey.tCO2_PT834052552 = 'GreenBeefTrial2';

data.tCO2_PT733677513 = [8.50 9002.47; 9.16 8991.19; 9.16 8991.19; 9.44 8991.19; 9.65 8991.19; 10.43 7998.29; 10.64 7998.29; 10.72 7998.29; 11.37 8428.72; 11.38 8428.72; 11.46 8428.72; 11.53 8674.2; 11.60 8674.2; 11.65 8674.2; 11.72 8674.2; 11.83 8738.96; 12.02 8504.9; 12.29 8996.67; 12.52 9049.79; 12.75 8543.36; 13.02 8401.86; 13.26 8391.83; 34.64 8269.35; 34.66 8269.35; 34.71 8269.35; 34.86 7980.97; 34.98 7980.97; 35.09 8032.74; 35.29 7477.3; 35.35 7526.65; 35.57 7233.46; 35.68 7199.22; 35.77 7199.22; 35.78 7199.22; 35.82 7187.12; 35.99 7115.39; 36.15 7259.74; 36.31 7610.61; 36.36 7570.59; 36.52 7754.3; 36.59 7890.81; 36.75 7771.18; 36.79 7771.18; 36.81 7806.08; 37.08 8173.2; 37.29 8451.81; 37.52 8381.98; 37.55 8381.98; 37.57 8381.98; 37.77 8465.36; 38.14 7721.98; 38.32 7646.61; 38.37 7815.56; 38.39 7815.56; 38.51 7815.56; 38.51 7815.56; 38.61 8129.51; 38.62 8129.51; 38.83 8232.95; 39.05 8971.66; 39.28 9188.29; 39.49 9137.72; 39.76 8885.79; 39.97 8745.93; 40.08 8843.9; 40.32 8981.91; 40.58 8770.96; 40.79 8653.51; 41.02 8833.41; 41.27 8561.12];
init.tCO2_PT733677513 = 514; units.init.tCO2_PT733677513 = 'kg'; label.init.tCO2_PT733677513 = 'Initial weight';
units.tCO2_PT733677513 = {'d', 'g/d'}; label.tCO2_PT733677513 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT733677513 = 'Daily CO2 emissions of individual PT733677513'; comment.tCO2_PT733677513 = 'Data from GreenBeef trial 2, individual PT733677513'; bibkey.tCO2_PT733677513 = 'GreenBeefTrial2';

data.tCO2_PT433677562 = [14.61 9024.98; 15.37 7820.66; 15.65 8228.17; 15.88 8468.03; 16.03 8468.03; 16.31 8208.89; 16.59 8482.06; 16.82 8527.91; 17.00 8527.91; 17.24 9138.12; 17.30 9138.12; 17.56 8909.34; 17.82 9495.43; 18.03 9495.43; 18.06 9092.25; 18.31 9187.02; 18.58 9306.22; 18.81 9389.13; 19.09 8789.21; 19.33 9379.73; 19.59 9565.67; 19.64 9402.55; 19.86 9705.62; 20.11 9462.6; 41.73 8485.89; 41.98 8185.28; 42.08 8223.03; 42.30 8580.57; 42.33 8580.57; 42.58 8481.0; 42.58 8415.65; 42.79 8415.65; 43.08 8625.37; 43.31 8594.42; 43.54 8594.42; 43.79 8718.51; 44.07 8847.98; 44.29 8841.21; 44.50 8841.21; 44.76 8926.1; 45.08 9011.6; 45.32 8791.33; 45.58 8671.8; 45.63 8671.8; 45.87 8562.4; 46.02 8580.68; 46.29 8635.52; 46.50 8564.03; 46.73 8707.46; 47.01 9096.76; 47.24 9079.21; 47.29 9258.65; 47.54 9474.13; 47.78 9468.79; 48.04 9768.16; 48.28 9752.1; 48.51 9608.4; 48.77 9399.28; 49.00 9251.8; 49.28 8981.96];
init.tCO2_PT433677562 = 497; units.init.tCO2_PT433677562 = 'kg'; label.init.tCO2_PT433677562 = 'Initial weight';
units.tCO2_PT433677562 = {'d', 'g/d'}; label.tCO2_PT433677562 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT433677562 = 'Daily CO2 emissions of individual PT433677562'; comment.tCO2_PT433677562 = 'Data from GreenBeef trial 2, individual PT433677562'; bibkey.tCO2_PT433677562 = 'GreenBeefTrial2';

data.tCO2_PT034067821 = [13.66 7718.53; 13.66 7718.53; 14.11 7529.34; 14.28 7725.79; 14.36 7725.79; 14.60 8241.24; 14.88 8952.35; 15.05 8952.35; 15.27 9155.98; 15.60 9253.66; 15.87 9335.5; 16.02 9335.5; 16.30 9049.81; 16.56 9120.92; 16.82 9151.86; 17.11 8980.85; 17.38 8473.11; 17.66 8326.7; 17.88 8148.79; 18.05 8188.6; 18.29 8289.95; 18.63 8323.04; 19.01 8413.56; 19.26 8250.21; 19.48 8424.05; 19.89 8062.44; 20.11 8148.1; 20.23 8148.1; 20.36 8148.1; 41.45 8683.88; 41.68 8756.23; 42.07 8548.6; 42.32 8710.99; 42.57 8647.68; 42.79 8394.72; 43.08 8372.47; 43.31 8637.82; 43.54 8628.97; 43.80 8795.2; 44.01 8555.58; 44.27 8686.5; 44.49 8913.7; 44.80 8934.2; 45.09 9569.03; 45.31 9550.89; 45.56 9286.04; 45.79 9423.5; 46.02 9203.86; 46.28 8866.65; 46.60 9117.89; 46.84 8843.87; 47.03 8682.17; 47.27 8845.03; 47.52 8128.03; 47.77 8511.12; 48.02 8698.14; 48.26 8863.83; 48.50 9479.59; 48.78 9546.07; 49.07 9180.61; 49.29 8702.36];
init.tCO2_PT034067821 = 453; units.init.tCO2_PT034067821 = 'kg'; label.init.tCO2_PT034067821 = 'Initial weight';
units.tCO2_PT034067821 = {'d', 'g/d'}; label.tCO2_PT034067821 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT034067821 = 'Daily CO2 emissions of individual PT034067821'; comment.tCO2_PT034067821 = 'Data from GreenBeef trial 2, individual PT034067821'; bibkey.tCO2_PT034067821 = 'GreenBeefTrial2';

data.tCO2_PT733677556 = [20.43 8858.84; 20.55 8977.14; 20.65 8977.14; 20.88 8798.52; 20.88 8798.52; 21.03 8363.12; 21.29 8642.01; 21.57 7759.93; 21.87 7613.48; 22.28 8211.69; 22.50 8141.21; 22.72 8099.99; 23.07 7914.83; 23.08 7914.83; 23.46 8015.7; 23.67 8000.73; 23.90 7913.9; 24.19 7988.66; 24.50 7839.79; 24.73 7973.07; 24.98 7985.25; 25.04 8179.71; 25.28 8332.97; 25.51 8200.78; 26.02 7164.92; 26.27 7052.79; 26.57 7852.16; 26.80 7871.25; 27.03 7871.25; 27.29 8218.83; 49.87 8841.56; 50.29 8784.03; 50.53 8518.44; 50.77 8363.69; 51.27 8182.87; 51.28 7955.26; 51.52 7955.26; 51.52 7955.26; 51.75 8019.47; 52.07 8198.78; 52.52 7451.49; 52.75 7124.46; 53.12 7625.93; 53.41 8585.49; 53.66 8994.16; 53.89 8428.84; 54.18 7763.11; 54.71 9055.91; 54.95 8693.05; 55.03 8693.05; 55.28 8625.82];
init.tCO2_PT733677556 = 477; units.init.tCO2_PT733677556 = 'kg'; label.init.tCO2_PT733677556 = 'Initial weight';
units.tCO2_PT733677556 = {'d', 'g/d'}; label.tCO2_PT733677556 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT733677556 = 'Daily CO2 emissions of individual PT733677556'; comment.tCO2_PT733677556 = 'Data from GreenBeef trial 2, individual PT733677556'; bibkey.tCO2_PT733677556 = 'GreenBeefTrial2';

data.tCO2_PT933677550 = [13.63 8883.72; 14.10 8181.27; 14.25 8178.75; 14.27 8178.75; 14.47 8178.75; 14.51 8178.75; 14.53 8178.75; 14.68 8192.75; 14.72 8192.75; 15.06 8635.18; 15.31 8561.66; 15.63 9034.67; 15.88 8835.86; 16.04 8748.6; 16.29 8951.74; 16.51 8720.16; 16.73 8646.99; 17.34 8890.99; 17.56 8890.99; 17.71 8778.85; 17.80 8778.85; 18.10 8434.69; 18.32 8767.32; 18.57 8818.62; 18.82 8935.67; 19.07 8991.44; 19.31 8968.03; 19.60 9092.64; 19.81 9721.28; 20.03 9721.28; 20.22 9807.84; 20.31 9807.84; 41.44 8117.73; 41.66 8211.51; 41.91 8476.79; 42.04 8457.79; 42.26 8683.28; 42.30 8683.28; 42.49 8596.12; 42.75 8861.93; 42.97 9081.89; 43.03 8820.23; 43.25 8651.5; 43.49 8797.85; 43.72 8513.64; 43.94 8030.34; 44.01 8335.3; 44.23 8530.21; 44.44 8965.57; 44.65 8906.46; 44.87 8984.81; 45.03 8955.74; 45.24 8915.58; 45.46 8514.5; 45.67 8773.09; 45.89 8957.14; 46.00 9193.26; 46.27 9447.71; 46.49 9702.51; 46.72 9609.63; 46.93 9682.39; 47.03 9579.19; 47.25 9591.64; 47.48 9414.3; 47.71 9478.23; 47.95 9439.49; 48.10 9132.77; 48.32 9027.77; 48.40 9027.77; 48.58 9168.96; 48.80 9070.59; 49.04 8916.46; 49.25 9228.75];
init.tCO2_PT933677550 = 525; units.init.tCO2_PT933677550 = 'kg'; label.init.tCO2_PT933677550 = 'Initial weight';
units.tCO2_PT933677550 = {'d', 'g/d'}; label.tCO2_PT933677550 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT933677550 = 'Daily CO2 emissions of individual PT933677550'; comment.tCO2_PT933677550 = 'Data from GreenBeef trial 2, individual PT933677550'; bibkey.tCO2_PT933677550 = 'GreenBeefTrial2';

data.tCO2_PT733677452 = [20.45 7120.29; 20.46 7120.29; 20.48 7120.29; 20.54 7140.54; 20.79 7078.02; 21.02 6763.61; 21.24 7213.21; 21.46 7176.56; 21.68 6934.0; 21.98 6974.26; 22.73 7637.72; 22.87 7535.44; 23.01 7535.44; 23.09 7535.44; 23.31 7688.03; 24.02 7318.28; 24.50 8030.22; 24.72 8224.13; 24.95 8148.36; 25.01 8329.68; 25.26 8072.2; 25.49 8488.79; 25.99 8472.48; 26.02 8695.78; 26.24 8466.33; 26.61 7718.82; 49.39 9155.94; 49.61 9182.6; 49.83 9182.6; 50.00 8968.88; 50.80 5926.35; 51.02 5926.35; 51.24 5853.66; 51.60 6492.73; 51.84 6810.32; 52.06 7058.43; 52.46 7134.34; 53.04 7426.92; 53.32 7595.98; 53.55 7358.67; 53.76 7200.97; 53.99 7122.58; 54.07 7055.47; 54.28 7059.23; 54.76 7872.42; 54.98 7970.69; 55.01 7970.69; 55.30 7909.56];
init.tCO2_PT733677452 = 458; units.init.tCO2_PT733677452 = 'kg'; label.init.tCO2_PT733677452 = 'Initial weight';
units.tCO2_PT733677452 = {'d', 'g/d'}; label.tCO2_PT733677452 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT733677452 = 'Daily CO2 emissions of individual PT733677452'; comment.tCO2_PT733677452 = 'Data from GreenBeef trial 2, individual PT733677452'; bibkey.tCO2_PT733677452 = 'GreenBeefTrial2';

data.tCO2_PT334023118 = [20.48 9168.57; 21.32 8804.79; 21.52 8830.26; 21.97 8626.37; 22.29 9047.25; 22.77 9130.28; 23.32 8954.41; 23.88 9872.64; 24.00 9872.64; 24.63 9032.31; 25.33 9060.14; 25.57 9060.14; 26.25 8304.34; 26.55 8304.34; 27.30 9735.47; 50.32 9747.78; 50.55 9747.78; 50.78 9799.54; 51.28 9246.08; 51.54 9859.75; 53.01 8703.4; 53.52 10699.14; 54.27 9238.96; 54.52 9238.96; 54.77 8954.07; 55.09 8664.52];
init.tCO2_PT334023118 = 587; units.init.tCO2_PT334023118 = 'kg'; label.init.tCO2_PT334023118 = 'Initial weight';
units.tCO2_PT334023118 = {'d', 'g/d'}; label.tCO2_PT334023118 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT334023118 = 'Daily CO2 emissions of individual PT334023118'; comment.tCO2_PT334023118 = 'Data from GreenBeef trial 2, individual PT334023118'; bibkey.tCO2_PT334023118 = 'GreenBeefTrial2';

data.tCO2_PT434164528 = [21.43 7667.97; 21.44 7667.97; 21.66 7712.84; 21.66 7712.84; 21.82 7634.73; 21.88 7442.09; 22.01 7688.3; 22.08 7688.3; 22.24 7441.68; 22.29 7280.05; 22.36 7435.0; 22.45 7565.44; 22.61 7537.87; 22.67 7537.87; 22.78 7497.04; 22.89 7725.77; 23.06 7565.28; 23.07 7540.35; 23.27 7482.35; 23.31 7749.34; 23.48 7525.52; 23.56 7559.88; 23.57 7601.03; 23.80 7665.03; 24.05 7675.88; 24.27 8494.82; 24.35 8580.47; 24.50 8381.02; 24.72 8187.18; 24.97 8324.33; 24.98 8324.33; 25.02 8289.78; 25.03 8289.78; 25.25 7960.2; 25.48 7986.14; 25.59 8397.81; 25.73 8397.81; 25.99 8481.71; 26.01 8481.71; 26.24 8712.9; 26.45 8778.44; 26.89 8633.17; 27.01 8421.82; 27.24 8421.82; 49.40 11384.9; 49.61 11384.9; 50.26 9148.81; 50.52 9339.88; 50.74 9339.88; 50.96 9338.5; 51.01 9400.7; 51.25 9404.42; 51.47 9381.66; 51.71 9256.36; 52.29 8464.78; 52.52 8671.9; 52.75 8872.75; 52.75 8872.75; 52.98 8960.7; 53.03 9250.59; 53.26 9682.76; 53.48 9719.23; 53.48 9398.2; 53.74 9259.85; 53.98 8849.96; 54.02 9483.52; 54.24 9432.64; 54.48 9440.61; 54.70 9380.51; 54.92 9183.02; 54.95 9183.02; 55.04 8678.43; 55.27 8553.48];
init.tCO2_PT434164528 = 450; units.init.tCO2_PT434164528 = 'kg'; label.init.tCO2_PT434164528 = 'Initial weight';
units.tCO2_PT434164528 = {'d', 'g/d'}; label.tCO2_PT434164528 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT434164528 = 'Daily CO2 emissions of individual PT434164528'; comment.tCO2_PT434164528 = 'Data from GreenBeef trial 2, individual PT434164528'; bibkey.tCO2_PT434164528 = 'GreenBeefTrial2';

data.tCO2_PT733602904 = [8.54 9903.13; 8.70 9907.89; 8.80 9696.1; 9.14 9417.03; 9.15 9417.03; 9.29 9073.48; 9.39 9128.63; 9.41 9652.11; 9.90 10376.57; 10.23 9862.34; 10.50 8847.19; 10.70 8722.61; 10.98 8398.56; 11.07 8389.99; 11.35 8159.42; 11.58 8134.49; 11.81 7956.66; 12.01 8132.78; 12.25 7910.02; 12.50 7870.26; 12.73 7684.22; 13.01 7685.76; 13.24 7674.91; 34.72 10242.38; 34.98 9440.31; 35.04 9232.96; 35.22 9294.95; 35.28 9282.55; 35.51 9147.58; 35.60 9065.29; 35.64 9065.29; 35.73 9265.93; 35.99 9606.87; 36.30 9526.64; 36.52 9258.36; 36.73 8873.75; 36.98 8731.86; 37.01 8731.86; 37.22 8810.58; 37.48 8818.18; 37.70 8814.98; 37.93 9593.11; 38.17 8786.87; 38.40 9001.59; 38.61 8951.0; 38.64 8951.0; 38.87 8966.05; 39.07 8848.42; 39.52 8139.48; 39.67 7918.95; 39.81 7918.95; 40.10 7803.04; 40.34 8351.17; 40.55 8373.8; 40.81 8344.7; 41.04 8501.14; 41.28 8043.63];
init.tCO2_PT733602904 = 495; units.init.tCO2_PT733602904 = 'kg'; label.init.tCO2_PT733602904 = 'Initial weight';
units.tCO2_PT733602904 = {'d', 'g/d'}; label.tCO2_PT733602904 = {'Time since start', 'Daily carbon dioxide (CO2) emissions'}; txtData.title.tCO2_PT733602904 = 'Daily CO2 emissions of individual PT733602904'; comment.tCO2_PT733602904 = 'Data from GreenBeef trial 2, individual PT733602904'; bibkey.tCO2_PT733602904 = 'GreenBeefTrial2';

%% Diet information
data.diet_comp_params = 10; units.diet_comp_params = '-'; label.diet_comp_params = 'Dummy variable'; bibkey.diet_comp_params = '-'; comment.diet_comp_params = 'List of composition parameters specific to each diet';
diets.diet_comp_params = {'mu_X', 'n_HX', 'n_OX', 'n_NX'};
units.diets.diet_comp_params = '-'; label.diets.diet_comp_params = 'List of composition parameters specific to each diet';

data.inds_of_diet = 10; units.inds_of_diet = '-'; label.inds_of_diet = 'Dummy variable'; bibkey.inds_of_diet = '-'; comment.inds_of_diet = 'Struct with list of individuals fed the diet';
diets.inds_of_diet = struct( ...
    'CTRL_2022', { 'PT524956505', 'PT833653649', 'PT924401183', 'PT933843894', 'PT533987885', 'PT224401177', 'PT333842562', 'PT524401180', 'PT533843896', 'PT933602927' }, ...
    'TMR_2022', { 'PT233843883', 'PT333653651', 'PT433843806', 'PT724523831', 'PT424401157', 'PT033634130', 'PT624139868', 'PT533358890', 'PT933843912', 'PT833653644' }, ...
    'TMR_2023', { 'PT733602904', 'PT333677539', 'PT834052552', 'PT634052553', 'PT334023113', 'PT533677434', 'PT733677513', 'PT434052554', 'PT233677506', 'PT433677524' }, ...
    'OIL_2023', { 'PT433677562', 'PT034067821', 'PT433677425', 'PT733677556', 'PT834023120', 'PT933677550', 'PT434164528', 'PT334023118', 'PT433677444', 'PT733677452' } ...
);
units.diets.inds_of_diet = '-'; label.diets.inds_of_diet = 'Struct with list of individuals fed the diet';



%% Multitier auxiliary variables

% individual data types
metaData.ind_data_types = {'tCH4', 'tCO2', 'tW'}; 

% Cell array of ind_ids
data.ind_list = 10; units.ind_list = '-'; label.ind_list = 'Dummy variable'; comment.ind_list = 'List of individuals'; bibkey.ind_list = '-'; 
tiers.ind_list = {'PT933843912', 'PT533987885', 'PT624139868', 'PT424401157', 'PT533358890', 'PT533843896', 'PT833653644', 'PT433843806', 'PT224401177', 'PT833653649', 'PT524401180', 'PT933843894', 'PT033634130', 'PT233843883', 'PT333842562', 'PT933602927', 'PT524956505', 'PT724523831', 'PT333653651', 'PT924401183', 'PT333677539', 'PT433677444', 'PT334023113', 'PT834023120', 'PT434052554', 'PT433677524', 'PT433677425', 'PT533677434', 'PT634052553', 'PT233677506', 'PT834052552', 'PT733677513', 'PT433677562', 'PT034067821', 'PT733677556', 'PT933677550', 'PT733677452', 'PT334023118', 'PT434164528', 'PT733602904'}; units.tiers.ind_list = '-'; label.tiers.ind_list = 'List of individuals'; 
metaData.ind_list = tiers.ind_list; % Save in metaData to use in pars_init.m

% Struct with form groups_of_ind.(ind_id) = list_of_groups_ids_ind_belongs_to
data.groups_of_ind = 10; units.groups_of_ind = '-'; label.groups_of_ind = 'Dummy variable'; comment.groups_of_ind = 'Groups of individuals'; bibkey.groups_of_ind = '-'; 
tiers.groups_of_ind = struct('PT933843912', {{'T1_2'}}, 'PT533987885', {{'T1_3'}}, 'PT624139868', {{'T1_2'}}, 'PT424401157', {{'T1_2'}}, 'PT533358890', {{'T1_5'}}, 'PT533843896', {{'T1_4'}}, 'PT833653644', {{'T1_2'}}, 'PT433843806', {{'T1_2'}}, 'PT224401177', {{'T1_4'}}, 'PT833653649', {{'T1_3'}}, 'PT524401180', {{'T1_3'}}, 'PT933843894', {{'T1_3'}}, 'PT033634130', {{'T1_5'}}, 'PT233843883', {{'T1_5'}}, 'PT333842562', {{'T1_3'}}, 'PT933602927', {{'T1_4'}}, 'PT524956505', {{'T1_4'}}, 'PT724523831', {{'T1_5'}}, 'PT333653651', {{'T1_5'}}, 'PT924401183', {{'T1_4'}}, 'PT333677539', {{'T2_3'}}, 'PT433677444', {{'T2_5'}}, 'PT334023113', {{'T2_4'}}, 'PT834023120', {{'T2_5'}}, 'PT434052554', {{'T2_4'}}, 'PT433677524', {{'T2_3'}}, 'PT433677425', {{'T2_2'}}, 'PT533677434', {{'T2_4'}}, 'PT634052553', {{'T2_3'}}, 'PT233677506', {{'T2_3'}}, 'PT834052552', {{'T2_3'}}, 'PT733677513', {{'T2_4'}}, 'PT433677562', {{'T2_5'}}, 'PT034067821', {{'T2_5'}}, 'PT733677556', {{'T2_2'}}, 'PT933677550', {{'T2_5'}}, 'PT733677452', {{'T2_2'}}, 'PT334023118', {{'T2_2'}}, 'PT434164528', {{'T2_2'}}, 'PT733602904', {{'T2_4'}}); units.tiers.groups_of_ind = '-'; label.tiers.groups_of_ind = 'Groups of individuals'; 

% Cell array of tier_sample_ids
data.tier_sample_list = 10; units.tier_sample_list = '-'; label.tier_sample_list = 'Dummy variable'; comment.tier_sample_list = 'Tier sample list'; bibkey.tier_sample_list = '-'; 
tiers.tier_sample_list = {'male'}; units.tiers.tier_sample_list = '-'; label.tiers.tier_sample_list = 'Tier sample list'; 
metaData.tier_sample_list = tiers.tier_sample_list; % Save in metaData to use in pars_init.m

% Struct with form 
% tier_sample_inds.(tier_sample_id) = list_of_inds_in_tier_sample
data.tier_sample_inds = 10; units.tier_sample_inds = '-'; label.tier_sample_inds = 'Dummy variable'; comment.tier_sample_inds = 'List of individuals that belong to the name sample'; bibkey.tier_sample_inds = '-'; 
tiers.tier_sample_inds = struct('male', {{'PT933843912', 'PT533987885', 'PT624139868', 'PT424401157', 'PT533358890', 'PT533843896', 'PT833653644', 'PT433843806', 'PT224401177', 'PT833653649', 'PT524401180', 'PT933843894', 'PT033634130', 'PT233843883', 'PT333842562', 'PT933602927', 'PT524956505', 'PT724523831', 'PT333653651', 'PT924401183', 'PT333677539', 'PT433677444', 'PT334023113', 'PT834023120', 'PT434052554', 'PT433677524', 'PT433677425', 'PT533677434', 'PT634052553', 'PT233677506', 'PT834052552', 'PT733677513', 'PT433677562', 'PT034067821', 'PT733677556', 'PT933677550', 'PT733677452', 'PT334023118', 'PT434164528', 'PT733602904'}}); units.tiers.tier_sample_inds = '-'; label.tiers.tier_sample_inds = 'List of individuals that belong to the name sample'; 


%% Tier parameters
% Cell array with tier parameters
data.tier_pars = 10; units.tier_pars = '-'; label.tier_pars = 'Dummy variable'; comment.tier_pars = 'Tier parameters'; bibkey.tier_pars = '-'; 
tiers.tier_pars = {'p_Am', 'kap_X', 'kap_P', 'xi_C', 'rho_xi', 'lambda', 'p_M', 'v', 'kap', 'E_G', 'E_Hb', 'E_Hx', 'E_Hp', 'h_a', 't_0', 'del_M', 'p_Am_f', 'E_Hx_f', 'E_Hp_f', 'n_NV', 'f_milk'}; units.tiers.tier_pars = '-'; label.tiers.tier_pars = 'Tier parameters'; 
metaData.tier_pars = tiers.tier_pars; % Save in metaData to use in pars_init.m

% Initial values for each tier parameter and sample
% Struct with form tier_par_init_values.(par).(tier_sample_id) = value;
metaData.tier_par_init_values = struct('p_Am', struct('male', 4967), 'kap_X', struct('male', 0.1354), 'kap_P', struct('male', 0.2649), 'xi_C', struct('male', 0.03554), 'rho_xi', struct('male', 0.05), 'lambda', struct('male', 2), 'p_M', struct('male', 83.68), 'v', struct('male', 0.08757), 'kap', struct('male', 0.9716), 'E_G', struct('male', 7829), 'E_Hb', struct('male', 2000000.0), 'E_Hx', struct('male', 20000000.0), 'E_Hp', struct('male', 60000000.0), 'h_a', struct('male', 5e-10), 't_0', struct('male', 80), 'del_M', struct('male', 0.154), 'p_Am_f', struct('male', 4667), 'E_Hx_f', struct('male', 20000000.0), 'E_Hp_f', struct('male', 60000000.0), 'n_NV', struct('male', 0.15), 'f_milk', struct('male', 1)); 


%% Set temperature data and remove weights for dummy variables
weights = setweights(data, []);
IPCC_data_weight = 0;


metaData.data_fields = fieldnames(data);
temp = struct();
for i = 1:length(metaData.data_fields)
    % Add typical temperature only to fields without specified temperature
    field = metaData.data_fields{i};
    if ~isfield(temp, field)
        temp.(field) = metaData.T_typical;
        units.temp.(field) = 'K';
        label.temp.(field) = 'temperature';
    end
    % Removing weight from dummy variables
    if strcmp(label.(field), 'Dummy variable')
        weights.(field) = 0;
    end
    if strcmp(bibkey.(field), 'IPCC')
        weights.(field) = weights.(field) * IPCC_data_weight;
    end
    % Saving data variable names in metaData
    if length(data.(field)) > 1
        metaData.data_1{end+1} = field; % univariate
    else
        metaData.data_0{end+1} = field; % zero-variate
    end
end
fetal_development_weight = 5;
weights.tWwe_Anthony = fetal_development_weight * weights.tWwe_Anthony;
weights.tWwe_Mao = fetal_development_weight * weights.tWwe_Mao;

% weights.CPR_Unfed_Herd19_HP = weights.CPR_Unfed_Herd19_HP * 10;

%% Set weight of individual data
ind_data_weights = struct('tW', 3/40, 'tCO2', 1/40, 'tCH4', 1/40);
inds_OIL = {diets.inds_of_diet.OIL_2023};
for dt=1:length(metaData.ind_data_types)
    data_type = metaData.ind_data_types{dt};
    cumulative = strcmp(data_type, 'tW');
    for i=1:length(tiers.ind_list)
        ind_id = tiers.ind_list{i};
        data_varname = [data_type '_' ind_id];
        if isfield(data, data_varname)
            weights.(data_varname) = weights.(data_varname) * ind_data_weights.(data_type);
            if cumulative
                n_dt = length(weights.(data_varname));
                sum_w = sum(weights.(data_varname));
                weights.(data_varname) = sum_w * (0:n_dt-1)' / sum(0:n_dt-1);
                % weights.(data_varname)(1) = 0;
                % weights.(data_varname) = weights.(data_varname) * n_dt / (n_dt - 1);
            end
            if strcmp(data_type, 'tCH4')
                if any(strcmp(ind_id, inds_OIL))
                    weights.(data_varname) = weights.(data_varname) * 0;
                end
            end
        end
    end
end
    

%% Set weight of group data
group_data_weights = struct('tJX_grp', 5/40);
for dt=1:length(metaData.group_data_types)
    data_type = metaData.group_data_types{dt};
    for g=1:length(tiers.group_list)
        g_id = tiers.group_list{g};
        data_varname = [data_type '_' g_id];
    
        if isfield(data, data_varname)
            n_inds_in_data = length(fieldnames(init.(data_varname)));
            weights.(data_varname) = weights.(data_varname) * group_data_weights.(data_type) * n_inds_in_data;
        end
    end
end

%% Set pseudo-data for tier parameters
[data, units, label, weights] = addpseudodata(data, units, label, weights);

data.psd.t_0 = 80;          units.psd.t_0 = 'd';       label.psd.t_0 = 'time at start development';
data.psd.f_milk = 1;        units.psd.f_milk = '-';    label.psd.f_milk = 'scaled functional response between birth and weaning';
data.psd.n_NE = 0.15;       units.psd.n_NE = '-';      label.psd.n_NE = 'chem. index of nitrogen in reserve';
data.psd.n_NV = 0.15;       units.psd.n_NV = '-';      label.psd.n_NV = 'chem. index of nitrogen in structure';

% weights.psd.p_M = 1*weights.psd.p_M;
weights.psd.t_0 = 0;
weights.psd.f_milk = 0.5;
% weights.psd.kap_G = . 1;
weights.psd.n_NE = .05;
weights.psd.n_NV = .05;

%% pack auxData and txtData for output
auxData.temp = temp;
auxData.tiers = tiers;
auxData.init = init;
auxData.diets = diets;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group Plots
set_tWwe = {'tWwe_Mao', 'tWwe_Anthony'}; subtitle_tWwe = {'Fetal development data from Mao et al. 2008 and Anthony et al. 1986'};
set_WN_ret = {'WN_ret_males', 'WN_ret_females'}; subtitle_WN_ret = {'Nitrogen retention for males and females from IPCC'};
set_WN_urine = {'WN_urine_males', 'WN_urine_females'}; subtitle_WN_urine = {'Nitrogen excretion in urine for males and females from IPCC'};
set_WN_feces = {'WN_feces_males', 'WN_feces_females'}; subtitle_WN_feces = {'Nitrogen excretion in feces for males and females from IPCC'};
metaData.grp.sets = {set_tWwe, set_WN_feces, set_WN_urine, set_WN_ret};
metaData.grp.subtitle = {subtitle_tWwe, subtitle_WN_feces, subtitle_WN_urine, subtitle_WN_ret};

%% Discussion points
D1 = 'For males, we assume that all energy going to the reproduction buffer is dissipatated.';
D2 = '';
metaData.discussion = struct('D1', D1, 'D2', D2);

%% Data Sources and References
bibkey = 'DakaMart2006'; type = 'Article'; bib = [ ... 
'author = {D?kay, I., M?rton, D., Keller, K., F?rd?s, A., T?r?k, M., Szab?, F.}, ' ... 
'year = {2006}, ' ...
'title = {Study on the age at first calving and the longevity of beef cows}, ' ...
'journal = {Journal of Central European Agriculture}, ' ...
'volume = {7}, ' ...
'pages = {377--388}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'BeltButt1992'; type = 'Article'; bib = [ ... 
'author = {Beltr?n, J. J. and  Butts, W. T. and Olson, T. A. and Koger, M.}, ' ... 
'year = {1992}, ' ...
'title = {Growth patterns of two lines of Angus cattle selected using predicted growth parameters}, ' ...
'journal = {Journal of Animal Science}, ' ...
'volume = {70}, ' ...
'pages = {734--41}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'LiveBee1945'; type = 'Article'; bib = [ ... 
'author = {Livesay, E. A. and  Bee, Ural G.}' ... 
'year = {1945}, ' ...
'title = {A study of the gestation periods of five breeds of cattle}, ' ...
'journal = {Journal of Animal Science}, ' ...
'volume = {4}, ' ...
'pages = {13--14}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Luns1982'; type = 'Article'; bib = [ ... 
'author = {Lunstra, D. D.}, ' ... 
'year = {1982}, ' ...
'title = {Testicular development and onset of puberty in beef bulls}, ' ...
'journal = {Beef Research Program Progress Report}, ' ...
'volume = {1}, ' ...
'pages = {26--27}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Bastos2022'; type = 'MasterThesis'; bib = [ ...
'author = {Bastos, Ana R. P.}, ' ... 
'year = {2022}, ' ...
'title = {Caracterização produtiva e reprodutiva da raça {Aberdeen}-{Angus} em {Portugal} no período 2014-2020}, ' ...
'school = {Universidade de Lisboa, Faculdade de Medicina Veterinária. Instituto Superior de Agronomia}, '
];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'FAO2024'; type = 'misc'; bib = [...
    'title = "Domestic Animal Diversity Information System ({DAD-IS}) website",' ...
    'author = "{Food and Agriculture Organization of the United nations}",' ...
    'howpublished = \url{https://www.fao.org/dad-is/browse-by-country-and-species/en/},"' ...
    'year = "cited December 2022"'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'IPCC'; type = 'misc'; bib = [...
    'title = 2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories',...
    'author = {IPCC}', ...
    ''
    ];

