
data = EstimationData(;
    timesinceconception=(
        Birth(78.0u"d"),
        Birth(AtTemperature(u"K"(30.0u"°C"), 48.0u"d")),
        Female(Ultimate(20.9 * 365.0u"d")),
    ),
    # TODO what does time mean as different to age - scaled time?
    timesincebirth=(
        Female(Puberty(10.0 * 365.0u"d")),
        Male(Puberty(5.5 * 365.0u"d")),
    ),
    length=(
        Birth(2.7u"cm"),
        Female(Puberty(18.7u"cm")),
        Male(Puberty(14.7u"cm")),
        Female(Ultimate(21.4u"cm")),
        Male(Ultimate(20.8u"cm")),
    ),
    wetweight=(
        Birth(8.0u"g"),
        Female(Puberty(2669.0u"g")),
        Male(Puberty(1297.0u"g")),
        Female(Ultimate(4000.0u"g")),
        Male(Ultimate(3673.0u"g")),
    ),
    reproduction=Female(Ultimate(AtTemperature(u"K"(22.0u"°C"), 36.0 / 365.0u"d"))),
    variate=(; lengths=Univariate(Time(365u"d"), Length(u"cm"), "$(@__DIR__)/data/length.csv")),
    # TODO why is k=0.3 etc here, what is this based on
    pseudo=(; k=0.3),
)

# TODO this should be defined in the data object
weights = defaultweights(data)
weights = merge(weights, (; 
    variate=(; lengths=2 .* weights.variate.lengths), 
    pseudo=defaultpseudoweights((k_J=0.0, k=0.1)),
))
temp = u"K"(22.0u"°C")

(; data, weights, temp)
