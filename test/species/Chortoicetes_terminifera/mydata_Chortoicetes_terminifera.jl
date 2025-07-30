data.ab = 17.4; units.ab = 'd'; label.ab = 'age at birth'; bibkey.ab = {'Greg1981','Greg1983'};   
  temp.ab = C2K(28.5);  units.temp.ab = 'K'; label.temp.ab = 'temperature';
data.tp = 34.35; units.tp = 'd'; label.tp = 'time since birth at puberty'; bibkey.tp = 'Greg1983';
  temp.tp = C2K(28.5); units.temp.tp = 'K'; label.temp.tp = 'temperature';
data.am = 60 + data.tp; units.am = 'd'; label.am = 'life span'; bibkey.am = 'Simp2018';   
  temp.am = C2K(35.1); units.temp.am = 'K'; label.temp.am = 'temperature'; 

data.Lb  = 0.5; units.Lb  = 'cm'; label.Lb = 'length at birth'; bibkey.Lb  = 'Rent2003';
data.Lp  = 3.2; units.Lp  = 'cm'; label.Lp = 'ultimate total length'; bibkey.Lp  = 'Rent2003';

data.Wdb = 9e-4; units.Wdb = 'g'; label.Wdb = 'dry weight at birth'; bibkey.Wdb = 'Farr1982';
data.Wd2 = 2.88e-3; units.Wd2 = 'g'; label.Wd2 = 'dry weight at beginning of instar 2'; bibkey.Wd2 = 'Clis2004';
data.Wd3 = 5.56e-3; units.Wd3 = 'g'; label.Wd3 = 'dry weight at beginning of instar 3'; bibkey.Wd3 = 'Clis2004';
data.Wd4 = 11.71e-3; units.Wd4 = 'g'; label.Wd4 = 'dry weight at beginning of instar 4'; bibkey.Wd4 = 'Clis2004';
data.Wd5 = 25.53e-3*1.5; units.Wd5 = 'g'; label.Wd5 = 'dry weight at beginning of instar 5'; bibkey.Wd5 = 'Clis2004';
data.Wdp = 0.1095; units.Wdp = 'g';   label.Wdp = 'dry weight at puberty'; bibkey.Wdp = 'Greg1983';

data.Ri  = 72*3/60;   units.Ri  = '#/d'; label.Ri  = 'maximum reprod rate';   bibkey.Ri  = 'Clar1965';   
  temp.Ri = C2K(35.1);  units.temp.Ri = 'K'; label.temp.Ri = 'temperature';
  
# uni-variate data
#Wd_instar = [data.Wdb,

data.Tab = [... # temperature (C), age at birth (d)
#16.2	119.1
#20.6	50.3
#22.6	36.7
25.9	23.7
26.8	20.9
28.5	17.4
32      13.3];
#36      10.7];
#39      12.3];
units.Tab   = {'C', 'd'};  label.Tab = {'temperature', 'age at birth'};  

# tW-data 
data.tW_26 = [... # time since birth (d), dry weight (g)
0       data.Wdb
8.85	data.Wd2
16.45	data.Wd3
27.2	data.Wd4
40.65	data.Wd5
57.05	data.Wdp];
units.tW_26   = {'d', 'g'};  label.tW_26 = {'time since birth', 'dry weight', '25.9 C'};  
temp.tW_26    = C2K(25.9);  units.temp.tW_26 = 'K'; label.temp.tW_26 = 'temperature';

data.tW_27 = [... # time since birth (d), dry weight (g)
0       data.Wdb
6.25	data.Wd2
14.4	data.Wd3
21.75	data.Wd4
31.9	data.Wd5
43.3	data.Wdp];
units.tW_27   = {'d', 'g'};  label.tW_27 = {'time since birth', 'dry weight', '26.8 C'};  
temp.tW_27    = C2K(26.8);  units.temp.tW_27 = 'K'; label.temp.tW_27 = 'temperature';

data.tW_29 = [... # time since birth (d), dry weight (g)
0       data.Wdb
5.7     data.Wd2
11.7	data.Wd3
17.6	data.Wd4
25.5	data.Wd5
34.3	data.Wdp];
units.tW_29   = {'d', 'g'};  label.tW_29 = {'time since birth', 'dry weight', '28.5 C'};  
temp.tW_29    = C2K(28.5);  units.temp.tW_29 = 'K'; label.temp.tW_29 = 'temperature';
  
## set weights for all real data
weights = setweights(data, []);
weights.Lb = 0 * weights.Lb;
weights.tW_26 = 3 * weights.tW_26;
weights.tW_27 = 3 * weights.tW_27;
weights.tW_29 = 3 * weights.tW_29;
weights.Tab = 7 * weights.Tab;

## set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.v = 5 * weights.psd.v;
