## set data
# zero-variate data
timesinceconception = (
    AtTemperture(u"K"(u"°C"(22)), Birth(4.4u"d")),
),
timesincebirth = (
    AtTemperture(u"K"(u"°C"(22)), Pupation(27.5u"d")),
),
lifespan = 
AtTemperture(u"K"(u"°C"(22)), Pupation(27.5u"d")),
    data.am = 18.4; units.am = 'd'; label.am = 'life span as female imago'; bibkey.am = 'GarcMeag2018';   
      temp.am = C2K(22); units.temp.am = 'K'; label.temp.am = 'temperature'; 

temp = 25u"°C"
duration = (
    Instar{1}(2.57u"d"),
    Instar{2}(2.07u"d"),
    Instar{3}(2.13u"d"),
    Instar{4}(2.48u"d"),
    Instar{5}(2.57u"d"),
    Instar{6}(2.13u"d"),
    Pupa(11.57u"d"),
)

# comment.te ='duration prepupa stage (1.87 d) + duration of pupa stage (9.7 d)';

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
 
# uni-variate data
data.Tab = [ ... # temperature (C), age at birth (d)
    18	6.3
    22	4
    26	3
    30	2
    32	2
]
units.Tab  = {'C', 'd'}; label.Tab = {'temperature', 'age at birth'};  
bibkey.Tab = 'Schl2018';

data.Tab2 = [ # temperature (C), age at birth (d)
    14	13.2
    18	6
    22	4.4
    26	3
    30	2
]
units.Tab2  = {'C', 'd'}; label.Tab2 = {'temperature', 'age at birth'};  
bibkey.Tab2 = 'GarcMeag2018';

data.TtI1 = [ ... # temperature (C), duration instar 1 (d)
18	4.9
22	3.7
26	3
30	2.2
32	2.7];
units.TtI1  = {'C', 'd'}; label.TtI1 = {'temperature', 'duration instar 1'};  
bibkey.TtI1 = 'Schl2018';

data.Tt2I1 = [ ... # temperature (C), duration instar 1 (d)
15	13.20531283
20	4.597309417
25	3.616006833
28	3.00585095
30	2.821319667];
units.Tt2I1  = {'C', 'd'}; label.Tt2I1 = {'temperature', 'duration instar 1'};  
bibkey.Tt2I1 = 'LopeCarr2019';

data.TtI2 = [ ... # temperature (C), duration instar 2 (d)
18	4.9
22	3
26	2.1
30	1.9
32	1.3];
units.TtI2  = {'C', 'd'}; label.TtI2 = {'temperature', 'duration instar 2'};  
bibkey.TtI2 = 'Schl2018';

data.Tt2I2 = [ ... # temperature (C), duration instar 1 (d)
15	7.925312834
20	3.343976084
25	2.122690583
28	1.93921845
30	2.1280205];
units.Tt2I2  = {'C', 'd'}; label.Tt2I2 = {'temperature', 'duration instar 2'};  
bibkey.Tt2I2 = 'LopeCarr2019';

data.TtI3 = [ ... # temperature (C), duration instar 3 (d)
18	5
22	2.5
26	2
30	1.4
32	1.1];
units.TtI3  = {'C', 'd'}; label.TtI3 = {'temperature', 'duration instar 3'};  
bibkey.TtI3 = 'Schl2018';

data.Tt2I3 = [ ... # temperature (C), duration instar 1 (d)
15	8.645329917
20	3.423976084
25	2.362656417
28	2.01921845
30	1.968037583];
units.Tt2I3  = {'C', 'd'}; label.Tt2I3 = {'temperature', 'duration instar 3'};  
bibkey.Tt2I3 = 'LopeCarr2019';

data.TtI4 = [ ... # temperature (C), duration instar 4 (d)
18	5.2
22	2.8
26	2.2
30	1.7
32	1.5];
units.TtI4  = {'C', 'd'}; label.TtI4 = {'temperature', 'duration instar 4'};  
bibkey.TtI4 = 'Schl2018';

data.Tt2I4 = [ ... # temperature (C), duration instar 1 (d)
15	11.65869742
20	3.770745249
25	2.469340167
28	2.232568866
30	2.234687166];
units.Tt2I4  = {'C', 'd'}; label.Tt2I4 = {'temperature', 'duration instar 4'};  
bibkey.Tt2I4 = 'LopeCarr2019';

data.TtI5 = [ ... # temperature (C), duration instar 5 (d)
18	6.2
22	3.4
26	2.3
30	2.2
32	1.8];
units.TtI5  = {'C', 'd'}; label.TtI5 = {'temperature', 'duration instar 5'};  
bibkey.TtI5 = 'Schl2018';

data.Tt2I5 = [ ... # temperature (C), duration instar 1 (d)
15	11.09864617
20	4.837292334
25	2.949340167
28	2.472551783
30	2.554687166];
units.Tt2I5  = {'C', 'd'}; label.Tt2I5 = {'temperature', 'duration instar 5'};  
bibkey.Tt2I5 = 'LopeCarr2019';

data.TtI6 = [ ... # temperature (C), duration instar 6 (d)
18	8.6
22	5.1
26	3.4
30	2
32	2.1];
units.TtI6  = {'C', 'd'}; label.TtI6 = {'temperature', 'duration instar 6'};  
bibkey.TtI6 = 'Schl2018';

data.Tt2I6 = [ ... # temperature (C), duration instar 1 (d)
15	14.83199658
20	5.904027333
25	3.882656417
28	3.272500534
30	3.221319667];
units.Tt2I6  = {'C', 'd'}; label.Tt2I6 = {'temperature', 'duration instar 6'};  
bibkey.Tt2I6 = 'LopeCarr2019';

data.Tte = [ ... # temperature (C), duration pupa stage (d)
18	30.68
22	17.06
26	11.43
30	9
32	7.82];
units.Tte  = {'C', 'd'}; label.Tte = {'temperature', 'duration pupa stage'};  
bibkey.Tte = 'Schl2018';

data.Tte2 = [ ... # temperature (C), duration pupa stage (d)
20 25.61
25 12.31
27 9.07
30 8.17];
units.Tte2  = {'C', 'd'}; label.Tte2 = {'temperature', 'duration pupa stage'};  
bibkey.Tte2 = 'LopeCarr2019';

data.Ts = [ ... # temperature (C), Larval mortality (#)
18	71
22	37
26	15
30	4
32	28];
units.Ts  = {'C', '#'}; label.Ts = {'temperature', 'larval mortality'};  
bibkey.Ts = 'Schl2018';

## set weights for all real data
weights = defaultweights(data)

## set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.v = 3 * weights.psd.v;
