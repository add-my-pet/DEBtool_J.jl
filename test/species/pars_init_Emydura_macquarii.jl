par = (;
    # reference parameter (not to be changed),
    T_ref = (20.0 + 273.15)u"K", # Param(20.0 + 273.15, units=u"K", label="Reference Temperature"),

    # core primary parameters
    z = Param(13.2002, units=nothing, label="zoom factor"),
    F_m = 6.5u"l/d/cm^2", # Param(6.5, units=u"l/d/cm^2", label="{F_m}, max spec searching rate"),
    kap_X = 0.8, # Param(0.8, units=nothing, label="digestion efficiency of food to reserve"),
    kap_P = 0.1, # Param(0.1, units=nothing, label="faecation efficiency of food to faeces"),
    v = Param(0.060464, units=u"cm/d", label="energy conductance"),
    kap = Param(0.7362, units=nothing, label="allocation fraction to soma"),
    kap_R = 0.95, # Param(0.95, units=nothing, label="reproduction efficiency"),
    p_M = Param(16.4025, units=u"J/d/cm^3", label="[p_M], vol-spec somatic maint"),
    p_T = 0.0u"J/d/cm^2", # Param(0.0, units=u"J/d/cm^2", label="{p_T}, surf-spec somatic maint"),
    k_J = Param(0.00060219, units=u"1/d", label="maturity maint rate coefficient"),
    E_G = Param(7857.8605, units=u"J/cm^3", label="[E_G], spec cost for structure"),
    E_Hb = Param(1.366e+04, units=u"J", label="maturity at birth"),
    E_Hp = Param(1.168e+07, units=u"J", label="maturity at puberty"),
    h_a = Param(1.211e-09, units=u"1/d^2", label="Weibull aging acceleration"),
    s_G = 0.0001, # Param(0.0001, units=nothing, label="Gompertz stress coefficient"),

    # other parameters
    E_Hpm = Param(4.711e+06, units=u"J", label="maturity at puberty for male"),
    T_A = 8000.0u"K", # Param(8000.0, units=u"K", label="Arrhenius temperature"),
    #T_AL = Param(50000.0, units=u"K", label="low temp boundary"),
    #T_AH = Param(50000.0, units=u"K", label="high temp boundary"),
    #T_L = Param(0 + 273.15, units=u"K", label="low Arrhenius temperature"),
    #T_H = Param(54.5 + 273.15, units=u"K", label="high Arrhenius temperature"),
    del_M = Param(0.61719, units=nothing, label="shape coefficient"),
    f = 1.0, # Param(1.0, units=nothing, label="scaled functional response for 0-var data"),
    z_m = Param(12.8559, units=u"cm", label="zoom factor for male"),

    # chemical parameters
    # specific densities; multiply by d_V to convert to vector if necessary
    d_X = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of food"),
    d_V = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of structure"),
    d_E = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of reserve"),
    d_P = 0.3u"g/cm^3", # Param(0.3, units=u"g/cm^3", label="specific density of faeces"),

    # chemical potentials from Kooy2010 Tab 4.2
    mu_X = 525000.0u"J/mol", # Param(525000.0, units=u"J/mol", label="chemical potential of food"),
    mu_V = 500000.0u"J/mol", # Param(500000.0, units=u"J/mol", label="chemical potential of structure"),
    mu_E = 550000.0u"J/mol", # Param(550000.0, units=u"J/mol", label="chemical potential of reserve"),
    mu_P = 480000.0u"J/mol", # Param(480000.0, units=u"J/mol", label="chemical potential of faeces"),

    # chemical potential of minerals
    mu_C = 0.0u"J/ mol", # Param(0.0, units=u"J/ mol", label="chemical potential of CO2"),
    mu_H = 0.0u"J/ mol", # Param(0.0, units=u"J/ mol", label="chemical potential of H2O"),
    mu_O = 0.0u"J/ mol", # Param(0.0, units=u"J/ mol", label="chemical potential of O2"),
    mu_N = 4880.0u"J/ mol", # Param(4880.0, units=u"J/ mol", label="chemical potential of N-waste"),

    # chemical indices for water-organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water),
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

    # chemical indices for minerals from Kooy2010
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

metapar = (; model = "std")

(; par, metapar)
