data = EstimationData(;
    timesincebirth = (
        Weaning(48u"d"), #    label.tx = 'time since birth at weaning'; bibkey.tx = 'AnAge';
        Puberty(304u"d"), #    label.tp = 'time since birth at puberty';   bibkey.tp = 'AnAge';
    ),
    timesinceconception = (
        Ultimate(21.3*365u"d"),
    ),
    length = (
        Birth(14.5u"cm"),
        Ultimate(90u"cm"),
    ),
    wetweight=(
        Birth(100.0u"g"),
        Weaning(1397.0u"g"),
        Ultimate(7500.0u"g"),
    ),
    gestation = 52u"d",
    reproduction = 5/365.0u"d^-1",
    variate = (
        Univariate(Time(u"d"), Length(u"cm"), "$(@__DIR__)/data/length.csv"),
        Univariate(Time(u"d"), WetWeight(u"g"), "$(@__DIR__)/data/wetweight.csv"),
    ),
    pseudo = (; t_0 = 0.0u"d"),
)

# TODO weights should be tied to data objects
weights = defaultweights(data)
weights = merge(weights, (; pseudo=defaultpseudoweights((; t_0=3.0))))
temp = u"K"(38.7u"°C")

(; data, weights, temp)
