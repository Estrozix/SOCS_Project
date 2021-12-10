


function population = PropagateInfection(population, latticeMatrix, infect_rate)


    infected = find(population(:,1) == Status.I | population(:, 1) == Status.A);
    for i = 1:length(infected)
        if rand < infect_rate
            q = infected(i);
            lindexInfected = population(q,4);
            local_indices = nonzeros(latticeMatrix(lindexInfected,:));


            for j = 1:length(local_indices)
                if population(local_indices(j),1) == Status.S
                    population(local_indices(j),1) = Status.E;
                end
            end
        end
    end

end