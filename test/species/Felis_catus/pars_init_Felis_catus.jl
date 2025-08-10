phylum = "Chordata"
class = "Mammalia" 

par = (;
    defaultchemistry(phylum, class)...,
    # reference parameter (not to be changed) 
    T_ref=Const(293.15; units=u"K", label="Reference temperature"), 
    # core primary parameters 
    T_A=Const(8000; units=u"K", label="Arrhenius temperature"), 
    z=Param(8.8041; units=nothing, label="zoom factor for females"), 
    F_m=Const(6.5; units=u"l/d/cm^2", label="{F_m}, max spec searching rate"), 
    κ_X=Const(0.8; units=nothing, label="digestion efficiency of food to reserve"), 
    κ_P=Const(0.1; units=nothing, label="faecation efficiency of food to faeces"), 
    v=Param(0.066988; units=u"cm/d", label="energy conductance"), 
    κ=Param(0.95393; units=nothing, label="allocation fraction to soma"), 
    κ_R=Const(0.95; units=nothing, label="reproduction efficiency"), 
    p_M=Param(205.5282; units=u"J/d/cm^3", label="[p_M], vol-spec somatic maint"), 
    p_T=Const(0; units=u"J/d/cm^2", label="{p_T}, surf-spec somatic maint"), 
    k_J=Const(0.002; units=u"1/d", label="maturity maint rate coefficient"), 
    E_G=Param(7798.8203; units=u"J/cm^3", label="[E_G], spec cost for structure"), 
    E_Hb=Param(1.324e+04; units=u"J", label="maturity at birth"), 
    E_Hx=Param(2.300e+05; units=u"J", label="maturity at weaning"), 
    E_Hp=Param(2.287e+06; units=u"J", label="maturity at puberty"), 
    h_a=Param(1.330e-27; units=u"1/d^2", label="Weibull aging acceleration"), 
    s_G=Const(0.1; units=nothing, label="Gompertz stress coefficient"), 
    s_F=Const(1e10; units=nothing, label="Stress coefficient of foetal development"), 
    t_0=Param(39.3624; units=u"d", label="time at start development"), 
    # other parameters 
    E_Hpm=Param(5.798e+08; units=u"J", label="maturity at puberty for males"), 
    f=Const(1; units=nothing, label="scaled functional response for 0-var data"), 
    f_tW=Const(1; units=nothing, label="scaled functional response for tW data"), 
    z_m=Param(9.4561; units=nothing, label="zoom factor for males"), 
)

organism=stx_animal(;
    temperatureresponse=ArrheniusResponse()),
    # lifecycle=LifeCycle(
    #     # TODO rethink how we write dimorphism
    #     Foetus() => Dimorphic(Female(Birth()), Male(Birth())),
    #     Baby() => Dimorphic(Female(Weaning()), Male(Weaning())),
    #     Juvenile() => Dimorphic(Female(Puberty()), Male(Puberty())),
    #     Adult() => Dimorphic(Female(Ultimate()), Male(Ultimate())),
    # ),
)

(; organism, par)
