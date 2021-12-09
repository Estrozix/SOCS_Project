


function population = StatusUpdate(population,options,t)


% Load in parameters
individuals = options.individuals;
recovery_rate = options.gamma;
mortality_rate = options.mu;
deimmunization_rate = options.alpha_nat;
vaccination_rate = options.sigma;
vacc_deimmun_rate = options.alpha_vacc; % idk
vacc_interval = options.vacc_interval;
inc_factor = options.inc_factor;
rho_a = options.rho_a;


% Exposed step
exposed_condition = (rand(individuals, 1) < inc_factor & population(:, 1) == Status.E);
asymptomatic_condition = exposed_condition & (rand(individuals, 1) < rho_a);

% Temporarily set all symptomatic
population(exposed_condition, 1) = Status.I;

% Set some of the symptomatic to asymptomatic
population(asymptomatic_condition, 1) = Status.A;

% Vaccinate step
vaccination_condition =  (rand(individuals,1) < vaccination_rate & population(:,1) == Status.S & (((t - population(:, 5)) > vacc_interval) | population(:, 5) == 0));
population(vaccination_condition,1) = Status.V;
population(vaccination_condition,5) = t;


% Recovery step (both symptomatic and asymptomatic)
recover_condition = (rand(individuals,1) < recovery_rate & (population(:,1) == Status.I | population(:, 1) == Status.A));
population(recover_condition,1) = Status.R;

% Death step (only sympomatic die)
death_condition = (rand(individuals,1) < mortality_rate & population(:,1) == Status.I);
population(death_condition,1) = Status.D;

% Deimmunization
deimmun_condition = (rand(individuals,1) < deimmunization_rate & population(:,1) == Status.R);
vacc_deimmun_condition = (rand(individuals,1) < vacc_deimmun_rate & population(:,1) == Status.V);
population(deimmun_condition | vacc_deimmun_condition,1) = Status.S;



end