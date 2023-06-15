Base.@kwdef struct data_mod_struct{A,L,W,R}
    ab::A = Param(78.0, units = u"d", temperature = Unitful.K(22Unitful.°C), label = "age at birth", bibkey = "carettochelys", weight = (1), comment = "all temps are guessed")
    ab30::A = Param(48.0, units = u"d", temperature = Unitful.K(30Unitful.°C), label = "age at birth", bibkey = "carettochelys", weight = (1), comment = "")
    tp::A = Param(10.0*365.0, units = u"d", temperature = Unitful.K(22Unitful.°C), label = "time since birth at puberty for females", bibkey = "Spen2002", weight = (1), comment = "")
    tpm::A = Param(5.5*365.0, units = u"d", temperature = Unitful.K(22Unitful.°C), label = "time since birth at puberty for males", bibkey = "Spen2002", weight = (1), comment = "")
    am::A = Param(20.9*365.0, units = u"d", temperature = Unitful.K(22Unitful.°C), label = "life span", bibkey = "life span", weight = (1), comment = "")
    Lb::L = Param(2.7, units = u"cm", temperature = nothing, label = "plastron length at birth", bibkey = "Spen2002", weight = (1), comment = "")
    Lp::L = Param(18.7, units = u"cm", temperature = nothing, label = "plastron length at puberty for females", bibkey = "Spen2002", weight = (1), comment = "")
    Lpm::L = Param(14.7, units = u"cm", temperature = nothing, label = "plastron length at puberty for males", bibkey = "Spen2002", weight = (1), comment = "")
    Li::L = Param(21.4, units = u"cm", temperature = nothing, label = "ultimate plastron length for females", bibkey = "Spen2002", weight = (1), comment = "")
    Lim::L = Param(20.8, units = u"cm", temperature = nothing, label = "ultimate plastron length for males", bibkey = "Spen2002", weight = (1), comment = "")
    Wwb::W = Param(8.0, units = u"g", temperature = nothing, label = "wet weight at birth", bibkey = "Spen2002", weight = (1), comment = "based on (Lb/Li)^3*Wwi")
    Wwp::W = Param(2669.0, units = u"g", temperature = nothing, label = "wet weight at puberty for females", bibkey = "Spen2002", weight = (1), comment = "based on (Lp/Li)^3*Wwi")
    Wwpm::W = Param(1297.0, units = u"g", temperature = nothing, label = "wet weight at puberty for males", bibkey = "Spen2002", weight = (1), comment = "based on (Lpm/Li)^3*Ww")
    Wwi::W = Param(4000.0, units = u"g", temperature = nothing, label = "ultimate wet weight for females", bibkey = "carettochelys", weight = (1), comment = "all temps are guessed")
    Wwim::W = Param(3673.0, units = u"g", temperature = nothing, label = "ultimate wet weight for males", bibkey = "carettochelys", weight = (1), comment = "based on (Lim/Li)^3*Wwi")
    Ri::R = Param(36.0/365.0, units = u"1/d", temperature = Unitful.K(22Unitful.°C), label = "maximum reprod rate", bibkey = "Spen2002", weight = (1), comment = "#/d")
end

data_mod = Model(data_mod_struct())
data[:val]
collect(data[:val]).*data[:units]
data[:weight] = fill(1, 16)

Base.@kwdef struct tL_struct{TL}
 tL::TL
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
tL = tL_struct(tL = tL2)
data2 = Model(data_struct(), tL_struct(tL = tL2))
data = data_struct(tL = tL2, psd = psdData)


tL::Vector{String} = ["time since birth", "carapace length"]
psd