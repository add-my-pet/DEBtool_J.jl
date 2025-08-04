using StaticArrays

# Convert the matrix tL1 into a named tuple with units assigned to each column
tL = @SVector[
    6.876
    7.090
    8.369
    8.689
    9.115
    9.435
    9.808
    10.075
    10.235
    10.661
    11.141
    11.354
    9.701
    10.768
    12.420
    11.674
    13.220
    13.326
    13.646
    12.100
    12.420
    12.633
    12.953
    14.072
]u"cm"

tLt = @SVector[
    0.981
    0.981
    1.956
    1.956
    1.957
    1.957
    1.957
    1.958
    1.958
    1.983
    2.833
    2.908
    2.931
    2.932
    2.984
    3.008
    3.833
    3.834
    3.834
    3.857
    3.883
    3.883
    3.883
    3.934
] * 365u"d"

data = (;
    age=(
        Birth(78.0u"d"),
        Birth(AtTemperature(u"K"(30.0u"°C"), 48.0u"d")),
        Female(Ultimate(20.9 * 365.0u"d")),
    ),
    # TODO what does time mean as different to age - scaled time?
    time=(
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
    univariate=(; lengths=Univariate(Times(tLt), Lengths(tL))),
)

# set pseudodata and respective weights
# TODO why is k=0.3 etc here
pseudo = defaultpseudodata(; data=(k=0.3,), weights=(k_J=0.0, k=0.1))
# set weights for all real data
weights = defaultweights(data)
weights = ConstructionBase.setproperties(data, (; univariate=(; lengths=2 .* weights.univariate.lengths), pseudo=pseudo.weights))
data = ConstructionBase.setproperties(data, (; pseudo=pseudo.data))
temp = u"K"(22.0u"°C")

(; data, temp, weights)
