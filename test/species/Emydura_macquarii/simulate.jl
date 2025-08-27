# Simulation
using GLMakie

tspan = (0.0, 8000.0)
environment = ConstantEnvironment(; 
    temperature=u"K"(22.0u"°C"),
    food=1.0,
    temperatureresponse=DEBtool_J.basetypeof(organism.temperatureresponse)(stripparams(par)),
) 
mbe = DEBtool_J.MetabolismBehaviorEnvironment(; metabolism=organism, environment, par=parent(parout))
sol = simulate(Simulator(; tspan=(0.0, 2000.0)), mbe)
plot(mbe; tspan=(0.0, 2000.0))

environment = Environment(; time=[0.0, 300.0, 600, 900.0, 1200.0, 1300.0, 2000.0],
    temperature=u"K".([10.0, 15.0, 22.0, 10.0, 10.0, 14.0, 20.0]u"°C"),
    food=[1.0, 0.8, 1.0, 0.9, 0.7, 1.0, 1.0],
    temperatureresponse=DEBtool_J.basetypeof(organism.temperatureresponse)(stripparams(par)),
    interpolation=QuadraticInterpolation,
) 
mbe = DEBtool_J.MetabolismBehaviorEnvironment(; metabolism=organism, environment, par=parent(parout))
plot(mbe; tspan=(0.0, 2000.0))
