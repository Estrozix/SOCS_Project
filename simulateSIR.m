% runs at most end_time iterations. if end_time=0, only stop when disease is dead.
function [S, I, R, D, V] = simulateSIR(options)
arguments
    options.latticeN double = 100
    options.individuals double = 1000
    options.beta (1,1) double
    options.gamma (1,1) double
    options.d (1,1) double
    options.mu (1,1) double
    options.alpha_nat (1,1) double
    options.alpha_vacc (1,1) double
    options.sigma (1,1) double
    options.end_time (1,1) double
    options.vacc_interval (1, 1) double
    options.inc_factor (1, 1) double
    options.show_scatter
    options.time_delay
end
%beta,gamma,d,mu,alpha,sigma,end_time
% Simulation Parameters
latticeN = options.latticeN;
individuals = options.individuals;
initial_infected_no = round(0.01*individuals);
move_probability = options.d;
recovery_rate = options.gamma;
infect_rate = options.beta;
mortality_rate = options.mu;
deimmunization_rate = options.alpha_nat;
vaccination_rate = options.sigma;
vacc_deimmun_rate = options.alpha_vacc; % idk
end_time = options.end_time;
vacc_interval = options.vacc_interval;
inc_factor = options.inc_factor;
show_scatter = options.show_scatter;
time_delay = options.time_delay;

% Initialize population
% store (status,pos_x,pos_y,linear_index,vaccination time)
population = zeros(individuals,5);
% 1 = susceptible
% 2 = infected
% 3 = recovered
% 4 = dead
% 5 = vaccinated (immune)
population(:,2:3) = randi([1,latticeN],individuals,2);
population(:,1) = Status.S;
population(1:initial_infected_no,1) = Status.I;
population(:, 5) = 0;


% Initialize data
S = zeros(1,end_time);
I = zeros(1,end_time);
R = zeros(1,end_time);
D = zeros(1,end_time);
V = zeros(1,end_time);
I(1) = initial_infected_no;
S(1) = individuals-initial_infected_no;


% Main simulation
t = 1;
infection_time = 0;
while t ~= end_time % don't stop if end_time == 0
    % move step
    will_move = rand(individuals,1) < move_probability & population(:,1) ~= 4;
    directions = [+1,0; -1,0; 0,+1; 0,-1];
    chosen_directions = directions(randi(4,individuals,1),:);
    population(:,2) = population(:,2) + will_move.*chosen_directions(:,1);
    population(:,3) = population(:,3) + will_move.*chosen_directions(:,2);
    population(:,2:3) = mod(population(:,2:3) - 1, latticeN) + 1;
    population(:,4) = population(:,2) + (population(:,3) - 1) * latticeN;

    % infection step, almost certainly most of the computation time
    starttime = tic;
    infected = find(population(:,1) == Status.I);
    for i = 1:length(infected)
        if rand < infect_rate
            local_sus = population(:,1) == Status.S & population(:,4) == population(infected(i),4);
            population(local_sus,1) = Status.E;
        end
    end
    infection_time = infection_time + toc(starttime);

    % exposed step
    exposed_condition = (rand(individuals, 1) < inc_factor & population(:, 1) == Status.E);
    population(exposed_condition, 1) = Status.I;

    % vaccinate step
    vaccination_condition =  (rand(individuals,1) < vaccination_rate & population(:,1) == Status.S & (((t - population(:, 5)) > vacc_interval) | population(:, 5) == 0));
    population(vaccination_condition,1) = Status.V;
    population(vaccination_condition,5) = t;
    
    % recovery step
    recover_condition = (rand(individuals,1) < recovery_rate & population(:,1) == Status.I);
    population(recover_condition,1) = Status.R;

    % death step
    death_condition = (rand(individuals,1) < mortality_rate & population(:,1) == Status.I);
    population(death_condition,1) = Status.D;

    % deimmunization
    deimmun_condition = (rand(individuals,1) < deimmunization_rate & population(:,1) == Status.R);
    vacc_deimmun_condition = (rand(individuals,1) < vacc_deimmun_rate & population(:,1) == Status.V);
    population(deimmun_condition | vacc_deimmun_condition,1) = Status.S;
    % Update data
    t = t + 1;
    S(t) = sum(population(:,1) == Status.S);
    I(t) = sum(population(:,1) == Status.I);
    R(t) = sum(population(:,1) == Status.R);
    D(t) = sum(population(:,1) == Status.D);
    V(t) = sum(population(:,1) == Status.V);
    % check for disease extinction
    if I(t) == 0
        if end_time > 0
            S((t+1):end) = S(t);
            I((t+1):end) = I(t);
            R((t+1):end) = R(t);
            D((t+1):end) = D(t);
            V((t+1):end) = V(t);
        end
        break;
    end
    if show_scatter
        suceptible_index = find(population(:,1) == 0);
        exposed_index = find(population(:,1) == 1);
        infected_index = find(population(:,1) == 2);
        recovered_index = find(population(:,1) == 3);
        dead_index = find(population(:,1) == 4);
        vaccinated_index = find(population(:,1) == 5);

        scatter(population(suceptible_index, 2), population(suceptible_index, 3), 15, [0.3010 0.7450 0.9330], "filled");
        hold on
        scatter(population(exposed_index, 2), population(exposed_index, 3), 15, [0.8500 0.3250 0.0980], "filled");
        scatter(population(infected_index, 2), population(infected_index, 3), 15, "red", "filled");
        scatter(population(recovered_index, 2), population(recovered_index, 3), 15, "magenta", "filled");
        scatter(population(dead_index, 2), population(dead_index, 3), 15, "black", "filled");
        scatter(population(vaccinated_index, 2), population(vaccinated_index, 3), 15, "blue", "filled");
        hold off
        legend("suceptible","exposed","infected","recovered","dead","vaccinated");
        pause(time_delay);
    end
    
end % end while
fprintf('Infection runtime: %.3f seconds\n', infection_time);
end % end function