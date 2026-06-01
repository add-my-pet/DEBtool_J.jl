using Test, DEBtool_J, Arrow, DataFrames, Unitful, TraitDataSources

# ── Inline fixture builder ─────────────────────────────────────────────────────
# Builds a minimal DataFrame matching the traits_build Arrow schema for
# Emydura macquarii.  Time values are in days (canonical unit).

const _TAXON   = "Emydura_macquarii"
const _T_TYP   = 295.15   # K — informational only (T_typical, NOT used in estimation)

const _tL_years = [0.981,0.981,1.956,1.956,1.957,1.957,1.957,1.958,1.958,1.983,
                   2.833,2.908,2.931,2.932,2.984,3.008,3.833,3.834,3.834,3.857,
                   3.883,3.883,3.883,3.934]
const _tL_cm    = [6.876,7.090,8.369,8.689,9.115,9.435,9.808,10.075,10.235,10.661,
                   11.141,11.354,9.701,10.768,12.420,11.674,13.220,13.326,13.646,12.100,
                   12.420,12.633,12.953,14.072]

function _row(;
    trait_name, value, unit,
    temperature=missing,           # missing = not individually recorded (use T_typical fallback)
    deb_field, deb_transition=missing, deb_sex=missing,
    deb_x_type=missing, deb_y_type=missing,
    deb_temperature_required::Bool, f=1.0,
    dataset_id="AmP_zerovariate",
    x_value=missing, x_unit=missing, weights=1.0,
)
    (;
        taxon_name_underscore = _TAXON,
        taxon_name            = replace(_TAXON, "_" => " "),
        trait_name,
        value                 = Float64(value),
        unit,
        temperature           = ismissing(temperature) ? missing : Float64(temperature),
        T_typical             = Float64(_T_TYP),
        deb_field,
        deb_transition,
        deb_sex,
        deb_x_type,
        deb_y_type,
        deb_temperature_required,
        f                     = Float64(f),
        dataset_id,
        x_value               = ismissing(x_value) ? missing : Float64(x_value),
        x_unit,
        weights               = Float64(weights),
    )
end

function _make_fixture()
    # All time/rate rows use the recorded temperatures from MATLAB mydata (C2K(22)=295.15 K
    # for most; C2K(30)=303.15 K for the second ab observation).
    scalars = [
        # timesincefertilisation — temperature required → AtTemperature(recorded temp)
        _row(trait_name="ab",  value=78.0,   unit="d",
             temperature=295.15,
             deb_field="timesincefertilisation", deb_transition="Birth",
             deb_temperature_required=true),
        _row(trait_name="ab",  value=48.0,   unit="d",
             temperature=303.15,
             deb_field="timesincefertilisation", deb_transition="Birth",
             deb_temperature_required=true),
        _row(trait_name="am",  value=7628.0, unit="d",
             temperature=295.15,
             deb_field="timesincefertilisation", deb_transition="Ultimate",
             deb_sex="Female", deb_temperature_required=true),
        # timesincebirth — temperature required
        _row(trait_name="tp",  value=3650.0, unit="d",
             temperature=295.15,
             deb_field="timesincebirth", deb_transition="Puberty",
             deb_sex="Female", deb_temperature_required=true),
        _row(trait_name="tpm", value=2008.0, unit="d",
             temperature=295.15,
             deb_field="timesincebirth", deb_transition="Puberty",
             deb_sex="Male", deb_temperature_required=true),
        # length — NOT temperature required
        _row(trait_name="Lb",  value=2.7,  unit="cm",
             deb_field="length", deb_transition="Birth",
             deb_temperature_required=false),
        _row(trait_name="Lp",  value=18.7, unit="cm",
             deb_field="length", deb_transition="Puberty",  deb_sex="Female",
             deb_temperature_required=false),
        _row(trait_name="Lpm", value=14.7, unit="cm",
             deb_field="length", deb_transition="Puberty",  deb_sex="Male",
             deb_temperature_required=false),
        _row(trait_name="Li",  value=21.4, unit="cm",
             deb_field="length", deb_transition="Ultimate", deb_sex="Female",
             deb_temperature_required=false),
        _row(trait_name="Lim", value=20.8, unit="cm",
             deb_field="length", deb_transition="Ultimate", deb_sex="Male",
             deb_temperature_required=false),
        # wetweight — NOT temperature required
        _row(trait_name="Wwb",  value=8.0,    unit="g{wet}",
             deb_field="wetweight", deb_transition="Birth",
             deb_temperature_required=false),
        _row(trait_name="Wwp",  value=2669.0, unit="g{wet}",
             deb_field="wetweight", deb_transition="Puberty",  deb_sex="Female",
             deb_temperature_required=false),
        _row(trait_name="Wwpm", value=1297.0, unit="g{wet}",
             deb_field="wetweight", deb_transition="Puberty",  deb_sex="Male",
             deb_temperature_required=false),
        _row(trait_name="Wwi",  value=4000.0, unit="g{wet}",
             deb_field="wetweight", deb_transition="Ultimate", deb_sex="Female",
             deb_temperature_required=false),
        _row(trait_name="Wwim", value=3673.0, unit="g{wet}",
             deb_field="wetweight", deb_transition="Ultimate", deb_sex="Male",
             deb_temperature_required=false),
        # reproduction — temperature required → AtTemperature(295.15 K = C2K(22))
        _row(trait_name="Ri", value=0.0986, unit="#{offspring}/d",
             temperature=295.15,
             deb_field="reproduction", deb_transition="Ultimate", deb_sex="Female",
             deb_temperature_required=true),
    ]

    tL_rows = [
        _row(
            trait_name="tL", value=_tL_cm[i], unit="cm",
            temperature=295.15,
            deb_field="variate", deb_x_type="Time", deb_y_type="Length",
            deb_temperature_required=true,
            dataset_id="AmP_univariate",
            x_value=_tL_years[i] * 365.25, x_unit="d",
            weights=2.0 / length(_tL_years),
        )
        for i in eachindex(_tL_years)
    ]

    DataFrame(vcat(scalars, tL_rows))
end

# Write fixture to a temp Arrow file and wrap in DEBTraitDB
function _with_db(f)
    mktempdir() do dir
        path = joinpath(dir, "traits_build.arrow")
        Arrow.write(path, _make_fixture())
        f(DEBTraitDB(path))
    end
end

# ── Tests ──────────────────────────────────────────────────────────────────────

@testset "materialize Emydura_macquarii" begin
    _with_db() do db

        @testset "available_traits" begin
            traits = available_traits(db, _TAXON)
            @test :tL  ∈ traits
            @test :Lb  ∈ traits
            @test :am  ∈ traits
            @test :Ri  ∈ traits
        end

        q    = TraitQuery(_TAXON)
        data = materialize(q, db)

        @testset "EstimationData.temperature is T_ref = 293.15 K" begin
            @test data.temperature ≈ 293.15u"K"
        end

        @testset "time/rate traits wrapped with AtTemperature" begin
            tsf = data.data.timesincefertilisation

            # ab rows have actual recorded temperatures (295.15 K and 303.15 K)
            @test any(tsf) do v
                v isa Birth && v.val isa AtTemperature &&
                ustrip(u"K", v.val.t) ≈ 295.15 &&
                ustrip(u"d", v.val.val) ≈ 78.0
            end
            @test any(tsf) do v
                v isa Birth && v.val isa AtTemperature &&
                ustrip(u"K", v.val.t) ≈ 303.15 &&
                ustrip(u"d", v.val.val) ≈ 48.0
            end

            # am (longevity): temperature = C2K(22) = 295.15 K (from MATLAB mydata)
            @test any(tsf) do v
                v isa Female &&
                v.val isa Ultimate &&
                v.val.val isa AtTemperature &&
                ustrip(u"K", v.val.val.t) ≈ 295.15 &&
                ustrip(u"d", v.val.val.val) ≈ 7628.0
            end

            # tp: Female > Puberty > AtTemperature (C2K(22) = 295.15 K)
            @test any(data.data.timesincebirth) do v
                v isa Female && v.val isa Puberty && v.val.val isa AtTemperature &&
                ustrip(u"K", v.val.val.t) ≈ 295.15
            end

            # Ri: Female > Ultimate > AtTemperature (C2K(22) = 295.15 K)
            ri = data.data.reproduction
            @test ri isa Tuple && length(ri) == 1
            @test ri[1] isa Female
            @test ri[1].val isa Ultimate
            @test ri[1].val.val isa AtTemperature
            @test ustrip(u"K", ri[1].val.val.t) ≈ 295.15
            @test ustrip(u"d^-1", ri[1].val.val.val) ≈ 0.0986
        end

        @testset "size/weight traits NOT wrapped with AtTemperature" begin
            lens = data.data.length
            wws  = data.data.wetweight

            # Lb: Birth, plain value
            @test any(lens) do v
                v isa Birth && !(v.val isa AtTemperature) &&
                ustrip(u"cm", v.val) ≈ 2.7
            end
            # Li: Female > Ultimate, plain value
            @test any(lens) do v
                v isa Female && v.val isa Ultimate &&
                !(v.val.val isa AtTemperature) &&
                ustrip(u"cm", v.val.val) ≈ 21.4
            end
            # Wwb: Birth, plain value
            @test any(wws) do v
                v isa Birth && !(v.val isa AtTemperature) &&
                ustrip(u"g", v.val) ≈ 8.0
            end
        end

        @testset "length field transitions and sexes" begin
            lens = data.data.length
            @test length(lens) == 5
            @test any(v -> v isa Birth,                           lens)  # Lb
            @test any(v -> v isa Female && v.val isa Puberty,     lens)  # Lp
            @test any(v -> v isa Male   && v.val isa Puberty,     lens)  # Lpm
            @test any(v -> v isa Female && v.val isa Ultimate,    lens)  # Li
            @test any(v -> v isa Male   && v.val isa Ultimate,    lens)  # Lim
        end

        @testset "univariate tL" begin
            @test !isnothing(data.data.variate)
            @test length(data.data.variate) == 1
            # deb_temperature_required=true → variate wrapped in AtTemperature(295.15 K)
            wrapped = data.data.variate[1]
            @test wrapped isa AtTemperature
            @test ustrip(u"K", wrapped.t) ≈ 295.15
            uv = wrapped.val
            @test uv isa Univariate
            @test uv.independent isa Time
            # EstimationData strips Weighted wrappers into data.weights;
            # uv.dependent is Length with data in an SVector.
            @test uv.dependent isa Length
            @test length(uv.dependent.val) == 24
            # Total weight = 2.0/24 × 24 = 2.0; stored as a flat SVector in data.weights
            @test sum(data.weights.variate[1]) ≈ 2.0
        end

        @testset "explicit trait selection with weight override" begin
            q2 = TraitQuery(_TAXON;
                traits  = (:Lb, :Li, :Lim, :ab, :tL),
                weights = ((trait=:tL, weight=5.0),),
            )
            data2 = materialize(q2, db)
            @test length(data2.data.length) == 3   # Lb, Li, Lim only
            @test !isnothing(data2.data.timesincefertilisation)
            @test isnothing(data2.data.wetweight)
            @test sum(data2.weights.variate[1]) ≈ 5.0
        end

        @testset "submitter filter" begin
            # entry_author column not yet in Arrow file; submitter filter warns and
            # returns all data rather than throwing — re-enable strict test once added.
            q3 = TraitQuery(_TAXON; submitter="Kearney")
            @test !isnothing(materialize(q3, db))

            q4 = TraitQuery(_TAXON; submitter="Nobody")
            @test_skip materialize(q4, db)   # requires entry_author column
        end

        @testset "exclude" begin
            q5   = TraitQuery(_TAXON; exclude=(:tL,))
            data5 = materialize(q5, db)
            @test isnothing(data5.data.variate)
        end
    end
end
