function [data, auxData, metaData, txtData, weights] = mydata_Arctogadus_glacialis

%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Actinopterygii'; 
metaData.order      = 'Gadiformes'; 
metaData.family     = 'Gadidae';
metaData.species    = 'Arctogadus_glacialis'; 
metaData.species_en = 'Arctic cod'; 

metaData.ecoCode.climate = {'ME'};
metaData.ecoCode.ecozone = {'MN'};
metaData.ecoCode.habitat = {'0jMp', 'jiMd'};
metaData.ecoCode.embryo  = {'Mp'};
metaData.ecoCode.migrate = {'Mo'};
metaData.ecoCode.food    = {'bjPz', 'jiCi', 'jiCvf'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(4); % K, temp of typical arctic water
metaData.data_0     = {'ab'; 'am'; 'Lp'; 'Li'; 'Wwb';'Wwp'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-L'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman'};        
metaData.date_subm = [2023 11 23];                           
metaData.email    = {'bas.kooijman@vu.nl'};                 
metaData.address  = {'VU University, Amsterdam'}; 

metaData.curator     = {'Dina Lika'};
metaData.email_cur   = {'lika@uoc.gr'}; 
metaData.date_acc    = [2023 11 23];

%% set data
% zero-variate data
data.ab = 47;    units.ab = 'd';    label.ab = 'age at birth';             bibkey.ab = 'guess';   
  temp.ab = C2K(4);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
data.am = 7*365;    units.am = 'd';    label.am = 'life span';                bibkey.am = 'guess';   
  temp.am = C2K(4);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lp  = 15;   units.Lp  = 'cm';  label.Lp  = 'total length at puberty'; bibkey.Lp  = 'guess';
data.Li  = 32.5;   units.Li  = 'cm';  label.Li  = 'ultimate total length';   bibkey.Li  = 'fishbase';

data.Wwb = 2.4e-3;   units.Wwb = 'g';   label.Wwb = 'weight at birth';   bibkey.Wwb = 'guess';
  comment.Wwb = 'besed on egg diameter of 1.67 mm of Boreogadus saida: pi/6*0.167^3';
data.Wwp = 35;   units.Wwp = 'g';   label.Wwp = 'wet weight at puberty';   bibkey.Wwp = 'guess';
  comment.Wwp = 'based on 0.00794*Lp^3.10, see F1';
data.Wwi = 157;   units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';     bibkey.Wwi = 'fishbase';
  comment.Wwi = 'based on 0.00794*Li^3.10, see F1';

data.Ri  = 4e3/365;   units.Ri  = '#/d'; label.Ri  = 'max reprod rate';     bibkey.Ri  = 'guess';   
  temp.Ri = C2K(4);    units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = 'based on Boreogadus saida';

% uni-variate data

% time-length
data.tL = [ ...
3.670	0.836
7.079	0.711
9.963	0.961
10.225	0.987
12.322	0.934
12.323	0.882
14.419	1.329
15.468	1.461
17.828	0.993
18.614	0.868
19.401	1.086
20.974	1.033
21.236	1.204
24.120	1.151
24.906	0.961
25.169	1.217
26.742	1.138
28.052	1.013
29.625	1.164
29.888	1.184
29.889	1.125
31.198	1.289
31.199	1.237
35.131	1.316
36.442	1.368
37.753	1.270
38.801	1.283
40.112	1.375
40.637	1.408
42.472	1.309
42.734	1.138
43.783	1.382
43.784	1.421
44.569	1.612
44.831	1.197
44.832	1.329
45.094	1.105
45.880	1.289
48.240	1.191
49.026	1.342
50.337	1.382
52.697	1.467
53.483	1.586
54.794	1.763
56.105	1.704
56.629	1.250
61.086	1.303
62.659	1.421
64.757	1.868
67.903	1.651
67.904	1.914
69.476	1.803
73.146	1.803
73.147	1.993
74.981	1.711
74.982	1.618
75.768	1.875
77.079	2.086
78.390	2.145
78.652	1.868
79.700	2.217
81.011	2.072
81.536	2.178
85.206	2.013
85.468	2.243
85.730	2.283
86.255	2.197
88.614	2.355
90.448	1.829
90.449	2.355
91.760	2.362
93.071	2.303
94.120	2.553
94.121	2.217
94.644	2.053
95.431	2.237
97.004	2.467
98.315	2.086
99.101	2.579
101.985	2.546
102.772	2.204
103.034	2.230
103.558	2.474
104.082	2.546
104.083	2.013
106.704	2.342
107.228	2.592
108.015	2.908
108.016	2.500
108.801	2.579
110.637	2.658
112.210	2.178
114.831	2.697
117.978	2.572
119.288	3.086
122.959	2.717
128.727	3.066
131.873	3.118];
units.tL = {'d', 'cm'};label.tL = {'time since birth', 'total length'};  
temp.tL = C2K(4); units.temp.tL = 'K'; label.temp.tL = 'temperature';
bibkey.tL = 'Bouc2014';

%% set weights for all real data
weights = setweights(data, []);
weights.tL = 3 * weights.tL;
weights.Wwp = 0 * weights.Wwp;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
%weights.psd.k_J = 0; weights.psd.k = 0.1;
%data.psd.k = 0.3; units.psd.k  = '-'; label.psd.k  = 'maintenance ratio'; 

%% pack auxData and txtData for output
auxData.temp      = temp;
txtData.units     = units;
txtData.label     = label;
txtData.bibkey    = bibkey;
txtData.comment   = comment;

% %% Group plots
% set1 = {''}; subtitle1 = {''};
% metaData.grp.sets = {set1};
% metaData.grp.subtitle = {subtitle1};

%% Discussion points
D1 = 'males are assumed not to differ from females';
D2 = 'Wwp is ignorned due to inconsistency with Lp and (Li,Wwi) data';
metaData.discussion = struct('D1',D1, 'D2',D2);

%% Facts
F1 = 'length-weight: weight in g = 0.00794*(TL in cm)^3.10';
metaData.bibkey.F1 = 'fishbase'; 
metaData.facts = struct('F1',F1);

%% Links
metaData.links.id_CoL = 'GB2Z'; % Cat of Life
metaData.links.id_ITIS = '164704'; % ITIS
metaData.links.id_EoL = '46564404'; % Ency of Life
metaData.links.id_Wiki = 'Arctogadus_glacialis'; % Wikipedia
metaData.links.id_ADW = 'Arctogadus_glacialis'; % ADW
metaData.links.id_Taxo = '44295'; % Taxonomicon
metaData.links.id_WoRMS = '126432'; % WoRMS
metaData.links.id_fishbase = 'Arctogadus-glacialis'; % fishbase

%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{https://en.wikipedia.org/wiki/Arctogadus_glacialis}}';
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
bibkey = 'Bouc2014'; type = 'PhDthesis'; bib = [ ... 
'author = {Caroline Bouchard}, ' ... 
'year = {2014}, ' ...
'title = {\emph{Boreogadus saida} et \emph{Arctogadus glacialis} Vie larvaire et juv\''{e}nile de deux gadid\''{e}s se partageant l''oc\''{e}an {A}rctique }, ' ...
'school = {Laval Univ.}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'fishbase'; type = 'Misc'; bib = ...
'howpublished = {\url{https://www.fishbase.se/summary/Arctogadus-glacialis.html}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
