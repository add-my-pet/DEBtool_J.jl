module DEBtool_JMakieExt

using DEBtool_J
using Makie
using ModelParameters
using DataInterpolations

function Makie.plot(mbe::DEBtool_J.MetabolismBehaviorEnvironment;
    tspan,
    sex::Union{DEBtool_J.Sex, Tuple{Vararg{DEBtool_J.Sex}}} = Female(),
    simulator=Simulator(; tspan),
    label=["E", "L", "H", "R"],
    kw...
)
    sexes = sex isa DEBtool_J.Sex ? (sex,) : sex
    title = join(string.(nameof.(typeof.(sexes))), " & ")
    linestyles = [:solid, :dash, :dot, :dashdot]
    sex_colors = [:tomato, :steelblue, :forestgreen, :darkorange]

    ModelParameters.MakieModel(mbe.par) do layout, obs
        n_vars = length(label)
        axes = map(enumerate(label)) do (i, lbl)
            row, col = (i - 1) ÷ 2 + 1, (i - 1) % 2 + 1
            Axis(layout[row, col]; ylabel=lbl, title=(i == 1 ? title : ""))
        end

        for (si, s) in enumerate(sexes)
            sol = lift(obs) do par
                simulate(simulator, DEBtool_J.rebuild(mbe; par), s)
            end
            sex_name = length(sexes) > 1 ? string(nameof(typeof(s))) : ""

            for (vi, ax) in enumerate(axes)
                t_obs = Observable(sol[].t)
                y_obs = Observable(map(u -> u[vi], sol[].u))
                lines!(ax, t_obs, y_obs;
                    color=sex_colors[si], label=sex_name,
                    linestyle=linestyles[si], kw...
                )
                on(sol) do new_sol
                    y_obs[] = map(u -> u[vi], new_sol.u)
                    t_obs[] = new_sol.t
                    notify(y_obs)
                end
            end
        end

        # Legend on first axis only (same sex distinction applies to all)
        length(sexes) > 1 && axislegend(axes[1]; position=:lt)

        if mbe.environment isa Environment
            time = mbe.environment.interpolators.temperature.t
            temp = mbe.environment.interpolators.temperature.u
            fr = mbe.environment.interpolators.food.u
            n_rows = (n_vars + 1) ÷ 2
            ax_temp = Axis(layout[n_rows + 1, 1:2]; ylabel="Temperature")
            ax_food = Axis(layout[n_rows + 2, 1:2]; ylabel="Food")
            scatterlines!(ax_temp, time, temp; color=:tomato)
            scatterlines!(ax_food, time, fr; color=:forestgreen)
        end
    end
end

end
