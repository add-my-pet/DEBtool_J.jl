# TODO Make these types somehow

const DEFAULT_CHEMICAL_PARAMETERS = (
    # specific densities; multiply by d_V to convert to vector if necessary
    d_X = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of food"),
    d_V = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of structure"),
    d_E = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of reserve"),
    d_P = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of faeces"),
)

const DEFAULT_CHEMICAL_POTENTIALS = ( # from Kooy2010 Tab 4.2
    mu_X = 525000.0u"J/mol", # Param(525000.0, units=u"J/mol", label="chemical potential of food"),
    mu_V = 500000.0u"J/mol", # Param(500000.0, units=u"J/mol", label="chemical potential of structure"),
    mu_E = 550000.0u"J/mol", # Param(550000.0, units=u"J/mol", label="chemical potential of reserve"),
    mu_P = 480000.0u"J/mol", # Param(480000.0, units=u"J/mol", label="chemical potential of faeces"),
)

const DEFAULT_CHEMICAL_POTENTIAL_OF_MINERALS = (
    mu_C = 0.0u"J/ mol", # Param(0.0, units=u"J/ mol", label="chemical potential of CO2"),
    mu_H = 0.0u"J/ mol", # Param(0.0, units=u"J/ mol", label="chemical potential of H2O"),
    mu_O = 0.0u"J/ mol", # Param(0.0, units=u"J/ mol", label="chemical potential of O2"),
    mu_N = 4880.0u"J/ mol", # Param(4880.0, units=u"J/ mol", label="chemical potential of N-waste"),
)

const DEFAULT_CHEMICAL_INDICES_FOR_WATER_ORGANICS = ( # from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water),
    # food
    n_CX = 1.0, # Param(1.0, units=nothing, label="chem. index of carbon in food"), # C/C = 1 by definition
    n_HX = 1.8, # Param(1.8, units=nothing, label="chem. index of hydrogen in food"),
    n_OX = 0.5, # Param(0.5, units=nothing, label="chem. index of oxygen in food"),
    n_NX = 0.15,# Param(0.15, units=nothing, label="chem. index of nitrogen in food"),
    # structure
    n_CV = 1.0, # Param(1.0, units=nothing, label="chem. index of carbon in structure"), # n_CV = 1 by definition
    n_HV = 1.8, # Param(1.8, units=nothing, label="chem. index of hydrogen in structure"),
    n_OV = 0.5, # Param(0.5, units=nothing, label="chem. index of oxygen in structure"),
    n_NV = 0.15,# Param(0.15, units=nothing, label="chem. index of nitrogen in structure"),
    # reserve
    n_CE = 1.0,  # Param(1.0, units=nothing, label="chem. index of carbon in reserve"),   # n_CE = 1 by definition
    n_HE = 1.8,  # Param(1.8, units=nothing, label="chem. index of hydrogen in reserve"),
    n_OE = 0.5,  # Param(0.5, units=nothing, label="chem. index of oxygen in reserve"),
    n_NE = 0.15, # Param(0.15, units=nothing, label="chem. index of nitrogen in reserve"),
    # faeces
    n_CP = 1.0,  # Param(1.0, units=nothing, label="chem. index of carbon in faeces"),    # n_CP = 1 by definition
    n_HP = 1.8,  # Param(1.8, units=nothing, label="chem. index of hydrogen in faeces"),
    n_OP = 0.5,  # Param(0.5, units=nothing, label="chem. index of oxygen in faeces"),
    n_NP = 0.15, # Param(0.15, units=nothing, label="chem. index of nitrogen in faeces"),
)

const DEFAULT_CHEMICAL_INDICES_FOR_MINERALS = ( # from Kooy2010
    # CO2
    n_CC = 1.0, # Param(1.0, units=nothing, label="chem. index of carbon in CO2"),
    n_HC = 0.0, # Param(0.0, units=nothing, label="chem. index of hydrogen in CO2"),
    n_OC = 2.0, # Param(2.0, units=nothing, label="chem. index of oxygen in CO2"),
    n_NC = 0.0, # Param(0.0, units=nothing, label="chem. index of nitrogen in CO2"),
    # H2O
    n_CH = 0.0, # Param(0.0, units=nothing, label="chem. index of carbon in H2O"),
    n_HH = 2.0, # Param(2.0, units=nothing, label="chem. index of hydrogen in H2O"),
    n_OH = 1.0, # Param(1.0, units=nothing, label="chem. index of oxygen in H2O"),
    n_NH = 0.0, # Param(0.0, units=nothing, label="chem. index of nitrogen in H2O"),
    # O2
    n_CO = 0.0, # Param(0.0, units=nothing, label="chem. index of carbon in O2"),
    n_HO = 0.0, # Param(0.0, units=nothing, label="chem. index of hydrogen in O2"),
    n_OO = 2.0, # Param(2.0, units=nothing, label="chem. index of oxygen in O2"),
    n_NO = 0.0, # Param(0.0, units=nothing, label="chem. index of nitrogen in O2"),
    # N-waste; multiply free by par to convert to vector if necessary
    n_CN = 1.0, # Param(1.0, units=nothing, label="chem. index of carbon in N-waste"),   # n_CN = 0 or 1 by definition
    n_HN = 0.8, # Param(0.8, units=nothing, label="chem. index of hydrogen in N-waste"),
    n_ON = 0.6, # Param(0.6, units=nothing, label="chem. index of oxygen in N-waste"),
    n_NN = 0.8, # Param(0.8, units=nothing, label="chem. index of nitrogen in N-waste"),
)

const DEFAULT_RANDOM_SEEDS = [
    2147483647,
    2874923758,
    1284092845,  # The values of the seed used to
    2783758913,
    3287594328,
    2328947617,  # generate random values (each one is used in a
    1217489374,
    1815931031,
    3278479237,  # single run of the algorithm).
    3342427357,
    223758927,
    3891375891,
    1781589371,
    1134872397,
    2784732823,
    2183647447,
    24923758,
    122845,
    2783784093,
    394328,
    2328757617,
    12174974,
    18593131,
    3287237,
    33442757,
    2235827,
    3837891,
    17159371,
    34211397,
    2842823,
]
