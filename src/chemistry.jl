
# TODO: none of this is really implemented yet
# But the idea is this will allow flexible use of elements to specify in structure, reserve and product

# Gets chemical indices and chemical potential of N-waste from phylum, class

"""
    Element

Abstract supertype for chemical elements. 

Is there another pakage for this?
"""
abstract type Element end

"""
    Element

Abstract supertype for chemical elements. 
"""
struct C <: Element end
struct H <: Element end
struct O <: Element end
struct N <: Element end
struct P <: Element end

# State
struct Structure{E<:Tuple{Vararg{Element}}}
    elements::E
end
Structure(elements::Element...) = Structure(elements)

# Waste type
abstract type AbstractNitrogenWaste end

# Do these make sense?
struct Ammonoletic <: AbstractNitrogenWaste end
struct Ureotelic <: AbstractNitrogenWaste end
struct Uricotelic <: AbstractNitrogenWaste end
struct CustomNWaste{Ch,HN,ON,NN,N,Am} <: AbstractNitrogenWaste
    n_CN::CN
    n_HN::HN
    n_ON::ON
    n_NN::NN
    mu_N::N
    ammonia::Am
end
