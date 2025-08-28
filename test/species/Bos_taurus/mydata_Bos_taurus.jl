# TODO fill all of this out

EstimationData(;
    temperature = 0.0u"K",
    timesincebirth = (
        Female(Weaning(200.0u"d")),
        Female(Puberty(307u"d")),
        Male(Weaning(200"d")),
        Male(Puberty(295u"d")),
    ),
    timesincefertilisation = (
        Birth(282.5u"d"),
        Ultimate(32.5*365u"d"),
    ),
    wetweight=(
        Female(Birth(34.9e3u"g")),
        Female(Weaning(251.2e3u"g")),
        Female(Puberty(301.5e3u"g")),
        Female(Ultimate(650e3u"g")),
        Male(Birth(37.4e3u"g")),
        Male(Weaning(264.1e3u"g")),
        Male(Puberty(374.1e3u"g")),
        Male(Ultimate(1000e3u"g")),
    ),
    # height= TODO withers height
    reproduction=1/436.7u"d^-1",
    variate = (
        # TODO get all the real csvs to add here
        MultiVariate(Time(u"d"), FoodIntake(u"kg/d"), MethandEmmisions(u"g/d"), CO2Emissions(u"g/d"), "data.csv"),
        MultiVariate(Time(u"d"), FoodIntake(u"kg/d"), MethandEmmisions(u"g/d"), CO2Emissions(u"g/d"), "otherdata.csv"),
        MultiVariate(Time(u"d"), FoodIntake(u"kg/d"), MethandEmmisions(u"g/d"), CO2Emissions(u"g/d"), "anotherdata.csv"),
        Univariate(Time(u"d"), WetWeight(u"kg"), "wetweigth.csv"),
    ),
)
