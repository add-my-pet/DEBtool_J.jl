phylum = "Arthropoda"
class = "Insecta" 

par = (;
    defaultchemistry(phylum, class)...,
    T_ref = Const(293.15; units=u"K", label = "Reference temperature"), 
    # core primary 
    T_A = Const(12545.34; units=u"K", label = "Arrhenius temperature"), 
    z = Param(4.671; units=nothing, label = "zoom factor"), 
    F_m = Const(6.5; units=u"l/d/cm^2", label = "{F_m}, max spec searching rate"), 
    kap_X = Const(0.8; units=nothing, label = "digestion efficiency of food to reserve"), 
    kap_P = Const(0.1; units=nothing, label = "faecation efficiency of food to faeces"), 
    v = Param(0.01051; units=u"cm/d", label = "energy conductance"), 
    kap = Param(0.8756; units=nothing, label = "allocation fraction to soma"), 
    kap_R = Const(0.95; units=nothing, label = "reproduction efficiency"), 
    p_M = Param(17.4; units=u"J/d/cm^3", label = "[p_M], vol-spec somatic maint"), 
    p_T = Const(0; units=u"J/d/cm^2", label = "{p_T}, surf-spec somatic maint"), 
    k_J = Const(0.002; units=u"1/d", label = "maturity maint rate coefficient"), 
    E_G = Param(6523; units=u"J/cm^3", label = "[E_G], spec cost for structure"), 
    E_Hb = Param(1.518; units=u"J", label = "maturity at birth"), 
    E_Hp = Param(163.4; units=u"J", label = "maturity at puberty"), 
    h_a = Param(1.898e-5; units=u"1/d^2", label = "Weibull aging acceleration"), 
    s_G = Const(0.0001; units=nothing, label = "Gompertz stress coefficient"), 
    # other
    T_A0 = Const(10597.34; units=u"K", label = "Arrhenius temperature egg"), 
    T_A5 = Const(13777.3; units=u"K", label = "Arrhenius temperature 5th instar and higher"), 
    T_AH = Const(16000; units=u"K", label = "Arrhenius temperature at upper boundary"), 
    T_AH0 = Const(16000; units=u"K", label = "Arrhenius temperature at upper boundary egg"), 
    T_AH5 = Const(16000; units=u"K", label = "Arrhenius temperature at upper boundary 5th instar and higher"), 
    T_AL = Const(18720; units=u"K", label = "Arrhenius temperature at lower boundary"), 
    T_H = Const(310.06; units=u"K", label = "upper boundary"), 
    T_H0 = Const(311.15; units=u"K", label = "upper boundary egg"), 
    T_H5 = Const(308.15; units=u"K", label = "upper boundary 5th instar and higher"), 
    T_L = Const(261.15; units=u"K", label = "lower boundary"), 
    del_M = Param(0.1744; units=nothing, label = "shape coefficient"), 
    f = Const(1; units=nothing, label = "scaled functional response for 0-var data"), 
    s_1 = Param(1.788; units=nothing, label = "stress at instar 1: L_1^2/ L_b^2"), 
    # s_2 = Param(1.5374; units=nothing, label = "stress at instar 1: L_2^2/ L_1^2"), 
    # s_3 = Param(1.6226; units=nothing, label = "stress at instar 1: L_3^2/ L_2^2"), 
    # s_4 = Param(2.2073; units=nothing, label = "stress at instar 1: L_4^2/ L_3^2"), 
    t_0 = Const(1; units=u"d", label = "time of start development at 20 C"), 
    d_V = Const(0.25; units=u"g/cm^3", label = "specific density of structure"), 
    d_E = Const(0.25; units=u"g/cm^3", label = "specific density of reserve"), 
)

organism = abp_animal(;
    temperatureresponse=ArrheniusResponse(),
)

(; organism, par)
