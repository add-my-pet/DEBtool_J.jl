clear; 
close all; 
global pets
    
pets = {'Bos_taurus_Angus'};
check_my_pet(pets);


%% Set estimation parameters
estim_options('default');
estim_options('max_step_number',500);
estim_options('max_fun_evals',5e4);
global simplex_size 
simplex_size = 0.05;
estim_options('simplex_size', simplex_size);
estim_options('filter',0);
tol_simplex = 1e-4;  
estim_options('tol_simplex',tol_simplex);

%% Estimate but only save .mat file
estim_options('pars_init_method', 2);
estim_options('results_output', 0);
estim_options('method', 'nm');
[nsteps, info, fval] = estim_pars;

n_runs = 50;
estim_options('pars_init_method', 1);
estim_options('results_output', 0);
prev_fval = 1e10;
i = 2;
% full simplex without significant improvement
while (abs(prev_fval-fval) > tol_simplex*10) && (i < n_runs)
    simplex_size = -simplex_size;
    prev_fval = fval;
    fprintf('Run %d\n', i)
    [nsteps, info, fval] = estim_pars;
    i = i + 1;
end

%% Save variables, estimation figures, and HTML
estim_options('pars_init_method', 1)
estim_options('results_output', 3);
estim_options('method', 'no');

estim_pars;

%% Load data and compute predictions
load(['results_' pets{1} '.mat']);

[data, auxData, metaData, txtData, weights] = feval(['mydata_' pets{1}]);
q = rmfield(par, 'free');
[prdData, info] = feval(['predict_' pets{1}], q, data, auxData);
if ~info
    fprintf('BUG!!! BIG BUG!!!')
end


%% Save data and predictions
save(['results_' pets{1} '.mat'], 'metaData', 'metaPar', 'par', 'txtPar', 'data', 'prdData')

%% Print parameters
fprintf(' n_NE: %.4f \n n_NV: %.4f \n', par.n_NE, par.n_NV)
