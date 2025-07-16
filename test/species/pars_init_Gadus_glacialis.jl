par = (;
    # reference parameter (not to be changed),
    T_ref = Param(20.0 + 273.15, units=u"K", free=(0), label="Reference Temperature"),

    # core primary parameters
    z = Param(2.3166, units=nothing, free=(1), label="zoom factor"),
    F_m = Param(6.5, units=u"l/d/cm^2", free=(0), label="{F_m}, max spec searching rate"),
    kap_X = Param(0.8, units=nothing, free=(0), label="digestion efficiency of food to reserve"),
    kap_P = Param(0.1, units=nothing, free=(0), label="faecation efficiency of food to faeces"),
    v = Param(0.024334, units=u"cm/d", free=(1), label="energy conductance"),
    kap = Param(0.89844, units=nothing, free=(1), label="allocation fraction to soma"),
    kap_R = Param(0.95, units=nothing, free=(0), label="reproduction efficiency"),
    p_M = Param(206.5258, units=u"J/d/cm^3", free=(1), label="[p_M], vol-spec somatic maint"),
    p_T = Param(0.0, units=u"J/d/cm^2", free=(0), label="{p_T}, surf-spec somatic maint"),    k_J = Param(0.00060219, units=u"1/d", free=(1), label="maturity maint rate coefficient"),
    E_G = Param(5248.4845, units=u"J/cm^3", free=(1), label="[E_G], spec cost for structure"),
    E_Hb = Param(2.613e-01, units=u"J", free=(1), label="maturity at birth"),
    E_Hj = Param(5.983e-01, units=u"J", free=(1), label="maturity at metamorphosis"),
    E_Hp = Param(6.521e+03, units=u"J", free=(1), label="maturity at puberty"),
    h_a = Param(2.754e-06, units=u"1/d^2", free=(1), label="Weibull aging acceleration"),
    s_G = Param(0.0001, units=nothing, free=(0), label="Gompertz stress coefficient"),

    # other parameters
    E_Hpm = Param(4.711e+06, units=u"J", free=(1), label="maturity at puberty for male"),
    T_A = Param(8000.0, units=u"K", free=(0), label="Arrhenius temperature"),
    T_AL = Param(90000.0, units=u"K", free=(0), label="low temp boundary"),
    T_AH = Param(29539.2, units=u"K", free=(0), label="high temp boundary"),
    T_L = Param(261.386, units=u"K", free=(0), label="low Arrhenius temperature"),
    T_H = Param(293.5, units=u"K", free=(0), label="high Arrhenius temperature"),
    del_M = Param(0.097871, units=nothing, free=(1), label="shape coefficient"),
    f = Param(1.0, units=nothing, free=(0), label="scaled functional response for 0-var data"),

    # chemical parameters
    # specific densities; multiply free by d_V to convert to vector if necessary
    d_X = Param(0.2, units=u"g/cm^3", free=(0), label="specific density of food"),
    d_V = Param(0.2, units=u"g/cm^3", free=(0), label="specific density of structure"),
    d_E = Param(0.2, units=u"g/cm^3", free=(0), label="specific density of reserve"),
    d_P = Param(0.2, units=u"g/cm^3", free=(0), label="specific density of faeces"),

    # chemical potentials from Kooy2010 Tab 4.2
    mu_X = Param(525000.0, units=u"J/ mol", free=(0), label="chemical potential of food"),
    mu_V = Param(500000.0, units=u"J/ mol", free=(0), label="chemical potential of structure"),
    mu_E = Param(550000.0, units=u"J/ mol", free=(0), label="chemical potential of reserve"),
    mu_P = Param(480000.0, units=u"J/ mol", free=(0), label="chemical potential of faeces"),

    # chemical potential of minerals
    mu_C = Param(0.0, units=u"J/ mol", free=(0), label="chemical potential of CO2"),
    mu_H = Param(0.0, units=u"J/ mol", free=(0), label="chemical potential of H2O"),
    mu_O = Param(0.0, units=u"J/ mol", free=(0), label="chemical potential of O2"),
    mu_N = Param(0.0, units=u"J/ mol", free=(0), label="chemical potential of N-waste"),

    # chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water),
    # food
    n_CX = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in food"), # C/C = 1 by definition
    n_HX = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in food"),
    n_OX = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in food"),
    n_NX = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in food"),
    # structure
    n_CV = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in structure"), # n_CV = 1 by definition
    n_HV = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in structure"),
    n_OV = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in structure"),
    n_NV = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in structure"),
    # reserve
    n_CE = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in reserve"),   # n_CE = 1 by definition
    n_HE = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in reserve"),
    n_OE = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in reserve"),
    n_NE = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in reserve"),
    # faeces
    n_CP = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in faeces"),    # n_CP = 1 by definition
    n_HP = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in faeces"),
    n_OP = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in faeces"),
    n_NP = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in faeces"),

    # chemical indices for minerals from Kooy2010
    # CO2
    n_CC = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in CO2"),
    n_HC = Param(0.0, units=nothing, free=(0), label="chem. index of hydrogen in CO2"),
    n_OC = Param(2.0, units=nothing, free=(0), label="chem. index of oxygen in CO2"),
    n_NC = Param(0.0, units=nothing, free=(0), label="chem. index of nitrogen in CO2"),
    # H2O
    n_CH = Param(0.0, units=nothing, free=(0), label="chem. index of carbon in H2O"),
    n_HH = Param(2.0, units=nothing, free=(0), label="chem. index of hydrogen in H2O"),
    n_OH = Param(1.0, units=nothing, free=(0), label="chem. index of oxygen in H2O"),
    n_NH = Param(0.0, units=nothing, free=(0), label="chem. index of nitrogen in H2O"),
    # O2
    n_CO = Param(0.0, units=nothing, free=(0), label="chem. index of carbon in O2"),
    n_HO = Param(0.0, units=nothing, free=(0), label="chem. index of hydrogen in O2"),
    n_OO = Param(2.0, units=nothing, free=(0), label="chem. index of oxygen in O2"),
    n_NO = Param(0.0, units=nothing, free=(0), label="chem. index of nitrogen in O2"),
    # N-waste; multiply free by par to convert to vector if necessary
    n_CN = Param(0.0, units=nothing, free=(0), label="chem. index of carbon in N-waste"),   # n_CN = 0 or 1 by definition
    n_HN = Param(3.0, units=nothing, free=(0), label="chem. index of hydrogen in N-waste"),
    n_ON = Param(0.0, units=nothing, free=(0), label="chem. index of oxygen in N-waste"),
    n_NN = Param(1.0, units=nothing, free=(0), label="chem. index of nitrogen in N-waste"),
)

metapar = (; model = "abj")

(; par, metapar)
