function [data, auxData, metaData, txtData, weights] = mydata_Spodoptera_frugiperda 

%% set metaData
metaData.phylum     = 'Arthropoda'; 
metaData.class      = 'Insecta'; 
metaData.order      = 'Lepidoptera'; 
metaData.family     = 'Noctuidae';
metaData.species    = 'Spodoptera_frugiperda'; 
metaData.species_en = 'Fall Armyworm'; 

metaData.ecoCode.climate = {'Am','Aw','Cwa','Cwb'}; 
metaData.ecoCode.ecozone = {'TN','THn','TPa','TPi'};
metaData.ecoCode.habitat = {'0iTg'};
metaData.ecoCode.embryo  = {'Thl','Tt'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bjHl','eiHn'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};  

metaData.T_typical  = C2K(25); % K, body temp
metaData.data_0     = {'ab'; 'tj'; 'te'; 'am'; 'L_t'; 'Wwj'; 'Ni'};
metaData.data_1     = {'T-ab'; 'T-te'; 'T-s'}; 

metaData.COMPLETE = 2.7; % using criteria of LikaKear2011

metaData.author   = {'Andre Gergs','Christian Baden'};    
metaData.date_subm = [2020 07 07];              
metaData.email    = {'andre.gergs@bayer.com'};            
metaData.address  = {'Bayer AG'};   

metaData.curator     = {'Bas Kooijman'};
metaData.email_cur   = {'bas.kooijman@vu.nl'}; 
metaData.date_acc    = [2020 07 21]; 

%% set data
% zero-variate data
data.ab = 4.4;    units.ab = 'd';    label.ab = 'age at birth'; bibkey.ab = 'GarcMeag2018';   
  temp.ab = C2K(22);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
data.tj = 27.5; units.tj = 'd'; label.tj = 'time since birth at pupation'; bibkey.tj = 'GarcMeag2018';   
  temp.tj = C2K(22);  units.temp.tj = 'K'; label.temp.tj = 'temperature';
data.am = 18.4; units.am = 'd'; label.am = 'life span as female imago'; bibkey.am = 'GarcMeag2018';   
  temp.am = C2K(22); units.temp.am = 'K'; label.temp.am = 'temperature'; 
data.t1 = 2.57; units.t1 = 'd'; label.t1 = 'duration of instar 1'; bibkey.t1 = 'MontHunt2019';   
  temp.t1 = C2K(25); units.temp.t1 = 'K'; label.temp.t1 = 'temperature'; 
data.t2 = 2.07; units.t2 = 'd'; label.t2 = 'duration of instar 2'; bibkey.t2 = 'MontHunt2019';   
  temp.t2 = C2K(25); units.temp.t2 = 'K'; label.temp.t2 = 'temperature'; 
data.t3 = 2.13; units.t3 = 'd'; label.t3 = 'duration of instar 3'; bibkey.t3 = 'MontHunt2019';   
  temp.t3 = C2K(25); units.temp.t3 = 'K'; label.temp.t3 = 'temperature'; 
data.t4 = 2.48; units.t4 = 'd'; label.t4 = 'duration of instar 4'; bibkey.t4 = 'MontHunt2019';   
  temp.t4 = C2K(25); units.temp.t4 = 'K'; label.temp.t4 = 'temperature'; 
data.t5 = 2.57; units.t5 = 'd'; label.t5 = 'duration of instar 5'; bibkey.t5 = 'MontHunt2019';   
  temp.t5 = C2K(25); units.temp.t5 = 'K'; label.temp.t5 = 'temperature'; 
data.t6 = 2.13; units.t6 = 'd'; label.t6 = 'duration of instar 6'; bibkey.t6 = 'MontHunt2019';   
  temp.t6 = C2K(25); units.temp.t6 = 'K'; label.temp.t6 = 'temperature';
data.te = 11.57; units.te = 'd'; label.te = 'duration of pupa stage'; bibkey.te = 'SilvOliv2017';   
  temp.te = C2K(25); units.temp.te = 'K'; label.temp.te = 'temperature';
  comment.te ='duration prepupa stage (1.87 d) + duration of pupa stage (9.7 d)';

 data.L1 = 0.035; units.L1 = 'cm'; label.L1 = 'head capsule of instar 1 females'; bibkey.L1 = 'MontHunt2019';
 data.L2 = 0.057; units.L2 = 'cm'; label.L2 = 'head capsule of instar 2 females'; bibkey.L2 = 'MontHunt2019';
 data.L3 = 0.087; units.L3 = 'cm'; label.L3 = 'head capsule of instar 3 females'; bibkey.L3 = 'MontHunt2019';
 data.L4 = 0.129; units.L4 = 'cm'; label.L4 = 'head capsule of instar 4 females'; bibkey.L4 = 'MontHunt2019';
 data.L5 = 0.189; units.L5 = 'cm'; label.L5 = 'head capsule of instar 5 females'; bibkey.L5 = 'MontHunt2019';
 data.L6 = 0.28;  units.L6 = 'cm'; label.L6 = 'head capsule of instar 6 females'; bibkey.L6 = 'MontHunt2019';

 data.Wwj = 0.2889;   units.Wwj = 'g'; label.Wwj = 'wet weight of pupa';      bibkey.Wwj = 'SilvOliv2017';
  comment.Wwj ='weight measure for artificial diet';
  
 data.Ni = 1604.2; units.Ni = '#'; label.Ni = 'number of eggs'; bibkey.Ni = 'BarrOliv2010';   
   comment.Ni ='Maximum egg numer found for corn';
 
% uni-variate data
data.Tab = [ ... % temperature (C), age at birth (d)
18	6.3
22	4
26	3
30	2
32	2];
units.Tab  = {'C', 'd'}; label.Tab = {'temperature', 'age at birth'};  
bibkey.Tab = 'Schl2018';

data.Tab2 = [ ... % temperature (C), age at birth (d)
14	13.2
18	6
22	4.4
26	3
30	2];
units.Tab2  = {'C', 'd'}; label.Tab2 = {'temperature', 'age at birth'};  
bibkey.Tab2 = 'GarcMeag2018';

data.TtI1 = [ ... % temperature (C), duration instar 1 (d)
18	4.9
22	3.7
26	3
30	2.2
32	2.7];
units.TtI1  = {'C', 'd'}; label.TtI1 = {'temperature', 'duration instar 1'};  
bibkey.TtI1 = 'Schl2018';

data.Tt2I1 = [ ... % temperature (C), duration instar 1 (d)
15	13.20531283
20	4.597309417
25	3.616006833
28	3.00585095
30	2.821319667];
units.Tt2I1  = {'C', 'd'}; label.Tt2I1 = {'temperature', 'duration instar 1'};  
bibkey.Tt2I1 = 'LopeCarr2019';

data.TtI2 = [ ... % temperature (C), duration instar 2 (d)
18	4.9
22	3
26	2.1
30	1.9
32	1.3];
units.TtI2  = {'C', 'd'}; label.TtI2 = {'temperature', 'duration instar 2'};  
bibkey.TtI2 = 'Schl2018';

data.Tt2I2 = [ ... % temperature (C), duration instar 1 (d)
15	7.925312834
20	3.343976084
25	2.122690583
28	1.93921845
30	2.1280205];
units.Tt2I2  = {'C', 'd'}; label.Tt2I2 = {'temperature', 'duration instar 2'};  
bibkey.Tt2I2 = 'LopeCarr2019';

data.TtI3 = [ ... % temperature (C), duration instar 3 (d)
18	5
22	2.5
26	2
30	1.4
32	1.1];
units.TtI3  = {'C', 'd'}; label.TtI3 = {'temperature', 'duration instar 3'};  
bibkey.TtI3 = 'Schl2018';

data.Tt2I3 = [ ... % temperature (C), duration instar 1 (d)
15	8.645329917
20	3.423976084
25	2.362656417
28	2.01921845
30	1.968037583];
units.Tt2I3  = {'C', 'd'}; label.Tt2I3 = {'temperature', 'duration instar 3'};  
bibkey.Tt2I3 = 'LopeCarr2019';

data.TtI4 = [ ... % temperature (C), duration instar 4 (d)
18	5.2
22	2.8
26	2.2
30	1.7
32	1.5];
units.TtI4  = {'C', 'd'}; label.TtI4 = {'temperature', 'duration instar 4'};  
bibkey.TtI4 = 'Schl2018';

data.Tt2I4 = [ ... % temperature (C), duration instar 1 (d)
15	11.65869742
20	3.770745249
25	2.469340167
28	2.232568866
30	2.234687166];
units.Tt2I4  = {'C', 'd'}; label.Tt2I4 = {'temperature', 'duration instar 4'};  
bibkey.Tt2I4 = 'LopeCarr2019';

data.TtI5 = [ ... % temperature (C), duration instar 5 (d)
18	6.2
22	3.4
26	2.3
30	2.2
32	1.8];
units.TtI5  = {'C', 'd'}; label.TtI5 = {'temperature', 'duration instar 5'};  
bibkey.TtI5 = 'Schl2018';

data.Tt2I5 = [ ... % temperature (C), duration instar 1 (d)
15	11.09864617
20	4.837292334
25	2.949340167
28	2.472551783
30	2.554687166];
units.Tt2I5  = {'C', 'd'}; label.Tt2I5 = {'temperature', 'duration instar 5'};  
bibkey.Tt2I5 = 'LopeCarr2019';

data.TtI6 = [ ... % temperature (C), duration instar 6 (d)
18	8.6
22	5.1
26	3.4
30	2
32	2.1];
units.TtI6  = {'C', 'd'}; label.TtI6 = {'temperature', 'duration instar 6'};  
bibkey.TtI6 = 'Schl2018';

data.Tt2I6 = [ ... % temperature (C), duration instar 1 (d)
15	14.83199658
20	5.904027333
25	3.882656417
28	3.272500534
30	3.221319667];
units.Tt2I6  = {'C', 'd'}; label.Tt2I6 = {'temperature', 'duration instar 6'};  
bibkey.Tt2I6 = 'LopeCarr2019';

data.Tte = [ ... % temperature (C), duration pupa stage (d)
18	30.68
22	17.06
26	11.43
30	9
32	7.82];
units.Tte  = {'C', 'd'}; label.Tte = {'temperature', 'duration pupa stage'};  
bibkey.Tte = 'Schl2018';

data.Tte2 = [ ... % temperature (C), duration pupa stage (d)
20 25.61
25 12.31
27 9.07
30 8.17];
units.Tte2  = {'C', 'd'}; label.Tte2 = {'temperature', 'duration pupa stage'};  
bibkey.Tte2 = 'LopeCarr2019';

data.Ts = [ ... % temperature (C), Larval mortality (%)
18	71
22	37
26	15
30	4
32	28];
units.Ts  = {'C', '%'}; label.Ts = {'temperature', 'larval mortality'};  
bibkey.Ts = 'Schl2018';

%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.v = 3 * weights.psd.v;

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group plots
set1 = {'Tab', 'Tab2'}; subtitle1 = {'Data from Schl2018, GarcMeag2018'};
set2 = {'TtI1', 'Tt2I1'}; subtitle2 = {'Data from Schl2018, LopeCarr2019'};
set3 = {'TtI2', 'Tt2I2'}; subtitle3 = {'Data from Schl2018, LopeCarr2019'};
set4 = {'TtI3', 'Tt2I3'}; subtitle4 = {'Data from Schl2018, LopeCarr2019'};
set5 = {'TtI4', 'Tt2I4'}; subtitle5 = {'Data from Schl2018, LopeCarr2019'};
set6 = {'TtI5', 'Tt2I5'}; subtitle6 = {'Data from Schl2018, LopeCarr2019'};
set7 = {'TtI6', 'Tt2I6'}; subtitle7 = {'Data from Schl2018, LopeCarr2019'};
set8 = {'Tte', 'Tte2'};   subtitle8 = {'Data from Schl2018, LopeCarr2019'};
metaData.grp.sets = {set1, set2, set3, set4, set5, set6, set7, set8};
metaData.grp.subtitle = {subtitle1,subtitle2,subtitle3, subtitle4, subtitle5, subtitle6, subtitle7, subtitle8};

%% Discussion points
D1 = 'Arrhenium temp of 1st instar and for larval mortality differ from the rest';
metaData.discussion = struct('D1', D1);

%% Links
metaData.links.id_CoL = '4Z9P3'; % Cat of Life
metaData.links.id_ITIS = '117472'; % ITIS
metaData.links.id_EoL = '533408'; % Ency of Life
metaData.links.id_Wiki = 'Spodoptera_frugiperda'; % Wikipedia
metaData.links.id_ADW = 'Spodoptera_frugiperda'; % ADW
metaData.links.id_Taxo = '591465'; % Taxonomicon
metaData.links.id_WoRMS = '1488755'; % WoRMS
metaData.links.id_lepidoptera = '269238'; % lepidoptera

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Spodoptera_frugiperda}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{../../../bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'GarcMeag2018'; type = 'Article'; bib = [ ... 
'author = {Garcia, A.G. and Godoy, W.A.C. and Thomas, J.M.G. and  Nagoshi, R.N. and Meagher, R.L.}, ' ...
'year = {2018}, ' ...
'title = {Delimiting Strategic Zones for the Development of Fall Armyworm ({L}epidoptera: {N}octuidae) on Corn in the {S}tate of {F}lorida}, ' ...
'journal = {Journal of Economic Entomology}, ' ...
'volume = {111}, ' ...
'pages = {120-126}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'MontHunt2019'; type = 'Article'; bib = [ ... 
'author = {Montezano, D.G and Specht, A. and Sosa-G\''{o}mez, D.R. and Roque-Specht,F.F. and de Paula-Moraes, S.V. and Peterson, J.A. and Hunt, T.E.}, ' ...
'year = {2019}, ' ...
'title = {Developmental Parameters of \emph{Spodoptera frugiperda} ({L}epidoptera: {N}octuidae) Immature Stages Under Controlled and Standardized Conditions}, ' ...
'journal = {Journal of Agricultural Science}, ' ...
'volume = {11}, ' ...
'pages = {-}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'SilvOliv2017'; type = 'Article'; bib = [ ... 
'author = {Silva, D. M. and Bueno, A.D. and Andrade, K. and Stecca, C.D. and Neves, P.M., Oliveira, M.C.}, ' ...
'year = {2017}, ' ...
'title = {Biology and nutrition of \emph{Spodoptera frugiperda} ({L}epidoptera: {N}octuidae) fed on different food sources}, ' ...
'journal = {Scientia Agricola}, ' ...
'volume = {74}, ' ...
'pages = {18-31}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'BarrOliv2010'; type = 'Article'; bib = [ ... 
'author = {Barros, E.M. and Torres, J.B. and Ruberson, J.R. and Oliveira, M.D.}, ' ...
'year = {2010}, ' ...
'title = {Development of \emph{Spodoptera frugiperda} on different hosts and damage to reproductive structures in cotton}, ' ...
'journal = {Entomologia Experimentalis et Applicata}, ' ...
'volume = {137}, ' ...
'pages = {237-245}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Schl2018'; type = 'Thesis'; bib = [ ... 
'author = {Schlemmer M.}, ' ...
'year = {2018}, ' ...
'title = {Effect of temperature on development and reproduction of \emph{Spodoptera frugiperda} ({L}epidoptera: {N}octuidae)}, ' ...
'publisher = {North-West University}, ' ...
'pages = {93}, ' ...
'howpublished = {\url{https://www.semanticscholar.org/paper/Effect-of-temperature-on-development-and-of-Schlemmer/acdfd8619c3de850d5a4efd9ace900339d1dfcb7}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'LopeCarr2019'; type = 'Article'; bib = [ ... 
'author = {L\''{o}pez, R.Y. and Ortega, A.V. and Centeno, J.H.A. and Ru\''{i}z, J.S. and Carranza, J.A.Q.}, ' ...
'year = {2010}, ' ...
'title = {Sistema de alerta contra el gusano cogollero \emph{Spodoptera frugiperda} ({J}. {E}. {S}mith) ({I}nsecta: {L}epidoptera: {N}octuidae)}, ' ...
'journal = {Revista Mexicana de Ciencias Agr\''{i}colas}, ' ...
'volume = {10}, ' ...
'pages = {405-416}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
