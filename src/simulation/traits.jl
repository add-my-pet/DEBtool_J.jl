# These are actually for NicheMap models

abstract type AbstractShape end

struct Plate{S}
    stretch::S
end
struct Cylinder{S}
    stretch::S
end
struct Ellipse{S}
    stretch::S
end
struct Lizard end
struct Frog end

abstract type AbstractMophology end

struct Morphology
    subcutaneousfat
    fat
    bareskinfraction
    eyefraction
    venstralsurfacefraction
    substratecontact
    groundskyfraction
end

struct Skin
    reflectance
    emmisivity
    wetness
end

struct Pelt
    reflectance
    emmisivity
    depth
    maxdepth
    compresseddepth
    density
    hairconductivity
    piloerectionfactor
end

struct DorsalVentralPelt{D<:Pelt,V<:Pelt}
    dorsal::D
    ventral::V
end
