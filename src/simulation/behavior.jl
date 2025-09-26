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

struct BurrowTemperatureRegulation{T} <: AbstractTemperatureRegulation
    burrowat::T
    emergeat::T
end

struct Panting{C}
    capacity::C
end

abstract type AbstractBiophysics end
        
struct Fur{T} <: AbstractBiophysics 
    thickness::T
end
struct WetSkin{W} <: AbstractBiophysics 
    wetness::W
end

abstract type ActivityPeriod end

struct Diurnal <: ActivityPeriod end
struct Norturnal <: ActivityPeriod end
struct Crepuscular <: ActivityPeriod end
"""
    ResponsiveActivity <: ActivityPeriod

    ResponsiveActivity(isactive)

# Arguments

- `isactive` a `Function` or functor that recieves a `ModelParEnvironment`
    object with the current system state, and decides whether to be "active"
    or "innactive".
"""
struct ResponsiveActivity{F} <: ActivityPeriod 
    isactive::F
end


