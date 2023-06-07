## petregr_f
# Finds parameter values for a pet that minimizes the lossfunction using Nelder Mead's simplex method using a filter

##
function petregr_f(func, par, data, auxData, weights, filternm, estim_opts, pets)
# created 2001/09/07 by Bas Kooijman; 
# modified 2015/01/29 by Goncalo Marques, 
#   2015/03/21 by Bas Kooijman, 
#   2015/03/30, 2015/04/27, 2015/07/29, 2016/05/05 by Goncalo Marques
#   2018/05/23, 2019/12/20 by Bas Kooijman

## Syntax
# [q, info, itercount, fval] = <../petregr_f.m *petregr_f*> (func, par, data, auxData, weights, filternm)

## Description
# Finds parameter values for a pet that minimizes the lossfunction using Nelder Mead's simplex method using a filter.
# The filter gives always a pass in the case that no filter has been selected in <estim_options.html *estim_options*>.
#
# Input
#
# * func: character string with name of user-defined function;
#      see nrregr_st or nrregr  
# * par: structure with parameters
# * data: structure with data
# * auxData: structure with auxiliary data
# * weights: structure with weights
# * filternm: character string with name of user-defined filter function
#  
# Output
# 
# * q: structure with parameters, result that minimizes the loss function
# * info: 1 if convergence has been successful; 0 otherwise
# * itercount: nummber if iterations
# * fval: minimum of loss function

## Remarks
# Set options with <nmregr_options.html *nmregr_options*>.
# Similar to <nrregr_st.html *nrregr_st*>, but slower and a larger bassin of attraction and uses a filter.
# The number of fields in data is variable.
# See <groupregr_f.html *groupregr_f*> for the multi-species situation.

  #global lossfunction, report, max_step_number, max_fun_evals, tol_simplex, tol_fun, simplex_size
  global st, fieldsInCells, auxVar, Y, meanY, W, P, meanP, q#, pets

  @unpack method, lossfunction, filter, pars_init_method, results_output, max_fun_evals,
  report, max_step_number, tol_simplex, tol_fun, simplex_size, search_method, num_results, 
  gen_factor, factor_type, bounds_from_ind, max_calibration_time, num_runs, add_initial, 
  refine_best, verbose, verbose_options, random_seeds, seed_index, ranges, mat_file,
  results_display, results_filename, save_results, sigma_share = estim_opts

  # option settings
  info = true; # initiate info setting
  fileLossfunc = "lossfunction_" * lossfunction;
  
  # prepare variable
  #   st: structure with dependent data values only
  st = deepcopy(data);
  nm, nst = fieldnmnst_st(st); # nst: number of data sets

  fieldsInCells = []
  auxVar = []
  for i = 1:nst   # makes st only with dependent variables
    fieldsInCells = split(nm[i], ".")
    #auxVar = getfield(st, fieldsInCells{1}{:});   # data in field nm{i}
    fieldsInCells1 = join(fieldsInCells[1:end-1], ".")
    auxVar = eval(Meta.parse("getfield(st.$fieldsInCells1, Symbol(fieldsInCells[end]))"))   # data in field nm[i]
    if isa(auxVar, Vector) && length(auxVar) >=2
    #[~, k, npage] = size(auxVar);
    #if k>=2 && npage==1# columns 2,3,.. are treated as data to be predicted if npage==1
      #st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2:end));
      eval(Meta.parse("setfield!(st.$fieldsInCells1, Symbol(fieldsInCells[end]), auxVar[2,:])"))
    end
  end

  # Y: vector with all dependent data, NaNs omitted
  # W: vector with all weights, but those that correspond NaNs in data omitted
  YmeanY = struct2vector(st, nm, st);
  Y = YmeanY[1] 
  meanY = YmeanY[2]
  W = struct2vector(weights, nm, st)[1]; 
  
  parnm = fieldnames(typeof(par.free));
  np = Int(length(parnm));
  #n_par = sum(cell2mat(struct2cell(par.free)));
  n_par = 0
  for field in parnm
   n_par += Int(getproperty(par.free, field))
  end

  if n_par == 0
    return; # no parameters to iterate
  end
  index = 1:np
  index = index[vec([getfield(par.free, field) for field in fieldnames(typeof(par.free))]) .== 1]

  free = deepcopy(par.free); # free is here removed, and after iteration added again
  #q = rmfield(par, "free"); # copy input parameter matrix into output TO DO
  q = deepcopy(par)
  #qvec = cell2mat(struct2cell(q));
  qvec = []
  #i = 0
  for field in fieldnames(typeof(par))
    #i = i + 1
    #field = fieldnames(typeof(par))[i]
    if field != :free
    aux = getproperty(par, field)
    append!(qvec, aux...)
    end
  end
  # set options if necessary
  
  if !@isdefined(max_step_number) || isempty(max_step_number)
    nmregr_options("max_step_number", 200 * n_par);
  end
  if !@isdefined(max_fun_evals) || isempty(max_fun_evals)
    nmregr_options("max_fun_evals", 200 * n_par);
  end
  if !@isdefined(tol_simplex) || isempty(tol_simplex)
    nmregr_options("tol_simplex", 1e-4);
  end
  if !@isdefined(tol_fun) || isempty(tol_fun)
    nmregr_options("tol_fun", 1e-4);
  end
  if !@isdefined(simplex_size) || isempty(simplex_size)
    nmregr_options("simplex_size", 0.05);
  end
  if !@isdefined(report) || isempty(report)
    nmregr_options("report", 1);
  end

  # Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = Int.(ones(1, n_par));
  two2np1 = 2:n_par + 1;
  one2n = 1:n_par;
  np1 = n_par + 1;

  call_func = Meta.parse("$func(q, data, auxData, pets)")
  call_fileLossfunc = Meta.parse("$fileLossfunc(Y, meanY, P, meanP, W)")
  call_filternm = Meta.parse("$filternm(q)")
  # Set up a simplex near the initial guess.
  xin = qvec[index];    # Place input guess in the simplex
  #v[:,1] = xin;
  unit_xin = map(unit, xin)
  v = zeros(Float64, length(xin), Int(n_par)+1).*unit_xin
  v[:,1] = xin;
  #f = eval(call_func)[1];
  f = predict_pets(pets, q, data, auxData)[1]
  PmeanP = struct2vector(f, nm, st);
  P = PmeanP[1]
  meanP = PmeanP[2]

  fv = zeros(Float64, 1, Int(n_par)+1)
  fv[:,1] .= eval(call_fileLossfunc);
  #fv(:,1) = feval(fileLossfunc, Y, meanY, P, meanP, W);

  # Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = simplex_size;         # 5 percent deltas is the default for non-zero terms
  zero_term_delta = simplex_size/ 20; # Even smaller delta for zero elements of q
  for j = 1:Int(n_par)
    y = deepcopy(xin);
    f_test = false;
    step_reducer = 1; # step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
    y_test = deepcopy(y);
    while !f_test
      if y[j] != 0
        y_test[j] = (1 + usual_delta / step_reducer) * y[j];
      else 
        y_test[j] = zero_term_delta / step_reducer;
      end
      qvec[index] = y_test; 
      #q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
      q = NamedTuple{parnm}(Tuple(qvec))
      #f_test = feval(filternm, q);
      f_test, flag = eval(call_filternm)

      if !f_test 
        println("The parameter set for the simplex construction is not realistic. \n");
        step_reducer = 2 * step_reducer;
      else
        #[f, f_test] = feval(func, q, data, auxData);
        f, f_test = predict_pets(pets, q, data, auxData)#eval(call_func);

        if !f_test 
          println("The parameter set for the simplex construction is not realistic. \n");
          step_reducer = 2 * step_reducer;
        end
      end
    end  
    v[:,j+1] = y_test;
    P, meanP = struct2vector(f, nm, st);
    #fv(:,j+1) = feval(fileLossfunc, Y, meanY, P, meanP, W);
    fv[:,j+1] .= eval(call_fileLossfunc);
  end     

  # sort so v(1,:) has the lowest function value 
  #[fv,j] = sort(fv);
  j, fv = sortperm(fv[1,:]), sort(fv[1,:])'
  #v = v(:,j);
  v = v[:, j]
  how = "initial";
  itercount = 1;
  func_evals = n_par + 1;
  if report == 1
    println("step " * string(itercount) *  " ssq ", string(minimum(fv)) *  "-", string(maximum(fv)) *  " " *  how *  "\n");
  end
  info = true;

  # Main algorithm
  # Iterate until the diameter of the simplex is less than tol_simplex
  #   AND the function values differ from the min by less than tol_fun,
  #   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals && itercount < max_step_number
    #if maximum(Unitful.ustrip(abs.(v[:, two2np1] .- v[:, onesn]))) <= tol_simplex && maximum(Unitful.ustrip(abs.(fv[1].-fv[two2np1]))) <= tol_fun
    if maximum(Unitful.ustrip(abs.(view(v, :, two2np1) .- view(v, :, onesn)))) <= tol_simplex && maximum(Unitful.ustrip(abs.(fv[1].-fv[two2np1]))) <= tol_fun
        break
    end
    how = "";
   
    # Compute the reflection point
   
    # xbar = average of the n (NOT n+1) best points
    #xbar = sum(v(:,one2n), 2)/ n_par;
    xbar = (sum(Unitful.ustrip(v[:, one2n]), dims=2) / n_par).*unit_xin
    xr = (1 + rho) * xbar - rho * v[:,np1];
    qvec[index] = xr; 
    #q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
    q = NamedTuple{parnm}(Tuple(qvec))
    #f_test = feval(filternm, q);
    f_test, flag = eval(call_filternm)
    if !f_test
      fxr = fv[:,np1] + 1;
    else
      #f, f_test = feval(func, q, data, auxData);
      f, f_test = predict_pets(pets, q, data, auxData)#eval(call_func);
      if !f_test 
        fxr = fv[:,np1] + 1;
      else
        #[P, meanP] = struct2vector(f, nm, st);
        P, meanP = struct2vector(f, nm, st);
        #fxr = feval(fileLossfunc, Y, meanY, P, meanP, W);
        fxr = eval(call_fileLossfunc);
      end
    end
    func_evals = func_evals + 1;
   
    if fxr < fv[1,1]#[1]
      # Calculate the expansion point
      xe = (1 + rho * chi) .* xbar - rho * chi .* v[:, np1];
      qvec[index] = xe; 
      q = NamedTuple{parnm}(Tuple(qvec))
      #q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
      f_test, flag = eval(call_filternm)
      #f_test = feval(filternm, q);
      if !f_test
         fxe = fxr + 1;
      else
        #[f, f_test] = feval(func, q, data, auxData);
        f, f_test = predict_pets(pets, q, data, auxData)#eval(call_func);
        if !f_test 
          fxe = fv[:,np1] + 1;
        else
          #[P, meanP] = struct2vector(f, nm, st);
          #fxe = feval(fileLossfunc, Y, meanY, P, meanP, W);
          P, meanP = struct2vector(f, nm, st);
          fxe = eval(call_fileLossfunc);
        end
      end
      func_evals = func_evals + 1;
      if fxe < fxr
         v[:,np1] = xe;
         fv[:,np1][1] = fxe;
         how = "expand";
      else
         v[:,np1] = xr; 
         fv[1,np1] = fxr;
         how = "reflect";
      end
    else # fv(:,1) <= fxr
      if fxr < fv[1,n_par]
         v[:,np1] = xr; 
         fv[1,np1] = fxr;
         how = "reflect";
      else # fxr >= fv(:,n_par) 
         # Perform contraction
         if fxr < fv[1,np1]
            # Perform an outside contraction
            xc = [1 + psi * rho] .* xbar - psi * rho .* v[:,np1];
            #qvec(index) = xc; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
            qvec[index] = xc; 
            q = NamedTuple{parnm}(Tuple(qvec))
            #f_test = feval(filternm, q);
            f_test, flag = eval(call_filternm)
            if !f_test
              fxc = fxr + 1;
            else            
              #[f, f_test] = feval(func, q, data, auxData);
              f, f_test = predict_pets(pets, q, data, auxData)#eval(call_func);
              if !f_test 
                fxc = fv[:,np1] + 1;
              else
                #[P, meanP] = struct2vector(f, nm, st);
                #fxc = feval(fileLossfunc, Y, meanY, P, meanP, W);
                P, meanP = struct2vector(f, nm, st);
                fxc = eval(call_fileLossfunc);
              end
            end
            func_evals = func_evals + 1;
            
            if fxc <= fxr
               v[:,np1] = xc; 
               #fv[:,np1][1] = fxc;
               fv[1,np1] = fxc;
               how = "contract outside";
            else
               # perform a shrink
               how = "shrink"; 
            end
         else
            # Perform an inside contraction
            xcc = (1 - psi) .* xbar + psi .* v[:,np1];
            #qvec(index) = xcc; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
            qvec[index] = xcc; 
            q = NamedTuple{parnm}(Tuple(qvec))
            #f_test = feval(filternm, q);
            f_test, flag = eval(call_filternm)
            if !f_test
              fxcc = fv[:,np1] + 1;
            else
              #[f, f_test] = feval(func, q, data, auxData);
              f, f_test = predict_pets(pets, q, data, auxData)#eval(call_func);
              if !f_test 
                fxcc = fv[:,np1] + 1;
              else
                #[P, meanP] = struct2vector(f, nm, st);
                #fxcc = feval(fileLossfunc, Y, meanY, P, meanP, W);
                P, meanP = struct2vector(f, nm, st);
                fxcc = eval(call_fileLossfunc);
              end
            end
            func_evals = func_evals + 1;
            
            if fxcc < fv[1,np1]
               v[:,np1] = xcc;
               fv[1,np1] = fxcc;
               how = "contract inside";
            else
               # perform a shrink
               how = "shrink";
            end
         end
         if how == "shrink"
            for j = two2np1
               f_test = false;
               step_reducer = 1;             # step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
               while !f_test
                  v_test = v[:,1] + sigma / step_reducer * (v[:,j] - v[:,1]);
                  #qvec(index) = v_test; q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
                  #f_test = feval(filternm, q);
                  qvec[index] = v_test; 
                  q = NamedTuple{parnm}(Tuple(qvec))
                  f_test, flag = eval(call_filternm)
                  if !f_test 
                     println("The parameter set for the simplex shrinking is not realistic. \n");
                     step_reducer = 2 * step_reducer;
                  else
                    #[f, f_test] = feval(func, q, data, auxData);
                    f, f_test = predict_pets(pets, q, data, auxData)#eval(call_func);
                    if !f_test 
                      println("The parameter set for the simplex shrinking is not realistic. \n");
                      step_reducer = 2 * step_reducer;
                    end
                  end
               end
               v[:,j] = v_test;
               #[P, meanP] = struct2vector(f, nm, st);
               #fv(:,j) = feval(fileLossfunc, Y, meanY, P, meanP, W);
               P, meanP = struct2vector(f, nm, st);
               #fv(:,j+1) = feval(fileLossfunc, Y, meanY, P, meanP, W);
               fv[:,j] .= eval(call_fileLossfunc);
            end
            func_evals = func_evals + n_par;
         end
      end
    end
    #[fv,j] = sort(fv);
    j, fv = sortperm(fv[1,:]), sort(fv[1,:])'
    v = v[:,j];
    itercount = itercount + 1;

    if report == 1 && mod(itercount, 10) == 0
      println("step " * string(itercount) *  " ssq ", string(minimum(fv)) *  "-", string(maximum(fv)) *  " " *  how *  "\n");
    end  
  end   # while


  #qvec(index) = v(:,1); q = cell2struct(mat2cell(qvec, ones(np, 1), [1]), parnm);
  qvec[index] = v[:,1]; 
  q = NamedTuple{parnm}(Tuple(qvec))
  #q.free = free; # add substructure free to q,
  q = merge(q, (free = free,))

  fval = minimum(fv); 
  if func_evals >= max_fun_evals
    if report > 0
      println("No convergences with " *	string(max_fun_evals) * " function evaluations\n");
    end
    info = false;
  elseif itercount >= max_step_number 
    if report > 0
      println("No convergences with " * string(max_step_number) * " steps\n");
    end
    info = false; 
  else
    if report > 0
     println("Successful convergence \n");              
    end
    info = true;
  end
  (q, info, itercount, fval)
end
   
function struct2vector(structin, fieldNames, structRef)
  # structRef has the same structure as struct, but some values can be NaN's; the values themselves are not used
  # struct2vector is called for data (which might have NaN's), but also for predictions, which do not have NaN's
  vec = Any[]
  meanVec = Any[]
  for i = 1:size(fieldNames, 1)
    fieldsInCells = split(fieldNames[i], '.')
    fieldsInCells1 = join(fieldsInCells[1:end-1], ".")
    global structin2 = deepcopy(structin)
    global fieldsInCells2 = deepcopy(fieldsInCells)
    global structRef2 = deepcopy(structRef)
    aux = eval(Meta.parse("getfield(structin2.$fieldsInCells1, Symbol(fieldsInCells2[end]))"))   # data in field nm[i]
    auxRef = eval(Meta.parse("getfield(structRef2.$fieldsInCells1, Symbol(fieldsInCells2[end]))"))   # data in field nm[i]
    #aux = aux[.!isnan.(auxRef)] # remove values that have NaN's in structRef - TO DO
    if !isa(aux, AbstractArray)
      aux = [aux]  # convert scalar to a 1-element array
    end
    append!(vec, aux...)
    #append!(meanVec, fill(mean(aux), length(aux))...)
    append!(meanVec, repeat(mean.(aux), length(aux[1]))...)
  end
  return (vec, meanVec)
end