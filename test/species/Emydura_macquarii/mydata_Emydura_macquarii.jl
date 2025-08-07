using StaticArrays: @SMatrix

# TODO use an external CSV / DataFrame for this?
tL = @SMatrix[ 
    0.981  6.876    
    0.981  7.090    
    1.956  8.369    
    1.956  8.689    
    1.957  9.115    
    1.957  9.435    
    1.957  9.808    
    1.958  10.075   
    1.958  10.235   
    1.983  10.661   
    2.833  11.141   
    2.908  11.354   
    2.931  9.701    
    2.932  10.768   
    2.984  12.420   
    3.008  11.674   
    3.833  13.220   
    3.834  13.326   
    3.834  13.646   
    3.857  12.100   
    3.883  12.420   
    3.883  12.633   
    3.883  12.953   
    3.934  14.072  
]

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
    variate=(; lengths=Univariate(Time(365u"d"), Length(u"cm"), tL)),
    pseudo=(; k=0.3),
)

# set pseudodata and respective weights
# TODO why is k=0.3 etc here, what is this based on
# set weights for all real data
weights = defaultweights(data)
weights = merge(weights, (; 
    variate=(; lengths=2 .* weights.variate.lengths), 
    pseudo=defaultpseudoweights((k_J=0.0, k=0.1)),
))
temp = u"K"(22.0u"°C")

(; data, weights, temp)
