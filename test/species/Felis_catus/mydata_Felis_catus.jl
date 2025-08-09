EstimationData(;
    temperature = u"K"(38.1u"°C"),
    timesincebirth=(
        Weaning(56.0u"d"),
        Puberty(239.0u"d"),
        # Male(Puberty(304.0u"d")),
    ),
    # TODO lifespan = 30*365u"d",
    wetweight=(
        Birth(97.5u"g"),
        Ultimate(3900.0u"g"),
    ),
    reproduction = 4/365u"d^-1",
    gestation = 65.0u"d",
    variate = (
        Univariate(Time(u"d"), Weighted(5.0, WetWeight(u"g")), "$(@__DIR__)/data/female_weight.csv"),
        # TODO wrap this as Male
        # Univariate(Time(u"d"), Weighted(5.0, Male(WetWeight(u"g"))), "$(@__DIR__)/data/male_weight.csv"),
    ),
)

# TODO tp = 5 .* weights.tp
