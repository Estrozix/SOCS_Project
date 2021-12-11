% Main 

clear, clc, clf


time = 3000;
starttime = tic;
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
    vacc_interval = 100);
fprintf('Total time: %.3f seconds\n', toc(starttime));


figure(69420);
plot(1:time,S)
hold on
plot(1:time,I)
plot(1:time,A)
plot(1:time,R)
plot(1:time,D)
plot(1:time,V)
plot(1:time,vacced,'--');
plot(1:time,doses,'--');
%plot(1:time,E)
legend("Susceptible", "Infected", "Asymptomatic", "Recovered", "Dead",'Vaccine-immune','Vaccinated at least once', 'Total \# of doses');

