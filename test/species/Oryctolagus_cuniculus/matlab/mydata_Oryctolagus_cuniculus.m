function [data, auxData, metaData, txtData, weights] = mydata_Oryctolagus_cuniculus

%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Mammalia'; 
metaData.order      = 'Lagomorpha'; 
metaData.family     = 'Leporidae';
metaData.species    = 'Oryctolagus_cuniculus'; 
metaData.species_en = 'Rabbit'; 

metaData.ecoCode.climate = {'BSk', 'Csa', 'Cfb', 'Dfb'};
metaData.ecoCode.ecozone = {'THp', 'TA'};
metaData.ecoCode.habitat = {'0iTg', '0iTs'};
metaData.ecoCode.embryo  = {'Tv'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'bxM', 'xiH'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(39); % K, body temp
metaData.data_0     = {'tg'; 'ax'; 'ap'; 'am'; 'Li'; 'Wwb'; 'Wwx'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-Ww'; 't-Wwe'}; 

metaData.COMPLETE = 2.8; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman'};    
metaData.date_subm = [2012 10 30];              
metaData.email    = {'bas.kooijman@vu.nl'};            
metaData.address  = {'VU University Amsterdam'};   

metaData.author_mod_1   = {'Bas Kooijman'};    
metaData.date_mod_1 = [2014 07 22];              
metaData.email_mod_1    = {'bas.kooijman@vu.nl'};            
metaData.address_mod_1  = {'VU University Amsterdam'};

metaData.author_mod_2   = {'Starrlight Augustine'};    
metaData.date_mod_2 = [2016 11 14];              
metaData.email_mod_2    = {'starrlight.augustine@akvaplan.niva.no'};            
metaData.address_mod_2  = {'Akvaplan-niva, Tromso, Norway'};   

metaData.curator     = {'Bas Kooijman'};
metaData.email_cur   = {'bas.kooijman@vu.nl'}; 
metaData.date_acc    = [2016 11 14]; 

%% set data
% zero-variate data

data.tg = 30;    units.tg = 'd';    label.tg = 'gestation time';             bibkey.tg = 'AnAge';   
  temp.tg = C2K(39);  units.temp.tg = 'K'; label.temp.tg = 'temperature';
  comment.tg = 'temp form Anage';
data.tx = 26;    units.tx = 'd';    label.tx = 'time since birth at weaning'; bibkey.tx = 'AnAge';   
  temp.tx = C2K(39);  units.temp.tx = 'K'; label.temp.tx = 'temperature';
data.tp = 730;   units.tp = 'd';    label.tp = 'time since birth at puberty'; bibkey.tp = 'AnAge';
  temp.tp = C2K(39);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.am = 9*365; units.am = 'd';    label.am = 'life span';                bibkey.am = 'AnAge';   
  temp.am = C2K(39);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Li  = 42;   units.Li  = 'cm';  label.Li  = 'ultimate head-rump length';  bibkey.Li  = 'Wiki';
  comment.Li = '34-50 cm';

data.Wwb = 46;   units.Wwb = 'g';   label.Wwb = 'wet weight at birth';     bibkey.Wwb = 'AnAge';
data.Wwx = 214;  units.Wwx = 'g';   label.Wwx = 'wet weight at weaning';   bibkey.Wwx = 'AnAge';
data.Wwi = 3900; units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';     bibkey.Wwi = 'Tynd1973';
  comment.Wwi = 'from tW data';

data.Ri  = 5*4.3/ 365; units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';  bibkey.Ri  = 'AnAge';   
  temp.Ri = C2K(39); units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
 
% uni-variate data
% t-W data
data.tW = [ ... % age (d), wet weight (g)
30.944	46.556
53.293	243.541
72.072	521.119
90.675	781.432
129.315	1336.016
169.062	1735.844
251.239	2614.389];
data.tW(:,1) = data.tW(:,1) - 30; % convert age to time since birth
units.tW   = {'d', 'g'};  label.tW = {'time since birth', 'wet weight'};  
temp.tW    = C2K(39);  units.temp.tW = 'K'; label.temp.tW = 'temperature';
bibkey.tW = 'Tynd1973';

data.tW_e = [ ... % time since birth (d), wet weight (g)
19.975	4.702
21.987	8.077
23.997	16.117
25.982	24.553
27.990	35.769
28.982	41.725
29.974	46.092];
units.tW_e   = {'d', 'g'};  label.tW_e = {'age', 'wet weight'};  
temp.tW_e    = C2K(39);  units.temp.tW_e = 'K'; label.temp.tW_e = 'temperature';
bibkey.tW_e = 'Lell1931';

%% set weights for all real data
weights = setweights(data, []);

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
data.psd.t_0 = 0;  units.psd.t_0 = 'd'; label.psd.t_0 = 'time at start development';
weights.psd.t_0 = 0.1;

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Links
metaData.links.id_CoL = '74ZBP'; % Cat of Life
metaData.links.id_ITIS = '180129'; % ITIS
metaData.links.id_EoL = '327977'; % Ency of Life
metaData.links.id_Wiki = 'Oryctolagus_cuniculus'; % Wikipedia
metaData.links.id_ADW = 'Oryctolagus_cuniculus'; % ADW
metaData.links.id_Taxo = '61547'; % Taxonomicon
metaData.links.id_WoRMS = '993620'; % WoRMS
metaData.links.id_MSW3 = '13500254'; % MSW3
metaData.links.id_AnAge = 'Oryctolagus_cuniculus'; % AnAge


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Oryctolagus_cuniculus}}';
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
bibkey = 'Tynd1973'; type = 'Book'; bib = [ ... 
'author = {Tyndale-Biscoe, H.}, ' ... 
'year = {1973}, ' ...
'title = {Life of marsupials}, ' ...
'publisher = {E. Arnold}, ' ...
'address = {London}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'Lell1931'; type = 'Article'; bib = [ ... 
'author = {Lell, W. A.}, ' ... 
'year = {1931}, ' ...
'title = {The relation of the volume of the amniotic fluid to the weight of the fetus at different stages of pregnancy in the rabbit}, ' ...
'journal = {Anat. Rec.}, ' ...
'volume = {51}, ' ...
'pages = {119--123}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Oryctolagus_cuniculus}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

