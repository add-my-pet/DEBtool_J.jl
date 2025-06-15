## estim_options
# Sets options for estim.pars

##
#  created at 2015/01/25 by Goncalo Marques; 
#  modified 2015/03/26 by Goncalo Marques, 2018/05/21, 2018/08/21 by Bas Kooijman, 
#    2019/12/20 by Nina Marn, 2021/06/07 by Bas Kooijman & Juan Robles,
#    2021/10/20, 2022/04/24 by Juan Robles

## Syntax
# <../estim_options.m *estim_options*> (key, val)

## Description
# Sets options for estimation one by one, some apply to methods nm and mmea, others to mmea only
#
# Input
#
# * no input: print values to screen
# * one input:
#
#    'default': sets options at default values
#     any other key (see below): print value to screen
#
# * two inputs
#
#    'loss_function': 
#      'sb': multiplicative symmetric bounded (default)
#      'su': multiplicative symmetric unbounded
#      're': relative error (not recommanded)
#      'SMAE': symmetric mean absolute error
#
#    'filter': 
#      0: do not use filters;
#      1: use filters (default)
#
#    'pars_init_method':
#      0: get initial estimates from automatized computation 
#      1: read initial estimates from .mat file (for continuation)
#      2: read initial estimates from pars_init file (default)
#
#    'results_output':
#      0     - only saves data to .mat (no printing to html or screen and no figures) - use this for (automatic) continuations 
#      1, -1 - no saving to .mat file, prints results to html (1) or screen (-1), shows figures but does not save them
#      2, -2 - saves to .mat file, prints results to html (2) or screen (-2), shows figures but does not save them
#      3, -3 - like 2 (or -2), but also prints graphs to .png files (default is 3)
#      4, -4 - like 3 (or -3), but also prints html with implied traits
#      5, -5 - like 4 (or -4), but includes related species in the implied traits
#      6     - like 5, but also prints html with population traits
#   
#    'method': 
#      'no': do not estimate
#      'nm': Nelder-Mead simplex method (default)
#      'mmea': multimodal evolutionary algorithm
#
#    'max_fun_evals': maximum number of function evaluations (default 10000)
#
#    'report': 
#       0 - do not report
#       1 - report steps to screen (default)
#
#    'max_step_number': maximum number of steps (default 500)
#
#    'tol_simplex': tolerance for how close the simplex points must be together to call them the same (default 1e-4)
#
#    'tol_fun': tolerance for how close the loss-function values must be together to call them the same (default 1e-4)
#
#    'simplex_size': fraction added (subtracted if negative) to the free parameters when building the simplex (default 0.05)
#
#    'search_method' (method mmea only): 
#      'mm_shade' - use mm_shade method (default)
#     
#    'num_results' (method mmea only): The size for the multimodal algorithm's population. The author recommended
#       50 for mm_shade ('search_method mm_shade', default) 
#       18 * number of free parameters for L-mm_shade ('search method l-mm_shade')
#
#    'gen_factor' (method mmea only): percentage to build the ranges for initializing the first population of individuals (default 0.5)                  
#
#    'bounds_from_ind' (method mmea only): 
#      0: use ranges from pseudodata if exist (these ranges not existing will be taken from data)         
#      1: use ranges from data (default) 
#
#    'max_calibration_time' (method mmea only): maximum calibration time in minutes (default 30)
#    'min_convergence_threshold' (method mmea only): the minimum improvement the mmea needs to reach 
#                                                    to continue the calibration process (default 1e-4)
#    'max_pop_dist': the maximum distance allowed between the solutions of the MMEA population to 
#                     continue the calibration process (default 0.2). 
#    'num_runs' (method mmea only): the number of independent runs to perform (default 1)
#
#    'add_initial' (method mmea only): if the initial individual is added in the first  population.
#      1: activated
#      0: not activated (default)
#
#     
#    'refine_best'  (method mmea only): if the best individual found is refined using Nelder-Mead.
#      0: not activated (default)
#      1: activated
#     
#    'verbose_options' (method mmea only): The number of solutions to show from the set of optimal solutions found by the algorithm through the calibration process (default 10)                                           
#
#    'verbose' (method mmea only): prints some information while the calibration  process is running              
#       0: not activated (default)
#       1: activated
#
#    'seed_index' (method mmea only): index of vector with values for the seeds used to generate random values 
#       each one is used in a single run of the algorithm (default 1, must be between 1 and 30)
#
#    'ranges' (method mmea only): Structure with ranges for the parameters to be calibrated (default empty)
#       one value (factor between [0, 1], if not: 0.01 is set) to increase and decrease the original parameter values.
#       two values (min, max) for the  minimum and maximum range values. Consider:               
#         (1) Use min < max for each variable in ranges. If it is not, then the range will be not used
#         (2) Do not take max/min too high, use the likely ranges of the problem
#         (3) Only the free parameters (see 'pars_init_my_pet' file) are considered
#       Set range with cell string of name of parameter and value for range, e.g. estim_options('ranges',{'kap', [0.3 1]}} 
#       Remove range-specification with e.g. estim_options('ranges', {'kap'}} or estim_options('ranges', 'kap'}
#
#    'results_display (method mmea only)': 
#       Basic - Does not show results in screen (default) 
#       Best  - Plots the best solution results in DEBtool style
#       Set   - Plots all the solutions remarking the best one 
#               html with pars (best pars and a measure of the variance of each parameter in the solutions obtained for example)
#       Complete - Joins all options with zero variate data with input and a measure of the variance of all the solutions considered
#
#    'results_filename (method mmea only)': The name for the results file (solutionSet_my_pet_time) 
#
#    'save_results' (method mmea only): If the results output images are going to be saved
#       0: no saving (default)
#       1: saving
#
#    'mat_file' (method mmea only): The name of the .mat-file with results from where to initialize the calibration parameters 
#       (only useful if pars_init_method option is equal to 1 and if there is a result file)
#       This file is outputted as results_my_pet.mat ("my pet" replaced by name of species) using method nm, results_output 0, 2-6.
#
#    'sigma_share': The value of the sigma share parameter (that is used
#       into the fitness sharing niching method if it is activated)
#
# Output
#
# * no output, but globals are set to values or values are printed to screen
#
## Remarks
# See <estim_pars.html *estim_pars*> for application of the option settings.
# Initial estimates are controlled by option 'pars_init_method', but the free-setting is always taken from the pars_init file.
# A typical estimation procedure is
# 
# * first use estim_options('pars_init_method',2) with estim_options('max_step_number',500),
# * then estim_options('pars_init_method',1), repeat till satiation or convergence (using arrow-up + enter)
# * type mat2pars_init in the Matlab's command window to copy the results in the .mat file to the pars_init file
#
# If results_output equals 5 or higher, the comparison species can be
# specified by declaring variable refPets as global and fill it with a
# cell-string of AmP species names.
#
# The default setting for max_step_number on 500 in method nm is on purpose not enough to reach convergence.
# Continuation (using arrow-up + 'enter' after 'pars_init_method' set on 1) is important to restore simplex size.
#
# Typical simplex options are also used in the evolutionary algorithm via local_search in mm_shade and lmm_shade
#
## Example of use
#  estim_options('default'); estim_options('filter', 0); estim_options('method', 'no')

#= function estim_options(key::String)

    global method, lossfunction, filter, pars_init_method, results_output, max_fun_evals
    global report, max_step_number, tol_simplex, tol_fun, simplex_size
    global search_method, num_results, gen_factor, factor_type, bounds_from_ind # method mmea only
    global max_calibration_time, num_runs, add_initial, refine_best
    global verbose, verbose_options
    global random_seeds, seed_index, ranges, mat_file, results_display
    global results_filename, save_results, sigma_share

    availableMethodOptions = ["no", "nm", "mmea", "nr"]

    #if exist("key","var") == 0
    #  key = "inexistent";
    #end

    if key == "default"
        lossfunction = "sb"
        filter = 1
        pars_init_method = 2
        results_output = 3
        method = "nm"
        max_fun_evals = 1e4
        report = 1
        max_step_number = 500
        tol_simplex = 1e-4
        tol_fun = 1e-4
        simplex_size = 0.05

        # for mmea method (taken from calibration_options)
        search_method = "mm_shade" # Use mm_shade: Success-History based Adaptive Differential Evolution 
        num_results = 50   # The size for the multimodal algorithm's population.
        # If not defined then sets the values recommended by the author, 
        # which are 100 for mm_shade ('mm_shade') and 18 * problem size for L-mm_shade.
        gen_factor = 0.5    # Percentage bounds for individual 
        # initialization. (e.g. A value of 0.9 means that, for a parameter value of 1, 
        # the range for generation is [(1 - 0.9) * 1, 1 * (1 + 0.9)] so
        # the new parameter value will be a random between [0.1, 1.9]
        factor_type = "mult" # The kind of factor to be applied when generatin individuals 
        #('mult' is multiplicative (Default) | 'add' if
        # additive);
        bounds_from_ind = 1 # This options selects from where the parameters for the initial population of individuals are taken. 
        # If the value is equal to 1 the parameters are generated from the data initial values 
        # if is 0 then the parameters are generated from the pseudo data values. 
        add_initial = 0     # If to add an invidivual taken from initial data into first population.                     # (only if it the 'add_initial' option is activated)
        refine_best = 0     # If a local search is applied to the best individual found. 
        max_calibration_time = 30 # The maximum calibration time calibration process. 
        num_runs = 5 # The number of runs to perform. 
        verbose = 0  # If to print some information while the calibration process is running. 
        verbose_options = 5 # The number of solutions to show from the  set of optimal solutions found by the  algorithm through the calibration process.
        random_seeds = [
            2147483647,
            2874923758,
            1284092845,  # The values of the seed used to
            2783758913,
            3287594328,
            2328947617,  # generate random values (each one is used in a
            1217489374,
            1815931031,
            3278479237,  # single run of the algorithm).
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
        ]
        seed_index = 1 # index for seeds for random number generator
        MersenneTwister(random_seeds[seed_index]) # initialize the number generator is with a seed, to be updated for each run of the calibration method.
        ranges = nothing #struct(); # The range struct is empty by default. 
        results_display = "Basic" # The results output style.
        results_filename = "Default"
        save_results = false # If results output are saved.
        mat_file = ""
        sigma_share = 0.1
    end


    if key == "loss_function"
        if length(lossfunction) != 0
            println("loss_function = ", lossfunction[1], " \n")
        else
            println("loss_function = unknown \n")
        end
        println("sb - multiplicative symmetric bounded \n")
        println("su - multiplicative symmetric unbounded \n")
        println("re - relative error \n")
        println("SMAE - symmetric mean absolute error \n")
    end

    if key == "filter"
        if length(filter) != 0
            println("filter = ", filter, " \n")
        else
            println("filter = unknown \n")
        end
        println("0 - do not use filter \n")
        println("1 - use filter \n")
    end

    if key == "pars_init_method"
        if length(pars_init_method) != 0
            println("pars_init_method = ", pars_init_method, " \n")
        else
            println("pars_init_method = unknown \n")
        end
        println("0 - get initial estimates from automatized computation \n")
        println("1 - read initial estimates from .mat file \n")
        println("2 - read initial estimates from pars_init file \n")
    end

    if key == "results_output"
        if length(results_output) != 0
            println("results_output = ", results_output, " \n")
        else
            println("results_output = unknown \n")
        end
        println(
            "0      only saves data results to .mat, no figures, no writing to html or screen\n",
        )
        println(
            "1, -1  no saving to .mat file, prints results to html (1) or screen (-1)\n",
        )
        println("2, -2  saves to .mat file, prints results to html (2) or screen (-2) \n")
        println(
            "3, -3  like 2 (or -2), but also prints graphs to .png files (default is 3)\n",
        )
        println("4, -4  like 3 (or -3), but also prints html with implied traits \n")
        println(
            "5, -5  like 3 (or -3), but also prints html with implied traits including related species \n",
        )
        println("6,     like 5, but also prints html with population traits \n")
    end

    if key == "method"
        if length(method) != 0
            println("method = ", method, " \n")
        else
            println("method = unknown \n")
        end
        println("''no'' - do not estimate \n")
        println("''nm'' - use Nelder-Mead method \n")
        println("''mmea'' - use multimodal evolutionary algorithm method \n")
    end

    if key == "max_fun_evals"
        if length(max_fun_evals) != 0
            println("max_fun_evals = ", max_fun_evals, " \n")
        else
            println("max_fun_evals = unknown \n")
        end
    end

    if key == "report"
        if length(report) != 0
            println("report = ", report, "\n")
        else
            println("report = unknown \n")
        end
        println("0 - do not report \n")
        println("1 - do report \n")
    end

    if key == "max_step_number"
        if length(max_step_number) != 0
            println("max_step_number = ", max_step_number, "\n")
        else
            println("max_step_number = unknown \n")
        end
    end

    if key == "tol_simplex"
        if length(tol_simplex) != 0
            println("tol_simplex = ", tol_simplex, "\n")
        else
            println("tol_simplex = unknown \n")
        end
    end

    if key == "simplex_size"
        if length(simplex_size) != 0
            println("simplex_size = ", simplex_size, "\n")
        else
            println("simplex_size = unknown \n")
        end
    end

    # method mmea only, taken from calibatrion_options
    if key == "search_method"
        search_method = "mm_shade" # Select mm_shade as the default method.
    end

    if key == "num_results"
        if length(num_results) != 0
            println("num_results = ", num_results, " \n")
        else
            println("num_results = unknown \n")
        end
    end

    if key == "gen_factor"
        if length(gen_factor) != 0.0
            println("gen_factor = ", gen_factor, " \n")
        else
            println("gen_factor = unknown \n")
        end
    end

    if key == "factor_type"
        factor_type = "mult"
        println("factor_type = ", factor_type, " \n")
    end

    if key == "bounds_from_ind"
        if length(bounds_from_ind) != 0
            println("bounds_from_ind = ", bounds_from_ind, " \n")
        else
            println("bounds_from_ind = unknown \n")
        end
    end

    if key == "add_initial"
        if length(add_initial) != 0
            println("add_initial = ", add_initial, " \n")
        else
            println("add_initial = unknown \n")
        end
    end

    if key == "refine_best"
        if length(refine_best) != 0
            println("refine_best = ", refine_best, " \n")
        else
            println("refine_best = unknown \n")
        end
    end

    if key == "max_calibration_time"
        if length(max_calibration_time) != 0
            println("max_calibration_time = ", max_calibration_time, " \n")
        else
            println("max_calibration_time = unkown \n")
        end
    end

    if key == "num_runs"
        if length(num_runs) != 0
            println("num_runs = ", num_runs, " \n")
        else
            println("num_runs = unkown \n")
        end
    end

    if key == "verbose"
        if length(verbose) != 0
            println("verbose = ", verbose, " \n")
        else
            println("verbose = unkown \n")
        end
    end

    if key == "verbose_options"
        if length(verbose_options) != 0
            println("verbose_options = ", verbose_options, " \n")
        else
            println("verbose_options = unkown \n")
        end
    end

    if key == "seed_index"
        if length(random_seeds) != 0
            println("seed_index = ", seed_index[1], " \n")
        else
            println("seed_index = unkown \n")
        end
    end
    MersenneTwister(random_seeds[seed_index]) # initialize the random number generator

    if key == "ranges"
        if length(ranges) != 0
            println("ranges = structure with fields: \n")
            println(ranges)
        else
            println("ranges = unkown \n")
        end
    end

    if key == "results_display"
        if strcmp(results_display, "Basic")
            println("results_display = ", results_display, " \n")
        elseif strcmp(results_display, "Best")
            println("results_display = ", results_display, " \n")
        elseif strcmp(results_display, "Set")
            println("results_display = ", results_display, " \n")
        elseif strcmp(results_display, "Complete")
            println("results_display = ", results_display, " \n")
        else
            println("results_display = unkown \n")
        end
    end

    if key == "results_filename"
        results_filename = "Default"
    end

    if key == "save_results"
        if length(save_results) != 0
            println("save_results = ", save_results, " \n")
        else
            println("save_results = unkown \n")
        end
    end

    if key == "mat_file"
        mat_file = [""]
    end

    if key == "sigma_share"
        if length(sigma_share) != 0.0
            println("sigma_share = ", sigma_share, " \n")
        else
            println("sigma_share = unknown \n")
        end
    end

    # only a single input
    if key == "inexistent"
        if length(lossfunction) != 0
            println("loss_function = ", lossfunction, " \n")
        else
            println("loss_function = unknown \n")
        end

        if length(filter) != 0
            println("filter = ", filter, " \n")
        else
            println("filter = unknown \n")
        end

        if length(pars_init_method) != 0
            println("pars_init_method = ", pars_init_method, " \n")
        else
            println("pars_init_method = unknown \n")
        end

        if length(results_output) != 0
            println("results_output = ", results_output, " \n")
        else
            println("results_output = unknown \n")
        end

        if length(method) != 0
            println("method = ", method, " \n")
            if strcmp(method, "mmea")
                calibration_options
            end
        else
            println("method = unknown \n")
        end

        if length(max_fun_evals) != 0
            println("max_fun_evals = ", max_fun_evals, " \n")
        else
            println("max_fun_evals = unknown \n")
        end

        if length(report) != 0
            println("report = ", report, " (method nm)\n")
        else
            println("report = unknown \n")
        end

        if length(max_step_number) != 0
            println("max_step_number = ", max_step_number, " (method nm)\n")
        else
            println("max_step_number = unknown \n")
        end

        if length(tol_simplex) != 0
            println("tol_simplex = ", tol_simplex, " (method nm)\n")
        else
            println("tol_simplex = unknown \n")
        end

        if length(simplex_size) != 0
            println("simplex_size = ", simplex_size, " (method nm)\n")
        else
            println("simplex_size = unknown \n")
        end

        # method mmea only
        if length(search_method) != 0
            println("search_method = ", search_method, " (method mmea)\n")
        else
            println("search_method = unkown \n")
        end

        if length(num_results) != 0.0
            println("num_results = ", num_results, " (method mmea)\n")
        else
            println("num_results = unknown \n")
        end

        if length(gen_factor) != 0.0
            println("gen_factor = ", gen_factor, " (method mmea)\n")
        else
            println("gen_factor = unknown \n")
        end

        if length(factor_type) != 0
            println("factor_type = ", factor_type, " \n")
        else
            println("factor_type = unkown \n")
        end

        if length(bounds_from_ind) != 0.0
            println("bounds_from_ind = ", bounds_from_ind, " (method mmea)\n")
        else
            println("bounds_from_ind = unknown \n")
        end

        if length(max_fun_evals) != 0
            println("max_fun_evals = ", max_fun_evals, " (method mmea)\n")
        else
            println("max_fun_evals = unkown \n")
        end

        if length(max_calibration_time) != 0
            println("max_calibration_time = ", max_calibration_time, " (method mmea)\n")
        else
            println("max_calibration_time = unkown \n")
        end

        if length(num_runs) != 0
            println("num_runs = ", num_runs, " (method mmea)\n")
        else
            println("num_runs = unkown \n")
        end

        if length(add_initial) != 0
            println("add_initial = ", add_initial, " (method mmea)\n")
        else
            println("add_initial = unkown \n")
        end

        if length(refine_best) != 0
            println("refine_best = ", refine_best, " (method mmea)\n")
        else
            println("refine_best = unkown \n")
        end

        if length(verbose) != 0
            println("verbose = ", verbose, " (method mmea)\n")
        else
            println("verbose = unkown \n")
        end

        if length(verbose_options) != 0
            println("verbose_options = ", verbose_options, " (method mmea)\n")
        else
            println("verbose_options = unkown \n")
        end

        if length(random_seeds) != 0
            println("random_seeds = ", random_seeds[1], " (method mmea)\n")
        else
            println("random_seeds = unkown \n")
        end

        if length(ranges) != 0
            println("ranges = structure with fields (method mmea)\n")
            disp(struct2table(ranges))
        else
            println("ranges = unkown \n")
        end

        if strcmp(results_display, "") != 0
            println("results_display = ", results_display, " (method mmea)\n")
        else
            println("results_display = unkown \n")
        end

        if strcmp(results_filename, "") != 0
            println("results_filename = ", results_filename, " (method mmea)\n")
        else
            println("results_filename = unkown \n")
        end

        if strcmp(mat_file, "") != 0
            println("mat_file = ", mat_file, " (method mmea)\n")
        else
            println("mat_file = unkown \n")
        end

        if strcmp(sigma_share, "") != 0
            println("sigma_share = ", sigma_share, " \n")
        else
            println("sigma_share = unkown \n")
        end

        otherwise
        println("key ", key, " is unkown \n\n")
        estim_options
    end

    ## warnings
    if method == "mmea" && filter == 0
        println(
            "Warning from estim_options: method mmea without using filters amounts to asking for trouble\n",
        )
    end
end


function estim_options(key::String, val)

    global method, lossfunction, filter, pars_init_method, results_output, max_fun_evals
    global report, max_step_number, tol_simplex, tol_fun, simplex_size
    global search_method, num_results, gen_factor, factor_type, bounds_from_ind # method mmea only
    global max_calibration_time, num_runs, add_initial, refine_best
    global verbose, verbose_options
    global random_seeds, seed_index, ranges, mat_file, results_display
    global results_filename, save_results, sigma_share

    availableMethodOptions = ["no", "nm", "mmea", "nr"]

    #if exist("key","var") == 0
    #  key = "inexistent";
    #end

    if key == "loss_function"
        lossfunction[1] = val
    end

    if key == "filter"
        filter = val
    end

    if key == "pars_init_method"
        pars_init_method = val
    end

    if key == "results_output"
        results_output = val
    end

    if key == "method"
        method = val
    end

    if key == "max_fun_evals"
        max_fun_evals = val
        max_calibration_time = Inf # mmea method only
    end

    if key == "report"
        report = val
    end

    if key == "max_step_number"
        max_step_number = val
    end

    if key == "tol_simplex"
        tol_simplex = val
    end

    if key == "simplex_size"
        simplex_size = val
    end

    # method mmea only, taken from calibatrion_options
    if key == "search_method"
        search_method = val
    end

    if key == "num_results"
        if num_results < 1
            num_results = 10
        else
            num_results = val
        end
    end

    if key == "gen_factor"
        gen_factor = val
    end

    if key == "factor_type"
        factor_type = val
    end

    if key == "bounds_from_ind"
        bounds_from_ind = val
    end

    if key == "add_initial"
        add_initial = val
    end

    if key == "refine_best"
        refine_best = val
    end

    if key == "max_calibration_time"
        max_calibration_time = val
        max_fun_evals = Inf
    end

    if key == "num_runs"
        num_runs = val
    end

    if key == "verbose"
        verbose = val
    end

    if key == "verbose_options"
        verbose_options = val
    end

    if key == "seed_index"
        seed_index = val
        rng(random_seeds(seed_index), "twister") # initialize the random number generator
    end

    # MK need to fix this
    # if key == "ranges"
    #     if iscell(val) && length(val)>1
    #       ranges.(val{1}) = val{2};
    #     elseif iscell(val) && isfield(ranges, val)
    #       ranges = rmfield(ranges, val{1});
    #     elseif isfield(ranges, val)
    #       ranges = rmfield(ranges, val);
    #     end
    #   end

    if key == "results_display"
        results_display = val
    end

    if key == "results_filename"
        results_filename = val
    end

    if key == "save_results"
        save_results = val
    end

    if key == "mat_file"
        mat_file = val
    end

    if key == "sigma_share"
        if val > 1.0
            val = 1.0
        elseif val < 0.0
            val = 0.0
        end
        sigma_share = val
    end

    ## warnings
    if method == "mmea" && filter == 0
        println(
            "Warning from estim_options: method mmea without using filters amounts to asking for trouble\n",
        )
    end
end =#

struct EstimOptions{C}
   method::String
   lossfunction::String
   filter::Bool
   pars_init_method::Int
   results_output::Int
   max_fun_evals::Int
   report::Bool
   max_step_number::Int
   tol_simplex::Float64
   tol_fun::Float64
   simplex_size::Float64
   search_method::String
   num_results::Int
   gen_factor::Float64
   factor_type::String
   bounds_from_ind::Int
   max_calibration_time::Int
   num_runs::Int
   add_initial::Bool
   refine_best::Bool
   verbose::Bool
   verbose_options::Int
   random_seeds::Vector{Int}
   seed_index::Int
   ranges::Union{Float64,Nothing}
   mat_file::Union{String,Nothing}
   results_display::String
   results_filename::String
   save_results::Bool
   sigma_share::Float64
   rng::MersenneTwister
   calibration::C
end

function EstimOptions(;
    method = "nm",
    lossfunction = "sb",
    filter = true,
    pars_init_method = 2,
    results_output = 3,
    max_fun_evals = 10000,
    report = true,
    max_step_number = 500,
    tol_simplex = 1e-4,
    tol_fun = 1e-4,
    simplex_size = 0.05,
    # for mmea method (taken from calibration_options)
    search_method = "mm_shade", # Use mm_shade: Success-History based Adaptive Differential Evolution
    num_results = 50,   # The size for the multimodal algorithm's population.
    # If not defined then sets the values recommended by the author,
    # which are 100 for mm_shade ('mm_shade') and 18 * problem size for L-mm_shade.
    gen_factor = 0.5,    # Percentage bounds for individual
    # initialization. (e.g. A value of 0.9 means that, for a parameter value of 1,
    # the range for generation is [(1 - 0.9) * 1, 1 * (1 + 0.9)] so
    # the new parameter value will be a random between [0.1, 1.9]
    factor_type = "mult", # The kind of factor to be applied when generatin individuals
    #('mult' is multiplicative (Default) | 'add' if
    # additive);
    bounds_from_ind = 1, # This options selects from where the parameters for the initial population of individuals are taken.
    # If the value is equal to 1 the parameters are generated from the data initial values
    # if is 0 then the parameters are generated from the pseudo data values.
    max_calibration_time = 30, # The maximum calibration time calibration process.
    num_runs = 5, # The number of runs to perform.
    add_initial = false,     # If to add an invidivual taken from initial data into first population.                     # (only if it the 'add_initial' option is activated)
    refine_best = false,     # If a local search is applied to the best individual found.
    verbose = false,  # If to print some information while the calibration process is running.
    verbose_options = 5, # The number of solutions to show from the  set of optimal solutions found by the  algorithm through the calibration process.
    random_seeds = [
        2147483647,
        2874923758,
        1284092845,  # The values of the seed used to
        2783758913,
        3287594328,
        2328947617,  # generate random values (each one is used in a
        1217489374,
        1815931031,
        3278479237,  # single run of the algorithm).
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
    ],
    seed_index = 1, # index for seeds for random number generator
    ranges = nothing, #struct(); # The range struct is empty by default.
    mat_file = "",
    results_display = "Basic", # The results output style.
    results_filename = "Default",
    save_results = false, # If results output are saved.
    sigma_share = 0.1,
    rng = MersenneTwister(random_seeds[seed_index]), # initialize the number generator is with a seed, to be updated for each run of the calibration method.
    calibration,
)

    rd = ("Basic", "Best", "Set", "Complete")
    results_display in rd || throw(ArgumentError("results_display must be one of $rd"))

    m = ("no", "nm", "mmea")
    method in m || throw(ArgumentError("method must be one of $m"))
    
    method == "mmea" && !filter && @warn "estim_options: use a filter with method `:mmea`"
    0 <= sigma_share <= 1 || throw(ArgumentError("sigma_share must be between 0 and 1"))

    return EstimOptions(
        method,
        lossfunction,
        filter,
        pars_init_method,
        results_output,
        max_fun_evals,
        report,
        max_step_number,
        tol_simplex,
        tol_fun,
        simplex_size,
        search_method,
        num_results,
        gen_factor,
        factor_type,
        bounds_from_ind,
        max_calibration_time,
        num_runs,
        add_initial,
        refine_best,
        verbose,
        verbose_options,
        random_seeds,
        seed_index,
        ranges,
        mat_file,
        results_display,
        results_filename,
        save_results,
        sigma_share,
        rng,
        calibration,
    )
end
