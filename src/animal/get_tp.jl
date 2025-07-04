## get_tp
# Gets scaled age and length at puberty, birth

##
function get_tp(p, f=1, tel_b=nothing, tau=nothing)
    ## Syntax
    # varargout = <../get_tp.m *get_tp*>(p, f, tel_b, tau)
    
    ## Description
    # Obtains scaled ages, lengths at puberty, birth for the std model at constant food, temperature;
    # Assumes that scaled reserve density e always equals f; if third input is specified and its second
    # element is not equal to second input (if specified), <get_tpm *get_tpm*> is run.
    #
    # Input
    #
    # * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
    # * f: optional scalar with functional response (default f = 1) or (n,2)-array with scaled time since birth and functional response
    # * tel_b: optional scalar with scaled length at birth
    #
    #      or 3-vector with scaled age at birth, reserve density and length at 0
    # * tau: optional n-vector with scaled times since birth
    #
    # Output
    #
    # * tvel: optional (n,4)-array with scaled time-since-birth, maturity, reserve density and length
    # * tau_p: scaled age at puberty \tau_p = a_p k_M
    # * tau_b: scaled age at birth \tau_b = a_b k_M
    # * lp: scaled length at puberty
    # * lb: scaled length at birth
    # * info: indicator equals 1 if successful, 0 otherwise
    
    ## Remarks
    # Function <get_tp_foetus.html *get_tp_foetus*> does the same for foetal development; the result depends on embryonal development.
    # A previous version of get_tp had as optional 3rd input a 2-vector with scaled length, l, and scaled maturity, vH, for a juvenile that is now exposed to f, but previously at another f.
    # Function <get_tpm *get_tpm*> took over this use.
    # Optional inputs might be empty
  
    ## Example of use
    # tau_p = get_tp([.5, .1, .1, .01, .2]) or tvel = get_tp([.5, .1, .1, .01, .2],[],[],0:0.014:) 
   
        #  unpack pars
        (; g, k, l_T, v_Hb, v_Hp) = p
            
        # Set default value for f if not provided
        if !isa(f, Vector) || length(f) == 0
            f = 1.0
        end
        
       # If f has 2 columns and tau is not specified, issue a warning and return
        if size(f, 2) == 2
            if tau === nothing
                @warn "Warning from get_tp: f has 2 columns, but tau is not specified"
                return get_tpm(p, f, tel_b, tau)
            end
        end
        
        # If tel_b is provided and not empty, and the second element of tel_b is not equal to f
        # and tau is specified, call get_tpm and return the result
        if tel_b !== nothing
            if length(tel_b) == 1
                tau_b = get_tb(p[[1, 2, 4]], f)
                l_b = tel_b
            elseif tel_b[2] != f && tau != nothing
                return get_tpm(p, f, tel_b, tau)
            elseif tel_b[2] != f
                return get_tpm(p, f, tel_b)
            else
                tau_b = tel_b[1]
                #e_b   = tel_b[2];
                l_b = tel_b[3]
            end
        else
            tau_b, l_b, info = get_tb(p, f)
        end


        # if tel_b !== nothing && length(tel_b) == 1
        #     tau_b, l_b, _ = get_tb(p[[1, 2, 4]], f)
        #     tau_p, l_p, _ = get_tp(p, f, tel_b, tau)
        #     return tau_p, tau_b, l_p, l_b, 1
        # elseif tel_b !== nothing && tel_b[2] != f && tau !== nothing
        #     return get_tpm(p, f, tel_b, tau)
        # elseif tel_b !== nothing && tel_b[2] != f
        #     return get_tpm(p, f, tel_b)
        # elseif tel_b !== nothing
        #     tau_b = tel_b[1]
        #     l_b = tel_b[3]
        # else
        #     tau_b, l_b, _ = get_tb(p[[1, 2, 4]], f)
        # end
        
        # Ensure v_Hp is greater than v_Hb
        if v_Hp < v_Hb
            @warn "Warning from get_tp: v_Hp < v_Hb"
            tau_b, l_b = get_tb(p, f)
            tau_p = nothing
            l_p = nothing
            return tau_p, tau_b, l_p, l_b, 0
        end
        
        # Calculate necessary parameters
        rho_B = 1 / (3 * (1 + f / g))
        l_i = f - l_T
        l_d = l_i - l_b
        
        # Determine if reproduction is possible and calculate l_p and tau_p accordingly
        if k == 1 && f * l_i^2 > v_Hp * k
            l_b = v_Hb^(1/3)
            tau_b = get_tb(p[[1, 2, 4]], f, l_b)
            l_p = v_Hp^(1/3)
            tau_p = tau_b + log(l_d / (l_i - l_p)) / rho_B
            info = true
        elseif f * l_i^2 <= v_Hp * k
            tau_b, l_b = get_tb(p, f)
            tau_p = NaN
            l_p = NaN
            info = false
        else
            l_p, _, info = get_lp1(p, f, l_b)
            tau_p = tau_b + log(l_d / (l_i - l_p)) / rho_B
        end
        
        # If tau is specified, compute additional values for maturity
        if tau !== nothing
            b3 = 1 / (1 + g / f)
            b2 = f - b3 * l_i
            a0 = - (b2 + b3 * l_i) * l_i^2 / k
            a1 = - l_i * l_d * (2 * b2 + 3 * b3 * l_i) / (rho_B - k)
            a2 = l_d^2 * (b2 + 3 * b3 * l_i) / (2 * rho_B - k)
            a3 = - b3 * l_d^3 / (3 * rho_B - k)
            ak = v_Hb + a0 + a1 + a2 + a3
            
            tau = reshape(tau, :, 1)  # Make sure tau is a column vector
            ert = exp(-rho_B * tau)
            ekt = exp(-k * tau)
            l = l_i - l_d * exp(-rho_B * tau)
            v_H = min(v_Hp, -a0 - a1 * ert - a2 * ert.^2 - a3 * ert.^3 + ak * ekt)
            tvel = hcat(tau, v_H, f .* ones(size(tau)), l)
        end
        
        # Check if tau_p is real and positive
        if !isreal(tau_p) || tau_p < 0
            info = false
        end
        
        # Return results
        if tau !== nothing
            return (; tvel, tau_p, tau_b, l_p, l_b, info)
        else
            return (; tau_p, tau_b, l_p, l_b, info)
        end
    end
    
