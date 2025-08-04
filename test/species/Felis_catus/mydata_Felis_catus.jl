
# uni-variate data
# time-weight
tW_f = [ # time (d), body weight (g)
     0.000	106.277
    14.092	309.864
    14.109	253.899
    17.055	286.372
    17.357	262.816
    19.130	265.805
    19.400	351.231
    20.577	368.933
    21.493	268.808
    21.796	245.252
    22.940	374.882
    22.947	351.318
    22.957	318.918
    23.249	330.707
    23.847	307.158
    24.719	357.253
    25.288	430.904
    25.321	318.976
    25.930	257.135
    26.794	333.739
    28.576	307.274
    31.470	513.530
    31.477	489.966
    38.293	431.223
    40.602	616.847
    41.767	675.786
    41.780	631.604
    41.786	613.931
    45.034	622.847
    47.698	611.130
    48.592	584.643
    48.640	422.641
    48.833	770.216
    48.899	546.359
    52.130	614.185
    56.862	605.464
    70.646	968.100
    71.265	873.859
    78.358	876.979
    78.819	1315.871
    80.960	1074.392
    81.201	1259.964
    81.578	983.096
    86.883	1033.300
    90.139	1018.652
    111.287	1466.889
    115.678	1611.326
    120.416	1581.987
]

tW_m = [ # time (d), body weight (g)
    9.617	383.603
    13.485	263.122
    15.829	313.368
    15.837	286.859
    16.729	260.415
    17.311	286.967
    18.200	272.305
    19.666	298.923
    22.014	334.442
    24.072	355.212
    24.083	316.921
    25.540	375.939
    26.739	311.226
    27.005	408.447
    31.976	547.252
    36.969	612.421
    41.360	721.728
    41.687	612.768
    43.750	612.920
    45.211	660.156
    46.067	757.421
    46.961	725.086
    47.570	657.384
    48.463	627.995
    48.504	489.559
    54.040	713.825
    55.800	746.355
    56.400	711.054
    70.816	815.208
    72.061	1592.914
    81.463	1705.535
    82.204	1190.126
    82.791	1201.951
    89.785	1479.344
    95.475	1182.267
    101.016	1388.860
    107.623	1978.448
]

## set data
# zero-variate data
data = Data(
    timesincebirth=(
        Weaning(56.0u"d"),
        Puberty(239.0u"d"),
        Male(Puberty(304.0u"d")),
    )
    lifespan = 30*365u"d",
    wetweight=(
        Birth(97.5u"g"),
        Ultimate(3900.0u"g"),
    ),
    reproduction = 4/365u"d^-1",
    gestation = 65.0u"d",
    univariate = (
        Univariate(SVector(tW_m[:, 1]u"d"), WetWeights(SVector(tW_m[:, 2]u"g"))),
        Univariate(SVector(tW_f[:, 1]u"d"), WetWeights(SVector(tW_f[:, 2]u"g"))),
    )
)

## set weights for all real data
weights = setweights(data)
weights = merge(weights, (;
    tW_f = 5 .* weights.tW_f,
    tW_m = 5 .* weights.tW_m,
    tp = 5 .* weights.tp,
))

## set pseudodata and respective weights
pseudo = generatepseudodata(data, units, label, weights)
weights = ConstructionBase.setproperties(data, (; univariate=(; lengths=2 .* weights.univariate.lengths), pseudo=pseudo.weights))
data = ConstructionBase.setproperties(data, (; pseudo=pseudo.data))
