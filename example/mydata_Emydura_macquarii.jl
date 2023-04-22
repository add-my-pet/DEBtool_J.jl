# module mydata_Emydura_macquarii
# using Parameters
# using ModelParameters
# using Unitful
# using Unitful: °C, K, d, g, cm, mol, J
# using ..addpseudodata
@with_kw mutable struct metaData_struct{T}
    phylum::String = "Chordata"
    class::String = "Reptilia"
    order::String = "Testudines"
    family::String = "Chelidae"
    species::String = "Emydura_macquarii"
    species_en::String = "Murray River turtle"
    ecoCode
    T_typical::T = Unitful.K(22Unitful.°C)
    data_0::Vector{String} = ["ab_T", "ap", "am", "Lb", "Lp", "Li", "Wwb", "Wwp", "Wwi", "Ri"]
    data_1::Vector{String} = ["t-L"]
    COMPLETE::Float32 = 2.5
    author::String = "Bas Kooijman"
    date_subm::Vector{Int32} = [2017, 10, 09]
    email::String = "bas.kooijman@vu.nl"
    address::String = "VU University, Amsterdam"
    curator::String = "Starrlight Augustine"
    email_cur::String = "starrlight@akvaplan.niva.no"
    date_acc::Vector{Int32} = [2017, 10, 09]
    links
    facts
    discussion
    bibkey
    biblist
end

@with_kw mutable struct ecoCode_struct
    climate::Vector{String} = ["Cfa", "Cfb"]
    ecozone::Vector{String} = ["TA"]
    habitat::Vector{String} = ["0bTd", "biFr"]
    embryo::Vector{String} = ["Tt"]
    migrate::Vector{String} = []
    food::Vector{String} = ["biCi"]
    gender::Vector{String} = ["Dg"]
    reprod::Vector{String} = ["O"]
end
ecoCode = ecoCode_struct()

@with_kw mutable struct data_struct{A,L,W,R}
    ab::A = 78.0d
    ab30::A = 48.0d
    tp::A = 10.0*365.0d
    tpm::A = 5.5*365.0d
    am::A = 20.9*365.0d
    Lb::L = 2.7cm
    Lp::L = 18.7cm
    Lpm::L = 14.7cm
    Li::L = 21.4cm
    Lim::L = 20.8cm
    Wwb::W = 8.0g
    Wwp::W = 2669.0g
    Wwpm::W = 1297.0g
    Wwi::W = 4000.0g
    Wwim::W = 3673.0g
    Ri::R = 36.0/365.0d
    tL
    psd
end
tL1 = [0.981	6.876
            0.981	7.090
            1.956	8.369
            1.956	8.689
            1.957	9.115
            1.957	9.435
            1.957	9.808
            1.958	10.075
            1.958	10.235
            1.983	10.661
            2.833	11.141
            2.908	11.354
            2.931	9.701
            2.932	10.768
            2.984	12.420
            3.008	11.674
            3.833	13.220
            3.834	13.326
            3.834	13.646
            3.857	12.100
            3.883	12.420
            3.883	12.633
            3.883	12.953
            3.934	14.072]
tL_age = tL1[:,1]*365*u"d"
tL_length = tL1[:,2]*u"cm"
tL2 = [tL_age, tL_length]
data = data_struct(tL = tL2, psd = psdData)

@with_kw mutable struct temp_struct{T}
    ab::T = Unitful.K(22Unitful.°C)
    ab30::T = Unitful.K(30Unitful.°C)
    tp::T = Unitful.K(22Unitful.°C)
    tpm::T = Unitful.K(22Unitful.°C)
    am::T = Unitful.K(22Unitful.°C)
    ri::T = Unitful.K(22Unitful.°C)
    tL::T = Unitful.K(22Unitful.°C)
end
temp = temp_struct()

@with_kw mutable struct label_struct
    ab::String = "age at birth"
    ab30::String = "age at birth"
    tp::String = "time since birth at puberty for females"
    tpm::String = "time since birth at puberty for males"
    am::String = "life span"
    Lb::String = "plastron length at birth"
    Lp::String = "plastron length at puberty for females"
    Lpm::String = "plastron length at puberty for males"
    Li::String = "ultimate plastron length for females"
    Lim::String = "ultimate plastron length for females"
    Wwb::String = "wet weight at birth"
    Wwp::String = "wet weight at puberty for females"
    Wwpm::String = "wet weight at puberty for males"
    Wwi::String = "ultimate wet weight for females"
    Wwim::String = "ultimate wet weight for males"
    Ri::String = "maximum reprod rate"
    tL::Vector{String} = ["time since birth", "carapace length"]
    psd
end
label = label_struct(psd = psdLabel)

@with_kw mutable struct bibkey_struct
    ab::String = "carettochelys"
    ab30::String = "carettochelys"
    tp::String = "Spen2002"
    tpm::String = "Spen2002"
    am::String = "life span"
    Lb::String = "Spen2002"
    Lp::String = "Spen2002"
    Lpm::String = "Spen2002"
    Li::String = "Spen2002"
    Lim::String = "Spen2002"
    Wwb::String = "Spen2002"
    Wwp::String = "Spen2002"
    Wwpm::String = "Spen2002"
    Wwi::String = "carettochelys"
    Wwim::String = "carettochelys"
    Ri::String = "Spen2002"
    tL::String = "Spen2002"
    F1::String = "Wiki"
end
bibkey = bibkey_struct()

@with_kw mutable struct units_struct
    ab::String = "d"
    ab30::String = "d"
    tp::String = "d"
    tpm::String = "d"
    am::String = "d"
    Lb::String = "cm"
    Lp::String = "cm"
    Lpm::String = "cm"
    Li::String = "cm"
    Lim::String = "cm"
    Wwb::String = "g"
    Wwp::String = "g"
    Wwpm::String = "g"
    Wwi::String = "g"
    Wwim::String = "g"
    Ri::String = "#/d"
    tL::Vector{String} = ["time since birth", "carapace length"]
    psd
end
units = units_struct(psd = psdUnits)

@with_kw mutable struct weight_struct
    ab::Float64 = 1
    ab30::Float64 = 1
    tp::Float64 = 1
    tpm::Float64 = 1
    am::Float64 = 1
    Lb::Float64 = 1
    Lp::Float64 = 1
    Lpm::Float64 = 1
    Li::Float64 = 1
    Lim::Float64 = 1
    Wwb::Float64 = 1
    Wwp::Float64 = 1
    Wwpm::Float64 = 1
    Wwi::Float64 = 1
    Wwim::Float64 = 1
    Ri::Float64 = 1
    tL
    psd
end
nvar = length(tL2)
N = length(tL2[1])
weights = weight_struct(tL = ones(N, nvar-1)/ N/ (nvar-1), psd = psdWeight)
## set weights for all real data
#weights = setweights(data, weights);
weights.tL = 2 * weights.tL;

## set pseudodata and respective weights
# [data, units, label, weights] = addpseudodata(data, units, label, weights);
weights.psd.k_J = 0; weights.psd.k = 0.1;
data.psd.k = 0.3; units.psd.k  = "-"; label.psd.k  = "maintenance ratio"; 

# Discussion points
@with_kw mutable struct discussion_struct
    D1::String = "Males are assumed to differ from females by {p_Am} and E_Hb only" # Cat of Life
end
discussion = discussion_struct()

# Facts
@with_kw mutable struct facts_struct
    F1::String = "Omnivorous"
end
facts = facts_struct()

# Links
@with_kw mutable struct links_struct
    id_CoL::String = "39LSX" # Cat of Life
    id_ITIS::String = "949506" # ITIS
    id_EoL::String = "794804" # Ency of Life
    id_Wiki::String = "Emydura_macquarii" # Wikipedia
    id_ADW::String = "Emydura_macquarii" # ADW
    id_Taxo::String = "93062" # Taxonomicon
    id_WoRMS::String = "1447999" # WoRMS
    id_ReptileDB::String = "genus=Emydura&species=macquarii" # ReptileDB
    id_AnAge::String = "Emydura_macquarii" # AnAge
end
links = links_struct()

@with_kw mutable struct struct_comment
    ab::String = "all temps are guessed"
    ab30::String = ""
    tp::String = ""
    tpm::String = ""
    am::String = ""
    Lb::String = ""
    Lp::String = ""
    Lpm::String = ""
    Li::String = ""
    Lim::String = ""
    Wwb::String = "based on (Lb/Li)^3*Wwi"
    Wwp::String = "based on (Lp/Li)^3*Wwi"
    Wwpm::String = "based on (Lpm/Li)^3*Ww"
    Wwi::String = ""
    Wwim::String = "based on (Lim/Li)^3*Wwi"
    Ri::String = "#/d"
    tL::Vector{String} = ["time since birth", "carapace length"]
end
comment = struct_comment()

# pack auxData and txtData for output

@with_kw mutable struct struct_txtData{A,B,C,D}
    units::A = units
    label::B = label
    bibkey::C = bibkey
    comment::D = comment
end
txtData = struct_txtData()

@with_kw mutable struct struct_auxData{T}
    temp::T = temp
end
auxData = struct_auxData()

# ## References
bibkey = "Wiki"; type = "Misc"; bib = 
 "howpublished = {\\url{http://en.wikipedia.org/wiki/Emydura_macquarii}}";
 #metaData.biblist.(bibkey) = ["""@", type, "{", bibkey, ", " bib, "}"";"];
 Wiki = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";

# #
bibkey = "Kooy2010"
type = "Book"
bib = [ # used in setting of chemical parameters and pseudodata
 "author = {Kooijman, S.A.L.M.}, ", 
 "year = {2010}, ", 
 "title  = {Dynamic Energy Budget theory for metabolic organisation}, ", 
 "publisher = {Cambridge Univ. Press, Cambridge}, ",
 "pages = {Table 4.2 (page 150), 8.1 (page 300)}, ", 
 "howpublished = {\\url{../../../bib/Kooy2010.html}}"]
 Kooy2010 = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
 #Kooy2010 = ["''@" * type * "{" * bibkey * ", " * bib[1] * "}'';"];
# #
bibkey = "Spen2002"; type = "Article"; bib = [  
 "author = {R.-J. Spencer}, " 
 "year = {2002}, "
 "title = {Growth patterns in two widely distributed freshwater turtles and a comparison of methods used to estimate age}, "
 "journal = {Austr. J. Zool.}, "
 "volume = {50}, "
 "pages = {477--490}"];
 #Spen2002 = ["''@" * type * "{" * bibkey * ", " * bib * "}'';"];
 Spen2002 = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
# metaData.biblist.(bibkey) = ["""@", type, "{", bibkey, ", " bib, "}"";"];
# #
bibkey = "AnAge"; type = "Misc"; bib =
 "howpublished = {\\url{http://genomics.senescence.info/species/entry.php?species=Emydura_macquarii}}";
 AnAge = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
 #metaData.biblist.(bibkey) = ["""@", type, "{", bibkey, ", " bib, "}"";"];
# #
 bibkey = "carettochelys"; type = "Misc"; bib = 
 "howpublished = {\\url{http://www.carettochelys.com/emydura/emydura_mac_mac_3.htm}}";
 carettochelys = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
# metaData.biblist.(bibkey) = ["""@", type, "{", bibkey, ", " bib, "}"";"];

@with_kw mutable struct biblist_struct
    Kooy2010::String = Kooy2010
    Spen2002::String = Spen2002
    AnAge::String = AnAge
    carettochelys::String = carettochelys
end
biblist = biblist_struct()

metaData = metaData_struct(ecoCode = ecoCode, links = links, facts = facts, discussion = discussion, bibkey = bibkey, biblist = biblist)

# export(data)
# export(auxData)
# export(metaData)
# export(txtData)
# export(weights)
# #(data, auxData, metaData, txtData, weights)
# end
