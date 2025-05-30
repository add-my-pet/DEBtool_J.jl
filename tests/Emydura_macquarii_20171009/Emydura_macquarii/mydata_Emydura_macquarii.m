function [data, auxData, metaData, txtData, weights] = mydata_Emydura_macquarii
%% set metaData
metaData.phylum     = 'Chordata'; 
metaData.class      = 'Reptilia'; 
metaData.order      = 'Testudines'; 
metaData.family     = 'Chelidae';
metaData.species    = 'Emydura_macquarii'; 
metaData.species_en = 'Murray River turtle';

metaData.ecoCode.climate = {'Cfa', 'Cfb'};
metaData.ecoCode.ecozone = {'TA'};
metaData.ecoCode.habitat = {'0bTd', 'biFr'};
metaData.ecoCode.embryo  = {'Tt'};
metaData.ecoCode.migrate = {};
metaData.ecoCode.food    = {'biCi'};
metaData.ecoCode.gender  = {'Dg'};
metaData.ecoCode.reprod  = {'O'};

metaData.T_typical  = C2K(22); % K, body temp
metaData.data_0     = {'ab_T'; 'ap'; 'am'; 'Lb'; 'Lp'; 'Li'; 'Wwb'; 'Wwp'; 'Wwi'; 'Ri'}; 
metaData.data_1     = {'t-L'}; 

metaData.COMPLETE = 2.5; % using criteria of LikaKear2011

metaData.author   = {'Bas Kooijman'};    
metaData.date_subm = [2017 10 09];              
metaData.email    = {'bas.kooijman@vu.nl'};            
metaData.address  = {'VU University, Amsterdam'}; 

metaData.curator     = {'Starrlight Augustine'};
metaData.email_cur   = {'starrlight@akvaplan.niva.no'}; 
metaData.date_acc    = [2017 10 09];

%% set data
% zero-variate data

data.ab = 78;     units.ab = 'd';    label.ab = 'age at birth';                      bibkey.ab = 'carettochelys';
  temp.ab = C2K(22);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
  comment.ab = 'all temps are guessed';
data.ab30 = 48;     units.ab30 = 'd';    label.ab30 = 'age at birth';                bibkey.ab30 = 'carettochelys';
  temp.ab30 = C2K(30);  units.temp.ab30 = 'K'; label.temp.ab30 = 'temperature';
data.tp = 10*365;     units.tp = 'd';    label.tp = 'time since birth at puberty for females';    bibkey.tp = 'Spen2002';
  temp.tp = C2K(22);  units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.tpm = 5.5*365;     units.tpm = 'd';    label.tpm = 'time since birth at puberty for males';    bibkey.tpm = 'Spen2002';
  temp.tpm = C2K(22);  units.temp.tpm = 'K'; label.temp.tpm = 'temperature';
data.am = 20.9*365;     units.am = 'd';    label.am = 'life span';                    bibkey.am = 'AnAge';   
  temp.am = C2K(22);  units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb = 2.7; units.Lb = 'cm';   label.Lb = 'plastron length at birth';               bibkey.Lb = 'Spen2002';
data.Lp = 18.7; units.Lp = 'cm';    label.Lp = 'plastron length at puberty for females'; bibkey.Lp = 'Spen2002';
data.Lpm = 14.7; units.Lpm = 'cm';    label.Lpm = 'plastron length at puberty for males'; bibkey.Lpm = 'Spen2002';
data.Li = 21.4; units.Li = 'cm';   label.Li = 'ultimate plastron length for females';  bibkey.Li = 'Spen2002';
data.Lim = 20.8; units.Lim = 'cm';   label.Lim = 'ultimate plastron length for females';  bibkey.Lim = 'Spen2002';

data.Wwb = 8; units.Wwb = 'g';   label.Wwb = 'wet weight at birth';     bibkey.Wwb = {'carettochelys','Spen2002'};
  comment.Wwb = 'based on (Lb/Li)^3*Wwi';
data.Wwp = 2669; units.Wwp = 'g';   label.Wwp = 'wet weight at puberty';     bibkey.Wwp = {'carettochelys','Spen2002'};
  comment.Wwp = 'based on (Lp/Li)^3*Wwi';
data.Wwpm = 1297; units.Wwpm = 'g';   label.Wwpm = 'wet weight at puberty';  bibkey.Wwpm = {'carettochelys','Spen2002'};
  comment.Wwpm = 'based on (Lpm/Li)^3*Wwi';
data.Wwi = 4000; units.Wwi = 'g';   label.Wwi = 'ultimate wet weight';                bibkey.Wwi = 'carettochelys';
data.Wwim = 3673; units.Wwim = 'g';   label.Wwim = 'ultimate wet weight';             bibkey.Wwim = 'carettochelys';
  comment.Wwpm = 'based on (Lim/Li)^3*Wwi';

data.Ri  = 36/365; units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';                bibkey.Ri  = 'Spen2002';   
  temp.Ri = C2K(22);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
 

% uni-variate data

% time-length
data.tL = [ ... % time since birth (yr), carapace length (cm)
0.981	6.876
0.981	7.090
1.956	8.369
1.956	8.689
1.957	9.115
1.957	9.435
1.957	9.808
1.958	10.075
1.958	10.235
1.983	10.661
2.833	11.141
2.908	11.354
2.931	9.701
2.932	10.768
2.984	12.420
3.008	11.674
3.833	13.220
3.834	13.326
3.834	13.646
3.857	12.100
3.883	12.420
3.883	12.633
3.883	12.953
3.934	14.072];
data.tL(:,1) = data.tL(:,1) * 365; % convert d to yr
units.tL   = {'d', 'cm'};  label.tL = {'time since birth', 'carapace length'};  
temp.tL    = C2K(22);  units.temp.tL = 'K'; label.temp.tL = 'temperature';
bibkey.tL = 'Spen2002';

%% set weights for all real data
weights = setweights(data, []);
weights.tL = 2 * weights.tL;

%% set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.k_J = 0; weights.psd.k = 0.1;
data.psd.k = 0.3; units.psd.k  = '-'; label.psd.k  = 'maintenance ratio'; 

%% pack auxData and txtData for output
auxData.temp = temp;
txtData.units = units;
txtData.label = label;
txtData.bibkey = bibkey;
txtData.comment = comment;

%% Discussion points
D1 = 'Males are assumed to differ from females by {p_Am} and E_Hb only'; 
metaData.discussion = struct('D1', D1);

%% Facts
F1 = 'Omnivorous';
metaData.bibkey.F1 = 'Wiki'; 
metaData.facts = struct('F1',F1);

%% Links
metaData.links.id_CoL = '39LSX'; % Cat of Life
metaData.links.id_ITIS = '949506'; % ITIS
metaData.links.id_EoL = '794804'; % Ency of Life
metaData.links.id_Wiki = 'Emydura_macquarii'; % Wikipedia
metaData.links.id_ADW = 'Emydura_macquarii'; % ADW
metaData.links.id_Taxo = '93062'; % Taxonomicon
metaData.links.id_WoRMS = '1447999'; % WoRMS
metaData.links.id_ReptileDB = 'genus=Emydura&species=macquarii'; % ReptileDB
metaData.links.id_AnAge = 'Emydura_macquarii'; % AnAge


%% References
bibkey = 'Wiki'; type = 'Misc'; bib = ...
'howpublished = {\url{http://en.wikipedia.org/wiki/Emydura_macquarii}}';
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
bibkey = 'Spen2002'; type = 'Article'; bib = [ ... 
'author = {R.-J. Spencer}, ' ... 
'year = {2002}, ' ...
'title = {Growth patterns in two widely distributed freshwater turtles and a comparison of methods used to estimate age}, ' ...
'journal = {Austr. J. Zool.}, ' ...
'volume = {50}, ' ...
'pages = {477--490}'];
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'AnAge'; type = 'Misc'; bib = ...
'howpublished = {\url{http://genomics.senescence.info/species/entry.php?species=Emydura_macquarii}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];
%
bibkey = 'carettochelys'; type = 'Misc'; bib = ...
'howpublished = {\url{http://www.carettochelys.com/emydura/emydura_mac_mac_3.htm}}';
metaData.biblist.(bibkey) = ['''@', type, '{', bibkey, ', ' bib, '}'';'];

