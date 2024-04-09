## calibration_options
# Sets options for calibration.pars

# Created at 2020/02/15 Juan Francisco Robles; 
# Modified 2020/02/22, 2020/02/24, 2020, 03, 11,
# 2020/03/12, 2020/06/02, 2021/03/23 by Juan Francisco Robles
#

## Syntax
# <../calibration_options.m *calibration_options*> (key, val)

## Description
# Sets options for calibration one by one
#
# Input
#
# * no input: print values to screen
# * one input:
#
#    "default": sets options by default
#
# * two inputs
#      
#    'search_method': 
#      'mm_shade' - use Success-history based parameter adaptation for 
#                Differential Evolution (mm_shade) with fitness sharing method.
#     
#    'num_results': The size for the multimodal algorithm's population.
#                   If it is not defined then sets the values recommended by 
#                   the author, which are 100 for mm_shade ('mm_shade') and 
#                   18 * problem size for L-mm_shade.
#    'gen_factor': percentage to build the ranges for initializing the 
#                  first population of individuals.
#    'factor_type': The kind of factor to be applied when generatin individuals 
#      'mult' - multiplicative (Default) 
#      'add' - additive 
#    'bounds_from_ind': 
#      1: use ranges from data (default); 
#      0: use ranges from pseudodata if exist (these ranges not existing 
#         will be taken from data).
#
#    'max_fun_evals': maximum number of function evaluations (10000 by
#                     default).
#
#    'max_calibration_time': maximum calibration time in minutes (0 by default).
#
#    'num_runs': the number of independent runs to perform.
#
#    'add_initial': if the initial individual is added in the first
#                   population.
#
#    'refine_initial': if the initial individual is refined using Nelder
#                    Mead.
#     
#    'refine_best': if the best individual found is refined using Nelder
#                    Mead.
#     
#    'verbose_options': The number of solutions to show from the set of 
#                        optimal solutions found by the algorithm through 
#                        the calibration process.  
#
#    'verbose': If to activate verbose options (1 yes, 0 no). 
#                This option prints some information while the calibration 
#                process is running.  
#
#    'random_seeds': The values for the seeds used to generate random
#                     values (each one is used in a single run of the
#                     algorithm). 
#    'ranges': Structure with ranges for the parameters to be calibrated (default empty)
#              one value (factor between [0, 1], if not: 0.01 is set) to 
#              increase and decrease the original parameter values.
#              two values (min, max) for the  minimum and maximum range values. 
#              Consider:               
#                 (1) Use min < max for each variable in ranges. If it is not, 
#                     then the range will be not used
#                 (2) Do not take max/min too high, use the likely ranges of the problem
#                 (3) Only the free parameters (see 'pars_init_my_pet' file) are considered
#              Set range with cell string of name of parameter and value for 
#              range, e.g. estim_options('ranges',{'kap', [0.3 1]}} 
#              Remove range-specification with e.g. estim_options('ranges', {'kap'}} 
#              or estim_options('ranges', 'kap'} 
#    'results_printlnlay': The type of results output to printlnlay after
#                      calibration execution. 
#                      Options: 
#                      (1) Basic - Does not show results in screen. 
#                      (2) Best - Plots the best solution results in
#                          DEBTools style.
#                      (3) Set - Plots all the solutions remarking the 
#                          best one. Html with pars (best pars and a 
#                          measure of the variance of each parameter in 
#                          the solutions obtained for example).
#                      (4) Complete - Joins options 1, 2 , and 3 together 
#                          with zero variate data with input and a measure 
#                          of the variance of all the solutions considered
#    'results_filename': The name for the results file. 
#    'save_results': If the results output images are going to be saved. 
#    'mat_file': A file with results from where to initialize the
#                calibration parameters (only useful if pars_init_method 
#                option is equal to 1 and if there is a result file)
#    'sigma_share': The value of the sigma share parameter (that is used
#    into the fitness sharing niching method if it is activated)
# Output
#
# * no output, but globals are set to values or values are printed to screen
#
## Remarks
# For other options see corresponding options file of the minimazation  algorithm, e.g. <../../regr/html/nmregr_options.html *nmregr_options*>.
# See <estim_pars.html *estim_pars*> for application of the option settings.
# Initial estimates are controlled by option 'pars_init_method', but the free-setting is always taken from the pars_init file
#
## Example of use
#  calibration_options('default'); calibration_options('random_seed', 123543545); calibration_options('add_initial', 1)

function calibration_options(key::String, val::String)
    # Global varaibles
    #global search_method, num_results, gen_factor, factor_type, bounds_from_ind
    #global max_fun_evals, max_calibration_time, num_runs, add_initial, refine_best
    #global verbose, verbose_options, random_seeds, seed_index
    #global ranges, mat_file, results_printlnlay, results_filename, save_results, sigma_share

    if !@isdefined(key)
        key = "inexistent"
    end
    if key in [
        "default",
        "search_method",
        "num_results",
        "gen_factor",
        "factor_type",
        "bounds_from_ind",
        "add_initial",
        "refine_best",
        "max_fun_evals",
        "max_calibration_time",
        "num_runs",
        "verbose",
        "verbose_options",
        "seed_index",
        "random_seeds",
        "ranges",
        "results_printlnlay",
        "results_filename",
        "save_results",
        "mat_file",
        "sigma_share",
    ]
        #switch key 
        #if key =={"default", ""}
        if key == "default" || key == ""
            search_method = "mm_shade" # Use mm_shade for parameter estimation
            num_results = 50 # The size for the multimodal algorithm's population.
            # If not defined then sets the values recommended by
            # the author, which are 100 for mm_shade ("mm_shade") and
            # 18 * problem size for L-mm_shade.
            gen_factor = 0.5 # Percentage bounds for individual 
            # initialization. (e.g. A value of 0.9 means
            # that, for a parameter value of 1, the range
            # for generation is [(1 - 0.9) * 1, 1 * (1 + 0.9)] so
            # the new parameter value will be a random
            # between [0.1, 1.9]
            factor_type = "mult" # The kind of factor to be applied when generatin individuals 
            #("mult" is multiplicative (Default) | "add" if
            # additive);
            bounds_from_ind = 1 # This options selects from where the 
            # parameters for the initial population of
            # individuals are taken. If the value is
            # equal to 1 the parameters are generated
            # from the data initial values if is 0 then
            # the parameters are generated from the
            # pseudo data values. 
            add_initial = 0 # If to add an invidivual taken from initial 
            # data into first population.
            refine_initial = 0 # If a refinement is applied to the initial 
            # individual of the population (only if it the
            # "add_initial" option is activated)
            refine_best = 0 # If a local search is applied to the best 
            # individual found. 
            #max_fun_evals = 20000; # The maximum number of function 
            # evaluations to perform before to end the
            # calibration process. 
            max_calibration_time = 30 # The maximum calibration time
            num_runs = 10 # The number of runs to perform. 
            verbose = 0 # If to print some information while the calibration 
            # process is running. 
            verbose_options = 5 # The number of solutions to show from the 
            # set of optimal solutions found by the
            # algorithm through the calibration process.
            random_seeds = [
                2147483647,
                2874923758,
                1284092845,
                2783758913,
                3287594328,
                2328947617,
                1217489374,
                1815931031,
                3278479237,
                3342427357,
                223758927,
                3891375891,
                1781589371,
                1134872397,
                2784732823,
                2183647447,
                24923758,
                122845,
                2783784093,
                394328,
                2328757617,
                12174974,
                18593131,
                3287237,
                33442757,
                2235827,
                3837891,
                17159371,
                34211397,
                2842823,
            ] # The values of the
            # seed used to
            # generate random
            # values (each one
            # is used in a
            # single run of the
            # algorithm). 
            seed_index = 1 # index for seeds for random number generator
            #rng(random_seeds(seed_index), "twister"); # initialize the number generator is with a seed, to be updated for each run of the calibration method. 
            MersenneTwister(random_seeds[seed_index]) # initialize the number generator is with a seed, to be updated for each run of the calibration method.
            ranges = nothing #struct(); # The range struct is empty by default. 
            results_printlnlay = "Basic" # The results output style.
            results_filename = "Default"
            save_results = false # If results output are saved.
            mat_file = "" # .mat filename for simulation results.
            sigma_share = 0.1 # Minimum distance between individuals to sanction them in Fitness Sharing. 
        end

        if key == "search_method"
            if !@isdefined(val)
                search_method = "mm_shade" # Select mm_shade as the default method.
            else
                search_method = val
            end
        end
        if key == "num_results"
            if !@isdefined(val)
                if length(num_results) != 0
                    println("num_results = " * string(num_results) * " \n")
                else
                    println("num_results = unknown \n")
                end
            else
                if num_results < 1
                    num_results = 10
                else
                    num_results = val
                end
            end
        end
        if key == "gen_factor"
            if !@isdefined(val)
                if length(gen_factor) != 0.0
                    println("gen_factor = ", string(gen_factor), " \n")
                else
                    println("gen_factor = unknown \n")
                end
            else
                gen_factor = val
            end
        end
        if key == "factor_type"
            println("e")
            if !@isdefined(val)
                println("a")
                if length(factor_type) != 0.0
                    println("o")
                    println("factor_type = ", factor_type, " \n")
                else
                    println("factor_type = unknown \n")
                end
                factor_type = val
            end
        end
        if key == "bounds_from_ind"
            if !@isdefined(val)
                if length(bounds_from_ind) != 0
                    println("bounds_from_ind = ", string(bounds_from_ind), " \n")
                else
                    println("bounds_from_ind = unknown \n")
                end
            else
                bounds_from_ind = val
            end
        end
        if key == "add_initial"
            if !@isdefined(val)
                if length(add_initial) != 0
                    println("add_initial = ", string(add_initial), " \n")
                else
                    println("add_initial = unknown \n")
                end
            else
                add_initial = val
            end
        end
        if key == "refine_best"
            if !@isdefined(val)
                if length(refine_best) != 0
                    println("refine_best = ", string(refine_best), " \n")
                else
                    println("refine_best = unknown \n")
                end
            else
                refine_best = val
            end
        end
        if key == "max_fun_evals"
            if !@isdefined(val)
                if length(max_fun_evals) != 0
                    println("max_fun_evals = ", string(max_fun_evals), " \n")
                else
                    println("max_fun_evals = unknown \n")
                end
            else
                max_fun_evals = val
                max_calibration_time = Inf
            end
        end
        if key == "max_calibration_time"
            if !@isdefined(val)
                if length(max_calibration_time) != 0
                    println("max_calibration_time = ", string(max_calibration_time), " \n")
                else
                    println("max_calibration_time = unknown \n")
                end
            else
                max_calibration_time = val
                max_fun_evals = Inf
            end
        end
        if key == "num_runs"
            if !@isdefined(val)
                if length(max_fun_evals) != 0
                    println("num_runs = ", string(num_runs), " \n")
                else
                    println("num_runs = unknown \n")
                end
            else
                num_runs = val
            end
        end
        if key == "verbose"
            if !@isdefined(val)
                if length(verbose) != 0
                    println("verbose = ", string(verbose), " \n")
                else
                    println("verbose = unknown \n")
                end
            else
                verbose = val
            end
        end
        if key == "verbose_options"
            if !@isdefined(val)
                if length(verbose_options) != 0
                    println("verbose_options = ", string(verbose_options), " \n")
                else
                    println("verbose_options = unknown \n")
                end
            else
                verbose_options = val
            end
        end
        if key == "seed_index"
            if !@isdefined(val)
                if length(random_seeds) != 0
                    println("seed_index = ", string(seed_index(1)), " \n")
                else
                    println("seed_index = unknown \n")
                end
            else
                seed_index = val
            end
            rng(random_seeds(seed_index), "twister") # initialize the random number generator
        end
        if key == "random_seeds"
            if !@isdefined(val)
                if length(random_seeds) != 0
                    println("random_seeds = ", string(random_seeds), " \n")
                else
                    println("random_seeds = unknown \n")
                end
            else
                random_seeds = val
            end
        end
        if key == "ranges"
            if !@isdefined(val)
                if length(ranges) != 0
                    println("ranges = ", string(ranges), " \n")
                else
                    println("ranges = unknown \n")
                end
            else
                ranges = val
            end
        end
        if key == "results_printlnlay"
            if !@isdefined(val)
                if results_printlnlay == "Basic"
                    println("results_printlnlay = ", results_printlnlay, " \n")
                elseif results_printlnlay == "Best"
                    println("results_printlnlay = ", results_printlnlay, " \n")
                elseif results_printlnlay == "Set"
                    println("results_printlnlay = ", results_printlnlay, " \n")
                elseif results_printlnlay == "Complete"
                    println("results_printlnlay = ", results_printlnlay, " \n")
                else
                    println("results_printlnlay = unknown \n")
                end
            else
                results_printlnlay = val
            end
        end
        if key == "results_filename"
            if !@isdefined(val)
                results_filename = "Default"
            else
                results_filename = val
            end
        end
        if key == "save_results"
            if !@isdefined(val)
                if length(save_results) != 0
                    println("save_results = ", save_results, " \n")
                else
                    println("save_results = unknown \n")
                end
            else
                save_results = val
            end
        end
        if key == "mat_file"
            if !@isdefined(val)
                mat_file = ""
            else
                mat_file = val
            end
        end
        if key == "sigma_share"
            if !@isdefined(val)
                if length(sigma_share) != 0.0
                    println("sigma_share = ", string(sigma_share), " \n")
                else
                    println("sigma_share = unknown \n")
                end
            else
                if val > 1.0
                    val = 1.0
                elseif val < 0.0
                    val = 0.0
                end
                sigma_share = val
            end
        end
    else
        if key != "inexistent"
            println("key ", key, " is unknown \n\n")
        end
        if search_method != ""
            println("search_method = ", search_method, " \n")
        else
            println("search_method = unknown \n")
        end
        if length(num_results) != 0.0
            println("num_results = ", string(num_results), " \n")
        else
            println("num_results = unknown \n")
        end
        if length(gen_factor) != 0.0
            println("gen_factor = ", string(gen_factor), " \n")
        else
            println("gen_factor = unknown \n")
        end
        if length(factor_type) != 0
            println("factor_type = ", factor_type, " \n")
        else
            println("factor_type = unknown \n")
        end
        if length(bounds_from_ind) != 0.0
            println("bounds_from_ind = ", string(bounds_from_ind), " \n")
        else
            println("bounds_from_ind = unknown \n")
        end
        if length(max_fun_evals) != 0
            println("max_fun_evals = ", string(max_fun_evals), " \n")
        else
            println("max_fun_evals = unknown \n")
        end
        if length(max_calibration_time) != 0
            println("max_calibration_time = ", string(max_calibration_time), " \n")
        else
            println("max_calibration_time = unknown \n")
        end
        if length(num_runs) != 0
            println("num_runs = ", string(num_runs), " \n")
        else
            println("num_runs = unknown \n")
        end
        if length(add_initial) != 0
            println("add_initial = ", string(add_initial), " \n")
        else
            println("add_initial = unknown \n")
        end
        if length(refine_best) != 0
            println("refine_best = ", string(refine_best), " \n")
        else
            println("refine_best = unknown \n")
        end
        if length(verbose) != 0
            println("verbose = ", string(verbose), " \n")
        else
            println("verbose = unknown \n")
        end
        if length(verbose_options) != 0
            println("verbose_options = ", string(verbose_options), " \n")
        else
            println("verbose_options = unknown \n")
        end
        if exist("ranges", "var")
            if isempty(ranges)
                println("No ranges defined \n")
            else
                println(size(ranges), "ranges defined \n")
            end
        else
            println("ranges = unknown \n")
        end
        if results_printlnlay != ""
            println("results_printlnlay = ", results_printlnlay, " \n")
        else
            println("results_printlnlay = unknown \n")
        end
        if results_filename != ""
            println("results_filename = ", results_filename, " \n")
        else
            println("results_filename = unknown \n")
        end
        if mat_file != ""
            println("mat_file = ", mat_file, " \n")
        else
            println("mat_file = unknown \n")
        end
        if sigma_share != ""
            println("sigma_share = ", sigma_share, " \n")
        else
            println("sigma_share = unknown \n")
        end
    end
end
