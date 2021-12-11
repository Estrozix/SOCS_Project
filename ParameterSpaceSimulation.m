% Parameter space

averages = 3;

% parameters to vary
vaccineIntervals = [100,200,300];


for i = 1:length(vaccineIntervals)

    [S, I, A, R, D, V, E, C, vacced, doses] = simulateSIR(...
        show_scatter = false, ...
        time_delay = 0.1, ...
        end_time = time, ...
        gamma = 0.006,... % set
        rho_a = 0.25,... % set
        mu = 0.00006, ... % set
        inc_factor = 0.08, ... % set
        d = 0.8, ... % set
        beta = 0.2,...
        alpha_nat = 0.01, ...
        alpha_vacc = 0.01, ...
        sigma = 0.0001, ...
        vacc_interval = vaccineIntervals(i) ...
        );

end
