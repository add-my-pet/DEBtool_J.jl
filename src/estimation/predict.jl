function predict(e::AbstractEstimator, model::DEBAnimal, par, data, temperature, n=0)
    # Hacks for checking final params against matlab
    if n == -1
        ref = (; 
            T_ref = 293.1500,
              T_A = 8000,
                z = 8.4650,
              F_m = 6.5000,
            κ_X = 0.8000,
            κ_P = 0.1000,
                v = 0.069418,
              κ = 0.97377,
            κ_R = 0.9500,
              p_M = 678.3452,
              p_T = 0,
              k_J = 0.0020,
              E_G = 7.8323383e+03,
             E_Hb = 4095,
             E_Hx = 205800,
             E_Hp = 4440000,
              h_a = 2.5470e-12,
              s_G = 0.0100,
              t_0 = 36.0855,
            del_M = 0.11173,
                f = 1,
             f_tW = 1,
             t_0W = -4.0959,
              d_X = 0.3000,
              d_V = 0.3000,
              d_E = 0.3000,
              d_P = 0.3000,
             mu_X = 525000,
             mu_V = 500000,
             mu_E = 550000,
             mu_P = 480000,
             mu_C = 0,
             mu_H = 0,
             mu_O = 0,
             mu_N = 122000,
             n_CX = 1,
             n_HX = 1.8000,
             n_OX = 0.5000,
             n_NX = 0.1500,
             n_CV = 1,
             n_HV = 1.8000,
             n_OV = 0.5000,
             n_NV = 0.1500,
             n_CE = 1,
             n_HE = 1.8000,
             n_OE = 0.5000,
             n_NE = 0.1500,
             n_CP = 1,
             n_HP = 1.8000,
             n_OP = 0.5000,
             n_NP = 0.1500,
             n_CC = 1,
             n_HC = 0,
             n_OC = 2,
             n_NC = 0,
             n_CH = 0,
             n_HH = 2,
             n_OH = 1,
             n_NH = 0,
             n_CO = 0,
             n_HO = 0,
             n_OO = 2,
             n_NO = 0,
             n_CN = 1,
             n_HN = 4,
             n_ON = 1,
             n_NN = 2,
        )
        # @show collect(keys(ref)) .=> collect(map(ustrip, par[keys(ref)])) .=> collect(ref)
        # vals = tuple.(collect(keys(ref)), collect(map(ustrip, par[keys(ref)])) .=> collect(ref), collect(map(ustrip, par[keys(ref)])) .== collect(ref))
        # @show vals
        # vals = filter(v -> v[3] == 0, vals)
        # @show vals
        # @show keys(ref)[3]
        # @show par[keys(ref)][3] collect(ref)[3]
        # @show collect(map(ustrip, par[keys(ref)])) .== collect(ref)
        @assert all(collect(map(ustrip, par[keys(ref)])) .== collect(ref))
        @assert map(ustrip, par[keys(ref)]) == ref
    end

    par = merge(compound_parameters(model, par), par)

    # Add male params, they will be empty if there is no dimorphic lifestage
    male = compute_male_params(model, par)
    par = merge(par, (; male))

    transitions = compute_transition_state(e, model, par)
    tr = model.temperatureresponse
    tc = tempcorr(tr, par, temperature)

    # ages = _temp_correct_predictions(x -> x.a, tr, par, transitions, (Birth(), Female(Puberty()), Female(Ultimate())), tc)
    # tspan = (0.0, ustrip(u"d", last(ages)))

    # environment = ConstantEnvironment(;
    #     time=tspan,
    #     functionalresponse=par.f,
    #     tempcorrection=tc,
    # ) 
    # mpe = DEBtool_J.MetabolismBehaviorEnvironment(; metabolism=model, environment, par)
    # sol = simulate(mpe; tspan)
    # vals = map(a -> sol(ustrip(u"d", a)), ages)
    # Birth length is the same
    # @assert sol[1][2] * par.L_m / par.del_M ≈ predictions.length[1] 
    # @show predictions.length[4] 
    # @show last(vals)[2] * par.L_m / par.del_M
    # @show sol[end][2] * par.L_m / par.del_M
    # Only calculate reproduction when needed

    # @show transitions[Puberty()]
    # @show transitions[Ultimate()]
    predictions = EstimationFields(
        timesincefertilisation = isnothing(data.timesincefertilisation) ? nothing : _temp_correct_predictions(x -> x.a, tr, par, transitions, data.timesincefertilisation, tc),
        timesincebirth = isnothing(data.timesincebirth) ? nothing : _temp_correct_predictions(x -> x.t, tr, par, transitions, data.timesincebirth, tc),
        length = isnothing(data.length) ? nothing : map(x -> transitions[x].Lw, data.length),
        wetweight = isnothing(data.wetweight) ? nothing : map(x -> transitions[x].Ww, data.wetweight),
        gestation = isnothing(data.gestation) ? nothing : gestation(par, transitions[Birth()].τ, tc),
        reproduction = if isnothing(data.reproduction)
            nothing
        else
            R = compute_reproduction_rate(e, model, par, transitions)
            r_at_t = Flatten.flatten(data.reproduction, AtTemperature)
            RT = if isempty(r_at_t)
                R * tc
            else
                tc_R = tempcorr(tr, par, only(r_at_t).t)
                R * tc_R
            end
        end,
        variate = if isnothing(data.variate)
            nothing
        else
            # uni-variate data
            map(data.variate) do u
                predict_variate(e, model, u, par, transitions, tc)
            end
        end
    )

    if n == -1
        @show "Checking predictions..."
        println(predictions) 
        d = (;
            tg = 52.311124108759159,
            tx = 45.303672529123801,
            tp = 3.145344895206874e+02,
            am = 7.748774439939329e+03,
            Lb = 17.261261878943422,
            Li = 75.763000089501475,
            Wwb = 95.438774624097007,
            Wwx = 1.479972942914628e+03,
            Wwi = 8.070096374380248e+03,
            Ri = 0.013766820776005,
        )
        @assert all(map((a, b) -> isapprox(ustrip(a.val), b; atol=1e-5), predictions.timesincebirth, values(d[(:tx, :tp)])))
        @assert all(map((a, b) -> isapprox(ustrip(a.val), b; atol=1e-4), predictions.timesincefertilisation, values(d[(:am,)])))
        @assert all(map((a, b) -> isapprox(ustrip(a.val), b; atol=1e-5), predictions.length, values(d[(:Lb, :Li)])))
        @assert all(map((a, b) -> isapprox(ustrip(a), b; atol=1e-5), predictions.wetweight, values(d[(:Wwb, :Wwx, :Wwi)])))
        @assert isapprox(ustrip(predictions.gestation), d.tg; atol=1e-5)
        @assert isapprox(ustrip(predictions.reproduction), d.Ri; atol=1e-5)
    end

    info = true 
    # Sort the returned value to match the data
    return (; predictions, info)
end

function _temp_correct_predictions(fieldgetter::Function, tr, par::NamedTuple, ls::Transitions, pred, tc::Number)
    map(pred) do p
        if p isa AbstractTransition{<:AtTemperature}
            rebuild(p, fieldgetter(ls[p]) / tempcorr(tr, par, p.val.t))
        else
            rebuild(p, fieldgetter(ls[p]) / tc)
        end
    end
end

function predict_variate(e::AbstractEstimator, o::DEBAnimal, us::Tuple, pars, transition_state, TC)
    map(us) do u
        predict_variate(e, o, u, pars, transition_state, TC)
    end
end
function predict_variate(e::AbstractEstimator, o::DEBAnimal, u::AtTemperature, pars, transition_state, TC_main)
    TC_data = tempcorr(temperatureresponse(o), u.t)
    predict_variate(e, o, u.x, pars, transition_state, TC_data)
end
predict_variate(e::AbstractEstimator, o::DEBAnimal, u::Univariate, pars, transition_state, TC) =
    predict_variate(e, o, u.independent, u.dependent, pars, transition_state, TC)
function predict_variate(e::AbstractEstimator, o::DEBAnimal, u::Multivariate, pars, transition_state, TC)
    map(u.dependents) do d
        predict_variate(e, o, u.independent, d, pars, transition_state, TC)
    end
end
function predict_variate(e::AbstractEstimator, o::DEBAnimal, u::Multivariate{<:Temperature}, pars, transition_state, TC)
    TCs = tempcorr(temperatureresponse(o), u.independent.val)
    map(u.dependents) do d
        predict_variate(e, o, u.independent, d, pars, transition_state, TC)
    end
end
function predict_variate(e::AbstractEstimator, o::DEBAnimal, independent::Time, dependent::Female, pars, transition_state, TC)
    predict_variate(e, o, u.independent, d.val, pars, transition_state, TC)
end
function predict_variate(e::AbstractEstimator, o::DEBAnimal, independent::Time, dependent::Male, pars, transition_state, TC)
    pars_male = merge(pars, pars.male)
    predict_variate(e, o, u.independent, d.val, pars_male, transition_state, TC)
end
function predict_variate(e::AbstractEstimator, o::DEBAnimal, independent::Time, dependent::Length, pars, transition_state, TC)
    (; k_M, f, g) = pars
    Lw_b = transition_state[Birth()].Lw
    Lw_i = transition_state[Ultimate()].Lw
    # TODO explain these equations
    rT_B = TC * k_M / 3 / (oneunit(f) + f / g)
    EWw = Lw_i .- (Lw_i .- Lw_b) .* exp.(-rT_B .* independent.val)
    return EWw
end
function predict_variate(e::AbstractEstimator, o::DEBAnimal, independent::Time, dependent::WetWeight, pars, transition_state, TC)
    (; f, k_M, L_m, v, ω) = pars
    L_b = transition_state[Birth()].L # cm, length at birth, ultimate
    L_i = transition_state[Ultimate()].L
    # time-weight 
    # f = f_tW TODO: how to allow a specific f for variate data
    ir_B = 3 / k_M + 3 * f * L_m / v
    rT_B = TC / ir_B     # d, 1/von Bert growth rate
    return (L_i .- (L_i .- L_b) .* exp.(-rT_B .* independent.val)) .^ 3 .* (oneunit(f) + f * ω) # g, wet weight
end
