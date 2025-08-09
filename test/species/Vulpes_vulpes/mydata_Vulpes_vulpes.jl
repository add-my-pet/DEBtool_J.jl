EstimationData(;
    temperature = u"K"(38.7u"°C"),
    timesincebirth = (
        Weaning(48u"d"),
        Puberty(304u"d"),
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
    pseudo = (; t_0=Weighted(3.0, 0.0u"d")),
)
