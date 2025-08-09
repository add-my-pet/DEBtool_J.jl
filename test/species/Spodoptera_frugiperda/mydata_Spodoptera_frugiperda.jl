EstimationData(;
    temperature = u"K"(25u"°C"),
    timesinceconception = (
        AtTemperature(u"K"(22.0u"°C"), Birth(4.4u"d")),
    ),
    timesincebirth = (
        AtTemperature(u"K"(22.0u"°C"), Emergence(27.5u"d")),
    ),
    duration = (
        Instar{1}(2.57u"d"),
        Instar{2}(2.07u"d"),
        Instar{3}(2.13u"d"),
        Instar{4}(2.48u"d"),
        Instar{5}(2.57u"d"),
        Instar{6}(2.13u"d"),
        Pupa(11.57u"d"),
        AtTemperature(u"K"(22.0u"°C"), Pupa(27.5u"d")),
        Imago(18.4u"d"),
    ),
    length = (
        # TODO are these shifted up by one? the original says "instar n" but thats a period of time not an exact transition
        Moult{1}(0.035u"cm"),
        Moult{2}(0.057u"cm"),
        Moult{3}(0.087u"cm"),
        Moult{4}(0.129u"cm"),
        Moult{5}(0.189u"cm"),
        Moult{6}(0.28u"cm"),
    ),
    wetweight=(Pupa(0.2889u"g"),),
    # n_eggs=1604.2,
    variate = (
        Multivariate(
            Temperature(u"°C"),
            (   Duration{Instar{1}}(u"d"),
                Duration{Instar{2}}(u"d"),
                Duration{Instar{3}}(u"d"),
                Duration{Instar{4}}(u"d"),
                Duration{Instar{5}}(u"d"),
                Duration{Instar{6}}(u"d"),
                Duration{Pupa}(u"d"),
            ),
            "$(@__DIR__)/data/durations_Schl2018.csv",
        ),
        Multivariate(
            Temperature(u"°C"),
            (   Duration{Instar{1}}(u"d"),
                Duration{Instar{2}}(u"d"),
                Duration{Instar{3}}(u"d"),
                Duration{Instar{4}}(u"d"),
                Duration{Instar{5}}(u"d"),
                Duration{Instar{6}}(u"d"),
            ),
            "$(@__DIR__)/data/durations_LopeColl2019.csv"
        ),
        Univariate(
            Temperature(u"°C"), 
            Duration{Pupa}(u"d"), 
            "$(@__DIR__)/data/durations_pupa.csv"
        ),
        Univariate(
            Temperature(u"°C"),
            Period{Conception,Birth}(u"d"),
            "$(@__DIR__)/data/age_at_birth_1.csv"
        ),
        Univariate(
            Temperature(u"°C"),
            Period{Conception,Birth}(u"d"),
            "$(@__DIR__)/data/age_at_birth_2.csv"
        ),
    ),
    pseudo=(; v=Weighted(0.3, 0.02u"cm/d")),
)
# TODO implement max egg number
# data.Ni = 1604.2; units.Ni = '#'; label.Ni = 'number of eggs'; bibkey.Ni = 'BarrOliv2010';
   # comment.Ni ='Maximum egg numer found for corn';
