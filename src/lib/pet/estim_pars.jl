## estim_pars
# Runs the AmP estimation procedure 

##
#function estim_pars(pets, pars_init_method, method, filter, covRules)
struct parPets_struct
  mypet
end
function estim_pars(par_model = par_model, metaPar = metaPar, estim_opts = estim_opts)
  # created 2015/02/10 by Goncalo Marques
  # modified 2015/02/10 by Bas Kooijman, 
  #   2015/03/31, 2015/shade07/30, 2017/02/03 by Goncalo Marques, 
  #   2018/05/23 by Bas Kooijman,  
  #   2018/08/17 by Starrlight Augustine,
  #   2019/03/20, 2019/12/16, 2019/12/20, 2021/06/02 by Bas kooijman

  ## Syntax 
  # [nsteps, info, fval] = <../estim_pars.m *estim_pars*>

  ## Description
  # Runs the entire estimation procedure, see Marques et al 2018, PLOS computational biology  https://doi.org/10.1371/journal.pcbi.1006100
  # See also Robles et al 2021, (in prep) for the ea-method.
  # 
  #
  # * gets the parameters
  # * gets the data
  # * initiates the estimation procedure
  # * sends the results for handling
  #
  # Input
  #
  # * no input
  #  
  # Output
  #
  # * nsteps: scalar with number of steps
  # * info: boolean with succussful convergence (true)
  # * fval: minimum of loss function

  ## Remarks
  # estim_options sets many options;
  # Option filter = 0 selects filter_nat, which always gives a pass, but
  # still allows for costomized filters in the predict file;
  # Option output >= 5 allow the filling of global refPets to choose
  # comparison species, otherwise this is done automatically.

  @unpack method, lossfunction, filter, pars_init_method, results_output, max_fun_evals,
  report, max_step_number, tol_simplex, tol_fun, simplex_size, search_method, num_results, 
  gen_factor, factor_type, bounds_from_ind, max_calibration_time, num_runs, add_initial, 
  refine_best, verbose, verbose_options, random_seeds, seed_index, ranges, mat_file,
  results_display, results_filename, save_results, sigma_share = estim_opts

  data_mod, data, auxData, metaData, txtData, weights = mydata_pets()

  par_names = fieldnames(typeof(par_model.parent)) # get the field names
  par_vals = par_model[:val] # get the values
  par_units = par_model[:units] # get the units
  par = NamedTuple{par_names}(Tuple([u === nothing ? typeof(v)(v) : v*u for (v, u) in zip(par_vals, par_units)])) # adjoin units to parameter values
  par_free = NamedTuple{par_names}(par_model[:free]) # get the vector of free parameters
  par = (par..., free=par_free) # append free parameters to the par struct

  # make sure that global covRules exists
  if isdefined(metaPar, :covRules)
    covRules = metaPar.covRules
  else
    covRules = "no"
  end

  # check parameter set if you are using a filter
  parPets = parPets_struct(par)

  if filter == 1
    pass = true
    filternm = "filter_std"
        passSpec, flag = filter_std(parPets.mypet)
      if ~passSpec
        println("The seed parameter set is not realistic. \n")
        print_filterflag(flag)
      end
      pass = pass && passSpec
    if ~pass
      error("The seed parameter set is not realistic")
    end
  else
    filternm = "filter_nat" # this filter always gives a pass
    pass = 1
  end

  # perform the actual estimation
  #  case "nm"
  par, info, nsteps, fval = petregr_f("predict_pets", par, data, auxData, weights, filternm, estim_opts, data_mod)   # estimate parameters using overwrite
  (nsteps, info, fval)
end
