# Test script for iso221 model
# Parameters from MATLAB DEBtool_M/iso_21/mydata_iso_221.m
# Tests:
#   1. Module loading and parameter compound calculation
#   2. sgr_iso221 growth rate solver convergence
#   3. Embryo shooting method produces reasonable birth state

using DEBtool_J
using Test
using Unitful
using ModelParameters

p_raw = (;
    M_X1   = Const(1e-3,  units=u"mol",        label="food particle size 1"),
    M_X2   = Const(1e-3,  units=u"mol",        label="food particle size 2"),
    F_X1m  = Const(2.0,   units=u"dm^2/d/cm^2",         label="searching rate food 1"),
    F_X2m  = Const(3.0,   units=u"dm^2/d/cm^2",         label="searching rate food 2"),
    J_X1Am = Param(2.0e-3, units=u"mol/d/cm^2", label="max ingestion rate food 1"),
    J_X2Am = Param(2.0e-3, units=u"mol/d/cm^2", label="max ingestion rate food 2"),
    y_E1X1 = Param(0.45,  units=u"mol/mol",        label="yield E1 on X1"),
    y_E2X1 = Param(0.35,  units=u"mol/mol",        label="yield E2 on X1"),
    y_E1X2 = Param(0.35,  units=u"mol/mol",        label="yield E1 on X2"),
    y_E2X2 = Param(0.45,  units=u"mol/mol",        label="yield E2 on X2"),
    y_P1X1 = Const(0.15,  units=u"mol/mol",        label="faecal yield P1 on X1"),
    y_P2X2 = Const(0.15,  units=u"mol/mol",        label="faecal yield P2 on X2"),
    y_VE1  = Param(0.8,   units=u"mol/mol",        label="yield V on E1"),
    y_VE2  = Param(0.8,   units=u"mol/mol",        label="yield V on E2"),
    v      = Param(0.02,  units=u"cm/d",        label="energy conductance"),
    kap    = Param(0.8,   units=nothing,        label="allocation fraction to soma"),
    mu_E1  = Const(4e5,   units=u"J/mol",       label="chemical potential E1"),
    mu_E2  = Const(6e5,   units=u"J/mol",       label="chemical potential E2"),
    mu_V   = Const(5e5,   units=u"J/mol",       label="chemical potential V"),
    j_E1M  = Param(0.09,  units=u"mol/d/mol",        label="spec somatic maint E1"),
    j_E2M  = Param(0.09 * 6e5 / 4e5, units=u"mol/d/mol", label="spec somatic maint E2"),
    J_E1T  = Const(0.0,   units=u"mol/d/cm^2",  label="surface-linked maint E1"),
    J_E2T  = Const(0.0,   units=u"mol/d/cm^2",  label="surface-linked maint E2"),
    MV     = Param(4e-3,  units=u"mol/cm^3",    label="volume-specific structure density"),
    kap_E1 = Const(0.0,   units=nothing,        label="rejected flux return fraction E1"),
    kap_E2 = Const(0.0,   units=nothing,        label="rejected flux return fraction E2"),
    kap_R1 = Const(0.95,  units=nothing,        label="reproduction efficiency E1"),
    kap_R2 = Const(0.95,  units=nothing,        label="reproduction efficiency E2"),
    rho1   = Const(0.01,  units=nothing,        label="maintenance preference for E1"),
    del_V  = Const(0.8,   units=nothing,        label="shrinking threshold"),
    E_Hb   = Param(1e1,   units=u"J",           label="maturity at birth"),
    E_Hp   = Param(2e4,   units=u"J",           label="maturity at puberty"),
    k_J    = Const(0.002, units=u"d^-1",        label="maturity maintenance rate"),
    k1_J   = Const(0.002, units=u"d^-1",        label="rejuvenation rate"),
    T_ref  = 293.0u"K",
    T_A    = Const(8000.0, units=u"K",          label="Arrhenius temperature"),
    h_H    = Const(1e-5,  units=u"d^-1",        label="hazard from rejuvenation"),
    h_a    = Const(2e-8,  units=u"d^-2",        label="Weibull aging acceleration"),
    s_G    = Const(1e-4,  units=nothing,        label="Gompertz stress coefficient"),
    n_CX1 = Const(1.0, units=nothing, label="C index X1"), n_HX1 = Const(1.8, units=nothing, label="H index X1"),
    n_OX1 = Const(0.5, units=nothing, label="O index X1"), n_NX1 = Const(0.2, units=nothing, label="N index X1"),
    n_CX2 = Const(1.0, units=nothing, label="C index X2"), n_HX2 = Const(1.8, units=nothing, label="H index X2"),
    n_OX2 = Const(0.5, units=nothing, label="O index X2"), n_NX2 = Const(0.2, units=nothing, label="N index X2"),
    n_CV  = Const(1.0, units=nothing, label="C index V"),  n_HV  = Const(1.8, units=nothing, label="H index V"),
    n_OV  = Const(0.5, units=nothing, label="O index V"),  n_NV  = Const(0.2, units=nothing, label="N index V"),
    n_CE1 = Const(1.0, units=nothing, label="C index E1"), n_HE1 = Const(1.61, units=nothing, label="H index E1"),
    n_OE1 = Const(0.33, units=nothing, label="O index E1"), n_NE1 = Const(0.28, units=nothing, label="N index E1"),
    n_CE2 = Const(1.0, units=nothing, label="C index E2"), n_HE2 = Const(2.0, units=nothing, label="H index E2"),
    n_OE2 = Const(0.6, units=nothing, label="O index E2"),  n_NE2 = Const(0.0, units=nothing, label="N index E2"),
    n_CP1 = Const(1.0, units=nothing, label="C index P1"), n_HP1 = Const(1.8, units=nothing, label="H index P1"),
    n_OP1 = Const(0.5, units=nothing, label="O index P1"), n_NP1 = Const(0.2, units=nothing, label="N index P1"),
    n_CP2 = Const(1.0, units=nothing, label="C index P2"), n_HP2 = Const(1.8, units=nothing, label="H index P2"),
    n_OP2 = Const(0.6, units=nothing, label="O index P2"), n_NP2 = Const(0.0, units=nothing, label="N index P2"),
    n_CC = Const(1.0, units=nothing, label=""), n_CH = Const(0.0, units=nothing, label=""),
    n_CO = Const(2.0, units=nothing, label=""), n_CN = Const(0.0, units=nothing, label=""),
    n_HC = Const(0.0, units=nothing, label=""), n_HH = Const(2.0, units=nothing, label=""),
    n_HO = Const(1.0, units=nothing, label=""), n_HN = Const(0.0, units=nothing, label=""),
    n_OC = Const(0.0, units=nothing, label=""), n_OH = Const(0.0, units=nothing, label=""),
    n_OO = Const(2.0, units=nothing, label=""), n_ON = Const(0.0, units=nothing, label=""),
    n_NC = Const(1.0, units=nothing, label=""), n_NH = Const(4.0, units=nothing, label=""),
    n_NO = Const(1.0, units=nothing, label=""), n_NN = Const(2.0, units=nothing, label=""),
)

# Strip Param/Const wrappers → raw values with Unitful units attached
p = ModelParameters.stripparams(p_raw)

@testset "iso221 model" begin
    @testset "compound_parameters" begin
        model = iso221_animal()
        cp = compound_parameters(model, p)
        @test cp.m_E1m > zero(cp.m_E1m)
        @test cp.m_E2m > zero(cp.m_E2m)
        @test cp.L_m   > zero(cp.L_m)
        @test cp.L_m   < 100 * oneunit(cp.L_m)  # sanity: not unreasonably large
        @test size(cp.n_O) == (4, 7)
        @test size(cp.n_M) == (4, 4)
        println("L_m = $(cp.L_m), m_E1m = $(cp.m_E1m), m_E2m = $(cp.m_E2m)")
    end

    @testset "sgr_iso221 solver" begin
        model = iso221_animal()
        cp    = compound_parameters(model, p)
        mu_EV = p.mu_E1 / p.mu_V
        k_E   = p.v / cp.L_m          # at max length, r should ≈ 0
        r, j1S, j2S, j1C, j2C, info = DEBtool_J._sgr_iso221(
            cp.m_E1m, cp.m_E2m, p.j_E1M, p.j_E2M,
            p.y_VE1, p.y_VE2, mu_EV, k_E, p.kap, p.rho1, zero(k_E)
        )
        @test info == true
        @test abs(r) < 0.01 * oneunit(k_E)
        println("sgr at L_m: r = $r (should ≈ 0)")

        k_E_small = p.v / (cp.L_m / 2)
        r2, = DEBtool_J._sgr_iso221(
            cp.m_E1m, cp.m_E2m, p.j_E1M, p.j_E2M,
            p.y_VE1, p.y_VE2, mu_EV, k_E_small, p.kap, p.rho1, zero(k_E_small)
        )
        @test r2 > zero(r2)
        println("sgr at L_m/2: r = $r2 (should > 0)")
    end

    @testset "embryo shooting method" begin
        p_full = merge(p, compound_parameters(iso221_animal(), p))
        var_b, a_b, M_E10, M_E20 = DEBtool_J._iso221_birth_state(p_full)
        @test M_E10 > zero(M_E10)
        @test M_E20 > zero(M_E20)
        @test a_b   > 0
        @test var_b.L_b > zero(var_b.L_b)
        @test var_b.E_Hb ≈ p.E_Hb
        println("Birth state: L_b = $(var_b.L_b), a_b = $a_b d")
        println("Initial reserves: M_E10 = $M_E10, M_E20 = $M_E20")
    end
end
