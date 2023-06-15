using Unitful

ab=30u"d"
tp=(100*24)u"hr"
ap=ab+tp
ap=ap |> u"d"

# explicitly pull out units to make code simpler
using Unitful:d, hr

ab=30d
tp=(100*24)hr
ap=ab+tp
ap=ap |> d

# temperature conversion example
Unitful.°C(73Unitful.°F)

# an example of calculating radiant heat loss
using Unitful: °C, K, d, g, cm, mol, J, kg, m
T_b = 30°C
T_b2 = (30+273.15)K
ϵ = 0.95
σ = Unitful.σ # the Stefan-Boltzmann constant and many others are in the Unitful package
σ = Unitful.uconvert(u"W/m^2/K^4", Unitful.σ)
Q_rad = σ*ϵ*T_b^4 # doesn't work because can't use celcius here
Q_rad = σ*ϵ*T_b2^4
Q_rad = σ*ϵ*Unitful.K(T_b)^4

# some DEB parameters and calculations
κ = 0.8
ṗ_M = 20u"J/d/cm^3"
ṗ_Am = 100u"J/d/cm^2"
E_G = 9000u"J/cm^3"
v̇ = 0.02u"cm/d"
f = 1
E_m = ṗ_Am / v̇
L_m = κ * ṗ_Am / ṗ_M
L_i = f * κ * ṗ_Am / ṗ_M

# some DEB stoichiometry examples
# food
n_CX = 1.0 # chem. index of carbon in food# chem. # C/C = 1 by definition
n_HX = 1.8 # chem. index of hydrogen in food# chem.
n_OX = 0.5 # chem. index of oxygen in food# chem.
n_NX = 0.15 # chem. index of nitrogen in food# chem.
# structure
n_CV = 1.0 # chem. index of carbon in structure# chem. # n_CV = 1 by definition
n_HV = 1.8 # chem. index of hydrogen in structure# chem.
n_OV = 0.5 # chem. index of oxygen in structure# chem.
n_NV = 0.15 # chem. index of nitrogen in structure# chem.
# reserve
n_CE = 1.0 # chem. index of carbon in reserve# chem.   # n_CE = 1 by definition
n_HE = 1.8 # chem. index of hydrogen in reserve# chem.
n_OE = 0.5 # chem. index of oxygen in reserve# chem.
n_NE = 0.15 # chem. index of nitrogen in reserve# chem.
# faeces
n_CP = 1.0 # chem. index of carbon in faeces# chem.    # n_CP = 1 by definition
n_HP = 1.8 # chem. index  of hydrogen in faeces# chem.
n_OP = 0.5 # chem. index of oxygen in faeces# chem.
n_NP = 0.15 # chem. index of nitrogen in faeces# chem.

#      X    V    E    P
n_O = [n_CX n_CV n_CE n_CP  # C/C, equals 1 by definition
       n_HX n_HV n_HE n_HP  # H/C  these values show that we consider dry-mass
       n_OX n_OV n_OE n_OP  # O/C
       n_NX n_NV n_NE n_NP]Unitful.mol/Unitful.mol; # N/C

# Molecular weights:
w_O = n_O' * [12, 1, 16, 14]Unitful.g/Unitful.mol; # g/mol, mol-weights for (unhydrated)  org. compounds
w_X = w_O[1];
w_V = w_O[2];
w_E = w_O[3];
w_P = w_O[4];

d_V = 0.3g/cm^3 # density of structure
d_E = 0.3g/cm^3 # density of reserve
M_V = d_V / w_V; # mol/cm^3, [M_V], volume-specific mass of structure

V = 1cm^3
E = 1000J/cm^3
μ_E = 550000J/mol
y_V_E = μ_E * M_V / E_G     # mol/mol, yield of structure on reserve
y_E_V = 1/ y_V_E            # mol/mol, yield of reserve on structure

m_Em = y_E_V * E_m / E_G   # mol/mol, reserve capacity
ω = m_Em * w_E * d_V/ d_E/ w_V # -, contribution of ash free dry mass of reserve to total ash free dry biomass

Ww_i = L_i^3 * d_V * (1 + f * ω)

using UnitfulMoles

# create compounds
@compound H2O
@compound CO2
@compound O2

1molH₂O |> u"g"
1molCO₂ |> u"g"
1molO₂ |> u"g"

# using abstract types and multiple dispatch

# Abstract supertype for the shape of the organism being modelled.
abstract type Shape end

# The geometry of an organism.
struct Geometry{V,D,L,A}
    volume::V
    characteristic_dimension::D
    lengths::L
    area::A
end

#Abstract supertype for organism bodies.
abstract type AbstractBody end

# function that gets the property 'shape' from an object of type AbstractBody
shape(body::AbstractBody) = body.shape

# function that gets the property 'geometry' from an object of type AbstractBody
# this same function name will later be redefined to dispatch on the type of 
# shape of the body to actually calculate geometric properties, and will be
# used by the function Body
geometry(body::AbstractBody) = body.geometry

# function that extracts the shape of the input argument of type Abstract body
# and then applies another method of calc_area to actually calculate the area 
calc_area(body::AbstractBody) = calc_area(shape(body), body)

# now define a struct to hold the properties of a body and then a function
# to allow construction of the Body struct from a given shape

#Physical dimensions of a body or body part.
struct Body{S<:Shape,G} <: AbstractBody
    shape::S
    geometry::G
end
function Body(shape::Shape)
    Body(shape, geometry(shape))
end

# now define specific shapes and the code to calculate their
# lengths and areas

# A flat plate-shaped organism shape.
struct Plate{M,D,B} <: Shape
    mass::M
    density::D
    b::B
    c::B
end

function geometry(shape::Plate)
    volume = shape.mass / shape.density
    length = volume^(1 / 3)
    a = (volume / (shape.b * shape.c))^(1 / 3)
    b = shape.b * a
    c = shape.c * a
    length1 = a * 2
    length2 = b * 2
    length3 = c * 2
    area = calc_area(shape, a, b, c)
    return Geometry(volume, length, (length1, length2, length3), area)
end

function calc_area(shape::Plate, body)
    a = body.geometry.lengths[1] / 2
    b = body.geometry.lengths[2] / 2
    c = body.geometry.lengths[3] / 2
    calc_area(shape, a, b, c)
end
calc_area(shape::Plate, a, b, c) = a * b * 2 + a * c * 2 + b * c * 2

# A cylindrical organism shape.
struct Cylinder{M,D,B} <: Shape
    mass::M
    density::D
    b::B
end

function geometry(shape::Cylinder)
    volume = shape.mass / shape.density
    length = volume^(1 / 3)
    r = (volume / (shape.b * π * 2))^(1 / 3)
    length1 = shape.b * r * 2
    length2 = 2 * r
    area = calc_area(shape, r, length1)
    return Geometry(volume, length, (length1, length2), area)
end

function calc_area(shape::Cylinder, body::AbstractBody)
    r = body.geometry.lengths[2] / 2
    l = body.geometry.lengths[1]
    calc_area(shape, r, l)
end
calc_area(shape::Cylinder, r, l) = 2 * π * r * l + 2 * π * r^2

density = 1000kg/m^3
my_mass = 65kg

my_shapeb = 2
my_shapec = 2

my_plate = Plate(my_mass, density, my_shapeb, my_shapec) # define my_plate as a Cylinder struct of type 'Shape' and give it required values
my_plate_body = Body(my_plate) # construct a Body, this constructor will apply the 'geometry' function to the inputs and return a struct that has the struct for the 'Shape' type, as well as the geometry struct

my_plate_body.geometry.area

my_shapeb = 3
my_cylinder = Cylinder(my_mass, density, my_shapeb) # define my_cylinder as a Cylinder struct of type 'Shape' and give it required values
my_cylinder_body = Body(my_cylinder) # construct a Body, this constructor will apply the 'geometry' function to the inputs and return a struct that has the struct for the 'Shape' type, as well as the geometry struct
my_cylinder_body.geometry.area
