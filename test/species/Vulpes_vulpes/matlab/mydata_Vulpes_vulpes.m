function [data, auxData, metaData, txtData, weights] = mydata_Vulpes_vulpes

%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Mammalia'; 
metaData.order      = 'Carnivora'; 
metaData.family     = 'Canidae';
metaData.species    = 'Vulpes_vulpes'; 
metaData.species_en = 'Red fox'; 

metaData.ecoCode.climate = {'B', 'C', 'D'};
metaData.ecoCode.ecozone = {'TH', 'TPi'};
metaData.ecoCode.habitat = {'0iTh', '0iTf', '0iTi', '0iTs'};
metaData.ecoCode.embryo  = {'Tv'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bxM', 'xiO'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(38.7); % K, body temp
metaData.data_0     = {'tg'; 'ax'; 'ap'; 'am'; 'Lb'; 'Li'; 'Wwb'; 'Wwx'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-L'; 't-Ww'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman'};    
metaData.date_subm = [2012 12 18];              
metaData.email    = {'bas.kooijman@vu.nl'};            
metaData.address  = {'VU University Amsterdam'};   

metaData.author_mod_1   = {'Bas Kooijman'};    
metaData.date_mod_1     = [2016 11 14];              
metaData.email_mod_1    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_1  = {'VU University Amsterdam'};   

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight.augustine@akvaplan.niva.no'}; 
metaData.date_acc    = [2016 11 14]; 

%% set data
% zero-variate data

data.tg = 52;    units.tg = 'd';    label.tg = 'gestation time';             bibkey.tg = 'AnAge';   
  temp.tg = C2K(38.7);  units.temp.tg = 'K'; label.temp.tg = 'temperature';
data.tx = 48;    units.tx = 'd';    label.tx = 'time since birth at weaning'; bibkey.tx = 'AnAge';   
  temp.tx = C2K(38.7);  units.temp.tx = 'K'; label.temp.tx = 'temperature';
data.tp = 304;    units.tp = 'd';    label.tp = 'time since birth at puberty';   bibkey.tp = 'AnAge';
  temp.tp = C2K(38.7);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.am = 21.3*365;    units.am = 'd';    label.am = 'life span';                bibkey.am = 'AnAge';   
  temp.am = C2K(38.7);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb  = 14.5;   units.Lb  = 'cm';  label.Lb  = 'head-body length at birth';   bibkey.Lb  = 'Wiki';
  comment.Lb = 'tail 7.5 cm';
data.Li  = 90;   units.Li  = 'cm';  label.Li  = 'ultimate head-body length';   bibkey.Li  = 'Wiki';
  comment.Li = 'tail 53 cm';

data.Wwb = 100;   units.Wwb = 'g';   label.Wwb = 'wet weight at birth';     bibkey.Wwb = 'AnAge';
data.Wwx = 1397;   units.Wwx = 'g';   label.Wwx = 'wet weight at weaning';   bibkey.Wwx = 'AnAge';
data.Wwi = 7500;   units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';     bibkey.Wwi = 'AnAge';

data.Ri  = 5/365;   units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';     bibkey.Ri  = 'AnAge';   
  temp.Ri = C2K(38.7);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = 'Wiki: one clutch per yr in spring';
  
% uni-variate data
% t-L data
data.tL = [ ... % head body length (cm), time (d)
3.891	26.621
7.440	21.319
7.776	25.808
8.539	18.966
9.569	26.868
9.889	18.370
10.320	25.886
11.001	35.158
11.771	28.511
16.462	28.473
20.679	19.553
20.792	16.915
20.899	32.832
23.627	38.768
24.775	25.477
24.793	32.313
25.636	34.259
26.821	22.140
28.590	34.919
28.764	27.984
32.481	34.302
34.851	35.064
36.552	39.445
36.909	32.118
38.766	35.228
40.663	33.358
41.753	30.712
47.669	44.825
48.573	36.224
51.719	49.285
54.486	43.989
54.654	43.109
55.991	42.122
58.954	49.325
60.615	52.436
60.698	55.072
61.754	51.353
61.806	53.013
64.579	54.162
65.508	52.592
65.676	51.712
66.558	54.928
68.559	50.127
72.596	54.196
73.781	48.327
75.681	52.804
75.999	62.958
81.710	58.029
81.710	45.529
82.822	56.067
82.855	57.141
83.103	58.799
84.260	58.302
85.613	57.803
86.505	55.061
88.591	59.244
89.962	59.330
90.616	55.223
91.724	53.164
91.899	52.479
96.669	61.230
101.748	61.091
103.764	63.028
103.773	50.821
105.899	62.523
121.957	63.371];
units.tL   = {'d', 'cm'};  label.tL = {'time since birth', 'head-body length'};  
temp.tL    = C2K(38.7);  units.temp.tL = 'K'; label.temp.tL = 'temperature';
bibkey.tL = 'KolbHews1980';
% t-W data
data.tW = [ ... % time (d), body weight (g)
4.219	454.495
8.142	548.330
8.471	324.307
9.224	226.370
10.091	546.621
10.177	147.713
10.465	487.928
11.269	1294.615
12.229	525.291
17.158	734.975
18.827	422.228
20.727	245.464
20.806	1247.340
20.896	148.039
20.906	186.940
23.974	1429.387
25.070	445.935
25.429	1048.733
26.072	1262.177
26.986	327.522
28.800	1259.785
28.849	724.721
32.814	974.162
34.717	1517.241
36.925	1038.650
37.031	1427.662
38.937	1270.348
41.011	1015.611
41.946	868.877
47.799	2322.887
48.735	1466.035
51.799	2698.755
54.945	2083.157
54.991	1538.369
56.526	1449.474
59.057	2157.371
60.762	2690.894
60.795	3527.441
61.832	3040.151
61.960	2796.847
64.639	3329.518
65.684	2871.403
65.705	2949.206
66.812	3434.616
68.537	2615.982
73.100	3623.654
73.737	2387.686
75.695	4564.957
75.863	3037.572
81.152	3850.054
81.849	2117.925
81.943	3178.154
82.838	4315.501
82.854	2943.892
83.795	3536.452
85.607	3748.871
86.887	2726.347
88.505	3658.780
89.559	3949.684
90.627	3579.098
91.653	3052.906
91.758	2722.075
92.416	5133.949
96.189	3963.324
101.775	4435.079
103.124	3665.414
103.635	2682.475
105.970	4810.777
106.411	4285.098
106.658	3759.590
107.813	3709.938
109.311	3484.890
112.844	4289.184
121.572	4135.614];
units.tW   = {'d', 'g'};  label.tW = {'time since birth', 'wet weight'};  
temp.tW    = C2K(38.7);  units.temp.tW = 'K'; label.temp.tW = 'temperature';
bibkey.tW = 'KolbHews1980';
comment.tW = 'NE-Scotland';
  
%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
data.psd.t_0 = 0;  units.psd.t_0 = 'd'; label.psd.t_0 = 'time at start development';
weights.psd.t_0 = 3;

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Links
metaData.links.id_CoL = '5BSG3'; % Cat of Life
metaData.links.id_ITIS = '180604'; % ITIS
metaData.links.id_EoL = '328609'; % Ency of Life
metaData.links.id_Wiki = 'Vulpes_vulpes'; % Wikipedia
metaData.links.id_ADW = 'Vulpes_vulpes'; % ADW
metaData.links.id_Taxo = '66456'; % Taxonomicon
metaData.links.id_WoRMS = '1457401'; % WoRMS
metaData.links.id_MSW3 = '14000892'; % MSW3
metaData.links.id_AnAge = 'Vulpes_vulpes'; % AnAge


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Vulpes_vulpes}}';
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
bibkey = 'KolbHews1980'; type = 'Article'; bib = [ ... 
'author = {Kolb, H. H. and Hewson, R.}, ' ... 
'year = {1980}, ' ...
'title = {The diet and growth of fox-cubs in two regions of {S}cotland}, ' ...
'journal = {Acta Theriologica}, ' ...
'volume = {25}, ' ...
'pages = {325--331}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Vulpes_vulpes}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

