function predict(e::AbstractEstimator, model::DEBOrganism, par, speciesdata) # predict
    (; data, auxData, data2) = speciesdata
    cPar = compound_parameters(model, par)
    d_V = 1Unitful.u"g/cm^3"               # cm, physical length at birth at f

    par = merge(par, cPar, (; d_V))
    # Add male params, will be empty if there is no dimorphic lifestage
    male = compute_male_params(model, par)
    par = merge(par, (; male))
    lifestage_state = compute_transition_state(e, model.lifestages, par)

    (; temp) = auxData
    tr = model.temperatureresponse
    TC = tempcorr(tr, par, temp.am)
    TC_30 = tempcorr(tr, par, temp.ab30)
    TC_Ri = tempcorr(tr, par, temp.Ri)

    τ_b =   lifestage_state[Birth()].τ
    l_b =   lifestage_state[Birth()].l
    L_b =   lifestage_state[Birth()].L
    Lw_b =  lifestage_state[Birth()].Lw
    Ww_b =  lifestage_state[Birth()].Ww
    a_b =  lifestage_state[Birth()].a
    a30_b = lifestage_state[Birth()].a
    t_p =  lifestage_state[Female(Puberty())].t
    τ_p =   lifestage_state[Female(Puberty())].τ
    L_p =   lifestage_state[Female(Puberty())].L
    Lw_p =  lifestage_state[Female(Puberty())].Lw
    Ww_p =  lifestage_state[Female(Puberty())].Ww
    l_i =   lifestage_state[Female(Ultimate())].l
    L_i =   lifestage_state[Female(Ultimate())].L
    Lw_i =  lifestage_state[Female(Ultimate())].Lw
    Ww_i =  lifestage_state[Female(Ultimate())].Ww
    t_pm = lifestage_state[Male(Puberty())].t
    L_pm =  lifestage_state[Male(Puberty())].L
    Lw_pm = lifestage_state[Male(Puberty())].Lw
    Ww_pm = lifestage_state[Male(Puberty())].Ww
    L_im =  lifestage_state[Male(Ultimate())].L
    Lw_im = lifestage_state[Male(Ultimate())].Lw
    Ww_im = lifestage_state[Male(Ultimate())].Ww
    a_m = lifestage_state[Female(Ultimate())].a

    (; R) = compute_reproduction_rate(e, par, lifestage_state)

    # uni-variate data
    tL = compute_univariate(e, Lengths(), Times(auxData.tLt), par, lifestage_state, TC)

    predictions1 = (
        age = map(data2.age) do x
            if x isa AbstractTransition{<:AtTemperature}
                lifestage_state[x].a / tempcorr(tr, par, x.val.t)
            else
                lifestage_state[x].a / TC
            end
        end,
        time = map(data2.time) do x
            if x isa AbstractTransition{<:AtTemperature}
                lifestage_state[x].t / tempcorr(tr, par, x.val.t)
            else
                lifestage_state[x].t / TC
            end
        end,
        length = map(x -> lifestage_state[x].Lw, data2.length),
        wetweigth = map(x -> lifestage_state[x].Ww, data2.wetweight),
        Ri=R * TC_Ri,
        tL,
    )

    # pack to output
    predictions = (;
        ab=a_b / TC,
        ab30=a30_b / TC_30,
        am=a_m / TC,
        tp=t_p / TC,
        tpm=t_pm / TC,
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
        Ri=R * TC_Ri,
        tL,
    )
    f(d) = Flatten.modify(x -> x isa AtTemperature ? x.x : x, Flatten.flatten(d, DEBtool_J.SELECT), DEBtool_J.SELECT)
    @assert f(predictions) == f(predictions1)
    info = true # TODO get this from solves
    return (; predictions, info)
end
