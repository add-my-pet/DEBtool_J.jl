## print_filterflag
# prints an explanation of the filter flag onto the screen

##
function print_filterflag(flag)
    # created 2015/03/17 by Goncalo Marques; modified 2015/04/14 by Goncalo Marques

    ## Syntax
    # <../print_filterflag.m *print_filterflag*> (flag)

    ## Description
    # Prints an explanation to the screen according to the flag produced by a
    #    filter
    # Meant to be run in the estimation procedure for the seed parameter set
    #
    # Input
    #
    # * flag: number with flag from filter
    #
    #      0: parameters pass the filter
    #      1: some parameter is negative
    #      2: some kappa or f is larger than 1
    #      3: growth efficiency is larger than 1
    #      4: maturity levels do not increase during life cycle
    #      5: puberty cannot be reached

    ## Remarks
    # The theory behind boundaries is discussed in <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html *LikaAugu2013*>.


    #switch flag

    if flag == 1
        println("One or more parameters are negative \n")

    elseif flag == 2
        println("kappa, f or one of the fractions is bigger than 1 \n")

    elseif flag == 3
        println("growth efficiency is bigger than 1 \n")

    elseif flag == 4
        println("maturity levels are not in the correct order \n")

    elseif flag == 5
        println("puberty or birth cannot be reached \n")
    end

    #end
end
