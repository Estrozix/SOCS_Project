% first analysis

clear, clc, clf

% Set parameters, vaccine interval every 5 months

time = 365 * 24;
starttime = tic;
[S, I, A, R, D, V, E, C, vacced, doses] = simulateSIR(...
    beta = 0.4,...
    gamma = 0.006,... % set
    d = 0.8, ...
    mu = 0.00006, ... % set
    alpha_nat = 0.0002, ... % set
    alpha_vacc = 0.0002, ... % set
    sigma = 0.0001, ... % set
    rho_a = 0.25,... % set
    end_time = time, ...
    vacc_interval = 3600, ...
    inc_factor = 0.08, ... % set
    show_scatter = false, ...
    time_delay = 0.1);
fprintf('Total time: %.3f seconds\n', toc(starttime));

timeD = 1:time;
dayTime = timeD / 24;

figure(69420);
plot(dayTime,D)
hold on
plot(dayTime,C)
plot(dayTime,vacced)
%plot(1:time,E)
legend("Deaths", "Cases", "Vaccinated");
axis([0, 365, 0, 1000])
