using StaticArrays, ConstructionBase

# uni-variate data

# TODO make this more concise.
# Maybe the Times/WetWeights wrappers can automatically make SVectors?
# Maybe Times is implicit as the first argument?
wetweights = (
    AtTemperature(u"K"(39u"°C"), 
        Univariate( # convert age to time since birth
            Times(@SVector[30.944, 53.293, 72.072, 90.675, 129.315, 169.062, 251.239]u"d" .- 30u"d"), 
            WetWeights(@SVector[46.556, 243.541, 521.119, 781.432, 1336.016, 1735.844, 2614.389]u"g"),
        )
    ), 
    AtTemperature(u"K"(39u"°C"), 
        Univariate(
            Times(@SVector[19.975, 21.987, 23.997, 25.982, 27.990, 28.982, 29.974]u"d"),
            WetWeights(@SVector[4.702, 8.077, 16.117, 24.553, 35.769, 41.725, 46.092]u"g"),
        )
    )
)

# TODO does this need the field names, they could be wrappers
data = EstimationData(;
    timesinceconception=(
        Birth(78.0u"d"),
        Ultimate(20.9 * 365.0u"d"),
    ),
    timesincebirth=(
        Weaning(26.0u"d"),
        Puberty(730.0u"d"),
    ),
    length=(
        Ultimate(42.0u"cm"),
    ),
    wetweight=(
        Birth(46.0u"g"),
        Puberty(214.0u"g"),
        Ultimate(3900.0u"g"),
    ),
    gestation=(Gestation(30.0u"d"),),
    reproduction=Female(Ultimate(AtTemperature(u"K"(39.0u"°C"), 5*4.3 / 365.0u"d"))),
    univariate=(; wetweights),
)

# set pseudodata and respective weights
# TODO why is k=0.3 etc here
pseudo = defaultpseudodata(; data=(t_0=0.0u"d",), weights=(t_0=0.1,))
# set weights for all real data
weights = defaultweights(data);
weights = ConstructionBase.setproperties(weights, (; pseudo=pseudo.weights))
data = ConstructionBase.setproperties(data, (; pseudo=pseudo.data))
temp = u"K"(22.0u"°C")

(; data, temp, weights)
