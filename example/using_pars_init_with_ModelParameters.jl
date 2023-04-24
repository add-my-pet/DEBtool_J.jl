using ModelParameters
using Parameters
using Unitful
using DataFrames

include("example/pars_init_Emydura_macquarii.jl")
par = Model(Par())

# can refer to elements like this
par.parent.E_G.val

# get the names of the values
names = fieldnames(typeof(par.parent))

# get values without units
vals = par[:val]

# collect as a vector, without units
vals_vec = collect(par[:val])

# get the units
units = par[:units]

# make a dataframe
df = DataFrame(par)

# combine values and units

vals_units = NamedTuple{names}(Tuple([u === nothing ? typeof(v)(v) : v*u for (v, u) in zip(vals, units)]))
# explanation of line above:
# zip(vals, units) creates an iterator that produces tuples of corresponding elements from vals and units. This iterator as two 'is' 
# columns, one for vals and one for units and these
# The for (v, u) in ... part of the code unpacks each tuple produced by zip into v (a value from vals) and u (a unit from units).
# v*u multiplies the value v with the unit u, creating a new value with units.
# u === nothing ? typeof(v)(v) : v*u checks if u is nothing. If it is, then we use typeof(v)(v) to create a value with the same type as v and the
# same value as v. If u is not nothing, then we use v*u from step 3 to create a new value with units.
# Tuple(...) creates a tuple from the array of values and units generated in step 4.
# NamedTuple{names}(...) creates a new named tuple from the tuple of values and units generated in step 5, using the field names from the names array.

# can now access elements like so:
vals_units.E_G