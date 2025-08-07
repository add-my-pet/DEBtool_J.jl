phylum = "Chordata"
class = "Mammalia" 

par = (;
    defaultchemistry(phylum, class)...,
    z = Param(7.7474;           units = nothing,     label = "zoom factor"), 
    F_m = Const(6.5;            units = u"l/d/cm^2", label = "{F_m}, max spec searching rate"), 
    κ_X = Const(0.8;            units = nothing,     label = "digestion efficiency of food to reserve"), 
    κ_P = Const(0.1;            units = nothing,     label = "faecation efficiency of food to faeces"), 
    v = Param(0.044457;         units = u"cm/d",     label = "energy conductance"), 
    κ = Param(0.43063;          units = nothing,     label = "allocation fraction to soma"), 
    κ_R = Const(0.95;           units = nothing,     label = "reproduction efficiency"), 
    p_M = Param(141.5511;       units = u"J/d/cm^3", label = "[p_M], vol-spec somatic maint"), 
    p_T = Const(0.0;            units = u"J/d/cm^2", label = "{p_T}, surf-spec somatic maint"), 
    k_J = Const(0.002;          units = u"1/d",      label = "maturity maint rate coefficient"), 
    E_G = Param(7843.1711;      units = u"J/cm^3",   label = "[E_G], spec cost for structure"), 
    E_Hb = Param(71724.1417;    units = u"J",        label = "maturity at birth"), 
    E_Hx = Param(511548.5682;   units = u"J",        label = "maturity at weaning"), 
    E_Hp = Param(41124175.223;  units = u"J",        label = "maturity at puberty"), 
    h_a = Param(8.856e-13;      units = u"1/d^2",    label = "Weibull aging acceleration"), 
    s_G = Const(0.1;            units = nothing,     label = "Gompertz stress coefficient"), 
    s_F = Const(1e10;           units = nothing,     label = "Stress coefficient of foetal development"), 
    t_0 = Param(8.1682;         units = u"d",        label = "time at start development"), 
    ## other parameters 
    T_A = Const(8000.0;         units = u"K",        label = "Arrhenius temperature"), 
    T_ref = Const(293.15;       units = u"K",        label = "Reference temperature"), 
    del_M = Param(0.18433;      units = nothing,     label = "shape coefficient"), 
    f = Const(1.0;              units = nothing,     label = "scaled functional response for 0-var data"), 
    f_tW = Const(1.0;           units = nothing,     label = "scaled functional response for tW data"), 
)

organism = stx_animal(;
    temperatureresponse = strip(ArrheniusResponse(; par[(:T_ref, :T_A)]...)),
)

(; organism, par)
