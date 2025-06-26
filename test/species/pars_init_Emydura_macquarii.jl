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
    DEFAULT_CHEMICAL_PARAMETERS...,
    DEFAULT_CHEMICAL_POTENTIALS...,
    DEFAULT_CHEMICAL_INDICES_FOR_WATER_ORGANICS...,
    DEFAULT_CHEMICAL_POTENTIAL_OF_MINERALS...,
    DEFAULT_CHEMICAL_INDICES_FOR_WATER_ORGANICS...,
    DEFAULT_CHEMICAL_INDICES_FOR_MINERALS...,

)
