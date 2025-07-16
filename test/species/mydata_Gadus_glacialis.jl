metaData = (;
    phylum="Chordata",
    class="Actinopterygii",
    order="Gadiformes",
    family="Gadidae",
    species="Arctogadus_glacialis",
    species_en="Arctic cod",
    # ecoCode::Any,
    T_typical=Unitful.K(22Unitful.°C),
    data_0=["ab", "am", "Lp", "Li", "Wwb", "Wwp", "Wwi", "Ri"],
    data_1=["t-L"],
    COMPLETE=2.5,
    author="Bas Kooijman",
    date_subm=[2023, 11, 23],
    email="bas.kooijman@vu.nl",
    address="VU University, Amsterdam",
    curator="Dina Lika",
    email_cur="lika@uoc.gr",
    date_acc=[2023, 11, 23],
    # links
    # facts
    # discussion
    # bibkey
    # biblist
)

ecoCode = (;
    climate=["ME"],
    ecozone=["MN"],
    habitat=["0jMp", "jiMd"],
    embryo=["Mp"],
    migrate=String["Mo"],
    food=["bjPz", "jiCi", "jiCvf"],
    gender=["D"],
    reprod=["O"],
)

tL1 = [
    3.670 0.836
    7.079 0.711
    9.963 0.961
    10.225 0.987
    12.322 0.934
    12.323 0.882
    14.419 1.329
    15.468 1.461
    17.828 0.993
    18.614 0.868
    19.401 1.086
    20.974 1.033
    21.236 1.204
    24.120 1.151
    24.906 0.961
    25.169 1.217
    26.742 1.138
    28.052 1.013
    29.625 1.164
    29.888 1.184
    29.889 1.125
    31.198 1.289
    31.199 1.237
    35.131 1.316
    36.442 1.368
    37.753 1.270
    38.801 1.283
    40.112 1.375
    40.637 1.408
    42.472 1.309
    42.734 1.138
    43.783 1.382
    43.784 1.421
    44.569 1.612
    44.831 1.197
    44.832 1.329
    45.094 1.105
    45.880 1.289
    48.240 1.191
    49.026 1.342
    50.337 1.382
    52.697 1.467
    53.483 1.586
    54.794 1.763
    56.105 1.704
    56.629 1.250
    61.086 1.303
    62.659 1.421
    64.757 1.868
    67.903 1.651
    67.904 1.914
    69.476 1.803
    73.146 1.803
    73.147 1.993
    74.981 1.711
    74.982 1.618
    75.768 1.875
    77.079 2.086
    78.390 2.145
    78.652 1.868
    79.700 2.217
    81.011 2.072
    81.536 2.178
    85.206 2.013
    85.468 2.243
    85.730 2.283
    86.255 2.197
    88.614 2.355
    90.448 1.829
    90.449 2.355
    91.760 2.362
    93.071 2.303
    94.120 2.553
    94.121 2.217
    94.644 2.053
    95.431 2.237
    97.004 2.467
    98.315 2.086
    99.101 2.579
    101.985 2.546
    102.772 2.204
    103.034 2.230
    103.558 2.474
    104.082 2.546
    104.083 2.013
    106.704 2.342
    107.228 2.592
    108.015 2.908
    108.016 2.500
    108.801 2.579
    110.637 2.658
    112.210 2.178
    114.831 2.697
    117.978 2.572
    119.288 3.086
    122.959 2.717
    128.727 3.066
    131.873 3.118
]

# Define units
unit_age = u"d"
unit_length = u"cm"

# Convert the matrix tL1 into a named tuple with units assigned to each column
tL = hcat(tL1[:, 1] * 365 * unit_age, tL1[:, 2] * unit_length)

data = (;
    ab=47.0u"d",
    am=7.0 * 365.0u"d",
    Lp=15.0u"cm",
    Li=32.5u"cm",
    Wwb=2.4e-3u"g",
    Wwp=35.0u"g",
    Wwi=157.0u"g",
    Ri=4.0e3 / 365.0u"d"
)

data = merge(data, (; tL))

temp = (;
    ab=Unitful.K(4Unitful.°C),
    tp=Unitful.K(4Unitful.°C),
    am=Unitful.K(4Unitful.°C),
    ri=Unitful.K(4Unitful.°C),
    tL=Unitful.K(4Unitful.°C),
)

bibkey = (
    ab="guess",
    am="guess",
    Lp="guess",
    Li="fishbase",
    Wwb="guess",
    Wwp="guess",
    Wwi="fishbase",
    Ri="guess",
    tL="Bouc2014",
    F1="fishbase"
)

## set weights for all real data
weights=DEBtool_J.setweights(data);
weights=merge(weights, (tL=3*weights.tL,))
## set pseudodata and respective weights
(psd, psdLabel, psdweights)=addpseudodata()
psd=merge(psd, (k=0.3,))

label = (;
    ab="age at birth",
    am="life span",
    Lp="length at puberty",
    Li="ultimate length",
    Wwb="wet weight at birth",
    Wwp="wet weight at puberty",
    Wwi="ultimate wet weight for females",
    Ri="maximum reprod rate",
    tL=["time since birth", "length"],
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
    D1="males are assumed not to differ from females",
    D2="Wwp is ignorned due to inconsistency with Lp and (Li,Wwi) data"
)

# Facts
facts = (
    F1 = "length-weight: weight in g = 0.00794*(TL in cm)^3.10"
)

# Links
links = (;
    id_CoL="GB2Z", # Cat of Life
    id_ITIS="164704", # ITIS
    id_EoL="46564404", # Ency of Life
    id_Wiki="Arctogadus_glacialis", # Wikipedia
    id_ADW="Arctogadus_glacialis", # ADW
    id_Taxo="44295", # Taxonomicon
    id_WoRMS="126432", # WoRMS
    id_fishbase="Arctogadus-glacialis'", # fishbase
)

comment = (;
    ab="all temps are guessed",
    am="",
    Lb="",
    Lp="",
    Li="",
    Wwb="based on egg diameter of 1.67 mm of Boreogadus saida: pi/6*0.167^3",
    Wwp="based on 0.00794*Lp^3.10, see F1",
    Wwi="based on 0.00794*Li^3.10, see F1",
    Ri="based on Boreogadus saida",
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

auxData = (;
    temp=temp,
)

# ## References
bibkey = "Wiki";
type = "Misc";
bib = "howpublished = {\\url{https://en.wikipedia.org/wiki/Arctogadus_glacialis}}";
Wiki = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";

# #
bibkey = "Kooy2010";
type = "Book";
bib = [
    "author = {Kooijman, S.A.L.M.}, ",
    "year = {2010}, ",
    "title  = {Dynamic Energy Budget theory for metabolic organisation}, ",
    "publisher = {Cambridge Univ. Press, Cambridge}, ",
    "pages = {Table 4.2 (page 150), 8.1 (page 300)}, ",
    "howpublished = {\\url{../../../bib/Kooy2010.html}}"
];
Kooy2010 = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";

# #
bibkey = "Bouc2014";
type = "PhDthesis";
bib = [
    "author = {Caroline Bouchard}, ",
    "year = {2014}, ",
    "title = {\\emph{Boreogadus saida} et \\emph{Arctogadus glacialis} Vie larvaire et juv\\'{e}nile de deux gadid\\'{e}s se partageant l''oc\\'{e}an {A}rctique }, ",
    "school = {Laval Univ.}"
];
Bouc2014 = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";

# #
bibkey = "fishbase";
type = "Misc";
bib = "howpublished = {\\url{https://www.fishbase.se/summary/Arctogadus-glacialis.html}}";
fishbase = "''@" * type * "{" * bibkey * ", " * join(bib) * "}'';";

# #
biblist = [Wiki, Kooy2010, Bouc2014, fishbase];

metaData = (;
    ecoCode=ecoCode,
    links=links,
    facts=facts,
    discussion=discussion,
    bibkey=bibkey,
    biblist=biblist,
)

(; data, auxData, metaData, txtData, weights)
