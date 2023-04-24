@with_kw mutable struct free_struct{F}
    # reference parameter (not to be changed) 
    T_ref::F = 0.0

    # core primary parameters 
    z::F = 1.0
    F_m::F = 0.0
    kap_X::F = 0.0
    kap_P::F = 0.0
    v::F = 1.0
    kap::F = 1.0
    kap_R::F = 0.0
    p_M::F = 1.0
    p_T::F = 0.0
    k_J::F = 1.0
    E_G::F = 1.0
    E_Hb::F = 1.0
    E_Hp::F = 1.0
    h_a::F = 1.0
    s_G::F = 0.0

    # other parameters 
    T_A::F = 0.0
    #T_AL::F = 0.0
    #T_AH::F = 0.0
    #T_L::F = 0.0
    #T_H::F = 0.0
    E_Hpm::F = 1.0
    del_M::F = 1.0
    f::F = 0.0
    z_m::F = 1.0

    # chemical parameters
    # specific densities; multiply free by d_V to convert to vector if necessary
    d_X::F = 0.0
    d_V::F = 0.0
    d_E::F = 0.0
    d_P::F = 0.0

    # chemical potentials from Kooy2010 Tab 4.2
    mu_X::F = 0.0
    mu_V::F = 0.0
    mu_E::F = 0.0
    mu_P::F = 0.0

    # chemical potential of minerals
    mu_C::F = 0.0
    mu_H::F = 0.0
    mu_O::F = 0.0
    mu_N::F = 0.0

    # chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
    # food
    n_CX::F = 0.0 # C/C = 1 by definition
    n_HX::F = 0.0
    n_OX::F = 0.0
    n_NX::F = 0.0
    # structure
    n_CV::F = 0.0 # n_CV = 1 by definition
    n_HV::F = 0.0
    n_OV::F = 0.0
    n_NV::F = 0.0
    # reserve
    n_CE::F = 0.0 # n_CE = 1 by definition
    n_HE::F = 0.0
    n_OE::F = 0.0
    n_NE::F = 0.0
    # faeces
    n_CP::F = 0.0 # n_CP = 1 by definition
    n_HP::F = 0.0
    n_OP::F = 0.0
    n_NP::F = 0.0

    # chemical indices for minerals from Kooy2010 
    # CO2 
    n_CC::F = 0.0
    n_HC::F = 0.0
    n_OC::F = 0.0
    n_NC::F = 0.0
    # H2O
    n_CH::F = 0.0
    n_HH::F = 0.0
    n_OH::F = 0.0
    n_NH::F = 0.0
    # O2
    n_CO::F = 0.0
    n_HO::F = 0.0
    n_OO::F = 0.0
    n_NO::F = 0.0
    # N-waste; multiply free by par to convert to vector if necessary
    n_CN::F = 0.0
    n_HN::F = 0.0
    n_ON::F = 0.0
    n_NN::F = 0.0
end
@with_kw mutable struct metaPar_struct
    model = "std"
end
metaPar = metaPar_struct()

@with_kw mutable struct par_struct{T,Z,L,K,V,PV,PS,R,EV,E,RR,S,DM,F,D,EM,N}
    # reference parameter (not to be changed) 
    T_ref::T = (20.0 + 273.15)u"K"

    # core primary parameters 
    z::N = 13.2002
    F_m::L = 6.5u"l/d/cm^2"
    kap_X::K = 0.8
    kap_P::K = 0.1
    v::V = 0.060464u"cm/d"
    kap::K = 0.7362
    kap_R::K = 0.95
    p_M::PV = 16.4025u"J/d/cm^3"
    p_T::PS = 0.0u"J/d/cm^2"
    k_J::R = 0.00060219u"1/d"
    E_G::EV = 7857.8605u"J/cm^3"
    E_Hb::E = 1.366e+04u"J"
    E_Hp::E = 1.168e+07u"J"
    h_a::RR = 1.211e-09u"1/d^2"
    s_G::S = 0.0001

    # other parameters 
    T_A::T = 8000.0u"K"
    #T_AL::T = 50000.0u"K"
    #T_AH::T = 50000.0u"K"
    #T_L::T = (0 + 273.15)u"K"
    #T_H::T = (54.5 + 273.15)u"K"
    E_Hpm::E = 4.711e+06u"J"
    del_M::DM = 0.61719
    f::F = 1.0
    z_m::Z = 12.8559u"cm"

    # chemical parameters
    # specific densities; multiply free by d_V to convert to vector if necessary
    d_X::D = 0.3u"g/cm^3"
    d_V::D = 0.3u"g/cm^3"
    d_E::D = 0.3u"g/cm^3"
    d_P::D = 0.3u"g/cm^3"

    # chemical potentials from Kooy2010 Tab 4.2
    mu_X::EM = 525000.0u"J/ mol"
    mu_V::EM = 500000.0u"J/ mol"
    mu_E::EM = 550000.0u"J/ mol"
    mu_P::EM = 480000.0u"J/ mol"

    # chemical potential of minerals
    mu_C::EM = 0.0u"J/ mol"
    mu_H::EM = 0.0u"J/ mol"
    mu_O::EM = 0.0u"J/ mol"
    mu_N::EM = 4880.0u"J/ mol"

    # chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
    # food
    n_CX::N = 1.0 # C/C = 1 by definition
    n_HX::N = 1.8
    n_OX::N = 0.5
    n_NX::N = 0.15
    # structure
    n_CV::N = 1.0 # n_CV = 1 by definition
    n_HV::N = 1.8
    n_OV::N = 0.5
    n_NV::N = 0.15
    # reserve
    n_CE::N = 1.0 # n_CE = 1 by definition
    n_HE::N = 1.8
    n_OE::N = 0.5
    n_NE::N = 0.15
    # faeces
    n_CP::N = 1.0 # n_CP = 1 by definition
    n_HP::N = 1.8
    n_OP::N = 0.5
    n_NP::N = 0.15

    # chemical indices for minerals from Kooy2010 
    # CO2 
    n_CC::N = 1.0
    n_HC::N = 0.0
    n_OC::N = 2.0
    n_NC::N = 0.0
    # H2O
    n_CH::N = 0.0
    n_HH::N = 2.0
    n_OH::N = 1.0
    n_NH::N = 0.0
    # O2
    n_CO::N = 0.0
    n_HO::N = 0.0
    n_OO::N = 2.0
    n_NO::N = 0.0
    # N-waste; multiply free by par to convert to vector if necessary
    n_CN::N = 1.0
    n_HN::N = 0.8
    n_ON::N = 0.6
    n_NN::N = 0.8
    
    # vector indicating whether parameters are free
    free::free_struct = free_struct()
end

@with_kw mutable struct parunits_struct{F}
    # reference parameter (not to be changed) 
    T_ref::F = "K"

    # core primary parameters 
    z::F = "cm"
    F_m::F = "l/d/cm^2"
    kap_X::F = "-"
    kap_P::F = "-"
    v::F = "cm/d"
    kap::F = "-"
    kap_R::F = "-"
    p_M::F = "J/d/cm^3"
    p_T::F = "J/d/cm^2"
    k_J::F = "1/d"
    E_G::F = "J/cm^3"
    E_Hb::F = "J"
    E_Hp::F = "J"
    h_a::F = "1/d^2"
    s_G::F = "-"

    # other parameters 
    T_A::F = "K"
    #T_AL::F = "K"
    #T_AH::F = "K"
    #T_L::F = "K"
    #T_H::F = "K"
    E_Hpm::F = "J"
    del_M::F = "-"
    f::F = "-"
    z_m::F = "cm"

    # chemical parameters
    # specific densities; multiply free by d_V to convert to vector if necessary
    d_X::F = "g/cm^3"
    d_V::F = "g/cm^3"
    d_E::F = "g/cm^3"
    d_P::F = "g/cm^3"

    # chemical potentials from Kooy2010 Tab 4.2
    mu_X::F = "J/ mol"
    mu_V::F = "J/ mol"
    mu_E::F = "J/ mol"
    mu_P::F = "J/ mol"

    # chemical potential of minerals
    mu_C::F = "J/ mol"
    mu_H::F = "J/ mol"
    mu_O::F = "J/ mol"
    mu_N::F = "J/ mol"

    # chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
    # food
    n_CX::F = "-" # C/C = 1 by definition
    n_HX::F = "-"
    n_OX::F = "-"
    n_NX::F = "-"
    # structure
    n_CV::F = "-" # n_CV = 1 by definition
    n_HV::F = "-"
    n_OV::F = "-"
    n_NV::F = "-"
    # reserve
    n_CE::F = "-" # n_CE = 1 by definition
    n_HE::F = "-"
    n_OE::F = "-"
    n_NE::F = "-"
    # faeces
    n_CP::F = "-" # n_CP = 1 by definition
    n_HP::F = "-"
    n_OP::F = "-"
    n_NP::F = "-"

    # chemical indices for minerals from Kooy2010 
    # CO2 
    n_CC::F = "-"
    n_HC::F = "-"
    n_OC::F = "-"
    n_NC::F = "-"
    # H2O
    n_CH::F = "-"
    n_HH::F = "-"
    n_OH::F = "-"
    n_NH::F = "-"
    # O2
    n_CO::F = "-"
    n_HO::F = "-"
    n_OO::F = "-"
    n_NO::F = "-"
    # N-waste; multiply free by par to convert to vector if necessary
    n_CN::F = "-"
    n_HN::F = "-"
    n_ON::F = "-"
    n_NN::F = "-"
end

units = parunits_struct()

Base.@kwdef struct parlabels_struct{F}
    # reference parameter (not to be changed) 
    T_ref::F = "Reference Temperature"

    # core primary parameters 
    z::F = "zoom factor"
    F_m::F = "{F_m}, max spec searching rate"
    kap_X::F = "digestion efficiency of food to reserve"
    kap_P::F = "faecation efficiency of food to faeces"
    v::F = "energy conductance"
    kap::F = "allocation fraction to soma"
    kap_R::F = "reproduction efficiency"
    p_M::F = "[p_M], vol-spec somatic maint"
    p_T::F = "{p_T}, surf-spec somatic maint"
    k_J::F = "maturity maint rate coefficient"
    E_G::F = "[E_G], spec cost for structure"
    E_Hb::F = "maturity at birth"
    E_Hp::F = "maturity at puberty"
    h_a::F = "Weibull aging acceleration"
    s_G::F = "Gompertz stress coefficient"

    # other parameters 
    T_A::F = "Arrhenius temperature"
    #T_AL::F = "low temp boundary"
    #T_AH::F = "high temp boundary"
    #T_L::F = "low Arrhenius temperature"
    #T_H::F = "high Arrhenius temperature"
    E_Hpm::F = "maturity at puberty for male"
    del_M::F = "shape coefficient"
    f::F = "scaled functional response for 0-var data"
    z_m::F = "zoom factor for male"

    # chemical parameters
    # specific densities; multiply free by d_V to convert to vector if necessary
    d_X::F = "specific density of food"
    d_V::F = "specific density of structure"
    d_E::F = "specific density of reserve"
    d_P::F = "specific density of faeces"

    # chemical potentials from Kooy2010 Tab 4.2
    mu_X::F = "chemical potential of food"
    mu_V::F = "chemical potential of structure"
    mu_E::F = "chemical potential of reserve"
    mu_P::F = "chemical potential of faeces"

    # chemical potential of minerals
    mu_C::F = "chemical potential of CO2"
    mu_H::F = "chemical potential of H2O"
    mu_O::F = "chemical potential of O2"
    mu_N::F = "chemical potential of N-waste"

    # chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
    # food
    n_CX::F = "chem. index of carbon in food" # C/C = 1 by definition
    n_HX::F = "chem. index of hydrogen in food"
    n_OX::F = "chem. index of oxygen in food"
    n_NX::F = "chem. index of nitrogen in food"
    # structure
    n_CV::F = "chem. index of carbon in structure" # n_CV = 1 by definition
    n_HV::F = "chem. index of hydrogen in structure"
    n_OV::F = "chem. index of oxygen in structure"
    n_NV::F = "chem. index of nitrogen in structure"
    # reserve
    n_CE::F = "chem. index of carbon in reserve"   # n_CE = 1 by definition
    n_HE::F = "chem. index of hydrogen in reserve"
    n_OE::F = "chem. index of oxygen in reserve"
    n_NE::F = "chem. index of nitrogen in reserve"
    # faeces
    n_CP::F = "chem. index of carbon in faeces"    # n_CP = 1 by definition
    n_HP::F = "chem. index of hydrogen in faeces"
    n_OP::F = "chem. index of oxygen in faeces"
    n_NP::F = "chem. index of nitrogen in faeces"

    # chemical indices for minerals from Kooy2010 
    # CO2 
    n_CC::F = "chem. index of carbon in CO2"
    n_HC::F = "chem. index of hydrogen in CO2"
    n_OC::F = "chem. index of oxygen in CO2"
    n_NC::F = "chem. index of nitrogen in CO2"
    # H2O
    n_CH::F = "chem. index of carbon in H2O"
    n_HH::F = "chem. index of hydrogen in H2O"
    n_OH::F = "chem. index of oxygen in H2O"
    n_NH::F = "chem. index of nitrogen in H2O"
    # O2
    n_CO::F = "chem. index of carbon in O2"
    n_HO::F = "chem. index of hydrogen in O2"
    n_OO::F = "chem. index of oxygen in O2"
    n_NO::F = "chem. index of nitrogen in O2"
    # N-waste; multiply free by par to convert to vector if necessary
    n_CN::F = "chem. index of carbon in N-waste"  # n_CN = 0 or 1 by definition
    n_HN::F = "chem. index of hydrogen in N-waste"
    n_ON::F = "chem. index of oxygen in N-waste"
    n_NN::F = "chem. index of nitrogen in N-waste"
end

labels = parlabels_struct()

Base.@kwdef struct txtPar_struct
    units::parunits_struct = parunits_struct()
    label::parlabels_struct = parlabels_struct()
end
txtPar = txtPar_struct()