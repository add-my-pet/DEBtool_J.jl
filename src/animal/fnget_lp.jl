function fnget_lp(lp, a0, a1, a2, a3, lj, li, k, rB, vHj, vHp)
    tjrB = (li - lp) / (li - lj) # exp(- tau_p r_B) for tau = scaled time since metam
    tjk = tjrB^(k / rB)          # exp(- tau_p k)

    # f = 0 if vH(tau_p) = vHp for varying lp
    f = vHp + a0 + a1 * tjrB + a2 * tjrB^2 + a3 * tjrB^3 - (vHj + a0 + a1 + a2 + a3) * tjk

    return f
end