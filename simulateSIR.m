% runs at most end_time iterations. if end_time=0, only stop when disease is dead.

function [S, I, A, R, D, V, E, C, Cm, nV, nVD] = simulateSIR(options)

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
    options.show_scatter (1, 1) logical
    options.rho_a (1, 1) double
    options.time_delay (1, 1) double
    options.print_benchmarks (1, 1) logical
end

% Simulation parameters
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

total_starttime = tic;

% Initialize population
% population: status(1),pos_x(2),pos_y(3),linear_index(4),vaccination time(5), # doses taken(6), times infected(7)
population = zeros(individuals,7);
population(:,1) = Status.S;
population(1:initial_infected_no,1) = Status.I;
population(:,2:3) = randi([1,latticeN],individuals,2);
population(:,4) = population(:,2) + (population(:,3)-1)*latticeN;
population(:,5) = 0;
population(1:initial_infected_no,7) = 1;


% Initialize lattice tensor
latticeMatrix = zeros(latticeN^2,10);
for i = 1:individuals
    lindex = population(i,4);
    freeSlot = find(latticeMatrix(lindex,:) == 0,1);
    latticeMatrix(lindex,freeSlot) = i;
end


% Initialize data
S = zeros(1,end_time);
I = zeros(1,end_time);
A = zeros(1,end_time);
R = zeros(1,end_time);
D = zeros(1,end_time);
V = zeros(1,end_time);
E = zeros(1,end_time);
C = zeros(1,end_time);
Cm = zeros(1,end_time);
nV = zeros(1,end_time); % # vaccinated
nVD = zeros(1,end_time); % # vaccine doses
I(1) = initial_infected_no;
S(1) = individuals-initial_infected_no;


% Main simulation
infection_runtime = 0;
t = 1;
while t ~= end_time % don't stop if end_time == 0


    % Move population & update latticeMatrix
    [population,latticeMatrix] = MovePopulation(population,...
        latticeMatrix, individuals, latticeN, move_probability);


    % Improved infection step
    infection_starttime = tic;
    population = PropagateInfection(population, latticeMatrix, infect_rate);
    infection_runtime = infection_runtime + toc(infection_starttime);

    % Update status
    population = StatusUpdate(population,options,t);


    % Update data
    t = t + 1;
    S(t) = sum(population(:,1) == Status.S);
    I(t) = sum(population(:,1) == Status.I);
    A(t) = sum(population(:,1) == Status.A);
    R(t) = sum(population(:,1) == Status.R);
    D(t) = sum(population(:,1) == Status.D);
    V(t) = sum(population(:,1) == Status.V);
    E(t) = sum(population(:,1) == Status.E);
    C(t) = sum(population(:,7) > 0);
    Cm(t) = sum(population(:,7));
    nV(t) = sum(population(:,6) > 0);
    nVD(t) = sum(population(:,6));

    % Check for disease extinction
    if I(t) == 0 && A(t) == 0 && E(t) == 0
        if end_time > 0
            S = S(1:t);
            I = I(1:t);
            A = A(1:t);
            R = R(1:t);
            D = D(1:t);
            V = V(1:t);
            E = E(1:t);
            C = C(1:t);
            Cm = Cm(1:t);
            nV = nV(1:t);
            nVD = nVD(1:t);
        end
        break;
    end

    if show_scatter
        PlotScatter(population, time_delay);
    end

end % end while
total_time = toc(total_starttime);
if options.print_benchmarks
    fprintf('Simulation took %.2f s of runtime, of which %.2f was spent infecting\n', total_time, infection_runtime);
end
end % end function


