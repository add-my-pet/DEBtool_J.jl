## set data
# zero-variate data

data.am = 18.4; units.am = 'd'; label.am = 'life span as female imago'; bibkey.am = 'GarcMeag2018';   
      temp.am = C2K(22); units.temp.am = 'K'; label.temp.am = 'temperature'; 

temp = 25u"°C"

# comment.te ='duration prepupa stage (1.87 d) + duration of pupa stage (9.7 d)';

data = EstimationData(; 
    timesinceconception = (
        AtTemperture(u"K"(u"°C"(22)), Birth(4.4u"d")),
    ),
    timesincebirth = (
        AtTemperture(u"K"(u"°C"(22)), Pupation(27.5u"d")),
    ),
    duration = (
        Instar{1}(2.57u"d"),
        Instar{2}(2.07u"d"),
        Instar{3}(2.13u"d"),
        Instar{4}(2.48u"d"),
        Instar{5}(2.57u"d"),
        Instar{6}(2.13u"d"),
        Pupa(11.57u"d"),
        AtTemperture(u"K"(22.0u"°C"), Pupa(27.5u"d")),
        Imago(18.4u"d"),
    )
    length = (
        # TODO are these shifted up by one? the original says "instar n" but thats a period of time not an exact transition
        Moult{1}(0.035u"cm"),
        Moult{2}(0.057u"cm"),
        Moult{3}(0.087u"cm"),
        Moult{4}(0.129u"cm"),
        Moult{5}(0.189u"cm"),
        Moult{6}(0.28u"cm"),
    ),
    wetweight=(Pupa(0.2889u"g"),),
    n_eggs=1604.2,
)

# data.L1 = 0.035; units.L1 = 'cm'; label.L1 = 'head capsule of instar 1 females'; bibkey.L1 = 'MontHunt2019';
# data.L2 = 0.057; units.L2 = 'cm'; label.L2 = 'head capsule of instar 2 females'; bibkey.L2 = 'MontHunt2019';
# data.L3 = 0.087; units.L3 = 'cm'; label.L3 = 'head capsule of instar 3 females'; bibkey.L3 = 'MontHunt2019';
# data.L4 = 0.129; units.L4 = 'cm'; label.L4 = 'head capsule of instar 4 females'; bibkey.L4 = 'MontHunt2019';
# data.L5 = 0.189; units.L5 = 'cm'; label.L5 = 'head capsule of instar 5 females'; bibkey.L5 = 'MontHunt2019';
# data.L6 = 0.28;  units.L6 = 'cm'; label.L6 = 'head capsule of instar 6 females'; bibkey.L6 = 'MontHunt2019';

# data.Ni = 1604.2; units.Ni = '#'; label.Ni = 'number of eggs'; bibkey.Ni = 'BarrOliv2010';   
   # comment.Ni ='Maximum egg numer found for corn';
 
# uni-variate data
Tab = [ # temperature (C), age at birth (d)
    18	6.3
    22	4.0
    26	3.0
    30	2.0
    32	2.0
]
# units.Tab  = {'C', 'd'}; label.Tab = {'temperature', 'age at birth'};  

Tab2 = [ # temperature (C), age at birth (d)
    14  13.2
    18  6.0
    22  4.4
    26  3.0
    30  2.0
]
# units.Tab2  = {'C', 'd'}; label.Tab2 = {'temperature', 'age at birth'};  
# bibkey.Tab2 = 'GarcMeag2018';
durations_Schl2018 = [ # temperature (C), duration instar 1-6 and pupa (d)
    18  4.9  4.9  5.0  5.2  6.2  8.6  30.68
    22  3.7  3.0  2.5  2.8  3.4  5.1  17.06
    26  3.0  2.1  2.0  2.2  2.3  3.4  11.43
    30  2.2  1.9  1.4  1.7  2.2  2.0  9.0
    32  2.7  1.3  1.1  1.5  1.8  2.1  7.82
]

durations_LopeCarr2019 = [ # temperature (C), duration instar 1-6 (d)
    15  13.20531283  7.925312834  8.645329917  11.65869742  11.09864617  14.83199658  
    20  4.597309417  3.343976084  3.423976084  3.770745249  4.837292334  5.904027333
    25  3.616006833  2.122690583  2.362656417  2.469340167  2.949340167  3.882656417
    28  3.00585095   1.93921845   2.01921845   2.232568866  2.472551783  3.272500534
    30  2.821319667  2.1280205    1.968037583  2.234687166  2.554687166  3.221319667
]

Tte2 = @SMatrix[ # temperature (C), duration pupa stage (d)
    20 25.61
    25 12.31
    27 9.07
    30 8.17
]

Ts = @SMatrix[ # temperature (C), Larval mortality (#)
    18	71
    22	37
    26	15
    30	4
    32	28
]
# TODO how to do this
# Univariate(Temperatures(u"C"), Mortality(Larva(), u"d"), Ts)
lifestages_Schl2018 = (ntuple(i -> Duration{Instar{i}}(u"d"), 6)..., Duration{Pupa}(u"d"))
lifestages_LopeCarr2019 = ntuple(i -> Duration{Instar{i}}(u"d"), 6)
variate = (
    Univariate(Temperatures(u"C"), Period{Conception,Birth}(u"d"), Tab1),
    Univariate(Temperatures(u"C"), Period{Conception,Birth}(u"d"), Tab2),
    Multivariate(Temperature(u"°C"), lifestages_Schl2018, durations_Schl2018),
    Multivariate(Temperature(u"°C"), lifestages_LopeCarr2019, durations_LopeCarr2019),
    Univariate(Temperatures(u"C"), Duration{Pupa}(u"d"), Tte2),
)

# units.Ts  = {'C', '#'}; label.Ts = {'temperature', 'larval mortality'};  
# bibkey.Ts = 'Schl2018';

## set weights for all real data
weights = defaultweights(data)

## set pseudodata and respective weights
[data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.v = 3 * weights.psd.v;
