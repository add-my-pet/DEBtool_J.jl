# Simulation

tspan = (0.0, 8000.0)
environment = ConstantEnvironment(; 
    time=tspan,
    temperature=u"K"(22.0u"°C"),
    functionalresponse=1.0,
    temperatureresponse=DEBtool_J.basetypeof(organism.temperatureresponse)(stripparams(par)),
) 
# environment = Environment(; time=[0.0, 300.0, 600, 900.0, 1200.0, 2000.0],
#     temperature=u"K".([10.0, 15.0, 22.0, 10.0, 10.0, 20.0]u"°C"),
#     functionalresponse=[1.0, 0.8, 1.0, 0.9, 0.7, 1.0],
#     temperatureresponse=DEBtool_J.basetypeof(organism.temperatureresponse)(stripparams(par)),
#     interpolation=QuadraticInterpolation,
# ) 

mpe = DEBtool_J.MetabolismBehaviorEnvironment(; metabolism=organism, environment, par=parent(parout))
sol = simulate(Simulator(; tspan), mpe)

# using GLMakie
# plot(mpe)
