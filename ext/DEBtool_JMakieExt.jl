module DEBtool_JMakieExt

using DEBtool_J
using Makie
using ModelParameters
using DataInterpolations

function Makie.plot(mpe::DEBtool_J.MetabolismBehaviorEnvironment)
    return ModelParameters.MakieModel(mpe.par) do layout, obs
        sol = lift(obs) do par
            simulate(rebuild(mbe; par))
        end
        # Define an axis to plot into
        ax1 = Axis(layout[1:5, 1])
        # And plot a heatmap of the output of `f`
        # plot!(ax1, sol)
        # Plot the environment 
        if mpe.environment isa Environment
            time = mpe.environment.interpolators.temperature.t
            temp = mpe.environment.interpolators.temperature.u
            fr = mpe.environment.interpolators.functionalresponse.u
            ax2 = Axis(layout[6, 1])
            ax3 = Axis(layout[7, 1])
            # DataCanvas(time, temp; color=:red, axis=ax2, figure=layout.parent.parent, scatter_kw=(; label="Temperature"))
            # DataCanvas(time, fr; color=:green, axis=ax3, figure=layout.parent.parent, scatter_kw=(; label="FR"))
            scatterlines!(ax2, time, temp; color=:red, label="Temperature")
            scatterlines!(ax3, time, fr; color=:green, label="Functional respoonse")
            axislegend(ax2)
            axislegend(ax3)
        end
    end
end

end
