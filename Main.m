% Main 

clear, clc, clf


month = 24*30;
time = 12*month*4;
betas = linspace(1*month,24*month,N2);
starttime = tic;
[S, I, A, R, D, V, E, C, Cm, vacced, doses] = simulateSIR(...
    show_scatter = false, ...
    time_delay = 0.1, ...
    end_time = time, ...
    gamma = 0.006,... % set
    rho_a = 0.25,... % set
    mu = 0.00006, ... % set
    inc_factor = 1/(5*24), ... % set
    d = 0.8, ... % set
    beta = 0.1,...
    sigma = 0.0001, ...
    vacc_interval = 100, ...
    alpha_vacc = -expm1(log(0.7)/(140*24)), ... % set (30 % loss after 20 weeks)
    alpha_nat = -expm1(log(0.7)/(140*24)), ... % set (30 % loss after 20 weeks)
    beta = betas(i),...
    sigma = 1/inverseSigma(j), ...
    print_benchmarks = false ...
    );
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

