# TODO fill all of this out

EstimationData(;
    temperature = 0.0u"K",
    timesincebirth = (
    ),
    timesincefertilisation = (
    ),
    length = (
    ),
    wetweight=(
    ),
    reproduction = 0.0u"d^-1",
    variate = (
        MultiVariate(Time(u"d"), FoodIntake(u"kg/d"), MethandEmmisions(u"g/d"), CO2Emissions(u"g/d"), "data.csv"),
        MultiVariate(Time(u"d"), FoodIntake(u"kg/d"), MethandEmmisions(u"g/d"), CO2Emissions(u"g/d"), "otherdata.csv"),
        MultiVariate(Time(u"d"), FoodIntake(u"kg/d"), MethandEmmisions(u"g/d"), CO2Emissions(u"g/d"), "anotherdata.csv"),
        Univariate(Time(u"d"), Weight(u"kg"), "weigth.csv"),
    ),
)
