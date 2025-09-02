module DEBtool_JMakieExt

using DEBtool_J
using Makie
using ModelParameters
using DataInterpolations

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
            # DataCanvas(time, temp; color=:red, axis=ax2, figure=layout.parent.parent, scatter_kw=(; label="Temperature"))
            # DataCanvas(time, fr; color=:green, axis=ax3, figure=layout.parent.parent, scatter_kw=(; label="FR"))
            scatterlines!(ax2, time, temp; color=:red, label="Temperature")
            scatterlines!(ax3, time, fr; color=:green, label="Food")
            axislegend(ax2)
            axislegend(ax3)
        end
    end
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
