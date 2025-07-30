pars = (;
    # reference parameter (not to be changed) 
    T_ref = Const(293.15; units=u"K", label = "Reference temperature"), 
    # core primary parameters 
    T_A = Const(8000; units=u"K", label = "Arrhenius temperature"), 
    z = Param(8.465; units=nothing, label = "zoom factor"), 
    F_m = Const(6.5; units=u"l/d.cm^2", label = "{F_m}, max spec searching rate"), 
    kap_X = Const(0.8; units=nothing, label = "digestion efficiency of food to reserve"), 
    kap_P = Const(0.1; units=nothing, label = "faecation efficiency of food to faeces"), 
    v = Param(0.069418; units=u"cm/d", label = "energy conductance"), 
    kap = Param(0.97377; units=nothing, label = "allocation fraction to soma"), 
    kap_R = Const(0.95; units=nothing, label = "reproduction efficiency"), 
    p_M = Param(678.3452; units=u"J/d.cm^3", label = "[p_M], vol-spec somatic maint"), 
    p_T = Const(0; units=u"J/d.cm^2", label = "{p_T}, surf-spec somatic maint"), 
    k_J = Const(0.002; units=u"1/d", label = "maturity maint rate coefficient"), 
    E_G = Param(7832.3383; units=u"J/cm^3", label = "[E_G], spec cost for structure"), 
    E_Hb = Param(4.095e+03; units=u"J", label = "maturity at birth"), 
    E_Hx = Param(2.058e+05; units=u"J", label = "maturity at weaning"), 
    E_Hp = Param(4.440e+06; units=u"J", label = "maturity at puberty"), 
    h_a = Param(2.547e-12; units=u"1/d^2", label = "Weibull aging acceleration"), 
    s_G = Const(0.01; units=nothing, label = "Gompertz stress coefficient"), 
    t_0 = Param(36.0855; units=u"d", label = "time at start development"), 
    # other parameters 
    del_M = Param(0.11173; units=nothing, label = "shape coefficient"), 
    f = Const(1; units=nothing, label = "scaled functional response for 0-var data"), 
    f_tW = Const(1; units=nothing, label = "scaled functional response for tW data"), 
    t_0W = Param(-4.0959; units=u"d", label = "time at birth in tL and tW data"), 
)

organism = stx_organism(;
    temperatureresponse = strip(ArrheniusResponse(; par[(:T_ref, :T_A)]...)),
)

(; organism, par)
