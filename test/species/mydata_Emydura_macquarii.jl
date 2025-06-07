metaData = (;
    phylum="Chordata",
    class="Reptilia",
    order="Testudines",
    family="Chelidae",
    species="Emydura_macquarii",
    species_en="Murray River turtle",
    # ecoCode::Any,
    T_typical=Unitful.K(22Unitful.°C),
    data_0=["ab_T", "ap", "am", "Lb", "Lp", "Li", "Wwb", "Wwp", "Wwi", "Ri"],
    data_1=["t-L"],
    COMPLETE=2.5,
    author="Bas Kooijman",
    date_subm=[2017, 10, 09],
    email="bas.kooijman@vu.nl",
    address="VU University, Amsterdam",
    curator="Starrlight Augustine",
    email_cur="starrlight@akvaplan.niva.no",
    date_acc=[2017, 10, 09],
    # links
    # facts
    # discussion
    # bibkey
    # biblist
)

ecoCode = (;
    climate=["Cfa", "Cfb"],
    ecozone=["TA"],
    habitat=["0bTd", "biFr"],
    embryo=["Tt"],
    migrate=String[],
    food=["biCi"],
    gender=["Dg"],
    reprod=["O"],
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

# Define units
unit_age = u"d"
unit_length = u"cm"

# Convert the matrix tL1 into a named tuple with units assigned to each column
tL = hcat(tL1[:, 1] * 365 * unit_age, tL1[:, 2] * unit_length)
# tL = Unitful.K(22Unitful.°C) => tL

data = (;
    ab=78.0u"d",
    ab30=48.0u"d",
    tp=10.0 * 365.0u"d",
    tpm=5.5 * 365.0u"d",
    am=20.9 * 365.0u"d",
    Lb=2.7u"cm",
    Lp=18.7u"cm",
    Lpm=14.7u"cm",
    Li=21.4u"cm",
    Lim=20.8u"cm",
    Wwb=8.0u"g",
    Wwp=2669.0u"g",
    Wwpm=1297.0u"g",
    Wwi=4000.0u"g",
    Wwim=3673.0u"g",
    Ri=36.0 / 365.0u"d"
)

data = merge(data, (; tL))

temp = (;
    ab=Unitful.K(22Unitful.°C),
    ab30=Unitful.K(30Unitful.°C),
    tp=Unitful.K(22Unitful.°C),
    tpm=Unitful.K(22Unitful.°C),
    am=Unitful.K(22Unitful.°C),
    Ri=Unitful.K(22Unitful.°C),
    tL=Unitful.K(22Unitful.°C),
)

rates = (;
    ab=Unitful.K(22Unitful.°C) => 78.0u"d",
    ab30=Unitful.K(30Unitful.°C) => 48.0u"d",
    tp=Unitful.K(22Unitful.°C) => 10.0 * 365.0u"d",
    tpm=Unitful.K(22Unitful.°C) => 5.5 * 365.0u"d",
    am=Unitful.K(22Unitful.°C) => 20.9 * 365.0u"d",
    Ri=Unitful.K(22Unitful.°C) => 36.0 / 365.0u"d",
)

data = merge(data, (; tL))

bibkey = (
    ab="carettochelys",
    ab30="carettochelys",
    tp="Spen2002",
    tpm="Spen2002",
    am="life span",
    Lb="Spen2002",
    Lp="Spen2002",
    Lpm="Spen2002",
    Li="Spen2002",
    Lim="Spen2002",
    Wwb="Spen2002",
    Wwp="Spen2002",
    Wwpm="Spen2002",
    Wwi="carettochelys",
    Wwim="carettochelys",
    Ri="Spen2002",
    tL="Spen2002",
    F1="Wiki",
)

## set weights for all real data
weights=DEBtool_J.setweights(data);
weights=merge(weights, (tL=2*weights.tL,))
## set pseudodata and respective weights
(psd, psdLabel, psdweights)=addpseudodata()
psd=merge(psd, (k=0.3,))

label = (;
    ab="age at birth",
    ab30="age at birth",
    tp="time since birth at puberty for females",
    tpm="time since birth at puberty for males",
    am="life span",
    Lb="plastron length at birth",
    Lp="plastron length at puberty for females",
    Lpm="plastron length at puberty for males",
    Li="ultimate plastron length for females",
    Lim="ultimate plastron length for females",
    Wwb="wet weight at birth",
    Wwp="wet weight at puberty for females",
    Wwpm="wet weight at puberty for males",
    Wwi="ultimate wet weight for females",
    Wwim="ultimate wet weight for males",
    Ri="maximum reprod rate",
    tL=["time since birth", "carapace length"],
    psd=psdLabel,
)

data=merge(data, (; psd))
psdweights=merge(psdweights, (k_J=0,))
psdweights=merge(psdweights, (k=0.1,))
psd=psdweights
weights=merge(weights, (; psd))

# label.psd.k = "maintenance ratio";

# Discussion points
discussion = (;
    D1="Males are assumed to differ from females by {p_Am} and E_Hb only", # Cat of Life
)

# Facts
facts = (
    F1 = "Omnivorous"
)

# Links
links = (;
    id_CoL="39LSX", # Cat of Life
    id_ITIS="949506", # ITIS
    id_EoL="794804", # Ency of Life
    id_Wiki="Emydura_macquarii", # Wikipedia
    id_ADW="Emydura_macquarii", # ADW
    id_Taxo="93062", # Taxonomicon
    id_WoRMS="1447999", # WoRMS
    id_ReptileDB="genus=Emydura&species=macquarii", # ReptileDB
    id_AnAge="Emydura_macquarii", # AnAge
)

comment = (;
    ab="all temps are guessed",
    ab30="",
    tp="",
    tpm="",
    am="",
    Lb="",
    Lp="",
    Lpm="",
    Li="",
    Lim="",
    Wwb="based on (Lb/Li)^3*Wwi",
    Wwp="based on (Lp/Li)^3*Wwi",
    Wwpm="based on (Lpm/Li)^3*Ww",
    Wwi="",
    Wwim="based on (Lim/Li)^3*Wwi",
    Ri="#/d",
    tL=["time since birth", "carapace length"],
)

# pack auxData and txtData for output

# TODO: move this somewhere shared if this is a common structure?
# struct TxtData{A,B,C,D}
#     units::A
#     label::B
#     bibkey::C
#     comment::D
# end

txtData = (; label, bibkey, comment)

auxData = (; temp,)

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
    ecoCode=ecoCode,
    links=links,
    facts=facts,
    discussion=discussion,
    bibkey=bibkey,
    biblist=biblist,
)

(; data, auxData, metaData, txtData, weights)
