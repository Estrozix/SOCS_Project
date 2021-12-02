clear, clc, clf, close all

number_of_agents = 1000;
initial_number_of_infected_agents = 10;
grid_size = 100;


immunity_percentage = 0.7;
infected = false;
mortality_rate = 0.5;
diffusion_rate = 0.5;
infection_rate = 0.5;

    at(1,1:999) = Agent(0.7,false, 0.5, 0.5, 0.5);
    at(1,1000) = Agent(0.7,true, 0.5, 0.5, 0.5);

%for i = 1:number_of_agents
 %   at(i).pos = [randi(grid_size), randi(grid_size)];
%end
at.pos(1:500) = TestClass();

%[at.pos] = deal([randi(grid_size); randi(grid_size)]);
%[at.pos] = deal(randi(grid_size, 2));
%at.pos
%for i=1:100
    %walk(at, grid_size)
 %   at.walk(grid_size)
    
    %at.x_pos

%end