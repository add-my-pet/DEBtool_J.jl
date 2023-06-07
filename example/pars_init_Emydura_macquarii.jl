Base.@kwdef struct Par{T,Z,L,K,V,PV,PS,R,EV,E,RR,S,D,DM,F,EM,N}
    # reference parameter (not to be changed) 
    T_ref::T = Param(20.0 + 273.15, units=u"K", free=(0), label="Reference Temperature")

    # core primary parameters 
    z::N = Param(13.2002, units=nothing, free=(1), label="zoom factor")
    F_m::L = Param(6.5, units=u"l/d/cm^2", free=(0), label="{F_m}, max spec searching rate")
    kap_X::K = Param(0.8, units=nothing, free=(0), label="digestion efficiency of food to reserve")
    kap_P::K = Param(0.1, units=nothing, free=(0), label="faecation efficiency of food to faeces")
    v::V = Param(0.060464, units=u"cm/d", free=(1), label="energy conductance")
    kap::K = Param(0.7362, units=nothing, free=(1), label="allocation fraction to soma")
    kap_R::K = Param(0.95, units=nothing, free=(0), label="reproduction efficiency")
    p_M::PV = Param(16.4025, units=u"J/d/cm^3", free=(1), label="[p_M], vol-spec somatic maint")
    p_T::PS = Param(0.0, units=u"J/d/cm^2", free=(0), label="{p_T}, surf-spec somatic maint")
    k_J::R = Param(0.00060219, units=u"1/d", free=(1), label="maturity maint rate coefficient")
    E_G::EV = Param(7857.8605, units=u"J/cm^3", free=(1), label="[E_G], spec cost for structure")
    E_Hb::E = Param(1.366e+04, units=u"J", free=(1), label="maturity at birth")
    E_Hp::E = Param(1.168e+07, units=u"J", free=(1), label="maturity at puberty")
    h_a::RR = Param(1.211e-09, units=u"1/d^2", free=(1), label="Weibull aging acceleration")
    s_G::S = Param(0.0001, units=nothing, free=(0), label="Gompertz stress coefficient")

    # other parameters 
    E_Hpm::E = Param(4.711e+06, units=u"J", free=(1), label="maturity at puberty for male")
    T_A::T = Param(8000.0, units=u"K", free=(0), label="Arrhenius temperature")
    #T_AL::T = Param(50000.0, units=u"K", free=(0), label="low temp boundary")
    #T_AH::T = Param(50000.0, units=u"K", free=(0), label="high temp boundary")
    #T_L::T = Param(0 + 273.15, units=u"K", free=(0), label="low Arrhenius temperature")
    #T_H::T = Param(54.5 + 273.15, units=u"K", free=(0), label="high Arrhenius temperature")
    del_M::DM = Param(0.61719, units=nothing, free=(1), label="shape coefficient")
    f::F = Param(1.0, units=nothing, free=(0), label="scaled functional response for 0-var data")
    z_m::Z = Param(13.2002, units=u"cm", free=(1), label="zoom factor for male")

    # chemical parameters
    # specific densities; multiply free by d_V to convert to vector if necessary
    d_X::D = Param(0.3, units=u"g/cm^3", free=(0), label="specific density of food")
    d_V::D = Param(0.3, units=u"g/cm^3", free=(0), label="specific density of structure")
    d_E::D = Param(0.3, units=u"g/cm^3", free=(0), label="specific density of reserve")
    d_P::D = Param(0.3, units=u"g/cm^3", free=(0), label="specific density of faeces")

    # chemical potentials from Kooy2010 Tab 4.2
    mu_X::EM = Param(525000.0, units=u"J/ mol", free=(0), label="chemical potential of food")
    mu_V::EM = Param(500000.0, units=u"J/ mol", free=(0), label="chemical potential of structure")
    mu_E::EM = Param(550000.0, units=u"J/ mol", free=(0), label="chemical potential of reserve")
    mu_P::EM = Param(480000.0, units=u"J/ mol", free=(0), label="chemical potential of faeces")

    # chemical potential of minerals
    mu_C::EM = Param(0.0, units=u"J/ mol", free=(0), label="chemical potential of CO2")
    mu_H::EM = Param(0.0, units=u"J/ mol", free=(0), label="chemical potential of H2O")
    mu_O::EM = Param(0.0, units=u"J/ mol", free=(0), label="chemical potential of O2")
    mu_N::EM = Param(4880.0, units=u"J/ mol", free=(0), label="chemical potential of N-waste")

    # chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
    # food
    n_CX::N = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in food") # C/C = 1 by definition
    n_HX::N = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in food")
    n_OX::N = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in food")
    n_NX::N = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in food")
    # structure
    n_CV::N = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in structure") # n_CV = 1 by definition
    n_HV::N = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in structure")
    n_OV::N = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in structure")
    n_NV::N = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in structure")
    # reserve
    n_CE::N = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in reserve")   # n_CE = 1 by definition
    n_HE::N = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in reserve")
    n_OE::N = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in reserve")
    n_NE::N = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in reserve")
    # faeces
    n_CP::N = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in faeces")    # n_CP = 1 by definition
    n_HP::N = Param(1.8, units=nothing, free=(0), label="chem. index of hydrogen in faeces")
    n_OP::N = Param(0.5, units=nothing, free=(0), label="chem. index of oxygen in faeces")
    n_NP::N = Param(0.15, units=nothing, free=(0), label="chem. index of nitrogen in faeces")

    # chemical indices for minerals from Kooy2010 
    # CO2 
    n_CC::N = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in CO2")
    n_HC::N = Param(0.0, units=nothing, free=(0), label="chem. index of hydrogen in CO2")
    n_OC::N = Param(2.0, units=nothing, free=(0), label="chem. index of oxygen in CO2")
    n_NC::N = Param(0.0, units=nothing, free=(0), label="chem. index of nitrogen in CO2")
    # H2O
    n_CH::N = Param(0.0, units=nothing, free=(0), label="chem. index of carbon in H2O")
    n_HH::N = Param(2.0, units=nothing, free=(0), label="chem. index of hydrogen in H2O")
    n_OH::N = Param(1.0, units=nothing, free=(0), label="chem. index of oxygen in H2O")
    n_NH::N = Param(0.0, units=nothing, free=(0), label="chem. index of nitrogen in H2O")
    # O2
    n_CO::N = Param(0.0, units=nothing, free=(0), label="chem. index of carbon in O2")
    n_HO::N = Param(0.0, units=nothing, free=(0), label="chem. index of hydrogen in O2")
    n_OO::N = Param(2.0, units=nothing, free=(0), label="chem. index of oxygen in O2")
    n_NO::N = Param(0.0, units=nothing, free=(0), label="chem. index of nitrogen in O2")
    # N-waste; multiply free by par to convert to vector if necessary
    n_CN::N = Param(1.0, units=nothing, free=(0), label="chem. index of carbon in N-waste")   # n_CN = 0 or 1 by definition
    n_HN::N = Param(0.8, units=nothing, free=(0), label="chem. index of hydrogen in N-waste")
    n_ON::N = Param(0.6, units=nothing, free=(0), label="chem. index of oxygen in N-waste")
    n_NN::N = Param(0.8, units=nothing, free=(0), label="chem. index of nitrogen in N-waste")
end
@with_kw struct metaPar_struct # does this need to be mutable?
    model = "std"
end
metaPar = metaPar_struct()