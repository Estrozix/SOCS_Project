% Parameter space
clear,clc

averages = 10;
time = 365 * 24 * 3;

% parameters to vary
vaccineIntervals = (24*30) .* [1:16];

tic
D_loop = zeros(averages,length(vaccineIntervals));
Cm_loop = zeros(averages,length(vaccineIntervals));
nVD_loop = zeros(averages,length(vaccineIntervals));

vaccine_length = length(vaccineIntervals);

pandemic_over = zeros(averages,length(vaccineIntervals));
parfor i = 1:length(vaccineIntervals)
    for run = 1:averages
        [S, I, A, R, D, V, E, C, Cm, nV, nVD] = simulateSIR(...
            show_scatter = false, ...
            time_delay = 0.1, ...
            end_time = time, ...
            gamma = 0.006,... % set
            rho_a = 0.25,... % set
            mu = 0.00006, ... % set
            inc_factor = 0.008, ... % set
            d = 0.8, ... % set
            beta = 0.1,...
            alpha_nat = 1/(24*30*5), ...
            alpha_vacc = 1/(24*30*5), ...
            sigma = 1/(24*30*3), ....
            vacc_interval = vaccineIntervals(i) ...
            );
        D_loop(run,i) = D(end);
        Cm_loop(run,i) = Cm(end);
        nVD_loop(run,i) = nVD(end);
        
        if length(S) < time
            pandemic_over(run, i) = 1
        end
    end
    disp("i: " + i + "/" + vaccine_length);
end
toc

Cm_mean = mean(Cm_loop);
D_mean = mean(D_loop);
nVD_mean = mean(nVD_loop);
pan_over_sum = sum(pandemic_over, 1);

plot(vaccineIntervals,D_mean)
hold on
plot(vaccineIntervals,Cm_mean)

disp(pan_over_sum);

figure(2)
plot(vaccineIntervals,nVD_mean)
