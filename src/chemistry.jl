
# TODO: none of this is really implemented yet
# But the idea is this will allow flexible use of elements to specify in structure, reserve and product

# Gets chemical indices and chemical potential of N-waste from phylum, class

# """
#     Element

# Abstract supertype for chemical elements. 

# Is there another pakage for this?
# """
# abstract type Element end

# """
#     Element

# Abstract supertype for chemical elements. 
# """
# struct C <: Element end
# struct H <: Element end
# struct O <: Element end
# struct N <: Element end
# struct P <: Element end

# # State
# struct Structure{E<:Tuple{Vararg{Element}}}
#     elements::E
# end
# Structure(elements::Element...) = Structure(elements)

# # Waste type
# abstract type AbstractNitrogenWaste end

# # Do these make sense?
# struct Ammonoletic <: AbstractNitrogenWaste end
# struct Ureotelic <: AbstractNitrogenWaste end
# struct Uricotelic <: AbstractNitrogenWaste end
# struct CustomNWaste{Ch,HN,ON,NN,N,Am} <: AbstractNitrogenWaste
#     n_CN::CN
#     n_HN::HN
#     n_ON::ON
#     n_NN::NN
#     mu_N::N
#     ammonia::Am
# end

function defaultchemistry(phylum, class;
    d_V=default_d_V(phylum, class) # see comments on section 3.2.1 of DEB3 
)
    d_V_unitless = ustrip(u"g/cm^3", d_V)
    # specific densites and N-waste based on taxonomy
    (; n_CN, n_HN, n_ON, n_NN, mu_N) = default_N_waste(phylum, class)


    return (;
        # specific densities; multiply free by d_V to convert to vector if necessary
        d_X=Const(d_V_unitless; units=u"g/cm^3", label="specific density of food"), 
        d_V=Const(d_V_unitless; units=u"g/cm^3", label="specific density of structure"), 
        d_E=Const(d_V_unitless; units=u"g/cm^3", label="specific density of reserve"), 
        d_P=Const(d_V_unitless; units=u"g/cm^3", label="specific density of faeces"),

        # chemical potentials from Kooy2010 Tab 4.2
        mu_X=Const(525000; units=u"J/ mol", label="chemical potential of food"), 
        mu_V=Const(500000; units=u"J/ mol", label="chemical potential of structure"), 
        mu_E=Const(550000; units=u"J/ mol", label="chemical potential of reserve"), 
        mu_P=Const(480000; units=u"J/ mol", label="chemical potential of faeces"), 

        # chemical potential of minerals
        mu_C=Const(0.0;    units=u"J/ mol", label="chemical potential of CO2"), 
        mu_H=Const(0.0;    units=u"J/ mol", label="chemical potential of H2O"), 
        mu_O=Const(0.0;    units=u"J/ mol", label="chemical potential of O2"), 
        mu_N=Const(mu_N;   units=u"J/ mol", label="chemical potential of N-waste"), 

        # chemical indices for water-free organics from Kooy2010 Fig 4.15 (excluding contributions of H and O atoms from water)
        # food
        n_CX=Const(1.0;    units=nothing, label="chem. index of carbon in food"), # C/C = 1 by definition
        n_HX=Const(1.8;    units=nothing, label="chem. index of hydrogen in food"),
        n_OX=Const(0.5;    units=nothing, label="chem. index of oxygen in food"),
        n_NX=Const(0.15;   units=nothing, label="chem. index of nitrogen in food"),
        # structure
        n_CV=Const(1.0;    units=nothing, label="chem. index of carbon in structure"), # n_CV = 1 by definition
        n_HV=Const(1.8;    units=nothing, label="chem. index of hydrogen in structure"),
        n_OV=Const(0.5;    units=nothing, label="chem. index of oxygen in structure"),
        n_NV=Const(0.15;   units=nothing, label="chem. index of nitrogen in structure"),
        # reserve
        n_CE=Const(1.0;    units=nothing, label="chem. index of carbon in reserve"),   # n_CE = 1 by definition
        n_HE=Const(1.8;    units=nothing, label="chem. index of hydrogen in reserve"),
        n_OE=Const(0.5;    units=nothing, label="chem. index of oxygen in reserve"),
        n_NE=Const(0.15;   units=nothing, label="chem. index of nitrogen in reserve"),
        # faeces
        n_CP=Const(1.0;    units=nothing, label="chem. index of carbon in faeces"),    # n_CP = 1 by definition
        n_HP=Const(1.8;    units=nothing, label="chem. index of hydrogen in faeces"),
        n_OP=Const(0.5;    units=nothing, label="chem. index of oxygen in faeces"),
        n_NP=Const(0.15;   units=nothing, label="chem. index of nitrogen in faeces"),  

        # chemical indices for minerals from Kooy2010 
        # CO2 
        n_CC=Const(1.0;    units=nothing, label="chem. index of carbon in CO2"), 
        n_HC=Const(0.0;    units=nothing, label="chem. index of hydrogen in CO2"),
        n_OC=Const(2.0;    units=nothing, label="chem. index of oxygen in CO2"),
        n_NC=Const(0.0;    units=nothing, label="chem. index of nitrogen in CO2"),
        # H2O
        n_CH=Const(0.0;    units=nothing, label="chem. index of carbon in H2O"), 
        n_HH=Const(2.0;    units=nothing, label="chem. index of hydrogen in H2O"),
        n_OH=Const(1.0;    units=nothing, label="chem. index of oxygen in H2O"),
        n_NH=Const(0.0;    units=nothing, label="chem. index of nitrogen in H2O"),
        # O2
        n_CO=Const(0.0;    units=nothing, label="chem. index of carbon in O2"),   
        n_HO=Const(0.0;    units=nothing, label="chem. index of hydrogen in O2"),
        n_OO=Const(2.0;    units=nothing, label="chem. index of oxygen in O2"),
        n_NO=Const(0.0;    units=nothing, label="chem. index of nitrogen in O2"),
        # N-waste; multiply free by par to convert to vector if necessary
        n_CN=Const(n_CN;   units=nothing, label="chem. index of carbon in N-waste"),   # n_CN = 0 or 1 by definition
        n_HN=Const(n_HN;   units=nothing, label="chem. index of hydrogen in N-waste"),
        n_ON=Const(n_ON;   units=nothing, label="chem. index of oxygen in N-waste"),
        n_NN=Const(n_NN;   units=nothing, label="chem. index of nitrogen in N-waste"),
    )
end

"""
    default_N_waste(phylum::String, class::String)

Generate default nitrogen waste stoichiometry depending on phylum and class.

Returns a `NamedTuple` with `(; n_CN, n_HN, n_ON, n_NN, mu_N)`.
"""
function default_N_waste(phylum, class)
    N_waste = N_waste_type(phylum, class)

    if N_waste == :ammonoletic
        n_CN = 0.0 
        n_HN = 3.0 
        n_ON = 0.0 
        n_NN = 1.0 # ammonia: H3N.0
        mu_N = 0.0
    elseif N_waste == :ureotelic
        n_CN = 1.0 
        n_HN = 4.0 
        n_ON = 1.0 
        n_NN = 2.0 # urea: CH4ON2
        mu_N = 122e3   # J/C-mol  synthesis from NH3, Withers page 119     
    elseif N_waste == :uricotelic
        n_CN = 1.0 
        n_HN = 0.8 
        n_ON = 0.6 
        n_NN = 0.8 # uric acid: C5H4O3N4
        mu_N = 244e3/5 # J/C-mol  synthesis from NH3, Withers page 119           
    end

    (; n_CN, n_HN, n_ON, n_NN, mu_N)
end

function N_waste_type(phylum, class)
    return if phylum == "Porifera"
        :ammonoletic
    elseif phylum in ("Ctenophora", "Cnidaria")                              # Radiata
        :ammonoletic
    elseif phylum == "Xenacoelomorpha"                          
        :ammonoletic
    elseif phylum == "Gastrotricha"                                          # Platyzoa
        :ammonoletic
    elseif phylum == "Rotifera"
        :ammonoletic
    elseif phylum in ("Platyhelminthes", "Nemertea", "Acanthocephala", "Chaetognatha")
        :ammonoletic
    elseif phylum in ("Bryozoa", "Entoprocta", "Phoronida", "Brachiopoda")   # Spiralia 
        :ammonoletic
    elseif phylum == "Annelida" # terrestrial species are ureotelic, aquatic ones ammonoletic
        if class == "Clitellata"
            :ureotelic
        else
            :ammonoletic
        end
    elseif phylum == "Sipuncula"
        :ammonoletic
    elseif phylum == "Mollusca" # terrestrial species are ureotelic
        :ammonoletic
    elseif phylum in ("Tardigrada", "Priapulida", "Nematoda")                # Ecdysozoa
        :ammonoletic
    elseif phylum == "Arthropoda" # terrestrial species are uricotelic, aquatic ones ammonoletic 
        if class in ("Arachnida","Entognatha","Insecta")
            :uricotelic
        else
            :ammonoletic
        end
    elseif phylum in ("Echinodermata","Hemichordata")                        # Deuterostomata
        :ammonoletic
    elseif phylum == "Chordata"
        if class in ("Leptocardii","Appendicularia","Thaliacea","Ascidiacea")
            :ammonoletic
        elseif class in ("Myxini","Cephalaspidomorphi")
            :ammonoletic
        elseif class in ("Chondrichthyes","Elasmobranchii")
            :ureotelic
        elseif class == "Actinopterygii"
            :ammonoletic
        elseif class == "Sarcopterygii"
            :ureotelic
        elseif class == "Amphibia"
            :ureotelic # ammonoletic in water 
        elseif class == "Reptilia"
            :uricotelic
            # crocs and aquatic snakes partly ammonoletic, 
            # turtles and leguanas partly ureotelic
        elseif class == "Aves"
            :uricotelic
        elseif class == "Mammalia"
            :ureotelic
        end
    else
        @warn "get_N_waste: taxon $phylum $class could not be identified: using `:ammonoletic`"
        :ammonoletic
    end
end

function default_d_V(phylum, class)
    d_V = if phylum == "Porifera"
        0.0587 # ash-free dry
    elseif phylum in ("Ctenophora", "Cnidaria")                  # Radiata
        0.02
    elseif phylum == "Xenacoelomorpha"                           # Platyzoa
        0.05
    elseif phylum == "Gastrotricha"                              # Platyzoa
        0.05
    elseif phylum == "Rotifera"
        0.06
    elseif phylum in ("Platyhelminthes", "Nemertea", "Acanthocephala", "Chaetognatha")
        0.07
    elseif phylum in ("Bryozoa", "Entoprocta", "Phoronida", "Brachiopoda") # Spiralia 
        0.07
    elseif phylum == "Annelida"
        0.16
    elseif phylum == "Sipuncula"
        0.11
    elseif phylum == "Mollusca"
        if class == "Cephalopoda"
            0.21
        elseif class == "Gastropoda"
            0.15
        elseif class == "Bivalvia"
            0.09
        else
            0.1
        end
    elseif phylum in ("Tardigrada", "Priapulida", "Nematoda") # Ecdysozoa
        0.07
    elseif phylum == "Arthropoda"
        if class == "Insecta"
            0.17 # 0.27 is possibly better
        else
            0.17
        end
    elseif phylum == "Echinodermata"                           # Deuterostomata
        0.09 # (AFDW)
    elseif phylum == "Hemichordata"
        0.07
    elseif phylum == "Chordata"
        if class in ("Mammalia", "Reptilia")
            0.3
        elseif class in ("Aves", "Amphibia")
            0.28
        elseif class in ("Chondrichthyes", "Elasmobranchii", "Actinopterygii", "Sarcopterygii")
            0.2
        elseif class == "Myxini"
            0.17
        elseif class == "Cephalaspidomorphi"
            0.125
        elseif class == "Appendicularia"
            0.045
        elseif class == "Thaliacea"
            0.08
        elseif class == "Ascidiacea"
            0.06
        elseif class == "Leptocardii"
            0.06  
        end 
    else
        @warn "get_d_V: taxon could not be identified, using 0.1 g/cm^3"
        0.1
    end
    return d_V * u"g/cm^3"
end
