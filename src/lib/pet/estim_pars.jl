## estim_pars
# Runs the AmP estimation procedure 

##
#function estim_pars(pets, pars_init_method, method, filter, covRules)
function estim_pars(pets = ["Emydura_macquarii"], par_model = par_model, metaPar = metaPar, estim_opts = estim_opts)

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

  #global pets#, pars_init_method, method, filter, covRules
  #global parPets, par

  @unpack method, lossfunction, filter, pars_init_method, results_output, max_fun_evals,
  report, max_step_number, tol_simplex, tol_fun, simplex_size, search_method, num_results, 
  gen_factor, factor_type, bounds_from_ind, max_calibration_time, num_runs, add_initial, 
  refine_best, verbose, verbose_options, random_seeds, seed_index, ranges, mat_file,
  results_display, results_filename, save_results, sigma_share = estim_opts

  pets = ["Emydura_macquarii"];
  include("predict_Emydura_macquarii.jl")

  n_pets = length(pets)

  # get data
  #[data, auxData, metaData, txtData, weights] = mydata_pets;
  data, auxData, metaData, txtData, weights = mydata_pets(pets)

  if n_pets == 1
    pars_initnm = "pars_init_" * pets[1]
    resultsnm = "results_" * pets[1] * ".jld2"
    #calibration_options("results_filename", resultsnm) # TO DO - uncomment once globals removed
  else
    pars_initnm = "pars_init_group"
    resultsnm = "results_group.jdl2"
  end

  # TO DO
  # set parameters
  # if pars_init_method == 0
  #   if n_pets != 1
  #     error("    For multispecies estimation get_pars cannot be used (pars_init_method cannot be 0)");
  #   else
  #     [par, metaPar, txtPar] = get_pars(data.(pets[1]), auxData.(pets[1]), metaData.(pets[1]));
  #   end
  # elseif pars_init_method == 1
  #     load(resultsnm, "par");
  #     if n_pets == 1
  #       [par2, metaPar, txtPar] = feval(pars_initnm, metaData.(pets[1]));
  #     else
  #       [par2, metaPar, txtPar] = feval(pars_initnm, metaData);
  #     end
  #     if length(fieldnames(par.free)) != length(fieldnames(par2.free))
  #       println("The number of parameters in pars.free in the pars_init and in the .mat file are not the same. \n");
  #       return;
  #     end
  #     par.free = par2.free;
  # elseif pars_init_method == 2
  #     if n_pets == 1
  #include("../example/pars_init_" * pets[1] * ".jl")
  par_names = fieldnames(typeof(par_model.parent)) # get the field names
  par_vals = par_model[:val] # get the values
  par_units = par_model[:units] # get the units
  par = NamedTuple{par_names}(Tuple([u === nothing ? typeof(v)(v) : v*u for (v, u) in zip(par_vals, par_units)])) # adjoin units to parameter values
  par_free = NamedTuple{par_names}(par_model[:free]) # get the vector of free parameters
  par = (par..., free=par_free) # append free parameters to the par struct
  #       end
  #       #[par, metaPar, txtPar] = feval(pars_initnm, metaData.(pets[1]));
  #     else
  #       [par, metaPar, txtPar] = feval(pars_initnm, metaData);
  #     end
  # end

  # make sure that global covRules exists
  #if exist("metaPar.covRules","var")
  if isdefined(metaPar, :covRules)
    covRules = metaPar.covRules
  else
    covRules = "no"
  end

  # TO DO
  # # set weightsPar in case of n_pets > 1, to minimize scaled variances of parameters
  # if n_pets > 1
  #   fldPar = fieldnames(typeof(par.free));
  #   for i = 1:length(fldPar)
  #      if isfield(metaPar, "weights") && isfield(metaPar.weights, fldPar[i])
  #        weightsPar.(fldPar[i]) = metaPar.weights.(fldPar[i]);
  #      else
  #        weightsPar.(fldPar[i]) = 0;
  #      end
  #   end
  # end

  # check parameter set if you are using a filter
  parPets = parGrp2Pets(par, pets) # convert parameter structure of group of pets to cell string for each pet
  if filter == 1
    pass = true
    filternm = n_pets[1]#cell(n_pets,1);
    for i = 1:n_pets
      #if ~iscell(metaPar.model) # model is a character string
      if !isa(metaPar.model, Array)
        filternm = "filter_" * metaPar.model
        petnm = pets[i]
        #[passSpec, flag] = feval(filternm, parPets.(pets[i]));
        passSpec, flag = eval(Meta.parse("$filternm(parPets.$petnm)"))
      elseif length(metaPar.model) == 1 # model could have been a character string
        #filternm = ["filter_", metaPar.model[1]];
        #[passSpec, flag] = feval(filternm, parPets.(pets[i]));
        filternm = "filter_" * metaPar.model
        petnm = pets[1]
        #[passSpec, flag] = feval(filternm, parPets.(pets[i]));
        passSpec, flag = eval(Meta.parse("$filternm(parPets.$petnm)"))
      else # model is a cell string
        #filternm[i] = ["filter_", metaPar.model[i]];
        filternm = "filter_" * metaPar.model[i]
        petnm = pets[i]
        #[passSpec, flag] = feval(filternm, parPets.(pets[i]));
        passSpec, flag = eval(Meta.parse("$filternm(parPets.$petnm)"))
        #[passSpec, flag] = feval(filternm[i], parPets.(pets[i]));
      end
      if ~passSpec
        println("The seed parameter set for " * pets[i] * " is not realistic. \n")
        print_filterflag(flag)
      end
      pass = pass && passSpec
    end
    if ~pass
      error("The seed parameter set is not realistic")
    end
  else
    filternm = "filter_nat" # this filter always gives a pass
    pass = 1
  end

  # perform the actual estimation
  #switch method
  #  case "nm"
  if method == "nm"
    #if n_pets == 1
    par, info, nsteps, fval = petregr_f("predict_pets", par, data, auxData, weights, filternm, estim_opts, pets)   # estimate parameters using overwrite
    #else
    #  [par, info, nsteps, fval] = groupregr_f("predict_pets", par, data, auxData, weights, weightsPar, filternm); # estimate parameters using overwrite
    #end
  end
  #  case "mmea" 
  # if method == "mmea"# TO DO
  #   [par, solutions_set, fval] = calibrate; 
  #   info = ~isempty(solutions_set); 
  #   nsteps = solutions_set.runtime_information.run_1.fun_evals;
  # end
  #case "nr"
  # if method == "nr"# TO DO
  #   [par, solutions_set, fval] = calibrate; 
  #   info = ~isempty(solutions_set); 
  #   nsteps = solutions_set.runtime_information.fun_evals;
  # #otherwise # do not estimate
  # end
  #end

  # Results
  #switch method
  if method in ["nm", "no"]
    #  results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights);
    # elseif method == "mmea" # TO DO
    #   mmea_name =  strsplit(resultsnm, ".");
    #   resultsnm = [mmea_name[1], "_mmea.", mmea_name[2]];
    #   calibration_options("results_filename", resultsnm);
    #   result_pets_mmea(solutions_set, par, metaPar, txtPar, data, auxData, metaData, txtData, weights);
    # elseif method == "nr" # TO DO
    #   mmea_name =  strsplit(resultsnm, ".");
    #   resultsnm = [mmea_name[1], "_mmea.", mmea_name[2]];
    #   calibration_options("results_filename", resultsnm);
    #   result_pets_mmea(solutions_set, par, metaPar, txtPar, data, auxData, metaData, txtData, weights);
  end

  # check filter
  #parPets = parGrp2Pets(par); # convert parameter structure of group of pets to cell string for each pet
  #if filter
  #  for i = 1:n_pets
  #    if iscell(metaPar.model)
  #      feval(["warning_", metaPar.model[i]], parPets.(pets[i]));
  #    else
  #      feval(["warning_", metaPar.model], parPets.(pets[i]));
  #    end
  #  end
  (nsteps, info, fval)
end
