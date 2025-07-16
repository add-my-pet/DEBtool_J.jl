## get_tj 
# Gets scaled age at metamorphosis

  # created at 2011/04/25 by Bas Kooijman, 
  # modified 2014/03/03 Starrlight Augustine, 2015/01/18 Bas Kooijman
  # modified 2018/09/10 (t -> tau) Nina Marn, 2023/04/05, 2023/08/28 2025/02/27 Bas Kooijman, 2025/03/03 Diogo Oliveira 
  
  ## Syntax
  # varargout = <../get_tj.m *get_tj*> (p, f, tel_b, tau)
  
  ## Description
  # Obtains scaled ages at metamorphosis, puberty, birth and the scaled lengths at these ages; works in scaled quantities at T_ref
  # Multiply the resulting trajectory/ages with the somatic maintenance rate coefficient kT_M to arrive at unscaled ages. 
  # Metabolic acceleration occurs between birth and metamorphosis, see also get_ts. 
  # Notice j-p-b sequence in output, due to the name of the routine
  #
  # Input
  #
  # * p: 6-vector with parameters: g, k, l_T, v_H^b, v_H^j, v_H^p 
  # * f: optional scalar with functional response (default f = 1) or (n,2)-array with scaled time since birth and scaled func response
  # * tel_b: optional scalar with scaled length at birth or 3-vector with scaled age at birth, reserve density and length at birth
  # * tau: optional n-vector with scaled times since birth at T_ref
  #  
  # Output
  #
  # * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
  # * tau_j: scaled age at metamorphosis \tau_j = a_j k_M
  # * tau_p: scaled age at puberty \tau_p = a_p k_M
  # * tau_b: scaled age at birth \tau_b = a_b k_M
  # * l_j: scaled length at end of V1-stage
  # * l_p: scaled length at puberty
  # * l_b: scaled length at birth
  # * l_i: ultimate scaled length
  # * rho_j: scaled exponential growth rate between b and j
  # * rho_B: scaled von Bertalanffy growth rate between j and i
  # * info: indicator equals 1 if successful, 0 otherwise
  
  ## Remarks
  # See <get_tj_foetus.html *get_tj_foetus*> in case of foetal development.
  # A previous version of get_tj had as optional 3rd input a 2-vector with scaled length, l, and scaled maturity, vH, for a juvenile that is now exposed to f, but previously at another f.
  # Function <get_tjm *get_tjm*> took over this use.
  # If input f is scalar (so food is constant), l_j and l_p are solved via fzero, and numerical integration is avoided.
  # If fzero fails, varying food it tried.
  # The theory behind these computations is presented in the comments on DEB3 for 7.8.2
 
  ## Example of use
  #  get_tj([.5, .1, 0, .01, .05, .2])
function get_tj(p, f=1.0, tel_b=nothing, tau=nothing)

    (; g, k, l_T, v_Hb, v_Hj, v_Hp) = p
    tvel = nothing
    tau_j = tau_p = tau_b = l_j = l_p = l_b = l_i = rho_j = rho_B = NaN
    info = 1

    # Determine if food is constant or varying
    if isa(f, Float64)
        f_i = f
        info_con = true
    elseif isa(f, Matrix)
        f_i = f[end, end]
        info_con = false
    else
        f_i = 1.0
        info_con = true
    end

    # Embryo stage
    if tel_b !== nothing
        if length(tel_b) == 1
            tau_b = get_tb((; g, k, v_Hb), f_i)
            e_b = f_i
            l_b = tel_b
        else
            tau_b, e_b, l_b = tel_b
        end
    else
        e_b = f_i
        tau_b, l_b = get_tb((; g, k, v_Hb), e_b)
    end

    vel_b = [v_Hb, e_b, l_b]
    rho_j = (f_i / l_b - 1 - l_T / l_b) / (1 + f_i / g)
    rho_B = 1 / (3 * (1 + f_i / g))

    tau_provided = tau !== nothing
    tau = tau_provided ? tau : [0.0, 1e10]

    # Juvenile and adult stage
    if info_con
        try
            l_j, info_lj = fzero(l -> get_lj(l, v_Hj, l_b, v_Hb, l_T, rho_j, rho_B, k, g, f_i), l_b, 1.0)
            l_p, info_lp = fzero(l -> get_lp(l, v_Hp, l_j, v_Hj, l_b, v_Hb, tau_b, l_T, rho_j, rho_B, k, g, f_i), l_j, l_j / l_b)

            s_M = l_j / l_b
            l_i = s_M * (f_i - l_T)
            l_d = l_i - l_j
            tau_j = tau_b + log(s_M) * 3 / rho_j
            tau_p = tau_j + log((l_i - l_j) / (l_i - l_p)) / rho_B

            Tau = tau .+ tau_b
            Tau_0j = Tau[Tau .< tau_j]
            Tau_ji = Tau[Tau .>= tau_j]

            if info_lj == 1 && info_lp == 1
                # Assign trajectories
                if tau_provided
                    l = vcat(
                        l_b .* exp.(Tau_0j .* rho_j ./ 3),
                        l_i .- (l_i .- l_j) .* exp.(-rho_B .* (Tau_ji .- tau_j))
                    )

                    b3 = f_i / (f_i + g)
                    b2 = f_i * s_M - b3 * l_i
                    a0 = - (b2 + b3 * l_i) * l_i^2 / k
                    a1 = - (2 * b2 + 3 * b3 * l_i) * l_i * l_d / (rho_B - k)
                    a2 = (b2 + 3 * b3 * l_i) * l_d^2 / (2 * rho_B - k)
                    a3 = - b3 * l_d^3 / (3 * rho_B - k)
                    sum_a = a0 + a1 + a2 + a3
                    sum_ae = a0 .+ a1 .* exp.(-rho_B .* Tau_ji) .+ a2 .* exp.(-2 .* rho_B .* Tau_ji) .+ a3 .* exp.(-3 .* rho_B .* Tau_ji)
                    v_H = vcat(
                        f_i * l_b^3 * (1 / l_b - rho_j / g) / (k + rho_j) .* (exp.(rho_j .* Tau_0j) .- exp.(-k .* Tau_0j)) .+ v_Hb .* exp.(-k .* Tau_0j),
                        (v_Hj .+ sum_a) .* exp.(-k .* Tau_ji) .- sum_ae
                    )
                    v_H = min.(v_H, v_Hp)
                    e = fill(f_i, length(tau))
                    tvel = hcat(tau, v_H, e, l)
                end
            else
                info = 0
                tau_j = tau_p = NaN
            end
        catch e
            info_con = false
        end
    end

    # If constant food failed, use integration
    if !info_con
        function dget_lj!(du, u, p, t)
            info_tau, f, l_b, g, k, l_T, v_Hj, v_Hp = p
            v_H, e, l = u
            dl = (f(t) - l - l_T) / (1 + f(t) / g)
            de = 0.0 # assume constant reserve if f constant; adjust if not
            dv_H = k * (f(t) * l^3 - v_H)
            du[1] = dv_H
            du[2] = de
            du[3] = dl
        end
        prev_condition = Ref(NaN)  # initialize
        function condition(u, t, integrator)
            v_H = u[1]
            return v_H - v_Hp
        end
        function affect!(integrator)
            c = condition(integrator.u, integrator.t, integrator)
            if isnan(prev_condition[]) || (prev_condition[] < 0 && c >= 0)
                terminate!(integrator)
            end
            prev_condition[] = c
        end

        cb = ContinuousCallback(condition, affect!)
        u0 = vel_b
        prob = ODEProblem(dget_lj!, u0, (0.0, maximum(tau)), (tau_provided, t -> f_i, l_b, g, k, l_T, v_Hj, v_Hp))
        #sol = solve(prob, callback=DiscreteCallback((u,t,integrator)->event_jp(u,t,integrator)[1], terminate!, direction=1))
        sol = solve(prob, callback=cb, saveat=tau, save_start=false, save_end=false)
        t = sol.t
        vel = reduce(hcat, sol.u)' # each row is a time point
        tvel = hcat(t, vel)
        tvel = tvel[2:end, :]
        if length(tau) == 1
            tvel = tvel[end, :]
        end
        # handle edge cases
        if isempty(t)
            tau_j = tau_p = l_j = l_p = l_i = NaN
            info = 0
        elseif length(t) == 1
            tau_j = tau_b + t[1]
            l_j = vel[1, 3]
            tau_p = NaN
            l_p = NaN
            l_i = f_i * l_j / l_b
        end
    end
    #Main.@infiltrate

    return tvel, tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info
end