function estimate(model, options, par::P, mydata_pet) where P
    (; data, auxData, metaData, weights) = mydata_pet

    function objective(parvec, data, auxData)
        par1 = stripparams(ModelParameters.update(par, parvec)::P)
        prdData, info = predict(model, par1, data, auxData)
        prdData1 = predict_pseudodata(par1, data, prdData)
        return prdData1, info
    end
    function filter(parvec)
        par1 = stripparams(ModelParameters.update(par, parvec))
        filter_std(par1)
    end

    filternm = "filter_nat" # this filter always gives a pass

    par, info, nsteps, fval = petregr_f(objective, filter, model, par, data, auxData, weights, filternm, options)   # estimate parameters using overwrite
    return par, nsteps, info, fval
end

function predict(model::DEBOrganism, par, data, auxData) # predict
    cPar = parscomp_st(par)
    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    par = merge(par, cPar, (; d_V))
    # Add male params, will be empty if there is no dimorphic lifestage
    male = compute_male_params(model, par)
    par = merge(par, (; male))

    (; temp) = auxData
    tr = model.temperatureresponse
    TC = tempcorr(tr, par, temp.am)
    TC_30 = tempcorr(tr, par, temp.ab30)
    TC_Ri = tempcorr(tr, par, temp.Ri)

    par = merge(par, (; TC, TC_30, TC_Ri))
    lifestage_state = compute_transition_state(model.lifestages, par)

    τ_b =   lifestage_state[Birth()].τ
    l_b =   lifestage_state[Birth()].l
    L_b =   lifestage_state[Birth()].L
    Lw_b =  lifestage_state[Birth()].Lw
    Ww_b =  lifestage_state[Birth()].Ww
    aT_b =  lifestage_state[Birth()].aT[1]
    a30_b = lifestage_state[Birth()].aT[2]
    tT_p =  lifestage_state[Female(Puberty())].tT
    τ_p =   lifestage_state[Female(Puberty())].τ
    L_p =   lifestage_state[Female(Puberty())].L
    Lw_p =  lifestage_state[Female(Puberty())].Lw
    Ww_p =  lifestage_state[Female(Puberty())].Ww
    l_i =   lifestage_state[Female(Ultimate())].l
    L_i =   lifestage_state[Female(Ultimate())].L
    Lw_i =  lifestage_state[Female(Ultimate())].Lw
    Ww_i =  lifestage_state[Female(Ultimate())].Ww
    tT_pm = lifestage_state[Male(Puberty())].tT
    L_pm =  lifestage_state[Male(Puberty())].L
    Lw_pm = lifestage_state[Male(Puberty())].Lw
    Ww_pm = lifestage_state[Male(Puberty())].Ww
    L_im =  lifestage_state[Male(Ultimate())].L
    Lw_im = lifestage_state[Male(Ultimate())].Lw
    Ww_im = lifestage_state[Male(Ultimate())].Ww

    aT_m = compute_lifespan(par, l_b)
    RT_i = compute_reproduction(par, L_i, lifestage_state)

    # uni-variate data
    ELw = compute_univariate(Lengths(), Times(data.tL[:, 1]), par, Lw_i, Lw_b)

    # pack to output
    prdData = (;
        ab=aT_b,
        ab30=a30_b,
        tp=tT_p,
        tpm=tT_pm,
        am=aT_m,
        Lb=Lw_b,
        Lp=Lw_p,
        Lpm=Lw_pm,
        Li=Lw_i,
        Lim=Lw_im,
        Wwb=Ww_b,
        Wwp=Ww_p,
        Wwpm=Ww_pm,
        Wwi=Ww_i,
        Wwim=Ww_im,
        Ri=RT_i,
        tL=ELw,
    )
    info = true # TODO get this from solves
    return (; prdData, info)
end
