function [data, auxData, metaData, txtData, weights] = mydata_Chortoicetes_terminifera

%% set metaData
metaData.phylum     = 'Arthropoda'; 
metaData.class      = 'Insecta'; 
metaData.order      = 'Orthoptera'; 
metaData.family     = 'Acrididae';
metaData.species    = 'Chortoicetes_terminifera'; 
metaData.species_en = 'Australian plague locust'; 

metaData.ecoCode.climate = {'BSh'};
metaData.ecoCode.ecozone = {'TA'};
metaData.ecoCode.habitat = {'0iTg', '0iTs', '0iTa', '0iTd'};
metaData.ecoCode.embryo  = {'Th'};
metaData.ecoCode.migrate = {'Ms'};
metaData.ecoCode.food    = {'biH'};
metaData.ecoCode.gender  = {'D'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(32); % K, body temp
metaData.data_0     = {'ab'; 'ap'; 'am'; 'Lb'; 'Lp'; 'Wdb'; 'Wdp'; 'Ri'}; 
metaData.data_1     = {'t-Wd_T'; 'T-ab'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Michael Kearney'};    
metaData.date_subm = [2019 07 01];              
metaData.email    = {'m.kearney@unimelb.edu.au'};            
metaData.address  = {'The University of Melbourne'};   

metaData.curator     = {'Bas Kooijman'};
metaData.email_cur   = {'bas.kooijman@vu.nl'}; 
metaData.date_acc    = [2019 07 01]; 

%% set data
% zero-variate data

data.ab = 17.4; units.ab = 'd'; label.ab = 'age at birth'; bibkey.ab = {'Greg1981','Greg1983'};   
  temp.ab = C2K(28.5);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
data.tp = 34.35; units.tp = 'd'; label.tp = 'time since birth at puberty'; bibkey.tp = 'Greg1983';
  temp.tp = C2K(28.5); units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.am = 60 + data.tp; units.am = 'd'; label.am = 'life span'; bibkey.am = 'Simp2018';   
  temp.am = C2K(35.1); units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb  = 0.5; units.Lb  = 'cm'; label.Lb = 'length at birth'; bibkey.Lb  = 'Rent2003';
  comment.Lb = 'Actually length of 1st instar';
data.Lp  = 3.2; units.Lp  = 'cm'; label.Lp = 'ultimate total length'; bibkey.Lp  = 'Rent2003';
  comment.Lp = 'Actually length of 6th instar';

data.Wdb = 9e-4; units.Wdb = 'g'; label.Wdb = 'dry weight at birth'; bibkey.Wdb = 'Farr1982';
  comment.Wdp = 'mean in Farrow Table 5, note that he gets a mean value of around 0.18 for fraction dry, and an egg dry weight of ~1.2 mg (1.1-1.31)';
data.Wd2 = 2.88e-3; units.Wd2 = 'g'; label.Wd2 = 'dry weight at beginning of instar 2'; bibkey.Wd2 = 'Clis2004';
  comment.Wd2 = 'Table 4.3 button grass diet';
data.Wd3 = 5.56e-3; units.Wd3 = 'g'; label.Wd3 = 'dry weight at beginning of instar 3'; bibkey.Wd3 = 'Clis2004';
  comment.Wd3 = 'Table 4.3 button grass diet';
data.Wd4 = 11.71e-3; units.Wd4 = 'g'; label.Wd4 = 'dry weight at beginning of instar 4'; bibkey.Wd4 = 'Clis2004';
  comment.Wd4 = 'Table 4.3 button grass diet';
data.Wd5 = 25.53e-3*1.5; units.Wd5 = 'g'; label.Wd5 = 'dry weight at beginning of instar 5'; bibkey.Wd5 = 'Clis2004';
  comment.Wd5 = 'Table 4.3 button grass diet';
data.Wdp = 0.1095; units.Wdp = 'g';   label.Wdp = 'dry weight at puberty'; bibkey.Wdp = 'Greg1983';
  comment.Wdp = 'fledgling weight from humidity study';

data.Ri  = 72*3/60;   units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';   bibkey.Ri  = 'Clar1965';   
  temp.Ri = C2K(35.1);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  comment.Ri = 'Clark 1965 reports 72 ovarioles, Steve Simpson pers. comm. says 3 clutches over adult life of 60 days, Ted Deveson pers. comm. reports ~8 clutches of 30 eggs every three days over 45 days';
  
% uni-variate data
%Wd_instar = [data.Wdb,

data.Tab = [... % temperature (C), age at birth (d)
%16.2	119.1
%20.6	50.3
%22.6	36.7
25.9	23.7
26.8	20.9
28.5	17.4
32      13.3];
%36      10.7];
%39      12.3];
units.Tab   = {'C', 'd'};  label.Tab = {'temperature', 'age at birth'};  
bibkey.Tab = 'Greg1983';

% tW-data 
data.tW_26 = [... % time since birth (d), dry weight (g)
0       data.Wdb
8.85	data.Wd2
16.45	data.Wd3
27.2	data.Wd4
40.65	data.Wd5
57.05	data.Wdp];
units.tW_26   = {'d', 'g'};  label.tW_26 = {'time since birth', 'dry weight', '25.9 C'};  
temp.tW_26    = C2K(25.9);  units.temp.tW_26 = 'K'; label.temp.tW_26 = 'temperature';
bibkey.tW_26 = {'Greg1981','Clis2004'};
comment.tW_26 = 'using Gregg 1981 PhD thesis data which splits females from males at 5th instar';

data.tW_27 = [... % time since birth (d), dry weight (g)
0       data.Wdb
6.25	data.Wd2
14.4	data.Wd3
21.75	data.Wd4
31.9	data.Wd5
43.3	data.Wdp];
units.tW_27   = {'d', 'g'};  label.tW_27 = {'time since birth', 'dry weight', '26.8 C'};  
temp.tW_27    = C2K(26.8);  units.temp.tW_27 = 'K'; label.temp.tW_27 = 'temperature';
bibkey.tW_27 = {'Greg1981','Clis2004'};
comment.tW_27 = 'using Gregg 1981 PhD thesis data which splits females from males at 5th instar';

data.tW_29 = [... % time since birth (d), dry weight (g)
0       data.Wdb
5.7     data.Wd2
11.7	data.Wd3
17.6	data.Wd4
25.5	data.Wd5
34.3	data.Wdp];
units.tW_29   = {'d', 'g'};  label.tW_29 = {'time since birth', 'dry weight', '28.5 C'};  
temp.tW_29    = C2K(28.5);  units.temp.tW_29 = 'K'; label.temp.tW_29 = 'temperature';
bibkey.tW_29 = {'Greg1981','Clis2004'};
comment.tW_29 = 'using Gregg 1981 PhD thesis data which splits females from males at 5th instar';

% data.tW_32 = [... % time since birth (d), dry weight (g)
% 4.1 	data.Wd2
% 8.5 	data.Wd3
% 13.15   data.Wd4
% 17.6	data.Wd5
% 22.9	data.Wd6];
% units.tW_32   = {'d', 'g'};  label.tW_32 = {'time since birth', 'dry weight', '32 C'};  
% temp.tW_32    = C2K(32);  units.temp.tW_32 = 'K'; label.temp.tW_32 = 'temperature';
% bibkey.tW_32 = {'Greg1981','Cliss2004'};
% comment.tW_32 = 'using Gregg 1981 PhD thesis data which splits females from males at 5th instar';

% data.tW_36 = [... % time since birth (d), dry weight (g)
% 3.65 	data.Wd2
% 7.45 	data.Wd3
% 11.95   data.Wd4
% 16.15	data.Wd5
% 20.7	data.Wd6];
% units.tW_36   = {'d', 'g'};  label.tW_36 = {'time since birth', 'dry weight', '36 C'};  
% temp.tW_36    = C2K(36);  units.temp.tW_36 = 'K'; label.temp.tW_36 = 'temperature';
% bibkey.tW_36 = {'Greg1981','Cliss2004'};
% comment.tW_36 = 'using Gregg 1981 PhD thesis data which splits females from males at 5th instar';

% data.tW_39 = [... % time since birth (d), dry weight (g)
% 2.95 	data.Wd2
% 6.95 	data.Wd3
% 10      data.Wd4
% 14.9	data.Wd5
% 18.3	data.Wd6];
% units.tW_39   = {'d', 'g'};  label.tW_39 = {'time since birth', 'dry weight', '39 C'};  
% temp.tW_39    = C2K(39);  units.temp.tW_39 = 'K'; label.temp.tW_39 = 'temperature';
% bibkey.tW_39 = {'Greg1981','Cliss2004'};
% comment.tW_39 = 'using Gregg 1981 PhD thesis data which splits females from males at 5th instar';
  
%% set weights for all real data
weights = setweights(data, []);
weights.Lb = 0 * weights.Lb;
weights.tW_26 = 3 * weights.tW_26;
weights.tW_27 = 3 * weights.tW_27;
weights.tW_29 = 3 * weights.tW_29;
weights.Tab = 7 * weights.Tab;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.v = 5 * weights.psd.v;

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Group plots
set1 = {'tW_29','tW_27','tW_26'}; subtitle1 = {'Data at 28.5, 26.8, 25.9 C'};
metaData.grp.sets = {set1};
metaData.grp.subtitle = {subtitle1};

%% Discussion points
D1 = 'Excluding observations at constant high temperature because this is probably stressfully unnatural';
D2 = 'We here assume that only the final instar allocates to reproduction';
D3 = 'Arrhenius parameters were derived from Gregg 1981 data on development under constant and fluctuating temperatures, to be described in detail in a MS in prep. by M. R. Kearney';
D4 = 'Length-weight relation is inconsistent for Wwb with other data; this data point is ignorned';
metaData.discussion = struct('D1', D1, 'D2', D2, 'D3', D3);

%% Links
metaData.links.id_CoL = '5YG4K'; % Cat of Life
metaData.links.id_ITIS = ''; % ITIS
metaData.links.id_EoL = '494057'; % Ency of Life
metaData.links.id_Wiki = 'Chortoicetes_terminifera'; % Wikipedia
metaData.links.id_ADW = 'Chortoicetes_terminifera'; % ADW
metaData.links.id_Taxo = '769000'; % Taxonomicon
metaData.links.id_WoRMS = ''; % WoRMS
metaData.links.id_orthoptera = '64604'; % orthoptera

%% References
bibkey = 'Kooy2010'; type = 'Book'; bib = [ ...  % used in setting of chemical parameters and pseudodata
'author = {Kooijman, S.A.L.M.}, ' ...
'year = {2010}, ' ...
'title  = {Dynamic Energy Budget theory for metabolic organisation}, ' ...
'publisher = {Cambridge Univ. Press, Cambridge}, ' ...
'pages = {Table 4.2 (page 150), 8.1 (page 300)}, ' ...
'howpublished = {\url{../../../bib/Kooy2010.html}}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Greg1981'; type = 'PhDthesis'; bib = [ ... 
'author = {Gregg, Peter C.}, ' ... 
'year = {1981}, ' ...
'title = {Aspects of the adaptation of a locust to its physical environment}, ' ...
'school = {Australian National University, Canberra}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Greg1983'; type = 'Article'; bib = [ ... 
'author = {Gregg, P.}, ' ... 
'year = {1983}, ' ...
'title = {Development of the {A}ustralian plague locust \emph{Chortoicetes terminifera} in relation to weather {I}. {E}ffects of constant temperature and humidity}, ' ...
'journal = {Australian Journal of Entomology}, ' ...
'volume = {22}, ' ...
'number = {3}, '...
'pages = {247--251}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Clis2004'; type = 'PhDthesis'; bib = [ ... 
'author = {Clissold, Fiona J.}, ' ... 
'year = {2004}, ' ...
'title = {Nutritional ecology of the {A}ustralian plague locust, \emph{Chortoicetes terminifera}}, ' ...
'school = {Monash University, Clayton}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Rent2003'; type = 'Book'; bib = [ ... 
'title = {A Guide to Australian Grasshoppers and Locusts}, ' ... 
'author = {Rentz, D. C. F. and Lewis, R. C. and Su, You Ning and Upton, Murray S.}, ' ... 
'year = {2003}, ' ...
'publisher = {Natural History Publications, Borneo}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Farr1982'; type = 'Article'; bib = [ ... 
'author = {Farrow, Roger A.}, ' ... 
'year = {1936}, ' ...
'title = {Population dynamics of the {A}ustralian plague locust, \emph{Chortoicetes Terminifera} ({W}alker) in central western {N}ew {S}outh {W}ales. {I}{I}. {F}actors influencing natality and survival}, ' ...
'journal = {Australian Journal of Zoology}, ' ...
'volume = {30}, ' ...
'number = {2}, '...
'pages = {199--222}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Clar1965'; type = 'Article'; bib = [ ... 
'author = {Clarke, D. P.}, ' ... 
'year = {1957}, ' ...
'title = {On the sexual maturation, breeding, and ovipsition behaviour of the {A}ustralian plague locust, \emph{Chortoicetes terminifera} ({W}alk.)}, ' ...
'journal = {Australian Journal of Zoology}, ' ...
'volume = {13}, ' ...
'number = {1}, '...
'pages = {17--46}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Simp2018'; type = 'Misc'; bib = [ ...
'author = {Steve Simpson}, ' ...     
'year = {2019}, ' ...
'howpublished = {pers. comm.}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

