module DEBtool_JMakieExt

using DEBtool_J
using Makie
using ModelParameters
using DataInterpolations
using Unitful

function Makie.plot(mbe::DEBtool_J.MetabolismBehaviorEnvironment;
    tspan,
    simulator=Simulator(; tspan),
    label=["E", "L", "H", "R"],
    kw...
)
    ModelParameters.MakieModel(mbe.par) do layout, obs
        # Define an axis to plot into
        ax1 = Axis(layout[1:5, 1])
        sol = lift(obs) do par
            simulate(simulator, DEBtool_J.rebuild(mbe; par))
        end
        # And plot a heatmap of the output of `f`
        plot_colored!(ax1, sol; label, kw...)
        axislegend(ax1)
        # Plot the environment
        if mbe.environment isa Environment
            time = mbe.environment.interpolators.temperature.t
            temp = mbe.environment.interpolators.temperature.u
            fr = mbe.environment.interpolators.food.u
            ax2 = Axis(layout[6, 1])
            ax3 = Axis(layout[7, 1])
            scatterlines!(ax2, time, temp; color=:red, label="Temperature")
            scatterlines!(ax3, time, fr; color=:green, label="Food")
            axislegend(ax2)
            axislegend(ax3)
        end
    end
end

"""
    Makie.plot(mbe::MetabolismBehaviorEnvironment{<:DEBAnimal{<:Iso221}}; tspan, ...)

Interactive 4-panel plot for the iso221 (2-reserve) DEB model. Sliders are created
automatically for all `Param` fields in `mbe.par`. Units flow through all intermediate
calculations; only the final values passed to Makie are stripped.

Panels: structural length L, reserve densities m_E1/m_E2, maturity E_H, reprod. buffers.
"""
function Makie.plot(mbe::DEBtool_J.MetabolismBehaviorEnvironment{<:DEBtool_J.DEBAnimal{<:DEBtool_J.Iso221}};
    tspan,
    simulator=Simulator(; tspan, saveat=range(first(tspan), last(tspan); length=400)),
    kw...
)
    ModelParameters.MakieModel(mbe.par) do layout, obs
        sol_obs = lift(obs) do par
            try
                simulate(simulator, DEBtool_J.rebuild(mbe; par))
            catch e
                @warn "iso221 simulation failed" exception=e
                nothing
            end
        end

        p0 = stripparams(mbe.par)
        d0 = isnothing(sol_obs[]) ? _iso221_empty() : _iso221_extract(sol_obs[], p0)

        ax_L = Axis(layout[1,1];
            xlabel="time (d)", ylabel="L (cm)", title="Structural length")
        ax_m = Axis(layout[1,2];
            xlabel="time (d)", ylabel="reserve density (mol/mol)", title="Reserve densities")
        ax_H = Axis(layout[2,1];
            xlabel="time (d)", ylabel="E_H (J)", title="Maturity")
        ax_R = Axis(layout[2,2];
            xlabel="time (d)", ylabel="M_R (mol)", title="Reprod. buffer")

        t_obs     = Observable(d0.t)
        L_obs     = Observable(d0.L_cm)
        m_E1_obs  = Observable(d0.m_E1)
        m_E2_obs  = Observable(d0.m_E2)
        E_H_obs   = Observable(d0.E_H_J)
        M_R1_obs  = Observable(d0.M_R1_mol)
        M_R2_obs  = Observable(d0.M_R2_mol)
        E_Hb_obs  = Observable([d0.E_Hb_J])
        E_Hp_obs  = Observable([d0.E_Hp_J])

        lines!(ax_L, t_obs, L_obs; color=:green)
        lines!(ax_m, t_obs, m_E1_obs; color=:blue,   label="E1 (protein)")
        lines!(ax_m, t_obs, m_E2_obs; color=:red,    label="E2 (non-prot.)")
        lines!(ax_H, t_obs, E_H_obs;  color=:purple)
        hlines!(ax_H, E_Hb_obs; color=:gray,  linestyle=:dash, label="E_Hb")
        hlines!(ax_H, E_Hp_obs; color=:black, linestyle=:dot,  label="E_Hp")
        lines!(ax_R, t_obs, M_R1_obs; color=:blue, label="M_R1")
        lines!(ax_R, t_obs, M_R2_obs; color=:red,  label="M_R2")
        axislegend(ax_m; position=:rt)
        axislegend(ax_H; position=:lt)
        axislegend(ax_R; position=:lt)

        on(sol_obs) do sol
            isnothing(sol) && return
            p = stripparams(obs[])
            d = _iso221_extract(sol, p)
            t_obs[]     = d.t
            L_obs[]     = d.L_cm
            m_E1_obs[]  = d.m_E1
            m_E2_obs[]  = d.m_E2
            E_H_obs[]   = d.E_H_J
            M_R1_obs[]  = d.M_R1_mol
            M_R2_obs[]  = d.M_R2_mol
            E_Hb_obs[]  = [d.E_Hb_J]
            E_Hp_obs[]  = [d.E_Hp_J]
        end
    end
end

# State order in sol.u: (M_E1, M_E2, M_V, E_H, M_R1, M_R2, q, h, S) — all bare Float64.
# Units are reattached from known physics before computing derived quantities.
function _iso221_extract(sol, p)
    sv   = sol.u
    M_V  = [s[3] for s in sv] .* u"mol"
    M_E1 = [s[1] for s in sv] .* u"mol"
    M_E2 = [s[2] for s in sv] .* u"mol"
    E_H  = [s[4] for s in sv] .* u"J"
    M_R1 = [s[5] for s in sv] .* u"mol"
    M_R2 = [s[6] for s in sv] .* u"mol"
    L    = (M_V ./ p.MV) .^ (1/3)  # cm
    m_E1 = M_E1 ./ M_V              # mol/mol (dimensionless)
    m_E2 = M_E2 ./ M_V
    return (;
        t        = sol.t,
        L_cm     = ustrip.(u"cm",  L),
        m_E1     = ustrip.(m_E1),
        m_E2     = ustrip.(m_E2),
        E_H_J    = ustrip.(u"J",   E_H),
        M_R1_mol = ustrip.(u"mol", M_R1),
        M_R2_mol = ustrip.(u"mol", M_R2),
        E_Hb_J   = ustrip(u"J",   p.E_Hb),
        E_Hp_J   = ustrip(u"J",   p.E_Hp),
    )
end

function _iso221_empty()
    return (;
        t=Float64[], L_cm=Float64[], m_E1=Float64[], m_E2=Float64[],
        E_H_J=Float64[], M_R1_mol=Float64[], M_R2_mol=Float64[],
        E_Hb_J=0.0, E_Hp_J=0.0,
    )
end

function plot_colored!(axis, sol_obs;
    color=[:red, :green, :blue, :yellow, :cyan, :magenta][eachindex(sol_obs[].u[1])],
    label=[string(Char(i+64)) for i in eachindex(sol_obs[].u[1])],
    kw...
)
    t = Observable(sol_obs[].t)
    obs = map(eachindex(sol_obs[].u[1])) do i
        o = Observable(map(u_t -> u_t[i], sol_obs[].u))
        lines!(axis, t, o; color=color[i], label=label[i])
        o
    end
    on(sol_obs) do sol
        for i in 1:length(sol.u[1])
            o = obs[i]
            o[] = map(u_t -> u_t[i], sol.u)
            t[] = sol.t
            notify(o)
        end
    end
    return axis
end

end
