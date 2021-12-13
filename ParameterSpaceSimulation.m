% Parameter space
clear,clc

averages = 10;
time = 365 * 24 * 5;

% parameters to vary
vaccineIntervals = (24*30) .* [1:24];

tic
D_loop = zeros(averages,length(vaccineIntervals));
Cm_loop = zeros(averages,length(vaccineIntervals));
parfor i = 1:length(vaccineIntervals)
    for run = 1:averages
        [S, I, A, R, D, V, E, C, Cm, vacced, doses, true_end] = simulateSIR(...
            show_scatter = false, ...
            time_delay = 0.1, ...
            end_time = time, ...
            gamma = 0.006,... % set
            rho_a = 0.25,... % set
            mu = 0.00006, ... % set
            inc_factor = 0.008, ... % set
            d = 0.8, ... % set
            beta = 0.03,...
            alpha_nat = 1/(24*30*5), ...
            alpha_vacc = 1/(24*30*5), ...
            sigma = 1/(24*30*6), ...
            vacc_interval = vaccineIntervals(i) ...
            );
        D_loop(run,i) = D(end);
        Cm_loop(run,i) = Cm(end);
    end
end
toc

Cm_mean = mean(Cm_loop);
D_mean = mean(D_loop);

plot(vaccineIntervals,D_mean)
hold on
plot(vaccineIntervals,Cm_mean)

