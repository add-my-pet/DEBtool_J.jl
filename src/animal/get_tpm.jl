function get_tpm(p, f=1, tel_b=nothing, tau=nothing)
    # created at 2023/03/26 by Bas Kooijman, 
 
    ## Syntax
    # varargout = <../get_tpm.m *get_tpm*> (p, f, tel_b, tau)
    
    ## Description
    # Obtains scaled ages, lengths at puberty, birth for the std model at constant or varying food, constant temperature;
    # Notice p-b sequence in output, due to the name of the routine.
    # State at birth (scaled age, reserve density, length) can optionally be specified
    # E.g. for female: [tau_b, f, l_b] with zoom factor z, but for male: [tau_b, f*z/z_m, l_b*z/z_m] with zoom factor z_m
    #
    # Input
    #
    # * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
    # * f: optional scalar with functional response (default f = 1) or (n,2)-array
    # * tel_b: optional 3-vector with scaled age, reserve density and length at birth
    # * tau: optional n-vector with scaled times since birth
    #  
    # Output
    #
    # * tvel: optional (n,4)-array with time since birth, scaled maturity, reserve density and length
    # * tau_p: scaled age at puberty \tau_p = a_p * k_M
    # * tau_b: scaled age at birth \tau_b = a_b * k_M
    # * l_p: scaled length at puberty l_b = L_b/ L_m
    # * l_b: scaled length at birth l_p = L_/p L_m
    # * info: indicator equals 1 if successful, 0 otherwise
    
    ## Remarks
    # If tel_b is specified and different from the DEB value for p and f, see get_tb, initial growth deviates from vBert
    # The m in get_tpm stands for male, see get_tp for female
    
    ## Example of use
    #  get_tpm([.5, .1, 0, .01, .05]) or: 
    #  tel_b = [t_b, f*z/z_m, l_b*z/z_m]; # for males assumes same absolute reserve density at birth
    #  pars_tpm = [g_m k l_T v_Hb v_Hx v_Hpm]; 
    #  tau = t * k_M * TC; # -, scaled time since birth corrected for temperature
    #  [tvel, tau_p, tau_b, l_p, l_b, info] = get_tpm(pars_tpm, f, tel_b, tau);
     
    # unpack pars
    #g    = p(1); % energy investment ratio
    #k    = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
    #l_T  = p(3); % scaled heating length {p_T}/[p_M]Lm
    #v_Hb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}
    #v_Hp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am}
    (; g, k, l_T, v_Hb, v_Hp) = p

    # If f is a scalar, set f_b to f; otherwise, extrapolate f at birth
    if isscalar(f)
        f_b = f # -, f at birth
    else
        f_b = extrapolate(interpolate((0, 1), f), 0)[1] # -, f at birth
    end

    # Get states at birth
    if tel_b === nothing
        tau_b, l_b, info_tb = get_tb([g, k, v_Hb], f_b)
        e_b = f_b
    else
        tau_b, e_b, l_b = tel_b
        info_tb = 1
    end

    # Specify times since birth in trajectory
    if tau === nothing
        tau_int = [0, 1e6]
        tau_end = tau_int[end]
        n_tau = 2
    else
        if tau[1] > 0
            tau_int = vcat([0], tau)
        else
            tau_int = tau
        end
        tau_end = tau[end]
        n_tau = length(tau)
    end

    # define dynamics function for ODE
    function dget_vel(vel, p, tau)
        v_H, e, l = vel
        if isscalar(f)
            f = extrapolate(interpolate((0, 1), f), tau)[1]
        end
        de = (f - e) * g / l
        rho = g * (e / l - (1 + l_T / l)) / (e + g)
        dl = rho * l / 3
        if v_H < v_Hp
            dv_H = e * l^3 * (1 / l - rho / g) - k * v_H
        else
            dv_H = 0
        end
        return [dv_H, de, dl]
    end

    # Define event function for detecting puberty
    function pub(vel, tau, f, g, k, l_T, v_Hp)
        v_H, _, _ = vel
        return v_H - v_Hp
    end

    # Integrate ODE forward in time
    vel_0 = [v_Hb, e_b, l_b]
    prob = ODEProblem(dget_vel, vel_0, tau_int, (f, g, k, l_T, v_Hp))
    t, vel = solve(prob, DP5(), reltol = 1e-9, abstol = 1e-9, callback = cb)

    if vel[end, 1] < v_Hp
        tau_p, e_p, l_p, info_tvel = NaN, NaN, NaN, 0
    else
        tau_p = tau_b + extrapolate(interpolate((vel[:, 1], t), t), v_Hp)[1]
        e_p = extrapolate(interpolate((vel[:, 1], vel[:, 2]), t), v_Hp)[1] #  equals f if e is in equilibrium at p
        l_p = extrapolate(interpolate((vel[:, 1], vel[:, 3]), t), v_Hp)[1]
        info_tvel = 1
    end
    tvel = hcat(t, vel) #  t(end)=1e6 if tau_p>1e6 or t(end)=tau_p if tau_p<1e6
    if length(tau_int) == 2
        tvel = tvel[[1, end], :]
    end
    if tau[1] > 0
        tvel = tvel[2:end, :]
    end

    info = min(info_tb, info_tvel)

    if tau !== nothing
        return (tvel, tau_p, tau_b, l_p, l_b, info)
    else
        return (tau_p, tau_b, l_p, l_b, info)
    end
end

function dget_vel(vel, tau, f, g, k, l_T, v_Hp)
    # Unpack vel
    # v_H = vel(1); % -, scaled maturity 
    # e = vel(2);   % -, scaled reserve density
    # l = vel(3);   % -, scaled structural length
    v_H, e, l = vel
    
    # Interpolate functional response if necessary
    if size(f, 2) == 2
        f = extrapolate(interpolate((0, 1), f), tau)[1]
    end
    
    # Calculate derivatives
    de = (f - e) * g / l  # d/dtau e
    rho = g * (e / l - (1 + l_T / l)) / (e + g)  # Scaled specific growth rate
    dl = rho * l / 3  # d/dtau l
    
    # Determine d/dtau v_H
    if v_H < v_Hp  # Juvenile
        dv_H = e * l^3 * (1 / l - rho / g) - k * v_H  # d/dtau v_H
    else  # Adult
        dv_H = 0
    end
    
    # Return derivatives
    return [dv_H, de, dl]  # d/dtau vel 
end

function pub(vel, tau, f, g, k, l_T, v_Hp)
    # Unpack vel
    v_H, _, _ = vel
    
    # Event function: trigger when v_H equals v_Hp
    value = v_H - v_Hp  # Trigger
    isterminal = [0, 1]  # Terminate after event
    direction = []  # Get all the zeros
    
    return value, isterminal, direction
end
