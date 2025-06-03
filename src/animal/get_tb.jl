## get_tb
#

##
function get_tb(p, eb, lb)
    #  created at 2007/07/27 by Bas Kooijman; modified 2014/03/17, 2015/01/18
    # modified 2018/09/10 (t -> tau) Nina Marn

    ## Syntax
    # [tau_b, lb, info] = <../get_tb.m *get_tb*> (p, eb, lb)

    ## Description
    # Obtains scaled age at birth, given the scaled reserve density at birth. 
    # Divide the result by the somatic maintenance rate coefficient to arrive at age at birth. 
    #
    # Input
    #
    # * p: 1 or 3-vector with parameters g, k_J/ k_M, v_H^b
    #
    #     Last 2 values are optional in invoke call to get_lb
    #
    # * eb: optional scalar with scaled reserve density at birth (default eb = 1)
    # * lb: optional scalar with scaled length at birth (default: lb is obtained from get_lb)
    #  
    # Output
    #
    # * tau_b: scaled age at birth \tau_b = a_b k_M
    # * lb: scalar with scaled length at birth: L_b/ L_m
    # * info: indicator equals 1 if successful, 0 otherwise

    ## Remarks
    # See also <get_tb1.html *get_tb1*> for backward integration over maturity and
    # <get_tb_foetus.html *get_tb_foetus*> for foetal development

    ## Example of use
    # get_tb([.1;.5;.03])
    # See also <../mydata_ue0.m *mydata_ue0*>

    # if !@isdefined(eb)
        # eb = 1 # maximum value as juvenile
    # end

    info = true

    # if !@isdefined(lb)
    #     if length(p) < 3
    #         println("not enough input parameters, see get_lb \n")
    #         tau_b = []
    #         return
    #     end
    #     lb, info = get_lb(p, eb)
    # end
    # if isempty(lb)
        # lb, info = get_lb(p, eb)
    # end
    lb, info = get_lb(p, eb)
    # unpack p
    g = p.g  # energy investment ratio

    xb = g / (eb + g) # f = e_b 
    ab = 3 * g * xb^(1 / 3) / lb # \alpha_b
    tau_b = 3 * quadgk(x -> dget_tb(x, ab, xb), 1e-15, xb)[1]
    (tau_b, lb, info)
end

function get_tb(p, eb)
    #  created at 2007/07/27 by Bas Kooijman; modified 2014/03/17, 2015/01/18
    # modified 2018/09/10 (t -> tau) Nina Marn

    ## Syntax
    # [tau_b, lb, info] = <../get_tb.m *get_tb*> (p, eb)

    ## Description
    # Obtains scaled age at birth, given the scaled reserve density at birth. 
    # Divide the result by the somatic maintenance rate coefficient to arrive at age at birth. 
    #
    # Input
    #
    # * p: 1 or 3-vector with parameters g, k_J/ k_M, v_H^b
    #
    #     Last 2 values are optional in invoke call to get_lb
    #
    # * eb: optional scalar with scaled reserve density at birth (default eb = 1)
    #  
    # Output
    #
    # * tau_b: scaled age at birth \tau_b = a_b k_M
    # * lb: scalar with scaled length at birth: L_b/ L_m
    # * info: indicator equals 1 if successful, 0 otherwise

    ## Remarks
    # See also <get_tb1.html *get_tb1*> for backward integration over maturity and
    # <get_tb_foetus.html *get_tb_foetus*> for foetal development

    ## Example of use
    # get_tb([.1;.5;.03])
    # See also <../mydata_ue0.m *mydata_ue0*>

    info = true

    # if !@isdefined(lb)
    if length(p) < 3
        println("not enough input parameters, see get_lb \n")
        tau_b = []
        return
    end
    lb, info = get_lb(p, eb)
    # end
    # if isempty(lb)
    #   lb, info = get_lb(p, eb);
    # end
    # unpack p
    g = p.g  # energy investment ratio

    xb = g / (eb + g) # f = e_b 
    ab = 3 * g * xb^(1 / 3) / lb # \alpha_b
    tau_b = 3 * quadgk(x -> dget_tb(x, ab, xb), 1e-15, xb, atol=1e-6)[1]
    (tau_b, lb, info)
end

# subfunction

function dget_tb(x, ab, xb)
    # called by get_tb
    f = x .^ (-2 / 3) ./ (1 - x) ./ (ab - real(beta0(x, xb)))
end
