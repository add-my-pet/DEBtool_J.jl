phylum="Chordata"
class="Mammalia" 

par = (;
    defaultchemistry(phylum, class)...,
    T_ref=Const(293.15, units=u"K", label="Reference temperature"), 

    # Core primary parameters 
    p_Am = Param(5467.0, units=u"J/d*cm^2", label="Surface-specific maximum assimilation rate for females"),
    E_Hx=Param(2e5, units=u"J", label="maturity at weaning for females"), 
    E_Hp=Param(2e6, units=u"J", label="maturity at puberty for females"), 
    kap_X=Param(0.1354, units=nothing, label="digestion efficiency of food to reserve"), 
    v=Param(0.02057, units=u"cm/d", label="energy conductance"), 
    kap=Param(0.9716, units=nothing, label="allocation fraction to soma"), 
    p_M=Param(100.68, units=u"J/d*cm^3", label="[p_M], vol-spec somatic maint"), 
    E_G=Param(7829.0, units=u"J/cm^3", label="[E_G], spec cost for structure"), 
    E_Hb=Param(2e4.0, units=u"J", label="maturity at birth"), 
    h_a=Param(5e-10, units=u"1/d^2", label="Weibull aging acceleration"), 
    t_0=Param(80.0, units=u"d", label="time at start development"), 
    del_M=Param(0.154, units=nothing, label="shape coefficent"),
    kap_P=Param(0.2649, units=nothing, label="faecation efficiency of food to faeces"), 
    xi_C=Param(0.1354, units=nothing, label="contribution of methane subtransformation to assimilation"),
    rho_xi=Const(0.05, units=nothing, label="reduction in xi_C due to the effect of the seaweed additive"),
    lambda=Const(2.0, units=nothing, label="slope parameter of sigmoid in transition between effect/no effect of the seaweed additive"),
    male = (;
        p_Am=Param(5467.0, units=u"J/d*cm^2", label="Surface-specific maximum assimilation rate"),
        E_Hx=Param(2e5, units=u"J", label="maturity at weaning"), 
        E_Hp=Param(2e6, units=u"J", label="maturity at puberty"), 
    ),

    # Standard parameters
    T_A=Const(8000.0, units=u"K", label="Arrhenius temperature"), 
    z=Const(13.0, units=nothing, label="zoom factor"), 
    F_m=Const(6.5, units=u"l/d*cm^2", label="{F_m}, max spec searching rate"), 
    kap_R=Const(0.95, units=nothing, label="reproduction efficiency"), 
    p_T=Const(0.0, units=u"J/d*cm^2", label="{p_T}, surf-spec somatic maint"), 
    k_J=Const(0.002, units=u"1/d", label="maturity maint rate coefficient"), 
    s_G=Const(0.1, units=nothing, label="Gompertz stress coefficient"), 

    # other parameters 
    f=Const(1.0, units=nothing, label="scaled functional response for 0-var data"), 
    f_milk=Param(1.0, units=nothing, label="scaled functional response between birth and weaning"), 

    # Methane chemical parameters
    mu_M=Const(816000.0, units=u"J/mol", label="chemical potential of methane"),
    n_CM=Const(1.0, units=nothing, label="chem. index of carbon in methane"),
    n_HM=Const(4.0, units=nothing, label="chem. index of hydrogen in methane"),
    n_OM=Const(0.0, units=nothing, label="chem. index of oxygen in methane"),
    n_NM=Const(0.0, units=nothing, label="chem. index of nitrogen in methane"),

    # Diet composition 
    n_HX=Const(1.85, units=nothing, label="chem. index of hydrogen in food"),
    n_OX=Const(0.752, units=nothing, label="chem. index of oxygen in food"),
    n_NX=Const(0.044, units=nothing, label="chem. index of nitrogen in food"),
    mu_X=Const(525000.0, units="J/ mol", label="chemical potential of food"), 

# TODO is this for
# dietCompositions=struct();
# dietCompositions.CTRL_2022=struct('mu_X', 518844, 'n_HX', 1.869, 'n_OX', 0.732, 'n_NX', 0.040);
# dietCompositions.TMR_2022=struct('mu_X', 510716, 'n_HX', 1.844, 'n_OX', 0.752, 'n_NX', 0.050);
# dietCompositions.TMR_2023=struct('mu_X', 509550, 'n_HX', 1.839, 'n_OX', 0.755, 'n_NX', 0.047);
# dietCompositions.OIL_2023=struct('mu_X', 513071, 'n_HX', 1.852, 'n_OX', 0.746, 'n_NX', 0.047);
# dietCompositions.Herd19_RFI=struct('mu_X', 529743, 'n_HX', 1.880, 'n_OX', 0.793, 'n_NX', 0.047);
# dietCompositions.Herd19_HP=struct('mu_X', 546064, 'n_HX', 1.841, 'n_OX', 0.752, 'n_NX', 0.034);
# dietCompositions.Bunt89_LP=struct('mu_X', 532521, 'n_HX', 1.825, 'n_OX', 0.764, 'n_NX', 0.029);
# dietCompositions.Bunt89_HP=struct('mu_X', 543457, 'n_HX', 1.852, 'n_OX', 0.725, 'n_NX', 0.058);

# # Set compositions in par struct
# dietNames=fieldnames(dietCompositions);
# for d=1:numel(dietNames)
#     diet=dietNames{d};
#     dietParamNames=fieldnames(dietCompositions.(diet));
#     for p=1:numel(dietParamNames)
#         paramName=dietParamNames{p};
#         dietParam=[paramName '_' diet];
#             (dietParam)=dietCompositions.(diet).(paramName); 
#         free.(dietParam)=0; 
#         units.(dietParam)=units.(paramName);
#         label.(dietParam)=[label.(paramName) 'for diet ' diet];
#     end
# end


    ## Feces and N-waste composition
    # Fajobi et al. 2022
    mu_P=Const(390318.0, units=u"J/mol", label="chemical potential of faeces"), 
    n_HP=Const(2.192, units=nothing, label="chem. index of hydrogen in faeces"),
    n_OP=Const(0.819, units=nothing, label="chem. index of oxygen in faeces"),
    n_NP=Const(0.030, units=nothing, label="chem. index of nitrogen in faeces"),  

    # Derived from Bristow et al. 1992
    mu_N=Const(518181.0, units=u"J/mol", label="chemical potential of N-waste"), 
    n_HN=Const(2.216, units=nothing, label="chem. index of hydrogen in N-waste"),
    n_ON=Const(0.594, units=nothing, label="chem. index of oxygen in N-waste"),
    n_NN=Const(0.897, units=nothing, label="chem. index of nitrogen in N-waste"),

    # Estimate composition of reserve and structure
    n_NE=Param(0.10, units=nothing, label="chem. index of nitrogen in reserve"),
    n_NV=Param(0.10, units=nothing, label="chem. index of nitrogen in structure"),
    # mu_E=Param(550000, units=u"J/mol"), label="chemical potential of reserve"), 
    # mu_V=Param(500000, units=u"J/mol"), label="chemical potential of structure"), 
)

organism=stx_animal(;
    temperatureresponse=ArrheniusResponse(),
)

(; organism, par)
