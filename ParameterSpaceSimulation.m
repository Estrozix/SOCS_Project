% Parameter space
clear,clc

averages = 5;
month = 24*30;
time = 12*month*4;

% parameters to vary
N1 = 1;
N2 = 24;
N3 = 24;
betas = 0.3;
inverseSigma = linspace(1*month,24*month,N2);
vaccineIntervals = linspace(1*month,24*month,N3);

% Initialize output
dataVariables = 5;
parameterSpace = zeros(N1,N2,N3,dataVariables);

iSteps = length(betas);
jSteps = length(inverseSigma);
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
                inc_factor = 1/(5*24), ... % set
                d = 0.8, ... % set
                alpha_vacc = -expm1(log(0.7)/(140*24)), ... % set (30 % loss after 20 weeks)
                alpha_nat = -expm1(log(0.7)/(140*24)), ... % set (30 % loss after 20 weeks)
                beta = betas(i),...
                sigma = 1/inverseSigma(j), ...
                vacc_interval = vaccineIntervals(k), ...
                print_benchmarks = false ...
                );

            tempData(runs,:) = [D(end),C(end),Cm(end),vacced(end),doses(end)];
            end
            
            parameterSpace(i,j,k,:) = mean(tempData);
            
            fprintf('i = %d, j = %d, k = %d\n', i, j, k);
        end
    end
end
toc

%% Plotting
% [S, I, A, R, D, V, E, C, Cm, nV, nVD]
imagePlot = squeeze(parameterSpace(1,:,:,1));
imagesc([inverseSigma(1),inverseSigma(end)]/month,[vaccineIntervals(1),vaccineIntervals(end)]/month,imagePlot.');
set(gca, 'YDir', 'normal');
xlabel("Average vaccination delay $1/\sigma$ (months)");
ylabel("Vaccination interval (months)");
title(sprintf('Number of deaths for infection chance $\\beta = %.2f$', betas));
colormap hot
colorbar
fprintf('Plotted.\n');

%% testing
fakeData = zeros(N1,N2,N2,dataVariables);
for j = 1:jSteps
    for k = 1:jSteps
        fakeData(1,j,k,2) = inverseSigma(j);
    end
end
imagesc([inverseSigma(1),inverseSigma(end)], [vaccineIntervals(1),vaccineIntervals(end)], squeeze(fakeData(1,:,:,2)).');
set(gca, 'YDir', 'normal');
xlabel("$\sigma$");
ylabel("interval");
title(sprintf('$\\beta = %.2f$', betas));
colormap hot
colorbar