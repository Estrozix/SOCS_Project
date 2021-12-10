% Main 

clear, clc, clf
% TODO:

% vaccinated status [X]
% move probability depends on illness []
% alpha increases with time []
% dynamic/dependent parameters (mu,gamma) etc []
% add Exposed status [X]
% vaccine dosage []
% add age property []
% vacination rate, vaccination program, vaccination positivity [] 
% vaccine decay  rate []
% vaccination percentage label []
% animation [X]

time = 1000;
starttime = tic;
[S, I, A, R, D, V, E, vacced, doses] = simulateSIR(...
    beta = 0.6,...
    gamma = 0.01,...
    d = 0.8, ...
    mu = 0.0005, ...
    alpha_nat = 0.01, ...
    alpha_vacc = 0.01, ...
    sigma = 0.001, ...
    rho_a = 0.5,...
    end_time = time, ...
    vacc_interval = 100, ...
    inc_factor = 0.1, ...
    show_scatter = false, ...
    time_delay = 0.1);
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
