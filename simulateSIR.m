% runs at most end_time iterations. if end_time=0, only stop when disease is dead.
function [S, I, R, D, V] = simulateSIR(beta,gamma,d,mu,alpha,sigma,end_time)

% Simulation Parameters
latticeN = 100;
individuals = 1000;
initial_infected_no = round(0.01*individuals);
move_probability = d;
recovery_rate = gamma;
infect_rate = beta;
mortality_rate = mu;
deimmunization_rate = alpha;
vaccination_rate = sigma;


% Initialize population
% store (status,pos_x,pos_y,linear_index,vaccination time)
population = zeros(individuals,5); 
% 1 = susceptible
% 2 = infected
% 3 = recovered
% 4 = dead
% 5 = vaccinated (immune)
population(:,2:3) = randi([0,latticeN],individuals,2);
population(:,1) = 1;
population(1:initial_infected_no,1) = 2;


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
    infected = find(population(:,1) == 2);
    for i = 1:length(infected)
        if rand < infect_rate
            local_sus = population(:,1) == 1 & population(:,4) == population(infected(i),4);
            population(local_sus,1) = 2;
        end
    end

    % vaccinate step
    vaccination_condition =  (rand(individuals,1) < vaccination_rate & population(:,1) == 1);
    population(vaccination_condition,1) = 5;
    population(vaccination_condition,5) = t;


    % recovery step
    recover_condition = (rand(individuals,1) < recovery_rate & population(:,1) == 2);
    population(recover_condition,1) = 3;

    % death step
    death_condition = (rand(individuals,1) < mortality_rate & population(:,1) == 2);
    population(death_condition,1) = 4;

    % deimmunization
    deimmun_condition = (rand(individuals,1) < deimmunization_rate & population(:,1) == 3);
    population(deimmun_condition,1) = 1;
    
    % Update data
    t = t + 1;
    S(t) = sum(population(:,1) == 1);
    I(t) = sum(population(:,1) == 2);
    R(t) = sum(population(:,1) == 3);
    D(t) = sum(population(:,1) == 4);
    V(t) = sum(population(:,1) == 5);
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
end % end while

end % end function