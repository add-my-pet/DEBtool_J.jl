# created 2000/08/16 by Bas Kooijman; modified 2011/04/10, 2017/07/24

## Syntax
# f = <../beta0.m *beta0*> (x0,x1)

## Description
#  particular incomplete beta function:
#   B_x1(4/3,0) - B_x0(4/3,0) = \int_x0^x1 t^(4/3-1) (1-t)^(-1) dt
#
# Input
#
# * x0: scalar with lower boundary for integration
# * x1: scalar with upper boundary for integration
#
# Output
#
# * f: scalar with particular incomplete beta function

## Remarks
# See also <../lib/misc/beta_34_0 *beta_34_0*>

## Example of use
# beta0(0.1, 0.2)
function _beta0!(buffer::AbstractArray, x0::AbstractArray, x1::Number)
    buffer .= _beta0.(x0, x1)
end
function _beta0(x0::Number, x1::Number)
    # if x0 < 0 | x0 >= 1 | x1 < 0 | x1 >= 1
    #   println("Warning from beta0: argument values (" * string(x0) * "," * string(x1) * ") outside (0,1) \n");
    #   f = [;];
    #   dbstack
    #   return;
    # elseif x0 > x1
    #   println("Warning from beta0: lower boundary " * string(x0) * " larger than upper boundary " * string(x1) * " \n");
    #   f = [;];
    #   dbstack
    #   return;
    # end

    n0 = length(x0)
    n1 = length(x1)
    if n0 != n1 && n0 != 1 && n1 != 1
        _warn_value_range(x0, x1)
        f = NaN
        return f
    end

    x03 = x0^(1 / 3)
    x13 = x1^(1 / 3)
    a3 = sqrt(3)
    f1 = -3 * x13 + a3 * atan((oneunit(x13) + 2 * x13) / a3) - log(Complex(x13 - oneunit(x13))) + log(oneunit(x13) + x13 + x13^2) / 2
    f0 = -3 * x03 + a3 * atan((oneunit(x03) + 2 * x03) / a3) - log(Complex(x03 - oneunit(x03))) + log(Complex(oneunit(x03) + x03 + x03^2)) / 2
    f = f1 - f0

    return f
end

@noinline _warn_value_range(x0, x1) = @warn "beta0: argument values (" * num2str(x0) * "," * num2str(x1), ") outside (0,1) \n"



## wass petregr_f
# Finds parameter values for a pet that minimizes the lossfunction using Nelder Mead's simplex method using a filter

function optimize(model, par, data, auxData, weights, filternm, options)

    function call_func(par, data, auxData)
        out=predict(model, par, data, auxData)
        prdData = out[1]
        info = out[2]
        # if ~info
        #     return
        # end
        prdData=predict_pseudodata(par, data, prdData)
        (prdData, info)
    end
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

    #global Y, meanY, W, P, meanP, q, pets
    #global q, pets
    # option settings
    info = true # initiate info setting
    # fileLossfunc = "lossfunction_" * options.lossfunction
    # srcpath = dirname(pathof(DEBtool_J))
    # examplepath = realpath(joinpath(srcpath, "../example"))
    # pet = "Emydura_macquarii";
    # include(joinpath(examplepath, "predict_" * pet * ".jl"))
    #using .Predict
    # prepare variable
    #   st: structure with dependent data values only
    #st = deepcopy(data)
    #nm, nst = fieldnmnst_st(data) # nst: number of data sets
    #nm=(keys(data)[1:(length(data)-1)]..., [Symbol(:psd, s) for s in keys(data.psd)]...) # assumes psd is the last item in data
    #nm=keys(data)[1:(length(data)-1)]

    #modified_nt = merge(new_matrices, select(nt, Not(:matrix1, :matrix2)))
   # modified_nt = merge(NamedTuple(modified_matrices), select(nt, v -> !isa(v, Matrix)))
    
    # assumes psd is the last item in data
    nmsize=ones(length(data)-1)
    for i in 1:length(data)-1
        if(!isempty(size(data[i])))
         nmsize[i]=size(data[i], 2)   
        end
    end
    matrix_indices = findall(==(2), nmsize)
    modmatrices=(;)
    for i in 1:length(matrix_indices)
        matrix_extract = data[matrix_indices[i]]
        matrix_extract = matrix_extract[:,size(matrix_extract, 2)]
        modmatrices=merge(modmatrices, (keys(data)[matrix_indices[i]] => matrix_extract,))
    end
    st=merge(data)
    for i in 1:length(modmatrices)
        st=merge(data, (keys(modmatrices)[i] => modmatrices[i],))  
    end

    nm=([string(k) for k in keys(data)[1:(length(data)-1)]]..., ["psd." * string(s) for s in keys(data.psd)]...) # assumes psd is the last item in data
    #nst=length(nm)


    # Y: vector with all dependent data, NaNs omitted
    # W: vector with all weights, but those that correspond NaNs in data omitted
    YmeanY = struct2vector(st, nm, st)
    Y = YmeanY[1]
    meanY = YmeanY[2]
    W = struct2vector(weights, nm, st)[1]

    parnm = fieldnames(typeof(par.free))
    np = Int(length(parnm))
    #n_par = sum(cell2mat(struct2cell(par.free)));
    n_par = 0
    for field in parnm
        n_par += Int(getproperty(par.free, field))
    end

    if n_par == 0
        return # no parameters to iterate
    end
    index = 1:np
    index = index[vec([
        getfield(par.free, field) for field in fieldnames(typeof(par.free))
    ]).==1]

    free = merge(par.free, ) # free is here removed, and after iteration added again
    #q = rmfield(par, "free"); # copy input parameter matrix into output TO DO
    q = merge(par, )
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

    # if !@isdefined(options.max_step_number) || isempty(options.max_step_number)
    #     nmregr_options("max_step_number", 200 * n_par)
    # end
    # if !@isdefined(options.max_fun_evals) || isempty(options.max_fun_evals)
    #     nmregr_options("max_fun_evals", 200 * n_par)
    # end
    # if !@isdefined(options.tol_simplex) || isempty(options.tol_simplex)
    #     nmregr_options("tol_simplex", 1e-4)
    # end
    # if !@isdefined(options.tol_fun) || isempty(options.tol_fun)
    #     nmregr_options("tol_fun", 1e-4)
    # end
    # if !@isdefined(options.simplex_size) || isempty(options.simplex_size)
    #     nmregr_options("simplex_size", 0.05)
    # end
    # if !@isdefined(options.report) || isempty(options.report)
    #     nmregr_options("report", 1)
    # end
end

function neldermead!(call_func, lossfunction, parvec, options)
    n_par = length(parvec)
    # Initialize parameters
    rho = 1
    chi = 2
    psi = 0.5
    sigma = 0.5
    onesn = Int.(ones(1, n_par))
    two2np1 = 2:n_par+1
    one2n = 1:n_par
    np1 = n_par + 1

    #call_func = Meta.parse("$func(q, data, auxData, pets)")
    #call_fileLossfunc = Meta.parse("$fileLossfunc(Y, meanY, P, meanP, W)")
    #call_filternm = Meta.parse("$filternm(q)")
    # Set up a simplex near the initial guess.
    xin = copy(parvec)    # Place input guess in the simplex
    y = copy(parvec)#merge(xin, )
    #v[:,1] = xin;
    # unit_xin = map(unit, xin)
    v = zeros(Float64, length(xin), n_par + 1)# .* unit_xin
    v[:, 1] = xin
    v_test = zeros(size(v, 1))
    #prdData = (;$petnm = outPseudoData)
    f, _ = call_func(parvec)#eval(call_func)[1]
    #P = [value(x) for x in values(PmeanP[1])]
    #meanP = [value(x) for x in values(PmeanP[2])]
    fv = zeros(Float64, 1, n_par + 1)
    fv[:, 1] .= lossfunction(f) #eval(call_fileLossfunc)
    #fv(:,1) = feval(fileLossfunc, Y, meanY, P, meanP, W);

    # Following improvement suggested by L.Pfeffer at Stanford
    usual_delta = options.simplex_size         # 5 percent deltas is the default for non-zero terms
    zero_term_delta = options.simplex_size / 20 # Even smaller delta for zero elements of q
    for j = 1:n_par
        y .= xin
        f_test = false
        step_reducer = 1 # step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
        y_test = deepcopy(y)#merge(y, )
        while !f_test
            if y[j] != 0
                y_test[j] = (1 + usual_delta / step_reducer) * y[j]
            else
                y_test[j] = zero_term_delta / step_reducer
            end
            parvec .= y_test
            #q = cell2struct(mat2cell(pars, ones(np, 1), [1]), parnm);
            #f_test = feval(filternm, q);
            f_test = true # f_test, flag = filter_std(q) #eval(call_filternm)

            if !f_test
                # println(
                #     "The parameter set for the simplex construction is not realistic. \n",
                # )
                step_reducer = 2 * step_reducer
            else
                #[f, f_test] = feval(func, q, data, auxData);
                f, f_test = call_func(parvec)#eval(call_func)

                if !f_test
                    # println(
                    #     "The parameter set for the simplex construction is not realistic. \n",
                    # )
                    step_reducer = 2 * step_reducer
                end
            end
        end
        v[:, j+1] = y_test
        #fv(:,j+1) = feval(fileLossfunc, Y, meanY, P, meanP, W);
        fv[:, j+1] .= lossfunction(f) #eval(call_fileLossfunc)
    end

    # sort so v(1,:) has the lowest function value 
    #[fv,j] = sort(fv);
    j, fv = sortperm(fv[1, :]), sort(fv[1, :])'
    #v = v(:,j);
    v = v[:, j]
    how = "initial"
    itercount = 1
    func_evals = n_par + 1
    if options.report
        # println(
        #     "step " * string(itercount) * " ssq ",
        #     string(minimum(fv)) * "-",
        #     string(maximum(fv)) * " " * how * "\n"
        # )
    end
    info = true

    # Main algorithm
    # Iterate until the diameter of the simplex is less than options.tol_simplex
    #   AND the function values differ from the min by less than options.tol_fun,
    #   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
    while func_evals < options.max_fun_evals && itercount < options.max_step_number
        #if maximum(Unitful.ustrip(abs.(v[:, two2np1] .- v[:, onesn]))) <= options.tol_simplex && maximum(Unitful.ustrip(abs.(fv[1].-fv[two2np1]))) <= options.tol_fun
        if maximum(Unitful.ustrip(abs.(view(v, :, two2np1) .- view(v, :, onesn)))) <=
           options.tol_simplex && maximum(Unitful.ustrip(abs.(fv[1] .- fv[two2np1]))) <= options.tol_fun
            break
        end
        how = ""

        # Compute the reflection point

        # xbar = average of the n (NOT n+1) best points
        #xbar = sum(v(:,one2n), 2)/ n_par;
        xbar = (sum(Unitful.ustrip(v[:, one2n]), dims = 2) / n_par)# .* unit_xin
        xr = (1 + rho) * xbar - rho * v[:, np1]
        parvec .= xr
        #q = cell2struct(mat2cell(pars, ones(np, 1), [1]), parnm);
        #f_test = feval(filternm, q);
        f_test = true # f_test, flag = filter_std(q) #eval(call_filternm)
        if !f_test
            fxr = fv[:, np1] + 1
        else
            #f, f_test = feval(func, q, data, auxData);
            f, f_test = call_func(parvec)#eval(call_func)[1]
            if !f_test
                fxr = fv[:, np1] + 1
            else
                #[P, meanP] = struct2vector(f, st);
                #fxr = feval(fileLossfunc, Y, meanY, P, meanP, W);
                fxr = lossfunction(f)
            end
        end
        func_evals = func_evals + 1

        if fxr < fv[1, 1]#[1]
            # Calculate the expansion point
            xe = (1 + rho * chi) .* xbar - rho * chi .* v[:, np1]
            parvec .= xe
            f_test = true # f_test, flag = filter_std(q) #eval(call_filternm)
            #f_test = feval(filternm, q);
            if !f_test
                fxe = fxr + 1
            else
                #[f, f_test] = feval(func, q, data, auxData);
                f, f_test = call_func(parvec)#eval(call_func)[1]
                if !f_test
                    fxe = fv[:, np1] + 1
                else
                    #[P, meanP] = struct2vector(f, st);
                    #fxe = feval(fileLossfunc, Y, meanY, P, meanP, W);
                    fxe = lossfunction(f) #eval(call_fileLossfunc)
                end
            end
            func_evals = func_evals + 1
            if fxe < fxr
                v[:, np1] = xe
                fv[1, np1] = fxe
                how = "expand"
            else
                v[:, np1] = xr
                fv[1, np1] = fxr
                how = "reflect"
            end
        else # fv(:,1) <= fxr
            if fxr < fv[1, n_par]
                v[:, np1] = xr
                fv[1, np1] = fxr
                how = "reflect"
            else # fxr >= fv(:,n_par) 
                # Perform contraction
                if fxr < fv[1, np1]
                    # Perform an outside contraction
                    xc = [1 + psi * rho] .* xbar - psi * rho .* v[:, np1]
                    parvec .= xc
                    #f_test = feval(filternm, q);
                    f_test = true # f_test, flag = filter_std(q) #eval(call_filternm)
                    if !f_test
                        fxc = fxr + 1
                    else
                        #[f, f_test] = feval(func, q, data, auxData);
                        f, f_test = call_func(parvec)#eval(call_func)[1]
                        if !f_test
                            fxc = fv[1, np1] + 1
                        else
                            #[P, meanP] = struct2vector(f, st);
                            #fxc = feval(fileLossfunc, Y, meanY, P, meanP, W);
                            fxc = lossfunction(f) #eval(call_fileLossfunc)
                        end
                    end
                    func_evals = func_evals + 1

                    if fxc <= fxr
                        v[:, np1] = xc
                        #fv[:,np1][1] = fxc;
                        fv[1, np1] = fxc
                        how = "contract outside"
                    else
                        # perform a shrink
                        how = "shrink"
                    end
                else
                    # Perform an inside contraction
                    xcc = (1 - psi) .* xbar + psi .* v[:, np1]
                    #pars(index) = xcc; q = cell2struct(mat2cell(pars, ones(np, 1), [1]), parnm);
                    parvec .= xcc
                    #f_test = feval(filternm, q);
                    f_test = true # f_test, flag = filter_std(q) #eval(call_filternm)
                    if !f_test
                        fxcc = fv[:, np1] + 1
                    else
                        #[f, f_test] = feval(func, q, data, auxData);
                        f, f_test = call_func(parvec)#eval(call_func)[1]
                        if !f_test
                            fxcc = fv[1, np1] + 1
                        else
                            #[P, meanP] = struct2vector(f, st);
                            #fxcc = feval(fileLossfunc, Y, meanY, P, meanP, W);
                            fxcc = lossfunction(f) #eval(call_fileLossfunc)
                        end
                    end
                    func_evals = func_evals + 1

                    if fxcc < fv[1, np1]
                        v[:, np1] = xcc
                        fv[1, np1] = fxcc
                        how = "contract inside"
                    else
                        # perform a shrink
                        how = "shrink"
                    end
                end
                if how == "shrink"
                    for j in two2np1
                        f_test = false
                        step_reducer = 1             # step_reducer will serve to reduce usual_delta if the parameter set does not pass the filter
                        while !f_test
                            v_test = v[:, 1] + sigma / step_reducer * (v[:, j] - v[:, 1])
                            #f_test = feval(filternm, q);
                            parvec .= v_test
                            f_test = true # f_test, flag = filter_std(q) #eval(call_filternm)
                            if !f_test
                                # println(
                                #     "The parameter set for the simplex shrinking is not realistic. \n",
                                # )
                                step_reducer = 2 * step_reducer
                            else
                                #[f, f_test] = feval(func, q, data, auxData);
                                f, f_test = call_func(parvec)#eval(call_func)[1]
                                if !f_test
                                    println(
                                        "The parameter set for the simplex shrinking is not realistic. \n",
                                    )
                                    step_reducer = 2 * step_reducer
                                end
                            end
                        end
                        v[:, j] = v_test
                        fv[:, j] .= lossfunction(f) #eval(call_fileLossfunc)
                    end
                    func_evals = func_evals + n_par
                end
            end
        end
        #[fv,j] = sort(fv);
        j, fv = sortperm(fv[1, :]), sort(fv[1, :])'
        v = v[:, j]
        itercount = itercount + 1
        # if itercount == 70
        #     itercount = 70
        # end
        if options.report && mod(itercount, 10) == 0
            # println(
            #     "step " * string(itercount) * " ssq ",
            #     string(minimum(fv)) * "-",
            #     string(maximum(fv)) * " " * how * "\n",
            # )
        end
    end   # while


    parvec .= v[:, 1]

    fval = minimum(fv)
    if func_evals >= options.max_fun_evals
        if options.report
            # println(
            #     "No convergences with " * string(options.max_fun_evals) * " function evaluations\n",
            # )
        end
        info = false
    elseif itercount >= options.max_step_number
        if options.report
            # println("No convergences with " * string(options.max_step_number) * " steps\n")
        end
        info = false
    else
        if options.report
            # println("Successful convergence \n")
        end
        info = true
    end

    return parvec, info, itercount, fval
end

function struct2vector(structin::NamedTuple, structref)
    @show structin structref
    combined = _combine(structin, structref)
    _mean(combined, structref)
    meanstruct = _mean(combined, structref)
    vec = Flatten.flatten(combined, Real) |> SVector
    meanvec = Flatten.flatten(meanstruct, Real) |> SVector

    return vec, meanvec
end

function _combine(x::NamedTuple, ref::NamedTuple{NM}) where NM
    map(NM) do n
        haskey(x, n) ? _combine(x[n], ref[n]) : ref[n]
    end |> NamedTuple{NM}
end
_combine(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_combine(x, ref) = x

function _mean(x::NamedTuple, ref::NamedTuple{NM}) where NM
    map(NM) do n
        _mean(x[n], ref[n])
    end |> NamedTuple{NM}
end
_mean(x::Number, ref::AbstractArray) = map(_ -> x, ref)
_mean(x::AbstractArray, ref::AbstractArray) = (m = mean(x); map(_ -> m, ref))
_mean(x::Number, ref::Number) = x * 1.0

