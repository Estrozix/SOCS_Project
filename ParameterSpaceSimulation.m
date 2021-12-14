% Parameter space
clear,clc

averages = 10;
month = 24*30;
time = 12*month*4;

% parameters to vary
N1 = 1;
N2 = 40;
N3 = 40;
betas = 0.03;
sigmas = linspace(1/(month),1/(24*month),N2);
vaccineIntervals = linspace(1*month,24*month,N3);

% Initialize output
dataVariables = 4;
parameterSpace = zeros(N1,N2,N3,dataVariables);

iSteps = length(betas);
jSteps = length(sigmas);
kSteps = length(vaccineIntervals);

tic
for i = 1:iSteps
    parfor j = 1:jSteps
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
            
            fprintf('i = %d, j = %d, k = %d\n', i, j, k);
        end
    end
end
toc

%% Plotting
% [S, I, A, R, D, V, E, C, Cm, nV, nVD]
imagePlot = squeeze(parameterSpace(1,:,:,2));
imagesc([sigmas(1),sigmas(end)],[vaccineIntervals(1),vaccineIntervals(end)],imagePlot.');
set(gca, 'YDir', 'normal');
xlabel("$\sigma$");
ylabel("interval");
title(sprintf('$\\beta = %.2f$', betas));
colormap hot
colorbar

%% testing
fakeData = zeros(N1,N2,N2,dataVariables);
for j = 1:jSteps
    for k = 1:jSteps
        fakeData(1,j,k,2) = sigmas(j);
    end
end
imagesc([sigmas(1),sigmas(end)], [vaccineIntervals(1),vaccineIntervals(end)], squeeze(fakeData(1,:,:,2)).');
set(gca, 'YDir', 'normal');
xlabel("$\sigma$");
ylabel("interval");
title(sprintf('$\\beta = %.2f$', betas));
colormap hot
colorbar