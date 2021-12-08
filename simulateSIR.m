% runs at most end_time iterations. if end_time=0, only stop when disease is dead.
function [S, I, A, R, D, V] = simulateSIR(options)
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
    options.rho_a (1, 1) double
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
rho_a = options.rho_a;

% Initialize population
% store (status,pos_x,pos_y,linear_index,vaccination time)
population = zeros(individuals,5);
% S (0) %suceptible
% E (1) %exposed
% I (2) %infected (symptomatic)
% A (3) %infected (asymptomatic)
% R (4) %recovered
% D (5) %dead
% V (6) %vaccinated
population(:,2:3) = randi([0,latticeN],individuals,2);
population(:,1) = Status.S;
population(1:initial_infected_no,1) = Status.I;
population(:, 5) = 0;


% Initialize data
S = zeros(1,end_time);
I = zeros(1,end_time);
A = zeros(1,end_time);
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
    will_move = rand(individuals,1) < move_probability;
    directions = [+1,0; -1,0; 0,+1; 0,-1];
    chosen_directions = directions(randi(4,individuals,1),:);
    population(:,2) = population(:,2) + will_move.*chosen_directions(:,1);
    population(:,3) = population(:,3) + will_move.*chosen_directions(:,2);
    population(:,2:3) = mod(population(:,2:3), latticeN);
    population(:,4) = population(:,2) + population(:,3)*latticeN;

    % infection step, almost certainly most of the computation time
    starttime = tic;
    infected = find(population(:,1) == Status.I | population(:, 1) == Status.A);
    for i = 1:length(infected)
        if rand < infect_rate
            local_sus = population(:,1) == Status.S & population(:,4) == population(infected(i),4);
            population(local_sus,1) = Status.E;
        end
    end
    infection_time = infection_time + toc(starttime);

    % exposed step
    exposed_condition = (rand(individuals, 1) < inc_factor & population(:, 1) == Status.E);
    asymptomatic_condition = exposed_condition & (rand(individuals, 1) < rho_a);

    % Temporarily set all symptomatic
    population(exposed_condition, 1) = Status.I;

    % Set some of the symptomatic to asymptomatic
    population(asymptomatic_condition, 1) = Status.A;

    % vaccinate step
    vaccination_condition =  (rand(individuals,1) < vaccination_rate & population(:,1) == Status.S & (((t - population(:, 5)) > vacc_interval) | population(:, 5) == 0));
    population(vaccination_condition,1) = Status.V;
    population(vaccination_condition,5) = t;
    
    % recovery step (both symptomatic and asymptomatic)
    recover_condition = (rand(individuals,1) < recovery_rate & (population(:,1) == Status.I | population(:, 1) == Status.A));
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
    A(t) = sum(population(:,1) == Status.A);
    R(t) = sum(population(:,1) == Status.R);
    D(t) = sum(population(:,1) == Status.D);
    V(t) = sum(population(:,1) == Status.V);
    % check for disease extinction
    if I(t) == 0
        if end_time > 0
            S((t+1):end) = S(t);
            I((t+1):end) = I(t);
            A((t+1):end) = A(t);
            R((t+1):end) = R(t);
            D((t+1):end) = D(t);
            V((t+1):end) = V(t);
        end
        break;
    end

    if show_scatter
        scatter(population(:, 2), population(:, 3), 10, population(:,1), "filled")
        pause(0.001)
    end

end % end while
fprintf('Infection runtime: %.3f seconds\n', infection_time);
end % end function