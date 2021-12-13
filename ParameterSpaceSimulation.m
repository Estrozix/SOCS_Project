% Parameter space
clear,clc

averages = 3;
month = 24*30;
time = 12*month*3;

% parameters to vary
N = 2;
betas = linspace(0.01,1,N);
sigmas = linspace(0.0001,0.001,N);
vaccineIntervals = linspace(1*month,24*month,N);

% Initialize output
dataVariables = 4;
parameterSpace = zeros(N,N,N,dataVariables);

iSteps = length(betas);
jSteps = length(sigmas);
kSteps = length(vaccineIntervals);

tic
parfor i = 1:iSteps
    for j = 1:jSteps
        for k = 1:kSteps
            
            tempData = zeros(averages,dataVariables);
            for runs = 1:averages

            [S, I, A, R, D, V, E, C, Cm, vacced, doses] = simulateSIR(...
                show_scatter = false, ... % optional
                time_delay = 0.1, ... % optional
                end_time = time, ... % variable
                gamma = 0.006,... % set
                rho_a = 0.25,... % set
                mu = 0.00006, ... % set
                inc_factor = 0.08, ... % set
                d = 0.8, ... % set
                alpha_vacc = -expm1(log(0.7)/(140*24)), ... % set (30 % loss after 20 weeks)
                alpha_nat = -expm1(log(0.7)/(140*24)), ... % set (30 % loss after 20 weeks)
                beta = betas(i),...
                sigma = sigmas(j), ...
                vacc_interval = vaccineIntervals(k) ...
                );

            tempData(runs,:) = [D(end),C(end),vacced(end),doses(end)];
            end
            
            parameterSpace(i,j,k,:) = mean(tempData);

        end
    end
end
toc



