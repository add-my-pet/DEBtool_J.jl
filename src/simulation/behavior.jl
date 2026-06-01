# TODO work out how best to integrate this with BiophysicalBehaviour.jl 
# (and what spelling for behaviour)
"""
    AbstractBehavior

Abstract supertype for organism behaviors.

Behaviors respond to physiological state and external stimuli,
to either control *exposure* to the external stimuli, or modify
physiological parameters to change the *effect* of the external stimuli.

- Response to environmental information that leads to:
    - Changes in metabolic parameters
    - Changes in the environment or position within the environment
"""
abstract type AbstractBehavior end

"""
    AbstractMovementBehavior

Abstract supertype behaviors that modify location based
on inforation from the environment, such as moving up into
cooler air or moving underground into a warmer/cooler burror.
"""
abstract type AbstractMovementBehavior <: AbstractBehavior end

abstract type AbstractTemperatureRegulation end

struct NullBehavior <: AbstractBehavior end

initialise_state(::NullBehavior) = ()

abstract type ActivityPeriod end

# struct Diurnal <: ActivityPeriod end
# struct Nocturnal <: ActivityPeriod end
# struct Crepuscular <: ActivityPeriod end
# """
#     ResponsiveActivity <: ActivityPeriod

#     ResponsiveActivity(isactive)

# # Arguments

# - `isactive` a `Function` or functor that recieves a `ModelParEnvironment`
#     object with the current system state, and decides whether to be "active"
#     or "innactive".
# """
# struct ResponsiveActivity{F} <: ActivityPeriod 
#     isactive::F
# end


