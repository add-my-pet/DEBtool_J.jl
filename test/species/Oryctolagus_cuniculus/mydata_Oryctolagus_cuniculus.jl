using StaticArrays: @SVector
# TODO does this even need the field names, they could be wrappers
EstimationData(;
    temperature=u"K"(39.0u"°C"),
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
    reproduction=Female(Ultimate(5*4.3 / 365.0u"d")),
    variate = (
        Univariate( # convert age to time since birth
            # TODO these should be in an csv, and the -30 should be built in not here, what is this about
            Time(@SVector[30.944, 53.293, 72.072, 90.675, 129.315, 169.062, 251.239]u"d" .- 30u"d"),
            WetWeight(@SVector[46.556, 243.541, 521.119, 781.432, 1336.016, 1735.844, 2614.389]u"g"),
        ),
        Univariate(
            Time(@SVector[19.975, 21.987, 23.997, 25.982, 27.990, 28.982, 29.974]u"d"),
            WetWeight(@SVector[4.702, 8.077, 16.117, 24.553, 35.769, 41.725, 46.092]u"g"),
        )
    ),
    pseudo=(; t_0=Weighted(0.1, 0.0u"d")), # TODO why is t_0=0.0 here
)
