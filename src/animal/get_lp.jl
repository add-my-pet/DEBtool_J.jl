## get_lp
# Gest scaled length at puberty

##
function get_lp(p, f, lb0)
    # created at 2008/06/04 by Bas Kooijman, 
    # modified 2014/03/03 Starrlight Augustine, 2015/01/18, 2019/01/29 by Bas Kooijman

    ## Syntax
    # [lp, lb, info] = <../get_lp.m *get_lp*> (p, f, lb0)

    ## Description
    # Obtains scaled length at puberty at constant food density. 
    # If scaled length at birth (second input) is not specified, it is computed (using automatic initial estimate); 
    # If it is specified, however, is it just copied to the (second) output. 
    # Food density is assumed to be constant. scaled length at puberty is obtained ny integrating over time with even detection
    #
    # Input
    #
    # * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
    # * f: optional scalar with scaled functional responses (default 1)
    # * lb0: optional scalar with scaled length at birth
    #
    #      or optional 2-vector with scaled length, l, and scaled maturity, vH
    #      for a juvenile that is now exposed to f, but previously at another f
    #      lb0 should be specified for foetal development
    #  
    # Output
    #
    # * lp: scalar with scaled length at puberty
    # * lb: scalar with scaled length at birth
    # * info: indicator equals 1 if successful, 0 otherwise

    ## Remarks
    # Similar to <get_lp1.html *get_lp1*>, which uses root finding, rather than integration
    # Function <get_lp_foetus.html *get_lp_foetus*> does the same, but then for foetal development. 

    ## Example of use
    # get_lp([.5, .1, .1, .01, .2])

    # unpack pars
    (; g, k, l_T, v_Hb, v_Hp) = p

    if !@isdefined(f)
        f = 1
    elseif isempty(f)
        f = 1
    end
    li = f - lT # -, scaled ultimate length

    # TODO this all seems broken
    if !@isdefined(lb0)
        lb0 = []
        lb, info = get_lb((; g, k, vHb), f)
    elseif isempty(lb0)
        lb, info = get_lb((; g, k, vHb), f)
    elseif length(lb0) < 2
        info = true
        lb = lb0
    else # for a juvenile of length l and maturity vH
        l = lb0[1]
        vH = lb0[2] # juvenile now exposed to f
        lb, info = get_lb((; g, k, vHb), f)
    end

    # d/d tau vH = b2 l^2 + b3 l^3 - k vH
    b3 = 1 / (1 + g / f)
    b2 = f - b3 * li
    # vH(t) = - a0 - a1 exp(- rB t) - a2 exp(- 2 rB t) - a3 exp(- 3 rB t) +
    #         + (vHb + a0 + a1 + a2 + a3) exp(-kt)
    a0 = -(b2 + b3 * li) * li^2 / k # see get_lp1
    if vHp > -a0      # vH can only reach -a0
        lp = [;]
        info = false
        println("Warning in get_lp: maturity at puberty cannot be reached \n")
        return
    end

    if k == 1
        lp = vHp^(1 / 3)
    elseif length(lb0) < 2
        if f * lb^2 * (g + lb) < vHb * k * (g + f)
            lp = [;]
            info = false
            println("Warning in get_lp: maturity does not increase at birth \n")
        else # compute using integration in maturity
            cb = ContinuousCallback(event_puberty, terminate_affect!)
            u0 = [v_Hb, lb]
            tspan = (0, 1e8)
            s_M = 1.0
            prob = ODEProblem(dget_l_ISO_t, u0, tspan, [k, l_T, g, f, s_M, v_Hp])
            #sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9, callback=cb)
            sol = solve(prob, DP5(), reltol = 1e-9, abstol = 1e-9, callback = cb)
            t = sol.t
            vHl = sol.u
            tp = t[end]
            vHlp = vHl[end]
            #options = odeset('Events', @event_puberty); s_M = 1;
            #[t, vHl, tp, vHlp] = ode45(@dget_l_ISO_t, [0; 1e8], [vHb; lb], options, k, lT, g, f, s_M, vHp);
            lp = vHlp[2]
        end
    else # for a juvenile of length l and maturity vH
        if f * l^2 * (g + l) < vH * k * (g + f)
            lp = [;]
            info = false
            println("Warning in get_lp: maturity does not increase initially \n")
        elseif vH + 1e-4 < vHp # compute using integration in time
            u0 = [vH, vHp]
            tspan = (0, 1e8)
            s_M = 1.0
            prob = ODEProblem(dget_l_ISO, u0, l, [k, lT, g, f, s_M]) # this needs finishing
            #sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9)
            sol = solve(prob, DP5(), reltol = 1e-9, abstol = 1e-9)
            #[vH, lbp] = ode45(@dget_l_ISO, [vH; vHp], l, [], k, lT, g, f, 1); 
            lp = lbp[end]
            if lp > 0.8 * f # recompute using integration in time with event
                cb = ContinuousCallback(event_puberty, terminate_affect!)
                u0 = [vHb, lb]
                tspan = (0, 1e8)
                s_M = 1.0
                prob = ODEProblem(dget_l_ISO_t, u0, tspan, [k, lT, g, f, s_M, vHp])
                #sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9, callback=cb)
                sol = solve(prob, DP5(), reltol = 1e-9, abstol = 1e-9, callback = cb)
                t = sol.t
                vHl = sol.u
                tp = t[end]
                vHlp = vHl[end]
                #options = odeset('Events', @event_puberty); s_M = 1;
                #[t, vHl, tp, vHlp] = ode45(@dget_l_ISO_t, [0; 1e8], [vHb; lb], options, k, lT, g, f, s_M, vHp);
                lp = vHlp[2]
            end
        else
            lp = l
            info = false
            println("Warning in get_lp: initial maturity exceeds puberty threshold \n")
        end
    end

    #   if lp > f - 1e-4
    #     println("Warning in get_lp: l_p very close to l_i\n')      
    #   end
    return (lp, lb, info)
end


function get_lp(p, f)
    # created at 2008/06/04 by Bas Kooijman, 
    # modified 2014/03/03 Starrlight Augustine, 2015/01/18, 2019/01/29 by Bas Kooijman

    ## Syntax
    # [lp, lb, info] = <../get_lp.m *get_lp*> (p, f)

    ## Description
    # Obtains scaled length at puberty at constant food density. 
    # If scaled length at birth (second input) is not specified, it is computed (using automatic initial estimate); 
    # If it is specified, however, is it just copied to the (second) output. 
    # Food density is assumed to be constant. scaled length at puberty is obtained ny integrating over time with even detection
    #
    # Input
    #
    # * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
    # * f: optional scalar with scaled functional responses (default 1)
    #
    #      or optional 2-vector with scaled length, l, and scaled maturity, vH
    #      for a juvenile that is now exposed to f, but previously at another f
    #  
    # Output
    #
    # * lp: scalar with scaled length at puberty
    # * lb: scalar with scaled length at birth
    # * info: indicator equals 1 if successful, 0 otherwise

    ## Remarks
    # Similar to <get_lp1.html *get_lp1*>, which uses root finding, rather than integration
    # Function <get_lp_foetus.html *get_lp_foetus*> does the same, but then for foetal development. 

    ## Example of use
    # get_lp([.5, .1, .1, .01, .2])

    # unpack pars
    (; g, k, l_T, v_Hb, v_Hp) = p

    if !@isdefined(f)
        f = 1
    elseif isempty(f)
        f = 1
    end
    li = f - l_T # -, scaled ultimate length

    # if !@isdefined(lb0)
    #    lb0 = [];
    lb, info = get_lb((; g, k, v_Hb), f)
    # elseif isempty(lb0)
    #     lb, info = get_lb([g, k, v_Hb], f);
    # elseif length(lb0) < 2
    #     info = true;
    #     lb = lb0;
    # else # for a juvenile of length l and maturity vH
    #     l = lb0(1); vH = lb0(2); # juvenile now exposed to f
    #     lb, info = get_lb([g, k, v_Hb], f);
    # end

    # d/d tau vH = b2 l^2 + b3 l^3 - k vH
    b3 = 1 / (1 + g / f)
    b2 = f - b3 * li
    # vH(t) = - a0 - a1 exp(- rB t) - a2 exp(- 2 rB t) - a3 exp(- 3 rB t) +
    #         + (vHb + a0 + a1 + a2 + a3) exp(-kt)
    a0 = -(b2 + b3 * li) * li^2 / k # see get_lp1
    if v_Hp > -a0      # vH can only reach -a0
        lp = [;]
        info = false
        println("Warning in get_lp: maturity at puberty cannot be reached \n")
        return
    end

    if k == 1
        lp = v_Hp^(1 / 3)
        #elseif length(lb0) < 2
    else
        if f * lb^2 * (g + lb) < v_Hb * k * (g + f)
            lp = [;]
            info = false
            println("Warning in get_lp: maturity does not increase at birth \n")
        else # compute using integration in maturity
            cb = ContinuousCallback(event_puberty, terminate_affect!)
            u0 = [v_Hb, lb]
            tspan = (0, 1e8)
            s_M = 1.0
            prob = ODEProblem(dget_l_ISO_t, u0, tspan, (; k, l_T, g, f, s_M, v_Hp))
            #sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9, callback=cb)
            sol = solve(prob, DP5(); reltol=1e-9, abstol=1e-9, callback=cb)
            t = sol.t
            v_Hl = sol.u
            tp = t[end]
            v_Hlp = v_Hl[end]
            #options = odeset('Events', @event_puberty); s_M = 1;
            #[t, v_Hl, tp, vHlp] = ode45(@dget_l_ISO_t, [0; 1e8], [vHb; lb], options, k, l_T, g, f, s_M, vHp);
            lp = v_Hlp[2]
        end
        # else # for a juvenile of length l and maturity vH
        #   if f * l^2 * (g + l) < vH * k * (g + f) 
        #      lp = [;];
        #      info = false;
        #      println("Warning in get_lp: maturity does not increase initially \n");
        #   elseif vH + 1e-4 < vHp # compute using integration in time
        #       u0 = [vH, vHp]
        #       tspan = (0, 1e8)
        #       s_M = 1.0
        #       prob = ODEProblem(dget_l_ISO, u0, l, [k, lT, g, f, s_M]) # this may be incorrect
        #       sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9, callback=cb)
        #     #[vH, lbp] = ode45(@dget_l_ISO, [vH; vHp], l, [], k, lT, g, f, 1); 
        #     lp = lbp[end];
        #     if lp > 0.8 * f # recompute using integration in time with event
        #       cb = ContinuousCallback(event_puberty,terminate_affect!)
        #       u0 = [vHb, lb]
        #       tspan = (0, 1e8)
        #       s_M = 1.0
        #       prob = ODEProblem(dget_l_ISO_t, u0, tspan, [k, lT, g, f, s_M, vHp])
        #       sol = solve(prob, Tsit5(), reltol=1e-9, abstol=1e-9, callback=cb)
        #       t = sol.t
        #       vHl = sol.u
        #       tp = t[end]
        #       vHlp = vHl[end]
        #       #options = odeset('Events', @event_puberty); s_M = 1;
        #       #[t, vHl, tp, vHlp] = ode45(@dget_l_ISO_t, [0; 1e8], [vHb; lb], options, k, lT, g, f, s_M, vHp);
        #       lp = vHlp[2];
        #     end    
        #   else
        #     lp = l;
        #     info = false;
        #     println("Warning in get_lp: initial maturity exceeds puberty threshold \n")
        #   end
    end

    #   if lp > f - 1e-4
    #     println("Warning in get_lp: l_p very close to l_i\n')      
    #   end
    return (lp, lb, info)
end

function event_puberty(v_Hl, t, integrator)
    # vHl: 2-vector with [vH; l]
    v_Hp = integrator.p[6]
    v_Hp - v_Hl[1] * (t < 5e5)
end

terminate_affect!(integrator) = terminate!(integrator)
