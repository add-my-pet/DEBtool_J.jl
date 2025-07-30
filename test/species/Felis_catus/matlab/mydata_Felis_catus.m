function [data, auxData, metaData, txtData, weights] = mydata_Felis_catus

%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Mammalia'; 
metaData.order      = 'Carnivora'; 
metaData.family     = 'Felidae';
metaData.species    = 'Felis_catus'; 
metaData.species_en = 'Domestic cat'; 

metaData.ecoCode.climate = {'B'};
metaData.ecoCode.ecozone = {'TPa'};
metaData.ecoCode.habitat = {'0iTi', '0iTg', '0iTa'};
metaData.ecoCode.embryo  = {'Tv'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bxM', 'xiC'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(38.1); % K, body temp
metaData.data_0     = {'tg'; 'ax'; 'ap'; 'am'; 'Wwb'; 'Wwi'; 'Ri';'JXi'}; 
metaData.data_1     = {'t-Ww'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author      = {'Bas Kooijman'};    
metaData.date_subm   = [2021 12 02];              
metaData.email       = {'bas.kooijman@vu.nl'};            
metaData.address     = {'VU University Amsterdam'};   

metaData.author_mod_1   = {'Bas Kooijman'};    
metaData.date_mod_1     = [2023 04 12];              
metaData.email_mod_1    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_1  = {'VU University, Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight@tecnico.ulisboa.pt'}; 
metaData.date_acc    = [2023 04 12];

%% set data
% zero-variate data

data.tg = 65;     units.tg = 'd';    label.tg = 'gestation time';             bibkey.tg = 'AnAge';   
  temp.tg = C2K(38.1);  units.temp.tg = 'K'; label.temp.tg = 'temperature';
data.tx = 56;     units.tx = 'd';    label.tx = 'time since birth at weaning'; bibkey.tx = 'AnAge';   
  temp.tx = C2K(38.1);  units.temp.tx = 'K'; label.temp.tx = 'temperature';
  comment.tx = '30 till 35 d';
data.tp = 289;    units.tp = 'd';    label.tp = 'time since birth at puberty for female'; bibkey.tp = 'AnAge';
  temp.tp = C2K(38.1);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.tpm = 304;    units.tpm = 'd';    label.tpm = 'time since birth at puberty for male'; bibkey.tpm = 'AnAge';
  temp.tpm = C2K(38.1);  units.temp.tpm = 'K'; label.temp.tpm = 'temperature';
data.am = 30*365;  units.am = 'd';    label.am = 'life span';                bibkey.am = 'AnAge';   
  temp.am = C2K(38.1);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Wwb = 97.5;   units.Wwb = 'g';   label.Wwb = 'wet weight at birth';     bibkey.Wwb = 'AnAge';
data.Wwi = 3900;  units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';     bibkey.Wwi = 'Wiki';  

data.Ri  = 4/365;   units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';    bibkey.Ri  = 'AnAge';   
  temp.Ri = C2K(38.1);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = '4 per litter, 1 litters per yr';

% uni-variate data
% time-weight
data.tW_f = [ ... % time (d), body weight (g)
 0.000	106.277
14.092	309.864
14.109	253.899
17.055	286.372
17.357	262.816
19.130	265.805
19.400	351.231
20.577	368.933
21.493	268.808
21.796	245.252
22.940	374.882
22.947	351.318
22.957	318.918
23.249	330.707
23.847	307.158
24.719	357.253
25.288	430.904
25.321	318.976
25.930	257.135
26.794	333.739
28.576	307.274
31.470	513.530
31.477	489.966
38.293	431.223
40.602	616.847
41.767	675.786
41.780	631.604
41.786	613.931
45.034	622.847
47.698	611.130
48.592	584.643
48.640	422.641
48.833	770.216
48.899	546.359
52.130	614.185
56.862	605.464
70.646	968.100
71.265	873.859
78.358	876.979
78.819	1315.871
80.960	1074.392
81.201	1259.964
81.578	983.096
86.883	1033.300
90.139	1018.652
111.287	1466.889
115.678	1611.326
120.416	1581.987];
units.tW_f = {'d', 'g'};  label.tW_f = {'time', 'wet weight', 'female'};  
temp.tW_f  = C2K(38.1);  units.temp.tW_f = 'K'; label.temp.tW_f = 'temperature';
bibkey.tW_f = 'FestBleb1970';
comment.tW_f = 'data for females';
%
data.tW_m = [ ... % time (d), body weight (g)
9.617	383.603
13.485	263.122
15.829	313.368
15.837	286.859
16.729	260.415
17.311	286.967
18.200	272.305
19.666	298.923
22.014	334.442
24.072	355.212
24.083	316.921
25.540	375.939
26.739	311.226
27.005	408.447
31.976	547.252
36.969	612.421
41.360	721.728
41.687	612.768
43.750	612.920
45.211	660.156
46.067	757.421
46.961	725.086
47.570	657.384
48.463	627.995
48.504	489.559
54.040	713.825
55.800	746.355
56.400	711.054
70.816	815.208
72.061	1592.914
81.463	1705.535
82.204	1190.126
82.791	1201.951
89.785	1479.344
95.475	1182.267
101.016	1388.860
107.623	1978.448];
units.tW_m = {'d', 'g'};  label.tW_m = {'time', 'wet weight', 'male'};  
temp.tW_m  = C2K(38.1);  units.temp.tW_m = 'K'; label.temp.tW_m = 'temperature';
bibkey.tW_m = 'FestBleb1970';
comment.tW_m = 'data for males';

%% set weights for all real data
weights = setweights(data, []);
weights.tW_f = 5 * weights.tW_f;
weights.tW_m = 5 * weights.tW_m;
weights.tp = 5 * weights.tp;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group plots
set1 = {'tW_f','tW_m'}; subtitle1 = {'Data for females, males'};
metaData.grp.sets = {set1};
metaData.grp.subtitle = {subtitle1};

%% Discussion points
D1 = 'Males are assumed to differ from females by {p_Am} only';
D2 = 'mod_1: males have equal state variables at b, compared to females';
metaData.discussion = struct('D1',D1, 'D2',D2);  

%% Links
metaData.links.id_CoL = '3DXV3'; % Cat of Life
metaData.links.id_ITIS = '183798'; % ITIS
metaData.links.id_EoL = '1037781'; % Ency of Life
metaData.links.id_Wiki = 'Felis_catus'; % Wikipedia
metaData.links.id_ADW = 'Felis_catus'; % ADW
metaData.links.id_Taxo = '168129'; % Taxonomicon
metaData.links.id_WoRMS = '1461480'; % WoRMS
metaData.links.id_MSW3 = '14000031'; % MSW3
metaData.links.id_AnAge = 'Felis_catus'; % AnAge


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Felis_catus}}';
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
bibkey = 'FestBleb1970'; type = 'Article'; bib = [ ... 
'author = {Festing, M. F. W. and Bleby, J.}, ' ... 
'doi = {10.1111/j.1748-5827.1970.t}, ' ...
'year = {1970}, ' ...
'title = {Breeding performance and growth of {SPF} cats (\emph{Felis catus})}, ' ...
'journal = {Journal of Small Animal Practice}, ' ...
'volume = {11(8)}, ' ...
'pages = {533–542}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Felis_catus}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'ADW'; type = 'Misc'; bib = ...
'howpublished = {\url{https://animaldiversity.org/accounts/Felis_catus/}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

