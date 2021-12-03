% Main 

clear,clc,clf

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
[S, I, R, D, V] = simulateSIR(0.8,0.01,0.7,0.005,0,0.001,time);

plot(1:time,S)
hold on
plot(1:time,I)
plot(1:time,R)
plot(1:time,D)
plot(1:time,V)
legend("Susceptible","Infected","Recovered","Dead","Vaccinated")
