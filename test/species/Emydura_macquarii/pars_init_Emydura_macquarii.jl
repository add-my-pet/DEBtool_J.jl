
par = (;
    # reference parameter (not to be changed),
    T_ref = (20.0 + 273.15)u"K", # Param(20.0 + 273.15, units=u"K", label="Reference Temperature"),

    # core primary parameters
    z = Param(13.2002, units=nothing, label="zoom factor"),
    z_m = Param(12.8559, units=u"cm", label="zoom factor for male"),
    v = Param(0.060464, units=u"cm/d", label="energy conductance"),
    κ = Param(0.7362, units=nothing, label="allocation fraction to soma"),
    p_M = Param(16.4025, units=u"J/d/cm^3", label="[p_M], vol-spec somatic maint"),
    k_J = Param(0.00060219, units=u"1/d", label="maturity maint rate coefficient"),
    E_G = Param(7857.8605, units=u"J/cm^3", label="[E_G], spec cost for structure"),
    E_Hb = Param(1.366e+04, units=u"J", label="maturity at birth"),
    E_Hp = Param(1.168e+07, units=u"J", label="maturity at puberty"),
    E_Hpm = Param(4.711e+06, units=u"J", label="maturity at puberty for male"),
    h_a = Param(1.211e-09, units=u"1/d^2", label="Weibull aging acceleration"),
    del_M = Param(0.61719, units=nothing, label="shape coefficient"),

    # Not estimated
    p_T = Const(0.0, units=u"J/d/cm^2", label="{p_T}, surf-spec somatic maint"),
    T_A = Const(8000.0, units=u"K", label="Arrhenius temperature"),
    κ_R = Const(0.95, units=nothing, label="reproduction efficiency"),
    f = Const(1.0, units=nothing, label="scaled functional response for 0-var data"),
    s_G = Const(0.0001, units=nothing, label="Gompertz stress coefficient"),

    # Not used at all
    # F_m = Const(6.5, units=u"l/d/cm^2", label="{F_m}, max spec searching rate"),
    # κ_X = Const(0.8, units=nothing, label="digestion efficiency of food to reserve"),
    # κ_P = Const(0.1, units=nothing, label="faecation efficiency of food to faeces"),

    # TODO these should be objects in the model
    DEFAULT_CHEMICAL_PARAMETERS...,
    DEFAULT_CHEMICAL_POTENTIALS...,
    DEFAULT_CHEMICAL_INDICES_FOR_WATER_ORGANICS...,
    DEFAULT_CHEMICAL_POTENTIAL_OF_MINERALS...,
    DEFAULT_CHEMICAL_INDICES_FOR_WATER_ORGANICS...,
    DEFAULT_CHEMICAL_INDICES_FOR_MINERALS...,

    # other parameters
    #T_AL = Const(50000.0, units=u"K", label="low temp boundary"),
    #T_AH = Const(50000.0, units=u"K", label="high temp boundary"),
    #T_L = Const(0 + 273.15, units=u"K", label="low Arrhenius temperature"),
    #T_H = Const(54.5 + 273.15, units=u"K", label="high Arrhenius temperature"),
)

organism = std_organism(;
    temperatureresponse = strip(ArrheniusResponse(; par[(:T_ref, :T_A)]...)),
    life = Life(
        Embryo() => Birth(),
        Juvenile() => Dimorphic(Female(Puberty()), Male(Puberty())),
        Adult() => Dimorphic(Female(Ultimate()), Male(Ultimate())),
    ),
)

(; organism, par)
