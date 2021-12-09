function PlotScatter(population, time_delay)
    suceptible_index = find(population(:,1) == Status.S);
    exposed_index = find(population(:,1) == Status.E);
    infected_index = find(population(:,1) == Status.I);
    infected_asymptomatic_index = find(population(:,1) == Status.A);
    recovered_index = find(population(:,1) == Status.R);
    dead_index = find(population(:,1) == Status.D);
    vaccinated_index = find(population(:,1) == Status.V);
    
    dead_scatter = scatter(population(dead_index, 2), population(dead_index, 3), 15, "black", "filled");
    hold on
    suceptible_scatter = scatter(population(suceptible_index, 2), population(suceptible_index, 3), 15, [0.3010 0.7450 0.9330], "filled");
    exposed_scatter = scatter(population(exposed_index, 2), population(exposed_index, 3), 15, [0.8500 0.3250 0.0980], "filled");
    infected_scatter = scatter(population(infected_index, 2), population(infected_index, 3), 15, "red", "filled");
    infected_asymptomatic_scatter = scatter(population(infected_asymptomatic_index, 2), population(infected_asymptomatic_index, 3), 15, "magenta", "filled");
    recovered_scatter = scatter(population(recovered_index, 2), population(recovered_index, 3), 15, "green", "filled");
    vaccinated_scatter = scatter(population(vaccinated_index, 2), population(vaccinated_index, 3), 15, "blue", "filled");
    hold off
    legend([dead_scatter,suceptible_scatter,exposed_scatter,infected_scatter,infected_asymptomatic_scatter,recovered_scatter,vaccinated_scatter],{"dead","suceptible","exposed","infected (symptomatic)","infected (asymptomatic)","recovered","vaccinated"});
    pause(time_delay);
end