% Main 

clear, clc, clf, close all

% TODO:

% vaccinated status
% move probability depends on illness
% alpha increases with time 
% Hospitalized status
% dynamic/dependent parameters (mu,gamma) etc
% add Exposed status
% vaccine dosage
% add age property
% vacination rate, vaccination program, vaccination positivity 
% vaccine decay  rate
% vaccination percentage variable
% animation ? (store position as function of time)


time = 3000;
[S, I, R, D, V] = simulateSIR(...
    beta = 0.8,...
    gamma = 0.01,...
    d = 1, ...
    mu = 0.005, ...
    alpha_nat = 0.01, ...
    alpha_vacc = 0.01, ...
    sigma = 0.001, ...
    end_time = time, ...
    vacc_interval = 100,...
    show_scatter = false);

figure
plot(1:time,S)
hold on
plot(1:time,I)
plot(1:time,R)
plot(1:time,D)
plot(1:time,V)
legend("Susceptible","Infected","Recovered","Dead","Vaccinated")
