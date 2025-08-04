## Description
# Obtains scaled length at birth, given the scaled reserve density at birth. 
#
# Input
#
# * p: 3-vector with parameters: g, k, v_H^b (see below)
# * eb: optional scalar with scaled reserve density at birth (default eb = 1)
#  
# Output
#
# * lb: scalar with scaled length at birth 
# * info: indicator equals 1 if successful, 0 otherwise

## Remarks
# The theory behind get_lb, get_tb and get_ue0 is discussed in 
#    <http://www.bio.vu.nl/thb/research/bib/Kooy2009b.html Kooy2009b>.
# Solves y(x_b) = y_b  for lb with explicit solution for y(x)
#   y(x) = x e_H/(1-κ) = x g u_H/ l^3
#   and y_b = x_b g u_H^b/ ((1-κ)l_b^3)
#   d/dx y = r(x) - y s(x);
#   with solution y(x) = v(x) \int r(x)/ v(x) dx
#   and v(x) = exp(- \int s(x) dx).
# A Newton Raphson scheme is used with Euler integration, starting from an optional initial value. 
# Replacement of Euler integration by ode23: <get_lb1.html *get_lb1*>,
#  but that function is much lower.
# Shooting method: <get_lb2.html *get_lb2*>.
# Bisection method (via fzero): <get_lb3.html *get_lb3*>.
# In case of no convergence, <get_lb2.html *get_lb2*> is run automatically as backup.
# Consider the application of <get_lb_foetus.html *get_lb_foetus*> for an alternative initial value.
function compute_length(at::Birth, p::NamedTuple; eb::Number=1.0)
    (; g, k, v_Hb) = p   # g = [E_G] * v/ κ * {p_Am}, energy investment ratio
    # k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
    # v_H^b = U_H^b g^2 kM^3/ (1 - κ) v^2; U_H^b = M_H^b/ {J_EAm}

    info = true

    if k == oneunit(k)
        lb = v_Hb^(1 / 3) # exact solution for k = 1
        info = true
        return lb, info
    end
    # if isempty(lb0)
    lb = v_Hb^(1 / 3) # exact solution for k = 1     

    n = 1000 + round(1000 * max(zero(k), k - oneunit(k)))
    xb = g / (g + eb)
    xb3 = xb^(1 / 3)
    x = LinRange(1e-6, xb, trunc(Int, n))
    # TODO: get the type from context
    buffer = Vector{Float64}(undef, length(x))
    buffer1 = Vector{Float64}(undef, length(x))
    buffer2 = Vector{Float64}(undef, length(x))
    l = Vector{typeof(g)}(undef, length(x))
    r = Vector{typeof(g)}(undef, length(x))
    s = Vector{Float64}(undef, length(x))
    dlnv = Vector{Float64}(undef, length(x))
    dlnl = Vector{Float64}(undef, length(x))
    dv = Vector{Float64}(undef, length(x))
    dl = Vector{Float64}(undef, length(x))
    scum = Vector{Float64}(undef, length(x))
    v = Vector{Float64}(undef, length(x))
    dx = xb / n
    x3 = x .^ (1 / 3)

    f1 = incomplete_beta_side(xb)
    b = real.(incomplete_beta_precalc.(x, f1)) ./ (3 * g)
    t0 = xb * g * v_Hb
    i = 0
    norm = 1 # make sure that we start Newton Raphson procedure
    ni = 100 # max number of iterations

    # TODO comment all of this
    while i < ni && norm > 1e-8
        l .= x3 ./ (xb3 ./ lb .- b)
        s .= (k .- x) ./ (1 .- x) .* l ./ g ./ x
        v .= exp.(-dx .* cumsum!(scum, s))
        vb = v[trunc(Int, n)]
        r .= (g .+ l)
        rv = r ./ v
        t = t0 / lb^3 / vb - dx * sum(rv)
        dl = xb3 ./ lb .^ 2 .* l .^ 2 ./ x3
        dlnl .= dl ./ l
        dv .= v .* exp.(-dx .* cumsum!(buffer1, buffer .= s .* dlnl))
        dvb = dv[trunc(Int, n)]
        dlnv .= dv ./ v
        dlnvb = dlnv[trunc(Int, n)]
        dr = dl
        buffer2 .= (dr ./ r .- dlnv) .* rv
        dt = -t0 / lb^3 / vb * (3 / lb + dlnvb) - dx * sum(buffer2)
        # [i lb t dt] # print progress
        lb = lb - t / dt # Newton Raphson step
        norm = t^2
        i = i + 1
    end

    if i == ni || lb < zero(lb) || lb > oneunit(lb) || isnan(norm) || isnan(lb) # no convergence
        # try to recover with a shooting method
        error("This branch has not been tested")
        lb, info = get_lb2(p, eb)
    end

    info == false && @warn "no convergence of l_b"

    return lb, info
end
# was get_lp1
function compute_length(at::Puberty, p::NamedTuple, l0::Number)
    (; g, k, l_T, v_Hb, v_Hp, f) = p
    sM = haskey(p, :sM) ? p.sM : 1.0
    v_H0 = v_Hb

    lb = l0

    rB = g / 3 / (f + g) # scaled von Bertalanffy growth rate
    li = sM * (f - l_T)  # scaled ultimate length
    ld = li - lb         # scaled length

    # TODO comment all of this math
    b3 = 1 / (1 + g / f) 
    b2 = f * sM - b3 * li

    a0 = - (b2 + b3 * li) * li^2 / k
    a1 = - li * ld * (2 * b2 + 3 * b3 * li) / (rB - k)
    a2 = ld^2 * (b2 + 3 * b3 * li) / (2 * rB - k)
    a3 = - b3 * ld^3 / (3 * rB - k)

    if v_Hp > -a0
        lp = NaN
        info = false
        error()
        @warn "maturity at puberty cannot be reached"
    elseif v_H0 > v_Hp
        lp = 1
        info = false
        error()
        @warn "initial maturity exceeds puberty threshold"
    elseif k == oneunit(k)
        info = true
        lp = v_Hp^(1/3)
        error()
    end

    # Find value of lp where f(lp) == 0
    bounds = (lb, li)
    v_Hja = v_H0 + a0 + a1 + a2 + a3
    lilj = 1 / (li - lb)
    krB = k / rB
    f = lp -> _fn_length_at_puberty(lp, a0, a1, a2, a3, lilj, li, krB, v_Hja, v_Hp)
    lp = solve(ZeroProblem(f, bounds), Bisection())
    info = !isnan(lp)

    return lp, info
end

# was fnget_lp
function _fn_length_at_puberty(lp, a0, a1, a2, a3, lilj, li, krB, v_Hja, v_Hp)
    tjrB = (li - lp) * lilj # exp(- tau_p r_B) for tau = scaled time since metam
    tjk = tjrB^krB          # exp(- tau_p k)
    # f = 0 if vH(tau_p) = vHp for varying lp
    f = v_Hp + a0 + a1 * tjrB + a2 * tjrB^2 + a3 * tjrB^3 - v_Hja * tjk
    return f
end

