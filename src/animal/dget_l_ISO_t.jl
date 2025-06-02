# vH: scalar with scaled maturity
# l: scalar with scaled length
# dl: scalar with d/dvH l
# called from get_lp, get_lj, get_ls
function dget_l_ISO_t(v_Hl, p, t)
    (; k, l_T, g, f, s_M, v_Hp) = p
    vH, l = v_Hl
    r = g * (f * s_M - l_T * s_M - l) / l / (f + g) # specific growth rate
    dl = l * r / 3                              # d/dt l
    dvH = f * l^2 * (s_M - l * r / g) - k * vH   # d/dt vH

    dvHl = [dvH, dl]

    return dvHl
end
