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
rho_a = options.rho_a;
time_delay = options.time_delay;

% Initialize population
% store (status,pos_x,pos_y,linear_index,vaccination time,bucket_index)
population = zeros(individuals,5);
% S (0) %suceptible
% E (1) %exposed
% I (2) %infected (symptomatic)
% A (3) %infected (asymptomatic)
% R (4) %recovered
% D (5) %dead
% V (6) %vaccinated
population(:,2:3) = randi([1,latticeN],individuals,2);
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

bucket_size = int32(100);
buckets_per_dim = idivide(latticeN,bucket_size);
assert(bucket_size*buckets_per_dim == latticeN);
buckets(1:buckets_per_dim,1:buckets_per_dim) = ArraySet(1000);
get_bucket_index = @(xpos,ypos) sub2ind([buckets_per_dim,buckets_per_dim], ...
    idivide(xpos,bucket_size,'ceil'),idivide(ypos,bucket_size,'ceil'));

for i = 1:individuals
    bucket_idx = get_bucket_index(population(i,2),population(i,3));
    buckets(bucket_idx) = buckets(bucket_idx).add(i);
end
disp(reshape([buckets.Length],buckets_per_dim,buckets_per_dim));


% Main simulation
t = 1;
infection_time = 0;
while t ~= end_time % don't stop if end_time == 0
    % move step
    prev_bucket_idx = get_bucket_index(int32(population(:,2)),int32(population(:,3)));
    will_move = rand(individuals,1) < move_probability & population(:,1) ~= Status.D;
    directions = [+1,0; -1,0; 0,+1; 0,-1];
    chosen_directions = directions(randi(4,individuals,1),:);
    population(:,2) = population(:,2) + will_move.*chosen_directions(:,1);
    population(:,3) = population(:,3) + will_move.*chosen_directions(:,2);
    population(:,2:3) = mod(population(:,2:3) - 1, latticeN) + 1;
    population(:,4) = population(:,2) + (population(:,3) - 1) * latticeN;
    new_bucket_idx = get_bucket_index(int32(population(:,2)),int32(population(:,3)));

    for i = 1:individuals
        if prev_bucket_idx(i) ~= new_bucket_idx(i)
            buckets(prev_bucket_idx(i)) = buckets(prev_bucket_idx(i)).remove(i);
            buckets(new_bucket_idx(i)) = buckets(new_bucket_idx(i)).add(i);
        end
    end

    % infection step, almost certainly most of the computation time
    starttime = tic;
%     infected = find(population(:,1) == Status.I | population(:, 1) == Status.A);
%     for i = 1:length(infected)
%         if rand < infect_rate
%             local_sus = population(:,1) == Status.S & population(:,4) == population(infected(i),4);
%             population(local_sus,1) = Status.E;
%         end
%     end
    infected = find(population(:,1) == Status.I | population(:, 1) == Status.A);
    for i = infected.'
        if rand < infect_rate
            bucket = buckets(new_bucket_idx(i));
            candidates = bucket.Elements(1:bucket.Length);
            local_sus = population(candidates,1) == Status.S & population(candidates,4) == population(i,4);
            population(candidates(local_sus),1) = Status.E;
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
        suceptible_index = find(population(:,1) == 0);
        exposed_index = find(population(:,1) == 1);
        infected_index = find(population(:,1) == 2);
        recovered_index = find(population(:,1) == 3);
        dead_index = find(population(:,1) == 4);
        vaccinated_index = find(population(:,1) == 5);

        bucket = buckets(1);
        bucket_index = bucket.Elements(1:bucket.Length);
        
        scatter(population(:,2), population(:,3), 15, 'black', 'filled');
        hold on
        scatter(population(bucket_index, 2), population(bucket_index, 3), 15, 'red', 'filled');
        hold off
%         scatter(population(dead_index, 2), population(dead_index, 3), 15, "black", "filled");
%         hold on
%         scatter(population(suceptible_index, 2), population(suceptible_index, 3), 15, [0.3010 0.7450 0.9330], "filled");
%         scatter(population(exposed_index, 2), population(exposed_index, 3), 15, [0.8500 0.3250 0.0980], "filled");
%         scatter(population(infected_index, 2), population(infected_index, 3), 15, "red", "filled");
%         scatter(population(recovered_index, 2), population(recovered_index, 3), 15, "green", "filled");
%         scatter(population(vaccinated_index, 2), population(vaccinated_index, 3), 15, "blue", "filled");
%         hold off
        %legend("suceptible","exposed","infected","recovered","dead","vaccinated");
        legend('plebs', 'bucket 1');
        pause(time_delay);
    end
    
end % end while
fprintf('Infection runtime: %.3f seconds\n', infection_time);
end % end function