

function [population,latticeMatrix] = MovePopulation(population,...
    latticeMatrix, individuals, latticeN, move_probability)

% Move population
will_move1 = rand(individuals,1) < move_probability & population(:,1) ~= Status.D & population(:,1) ~= Status.I;
will_move2 = rand(individuals,1) < move_probability/10 & population(:,1) == Status.I;
will_move = will_move1 | will_move2;
directions = [+1,0; -1,0; 0,+1; 0,-1];
chosen_directions = directions(randi(4,individuals,1),:);
temporaryLindex = population(:,4);
population(:,2) = population(:,2) + will_move.*chosen_directions(:,1);
population(:,3) = population(:,3) + will_move.*chosen_directions(:,2);
population(:,2:3) = mod(population(:,2:3)-1, latticeN)+1;
population(:,4) = population(:,2) + (population(:,3)-1)*latticeN;

% Update latticeMatrix
for i = 1:individuals  
    if will_move(i)

        % remove their previous step
        tempLindex = temporaryLindex(i);
        removeIndex = find(latticeMatrix(tempLindex,:) == i,1);
        latticeMatrix(tempLindex,removeIndex) = 0;

        % add their new position
        lindex = population(i,4);
        freeSlot = find(latticeMatrix(lindex,:) == 0,1);
        latticeMatrix(lindex,freeSlot) = i;
    end
end

end