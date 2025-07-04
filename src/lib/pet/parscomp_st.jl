function parscomp_st(p)
    # created 2013/07/08 by Bas Kooijman; modified 2015/01/17 Goncalo Marques
    # modified 2015/04/25 Starrlight, Bas Kooijman (kap_X_P replaced by kap_P)
    # modified 2015/08/03 by Starrlight, 2017/11/16, 2018/08/22 by Bas Kooijman, 
    # mod 2019/08/30 by Nina Marn (note on {p_Am})

    ## Syntax
    # cPar = <../parscomp_st.m *parscomp_st*> (par, chem)

    ## Description
    # Computes compound parameters from primary parameters that are frequently used
    #
    # Input
    #
    # * par : structure with parameters
    #  
    # Output
    #
    # * cPar : structure with scaled quantities and compound parameters

    ## Remarks
    # The quantities that are computed concern, where relevant:
    #
    # * p_Am: J/d.cm^2, {p_Am}, spec assimilation flux
    # * n_O, 4-4 matrix of chemical indices for water-free organics
    # * n_M,  4-4 matrix of chemical indices for minerals
    # * w_O, w_X, w_V, w_E, w_P: g/mol, mol-weights for (unhydrated)  org. compounds
    # * M_V: mol/cm^3, [M_V], volume-specific mass of structure
    # * y_V_E: mol/mol, yield of structure on reserve
    # * y_E_V: mol/mol, yield of reserve on structure
    # * k_M: 1/d, somatic maintenance rate coefficient
    # * k: -, maintenance ratio
    # * E_m: J/cm^3, [E_m], reserve capacity 
    # * m_Em: mol/mol, reserve capacity
    # * g: -, energy investment ratio
    # * L_m: cm, maximum length
    # * L_T: cm, heating length (also applies to osmotic work)
    # * l_T: - , scaled heating length
    # * w: -, \omega, contribution of ash free dry mass of reserve to total ash free dry biomass
    # * ome: -, \omega, contribution of ash free dry mass of reserve to total ash free dry biomass
    # * J_E_Am: mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux
    # * y_E_X: mol/mol, yield of reserve on food
    # * y_X_E: mol/mol, yield of food on reserve
    # * p_Xm: J/d.cm^2, max spec feeding power
    # * J_X_Am: mol/d.cm^2, {J_XAm}, max surface-spec feeding flux
    # * y_P_X: mol/mol, yield of faeces on food 
    # * y_X_P: mol/mol, yield of food on faeces
    # * y_P_E: mol/mol, yield of faeces on reserve
    # * eta_XA, eta_PA, eta_VG; eta_O: mol/J, mass-power couplers
    # * J_E_M: mol/d.cm^3, [J_EM], vol-spec somatic  maint costs
    # * J_E_T: mol/d.cm^2, {J_ET}, surface-spec somatic  maint costs
    # * j_E_M: mol/d.mol, mass-spec somatic  maint costs
    # * j_E_J: mol/d.mol, mass-spec maturity maint costs
    # * kap_G: -, growth efficiency
    # * E_V: J/cm^3, [E_V], volume-specific energy of structure
    # * K: c-mol X/l, half-saturation coefficient
    # * M_H*, U_H*, V_H*, v_H*, u_H*: scaled maturities computed from all unscaled ones: E_H*
    # * s_H: -, maturity ratio E_Hb/ E_Hp
    if hasproperty(p, :p_Am)
        p_Am = p.p_Am
    else
        p_Am = p.z * p.p_M / p.kap * 1u"cm"   # J/d.cm^2, {p_Am} spec assimilation flux; the expression for p_Am is multiplied also by L_m^ref = 1 cm, for units to match. 
    end

    cPar = (; p_Am)

    #         X       V       E       P
    n_O = @SMatrix[
            p.n_CX p.n_CV p.n_CE p.n_CP  # C/C, equals 1 by definition
            p.n_HX p.n_HV p.n_HE p.n_HP  # H/C  these values show that we consider dry-mass
            p.n_OX p.n_OV p.n_OE p.n_OP  # O/C
            p.n_NX p.n_NV p.n_NE p.n_NP
        ]u"mol" / u"mol" # N/C

    #          C       H       O       N
    n_M =
        @SMatrix[
            p.n_CC p.n_CH p.n_CO p.n_CN  # CO2
            p.n_HC p.n_HH p.n_HO p.n_HN  # H2O  
            p.n_OC p.n_OH p.n_OO p.n_ON  # O2
            p.n_NC p.n_NH p.n_NO p.n_NN
        ]u"mol" / u"mol" # NH3
    cPar = merge(cPar, (; n_O, n_M))

    # -------------------------------------------------------------------------
    # Molecular weights:
    w_O = n_O' * @SVector[12, 1, 16, 14]u"g" / u"mol" # g/mol, mol-weights for (unhydrated)  org. compounds
    w_X = w_O[1]
    w_V = w_O[2]
    w_E = w_O[3]
    w_P = w_O[4]
    cPar = merge(cPar, (; w_X, w_V, w_E, w_P))

    # -------------------------------------------------------------------------
    # Conversions and compound parameters cPar
    M_V = p.d_V / w_V            # mol/cm^3, [M_V], volume-specific mass of structure
    y_V_E = p.mu_E * M_V / p.E_G     # mol/mol, yield of structure on reserve
    y_E_V = 1 / y_V_E            # mol/mol, yield of reserve on structure
    k_M = p.p_M / p.E_G            # 1/d, somatic maintenance rate coefficient
    k = p.k_J / k_M            # -, maintenance ratio
    E_m = p_Am / p.v             # J/cm^3, [E_m], reserve capacity 
    m_Em = y_E_V * E_m / p.E_G   # mol/mol, reserve capacity
    g2 = p.E_G / p.kap / E_m      # -, energy investment ratio
    L_m = p.v / k_M / g2           # cm, maximum length
    L_T = p.p_T / p.p_M           # cm, heating length (also applies to osmotic work)
    l_T = L_T / L_m            # - , scaled heating length
    ome = m_Em * w_E * p.d_V / p.d_E / w_V # -, \omega, contribution of ash free dry mass of reserve to total ash free dry biomass
    w = ome                   # -, just for consistency with the past
    J_E_Am = p_Am / p.mu_E          # mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux

    cPar = merge(
        cPar, (; M_V, y_V_E, y_E_V, k_M, k, E_m, m_Em, g = g2, L_m, L_T, l_T, ome, w, J_E_Am),
    )

    if hasproperty(p, :E_Hp)
        s_H = p.E_Hb / p.E_Hp        # -, maturity ratio
    else
        s_H = 1
    end
    cPar = merge(cPar, (; s_H))

    if hasproperty(p, :kap_X)
        y_E_X = p.kap_X * p.mu_X / p.mu_E  # mol/mol, yield of reserve on food
        y_X_E = 1 / y_E_X            # mol/mol, yield of food on reserve
        p_Xm = p_Am / p.kap_X         # J/d.cm^2, max spec feeding power
        J_X_Am = y_X_E * J_E_Am      # mol/d.cm^2, {J_XAm}, max surface-spec feeding flux
        cPar = merge(cPar, (; y_E_X, y_X_E, p_Xm, J_X_Am))
    end

    if hasproperty(p, :kap_P)
        y_P_X = p.kap_P * p.mu_X / p.mu_P  # mol/mol, yield of faeces on food 
        y_X_P = 1 / y_P_X            # mol/mol, yield of food on faeces
        cPar = merge(cPar, (; y_P_X, y_X_P))
    end

    if hasproperty(p, :kap_X) && hasproperty(p, :kap_P)
        y_P_E = y_P_X / y_E_X          # mol/mol, yield of faeces on reserve
        #  Mass-power couplers
        eta_XA = y_X_E / p.mu_E          # mol/J, food-assim energy coupler
        eta_PA = y_P_E / p.mu_E          # mol/J, faeces-assim energy coupler
        eta_VG = y_V_E / p.mu_E          # mol/J, struct-growth energy coupler
        z = zero(eta_XA)
        eta_O = @SMatrix[
            -eta_XA z z         # mol/J, mass-energy coupler
            z z eta_VG    # used in: J_O = eta_O * p
            1/p.mu_E -1/p.mu_E -1/p.mu_E
            eta_PA z z
        ]
        cPar = merge(cPar, (; y_P_E, eta_XA, eta_PA, eta_VG, eta_O))
    end

    J_E_M = p.p_M / p.mu_E          # mol/d.cm^3, [J_EM], volume-spec somatic  maint costs
    J_E_T = p.p_T / p.mu_E          # mol/d.cm^2, {J_ET}, surface-spec somatic  maint costs
    j_E_M = k_M * y_E_V            # mol/d.mol, mass-spec somatic  maint costs
    j_E_J = p.k_J * y_E_V          # mol/d.mol, mass-spec maturity maint costs
    kap_G = p.mu_V * M_V / p.E_G    # -, growth efficiency
    E_V = p.d_V * p.mu_V / w_V    # J/cm^3, [E_V] volume-specific energy of structure
    cPar = merge(cPar, (; J_E_M, J_E_T, j_E_M, j_E_J, kap_G, E_V))

    if hasproperty(p, :F_m)
        K2 = J_X_Am / p.F_m        # c-mol X/l, half-saturation coefficient
        cPar = merge(cPar, (; K = K2))
    end

    if hasproperty(p, :E_Rj)
        v_Rj = p.kap / (1 - p.kap) * p.E_Rj / p.E_G
        cPar = merge(cPar, (; v_Rj))
    end

    parnames = string.(collect(keys(p)))
    matLev = parnames[findall(x -> x == "E_H", first.(parnames, 3))]
    matInd = replace.(matLev, "E_H" => "")
    mat_H = replace.(matLev, "E_" => "M_")
    mat_U = replace.(matLev, "E_" => "U_")
    mat_u = replace.(matLev, "E_" => "u_")
    mat_V = replace.(matLev, "E_" => "V_")
    mat_v = replace.(matLev, "E_" => "v_")

    return _add_pars(p, cPar, p_Am, g2, k_M)
end

# This is ugly
@generated function _add_pars(p::NamedTuple{P}, cPar, p_Am, g2, k_M) where P
    # add the Scaled maturity levels:
    parnames = string.(collect(P))
    matLev = parnames[findall(x -> x == "E_H", first.(parnames, 3))]
    matInd = replace.(matLev, "E_H" => "")
    mat_H = replace.(matLev, "E_" => "M_")
    mat_U = replace.(matLev, "E_" => "U_")
    mat_u = replace.(matLev, "E_" => "u_")
    mat_V = replace.(matLev, "E_" => "V_")
    mat_v = replace.(matLev, "E_" => "v_")

    blocks = map(1:length(matInd)) do i
        stri = matInd[i]
        quote
            M_Hx = getproperty(p, $(QuoteNode(Symbol("E_H" * stri)))) / p.mu_E
            cPar = merge(cPar, NamedTuple{($(QuoteNode(Symbol(mat_H[i]))),)}((M_Hx,)))
            U_Hx = getproperty(p, $(QuoteNode(Symbol("E_H" * stri)))) / p_Am
            cPar = merge(cPar, NamedTuple{($(QuoteNode(Symbol(mat_U[i]))),)}((U_Hx,)))
            V_Hx = getproperty(cPar, $(QuoteNode(Symbol("U_H" * stri)))) / (1 - p.kap)
            cPar = merge(cPar, NamedTuple{($(QuoteNode(Symbol(mat_V[i]))),)}((V_Hx,)))
            v_Hx = getproperty(cPar, $(QuoteNode(Symbol("V_H" * stri)))) * g2^2 * k_M^3 / p.v^2
            cPar = merge(cPar, NamedTuple{($(QuoteNode(Symbol(mat_v[i]))),)}((v_Hx,)))
            u_Hx = getproperty(cPar, $(QuoteNode(Symbol("U_H" * stri)))) * g2^2 * k_M^3 / p.v^2
            cPar = merge(cPar, NamedTuple{($(QuoteNode(Symbol(mat_u[i]))),)}((u_Hx,)))
        end

        #cPar.(['M_H', stri]) = p.(['E_H', stri])/ p.mu_E;                 % mmol, maturity at level i
        #cPar.(['U_H', stri]) = p.(['E_H', stri])/ p_Am;                   % cm^2 d, scaled maturity at level i
        #cPar.(['V_H', stri]) = cPar.(['U_H', stri])/ (1 - p.kap);         % cm^2 d, scaled maturity at level i
        #cPar.(['v_H', stri]) = cPar.(['V_H', stri]) * g^2 * k_M^3/ p.v^2; % -, scaled maturity density at level i
        #cPar.(['u_H', stri]) = cPar.(['U_H', stri]) * g^2 * k_M^3/ p.v^2; % -, scaled maturity density at level i 
    end
    blocks = Expr(:block, blocks...)
    return quote
        $blocks
        return cPar
    end
end
