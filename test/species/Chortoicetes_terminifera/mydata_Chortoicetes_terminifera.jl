  
# uni-variate data
#Wd_instar = [data.Wdb,

data.Tab = [ # temperature (C), age at birth (d)
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
data.tW_26 = [ # time since birth (d), dry weight (g)
    0       data.Wdb
    8.85	data.Wd2
    16.45	data.Wd3
    27.2	data.Wd4
    40.65	data.Wd5
    57.05	data.Wdp
]
units.tW_26   = {'d', 'g'};  label.tW_26 = {'time since birth', 'dry weight', '25.9 C'};  
temp.tW_26    = C2K(25.9);  units.temp.tW_26 = 'K'; label.temp.tW_26 = 'temperature';

data.tW_27 = [ # time since birth (d), dry weight (g)
    0       data.Wdb
    6.25	data.Wd2
    14.4	data.Wd3
    21.75	data.Wd4
    31.9	data.Wd5
    43.3	data.Wdp
]
units.tW_27   = {'d', 'g'};  label.tW_27 = {'time since birth', 'dry weight', '26.8 C'};  
temp.tW_27    = C2K(26.8);  units.temp.tW_27 = 'K'; label.temp.tW_27 = 'temperature';

data.tW_29 = [ # time since birth (d), dry weight (g)
0       data.Wdb
5.7     data.Wd2
11.7	data.Wd3
17.6	data.Wd4
25.5	data.Wd5
34.3	data.Wdp];
units.tW_29   = {'d', 'g'};  label.tW_29 = {'time since birth', 'dry weight', '28.5 C'};  
temp.tW_29    = C2K(28.5);  units.temp.tW_29 = 'K'; label.temp.tW_29 = 'temperature';

data = (
    timesinceconception = (
        Birth(17.4u"d")
    ),
    timesincebirth = (
        Puberty(34.35u"d")
    ),
    lifespan = 34.35u"d" + 60u"d"
    length = (
        Birth(0.5u"cm"),
        Puberty(3.2u"cm"),
    ),
    dryweight = (
        Birth(9e-4u"g"),
        Instar{2}(2.88e-3u"g"),
        Instar{3}(5.56e-3u"g"),
        Instar{4}(11.71e-3u"g"),
        Instar{5}(25.53e-3*1.5u"g"),
        Puberty(0.1095u"g"),
    ),
    reproduction = 72*3/60u"d^-1",
)
  
## set weights for all real data
weights = defaultweights(data)
weights.Lb = 0 * weights.Lb;
weights.tW_26 = 3 * weights.tW_26
weights.tW_27 = 3 * weights.tW_27
weights.tW_29 = 3 * weights.tW_29
weights.Tab = 7 * weights.Tab

## set pseudodata and respective weights
[data, units, label, weights] = defaultpseudodata(data, units, label, weights)
weights.psd.v = 5 * weights.psd.v
