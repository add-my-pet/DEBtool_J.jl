## initial_scaled_reserve
# Gets initial scaled reserve

##
function initial_scaled_reserve(f, p, Lb0)
    #  created 2007/08/06 by Bas Kooyman; modified 2009/09/29

    ## Syntax
    # [U0, Lb, info] = <../initial_scaled_reserve.m *initial_scaled_reserve*>(f, p, Lb0)

    ## Description
    # Gets initial scaled reserve
    #
    # Input
    #
    # * f: n-vector with scaled functional responses
    # * p: 5-vector with parameters: VHb, g, kJ, kM, v
    # * Lb0: optional n-vector with lengths at birth
    #
    # Output
    #
    # * U0: n-vector with initial scaled reserve: M_E^0/ {J_EAm} or E^0/ {p_Am}
    # * Lb: n-vector with length at birth
    # * info: n-vector with 1's if successful, 0's otherwise

    ## Remarks
    # Like <get_ue0.html *get_ue0*>, but allows for vector arguments and
    # input and output is not downscaled to dimensionless quantities,

    ## Example of use 
    # p = [.8 .42 1.7 1.7 3.24 .012]; initial_scaled_reserve(1,p)

    #  unpack parameters
    (; VHb, g, kJ, kM, v) = p

    # if kJ = kM: VHb = g * Lb^3/ v;

    nf = length(f)
    U0 = zeros(nf, 1)u"d" * u"cm"^2
    Lb = zeros(nf, 1)u"cm"
    info = zeros(nf, 1)
    q = (; g, k=kJ / kM, v_Hb=VHb * g^2 * kM^3 / v^2)
    #if exist('Lb0','var') == 1
    lb0 = ones(nf, 1) .* Lb0 * kM * g / v
    #else
    #  lb0 = ones(nf,1) * get_lb(q,f[1])[1]; # initial estimate for scaled length
    #end
    for i = 1:nf
        lb, info[i] = get_lb(q, f[i], lb0[i])
        ## try get_lb1 or get_lb2 for higher accuracy
        Lb[i] = lb * v / kM / g
        uE0 = get_ue0(q, f[i], lb)
        U0[i] = uE0 * v^2 / g^2 / kM^3
    end

    return (; U0, Lb, info)
end

function initial_scaled_reserve(f, p)
    #  created 2007/08/06 by Bas Kooyman; modified 2009/09/29

    ## Syntax
    # [U0, Lb, info] = <../initial_scaled_reserve.m *initial_scaled_reserve*>(f, p)

    ## Description
    # Gets initial scaled reserve
    #
    # Input
    #
    # * f: n-vector with scaled functional responses
    # * p: 5-vector with parameters: VHb, g, kJ, kM, v
    #
    # Output
    #
    # * U0: n-vector with initial scaled reserve: M_E^0/ {J_EAm} or E^0/ {p_Am}
    # * Lb: n-vector with length at birth
    # * info: n-vector with 1's if successful, 0's otherwise

    ## Remarks
    # Like <get_ue0.html *get_ue0*>, but allows for vector arguments and
    # input and output is not downscaled to dimensionless quantities,

    ## Example of use 
    # p = [.8 .42 1.7 1.7 3.24 .012]; initial_scaled_reserve(1,p)

    #  unpack parameters
    (; VHb, g, kJ, kM, v) = p

    # if kJ = kM: VHb = g * Lb^3/ v;

    nf = length(f)
    U0 = zeros(nf, 1)Unitful.d * Unitful.cm^2
    Lb = zeros(nf, 1)Unitful.cm
    info = zeros(nf, 1)
    q = (; g, k=kJ / kM, v_Hb=VHb * g^2 * kM^3 / v^2)
    #if exist('Lb0','var') == 1
    #  lb0 = ones(nf,1) .* Lb0 * kM * g/ v;
    #else
    lb0 = ones(nf, 1) * get_lb(q, f[1])[1] # initial estimate for scaled length
    #end
    for i = 1:nf
        lb, info[i] = get_lb(q, f[i])
        ## try get_lb1 or get_lb2 for higher accuracy
        Lb[i] = lb * v / kM / g
        uE0 = get_ue0(q, f[i], lb)[1]
        U0[i] = uE0 * v^2 / g^2 / kM^3
    end

    return (; U0, Lb, info)
end
