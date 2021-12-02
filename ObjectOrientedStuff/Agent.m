classdef Agent
    
    properties
        pos
        immunity_percentage %Probability of the agent not getting infected.
        infected %bool
        mortality_rate %if infected: probabability that the agent dies.
        diffusion_rate %probability of movement (random direction) (varies depending on infected bool).
        infection_rate %if infected: probability of spreading the infection to another agent occupying the same space
    end
    
    methods
        function obj = Agent(immunity_percentage, infected, mortality_rate, diffusion_rate, infection_rate)
            obj.pos = 0;
            obj.immunity_percentage = immunity_percentage;
            obj.infected = infected;
            obj.mortality_rate = mortality_rate;
            obj.diffusion_rate = diffusion_rate;
            obj.infection_rate = infection_rate;
        end
    end
    
    methods
        
        %function obj = set.pos(obj, p)
         %   obj.pos = p;
        %end
        
        function p = test(obj, grid_size)
            p = randi(grid_size);
        end
        
        
        
        function obj = walk(obj, grid_size)
            if obj.diffusion_rate > rand
                temp_rand = rand;
                if 1/4 > temp_rand
                    obj.pos(1) = obj.pos(1) - 1;
                    if obj.pos(1) == 0
                        obj.pos(1) = grid_size;
                    end
                elseif 2/4 > temp_rand
                    obj.pos(1) = obj.pos(1) + 1;
                    if obj.pos(1) == grid_size + 1
                        obj.pos(1) = 1;
                    end
                elseif 3/4 > temp_rand
                    obj.pos(2) = obj.pos(2) - 1;
                    if obj.pos(2) == 0
                        obj.pos(2) = grid_size;
                    end
                else
                    obj.pos(2) = obj.pos(2) + 1;
                    if obj.pos(2) == grid_size + 1
                        obj.pos(2) = 1;
                    end
                end
            end
        end
        
        
    end
end