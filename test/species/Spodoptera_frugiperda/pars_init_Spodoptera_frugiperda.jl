phylum = "Arthropoda"
class = "Insecta"

par = (;
    defaultchemistry(phylum, class)...,
    # reference     
    T_ref = Const(293.15; units=u"K", label = "Reference temperature"), 
    # core primary    
    T_A = Param(8355.6733; units=u"K", label = "Arrhenius temperature"), 
    z = Param(0.89985; units=nothing, label = "zoom factor"), 
    F_m = Const(6.5; units=u"l/d/cm^2", label = "{F_m}, max spec searching rate"), 
    kap_X = Const(0.8; units=nothing, label = "digestion efficiency of food to reserve"), 
    kap_P = Const(0.1; units=nothing, label = "faecation efficiency of food to faeces"), 
    v = Param(0.01029; units=u"cm/d", label = "energy conductance"), 
    kap = Param(0.78329; units=nothing, label = "allocation fraction to soma"), 
    kap_R = Const(0.95; units=nothing, label = "reproduction efficiency"), 
    kap_V = Const(0.01; units=nothing, label = "conversion efficient E -> V -> E"), 
    p_M = Param(34.8023; units=u"J/d/cm^3", label = "[p_M], vol-spec somatic maint"), 
    p_T = Const(0; units=u"J/d/cm^2", label = "{p_T}, surf-spec somatic maint"), 
    k_J = Const(0.002; units=u"1/d", label = "maturity maint rate coefficient"), 
    E_G = Const(4400; units=u"J/cm^3", label = "[E_G], spec cost for structure"), 
    E_Hb = Param(1.926e-03; units=u"J", label = "maturity at birth"), 
    s_j = Const(0.9999; units=nothing, label = "reprod buffer/structure at pupation as fraction of max"), 
    E_He = Param(4.518e-01; units=u"J", label = "maturity at emergence"), 
    h_a = Param(3.270e-02; units=u"1/d^2", label = "Weibull aging acceleration"), 
    s_G = Const(0.0001; units=nothing, label = "Gompertz stress coefficient"), 
    # other
    T_A1 = Const(6668; units=u"K", label = "Arrhenius temperature for 1st instar"), 
    T_AH = Const(300000; units=u"K", label = "Arrhenius temperature at lower boundary temperature"), 
    T_AL = Const(17800; units=u"K", label = "Arrhenius temperature at lower boundary temperature"), 
    T_As = Const(12610; units=u"K", label = "Arrhenius temperature for larval mortality"), 
    T_H = Const(304.6; units=u"K", label = "upper boundary temperature"), 
    T_L = Const(289.4; units=u"K", label = "lower boundary temperature"), 
    del_M = Param(0.37458; units=nothing, label = "shape coefficient for head capsule of larva"), 
    f = Const(1; units=nothing, label = "scaled functional response for 0-var data"), 
    h_b = Param(0.026977; units=u"1/d", label = "background hazard during larval stage"), 
    s_1 = Param(3.1494; units=nothing, label = "stress at instar 1: L_1^2/ L_b^2"), 
    s_2 = Param(2.2664; units=nothing, label = "stress at instar 2: L_2^2/ L_1^2"), 
    s_3 = Param(2.2905; units=nothing, label = "stress at instar 3: L_3^2/ L_2^2"), 
    s_4 = Param(2.6563; units=nothing, label = "stress at instar 4: L_4^2/ L_3^2"), 
    s_5 = Param(2.891; units=nothing, label = "stress at instar 5: L_5^2/ L_4^2"), 
)

organism = hex_animal(5;
    # TODO add the parameters to temp response somewhere else?
    temperatureresponse=stripparams(LowAndHighTorporResponse(; par[(:T_ref, :T_A, :T_L, :T_AL, :T_H, :T_AH)]...))
)

(; organism, par)
