% first analysis

clear, clc, clf

% Set parameters, vaccine interval every 5 months
time = 365 * 24 * 5;
starttime = tic;
[S, I, A, R, D, V, E, C, Cm, vacced, doses, true_end] = simulateSIR(...
    beta = 0.03,...
    gamma = 0.006,... % set
    d = 0.8, ...
    mu = 0.00006, ... % set
    alpha_nat = 1/(24*30*5), ... % set
    alpha_vacc = 1/(24*30*5), ... % set
    sigma = 1/(24*30*6), ... % set
    rho_a = 0.25,... % set
    end_time = time, ...
    vacc_interval = (24*30*1), ...
    inc_factor = 0.008, ... % set
    show_scatter = false, ...
    time_delay = 0.1);
fprintf('Total time: %.3f seconds\n', toc(starttime));

