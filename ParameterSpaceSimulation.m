% Parameter space
clear,clc

averages = 10;
time = 3000;

% parameters to vary
vaccineIntervals = [100:50:400];

tic
D_loop = zeros(averages,length(vaccineIntervals));
parfor i = 1:length(vaccineIntervals)
    for run = 1:averages
        [S, I, A, R, D, V, E, C, vacced, doses] = simulateSIR(...
            show_scatter = false, ...
            time_delay = 0.1, ...
            end_time = time, ...
            gamma = 0.006,... % set
            rho_a = 0.25,... % set
            mu = 0.00006, ... % set
            inc_factor = 0.08, ... % set
            d = 0.8, ... % set
            beta = 0.4,...
            alpha_nat = 0.01, ...
            alpha_vacc = 0.01, ...
            sigma = 0.0001, ...
            vacc_interval = vaccineIntervals(i) ...
            );
        D_loop(run,i) = D(end);
    end
end
toc


D_mean = mean(D_loop);

plot(vaccineIntervals,D_mean)

