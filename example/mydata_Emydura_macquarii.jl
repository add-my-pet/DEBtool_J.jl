# module mydata_Emydura_macquarii
# using Parameters
# using ModelParameters
# using Unitful
# using Unitful: °C, K, d, g, cm, mol, J
# using ..addpseudodata
metaData = (;
    phylum = "Chordata",
    class = "Reptilia",
    order = "Testudines",
    family = "Chelidae",
    species = "Emydura_macquarii",
    species_en = "Murray River turtle",
    # ecoCode::Any,
    T_typical = Unitful.K(22Unitful.°C),
    data_0 = ["ab_T", "ap", "am", "Lb", "Lp", "Li", "Wwb", "Wwp", "Wwi", "Ri"],
    data_1 = ["t-L"],
    COMPLETE = 2.5,
    author = "Bas Kooijman",
    date_subm = [2017, 10, 09],
    email = "bas.kooijman@vu.nl",
    address = "VU University, Amsterdam",
    curator = "Starrlight Augustine",
    email_cur = "starrlight@akvaplan.niva.no",
    date_acc = [2017, 10, 09],
    # links
    # facts
    # discussion
    # bibkey
    # biblist
)

ecoCode = (;
    climate = ["Cfa", "Cfb"],
    ecozone = ["TA"],
    habitat = ["0bTd", "biFr"],
    embryo = ["Tt"],
    migrate = String[],
    food = ["biCi"],
    gender = ["Dg"],
    reprod = ["O"],
)

tL1 = [
    0.981 6.876
    0.981 7.090
    1.956 8.369
    1.956 8.689
    1.957 9.115
    1.957 9.435
    1.957 9.808
    1.958 10.075
    1.958 10.235
    1.983 10.661
    2.833 11.141
    2.908 11.354
    2.931 9.701
    2.932 10.768
    2.984 12.420
    3.008 11.674
    3.833 13.220
    3.834 13.326
    3.834 13.646
    3.857 12.100
    3.883 12.420
    3.883 12.633
    3.883 12.953
    3.934 14.072
]

tL_age = tL1[:, 1] * 365 * u"d"
tL_length = tL1[:, 2] * u"cm"
tL2 = [tL_age, tL_length]

data = (;
    ab = 78.0d,
    ab30 = 48.0d,
    tp = 10.0 * 365.0d,
    tpm = 5.5 * 365.0d,
    am = 20.9 * 365.0d,
    Lb = 2.7cm,
    Lp = 18.7cm,
    Lpm = 14.7cm,
    Li = 21.4cm,
    Lim = 20.8cm,
    Wwb = 8.0g,
    Wwp = 2669.0g,
    Wwpm = 1297.0g,
    Wwi = 4000.0g,
    Wwim = 3673.0g,
    Ri = 36.0 / 365.0d,
    tl = tL2 ,
    psd = psdData,
)

temp = (;
    abg = Unitful.K(22Unitful.°C),
    ab30g = Unitful.K(30Unitful.°C),
    tpg = Unitful.K(22Unitful.°C),
    tpmg = Unitful.K(22Unitful.°C),
    amg = Unitful.K(22Unitful.°C),
    rig = Unitful.K(22Unitful.°C),
    tLg = Unitful.K(22Unitful.°C),
)

label = (;
    ab = "age at birth",
    ab30 = "age at birth",
    tp = "time since birth at puberty for females",
    tpm = "time since birth at puberty for males",
    am = "life span",
    Lb = "plastron length at birth",
    Lp = "plastron length at puberty for females",
    Lpm = "plastron length at puberty for males",
    Li = "ultimate plastron length for females",
    Lim = "ultimate plastron length for females",
    Wwb = "wet weight at birth",
    Wwp = "wet weight at puberty for females",
    Wwpm = "wet weight at puberty for males",
    Wwi = "ultimate wet weight for females",
    Wwim = "ultimate wet weight for males",
    Ri = "maximum reprod rate",
    tL = ["time since birth", "carapace length"],
    psd = psdLabel,
)

bibkey = (
    ab = "carettochelys",
    ab30 = "carettochelys",
    tp = "Spen2002",
    tpm = "Spen2002",
    am = "life span",
    Lb = "Spen2002",
    Lp = "Spen2002",
    Lpm = "Spen2002",
    Li = "Spen2002",
    Lim = "Spen2002",
    Wwb = "Spen2002",
    Wwp = "Spen2002",
    Wwpm = "Spen2002",
    Wwi = "carettochelys",
    Wwim = "carettochelys",
    Ri = "Spen2002",
    tL = "Spen2002",
    F1 = "Wiki",
)

units = (
    ab = "d",
    ab30 = "d",
    tp = "d",
    tpm = "d",
    am = "d",
    Lb = "cm",
    Lp = "cm",
    Lpm = "cm",
    Li = "cm",
    Lim = "cm",
    Wwb = "g",
    Wwp = "g",
    Wwpm = "g",
    Wwi = "g",
    Wwim = "g",
    Ri = "#/d",
    tL = ["time since birth", "carapace length"],
    psd = psdUnits,
)

nvar = length(tL2)
N = length(tL2[1])
## set weights for all real data
#weights = setweights(data, weights);
# weights.tL = 2 * weights.tL;

## set pseudodata and respective weights
# [data, units, label, weights] = addpseudodata(data, units, label, weights);
# weights.psd.k_J = 0;
# weights.psd.k = 0.1;

weights = (;
    abg = 1,
    ab30g = 1,
    tpg = 1,
    tpmg = 1,
    amg = 1,
    Lbg = 1,
    Lpg = 1,
    Lpmg = 1,
    Lig = 1,
    Limg = 1,
    Wwbg = 1,
    Wwpg = 1,
    Wwpmg = 1,
    Wwig = 1,
    Wwimg = 1,
    Rig = 1,
    tL = ones(N, nvar - 1) / N / (nvar - 1),
    psd = psdWeight,
)

data.psd.k = 0.3;
units.psd.k = "-";
label.psd.k = "maintenance ratio";

# Discussion points
discussion = (;
    D1 = "Males are assumed to differ from females by {p_Am} and E_Hb only", # Cat of Life
)

# Facts
facts = (
    F1= "Omnivorous"
)

# Links
links = (; 
    id_CoL = "39LSX", # Cat of Life
    id_ITIS = "949506", # ITIS
    id_EoL = "794804", # Ency of Life
    id_Wiki = "Emydura_macquarii", # Wikipedia
    id_ADW = "Emydura_macquarii", # ADW
    id_Taxo = "93062", # Taxonomicon
    id_WoRMS = "1447999", # WoRMS
    id_ReptileDB = "genus=Emydura&species=macquarii", # ReptileDB
    id_AnAge = "Emydura_macquarii", # AnAge
)

comment = (;
    ab = "all temps are guessed",
    ab30 = "",
    tp = "",
    tpm = "",
    am = "",
    Lb = "",
    Lp = "",
    Lpm = "",
    Li = "",
    Lim = "",
    Wwb = "based on (Lb/Li)^3*Wwi",
    Wwp = "based on (Lp/Li)^3*Wwi",
    Wwpm = "based on (Lpm/Li)^3*Ww",
    Wwi = "",
    Wwim = "based on (Lim/Li)^3*Wwi",
    Ri = "#/d",
    tL = ["time since birth", "carapace length"],
)

# pack auxData and txtData for output

# TODO: move this somewhere shared if this is a common structure?
# struct TxtData{A,B,C,D}
#     units::A
#     label::B
#     bibkey::C
#     comment::D
# end

txtData = (; units, label, bibkey, comment)

auxData = (;
    temp = temp,
)

# ## References
bibkey = "Wiki";
type = "Misc";
bib = "howpublished = {\\url{http://en.wikipedia.org/wiki/Emydura_macquarii}}";
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
    "howpublished = {\\url{../../../bib/Kooy2010.html}}",
]
Kooy2010 = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
#Kooy2010 = ["''@" * type * "{" * bibkey * ", " * bib[1] * "}'';"];
# #
bibkey = "Spen2002";
type = "Article";
bib = [
    "author = {R.-J. Spencer}, "
    "year = {2002}, "
    "title = {Growth patterns in two widely distributed freshwater turtles and a comparison of methods used to estimate age}, "
    "journal = {Austr. J. Zool.}, "
    "volume = {50}, "
    "pages = {477--490}"
];
#Spen2002 = ["''@" * type * "{" * bibkey * ", " * bib * "}'';"];
Spen2002 = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
# metaData.biblist.(bibkey) = ["""@", type, "{", bibkey, ", " bib, "}"";"];
# #
bibkey = "AnAge";
type = "Misc";
bib = "howpublished = {\\url{http://genomics.senescence.info/species/entry.php?species=Emydura_macquarii}}";
AnAge = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
#metaData.biblist.(bibkey) = ["""@", type, "{", bibkey, ", " bib, "}"";"];
# #
bibkey = "carettochelys";
type = "Misc";
bib = "howpublished = {\\url{http://www.carettochelys.com/emydura/emydura_mac_mac_3.htm}}";
carettochelys = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";
# metaData.biblist.(bibkey) = ["""@", type, "{", bibkey, ", " bib, "}"";"];

biblist = [Kooy2010, Kooy2010, Spen2002, AnAge, carettochelys]

metaData = (;
    ecoCode = ecoCode,
    links = links,
    facts = facts,
    discussion = discussion,
    bibkey = bibkey,
    biblist = biblist,
)

(; data, auxData, metaData, txtData, weights)
