# DEBtool_J.jl
Beta version of DEBtool_M coded in Julia language

This currently runs the estimation procedure for the turtle Emydura macquarii and appears to work as the Matlab version. It does not yet include the results_pets function and so does not produce outputs.

Performance is presently 3x faster than the Matlab version. Dimensions and units are incorporated via the package Unitful. The ModelParameters package is used to construct the parameters struct in pars_init.
