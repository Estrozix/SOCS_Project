classdef ArraySet
    properties
        Capacity (1,1) int32
        Length (1,1) int32
        Elements double
    end
    
    methods
        function obj = ArraySet(capacity)
            obj.Capacity = int32(capacity);
            obj.Length = 0;
            obj.Elements = zeros(1,capacity);
        end
        
        function obj = add(obj, element)
            if obj.Length == obj.Capacity
                % grow by 50%
                obj.Capacity = obj.Capacity + obj.Capacity/2;
                prev_elements = obj.Elements;
                obj.Elements = zeros(1,obj.Capacity);
                obj.Elements(1:obj.Length) = prev_elements;
                fprintf('Expanding capacity to %d elements.\n',obj.Capacity);
            end
            obj.Length = obj.Length + 1;
            obj.Elements(obj.Length) = element;
        end
        
        % removes one instance of element in the set, if it exists
        function obj = remove(obj, element)
            for i = 1:obj.Length
                if obj.Elements(i) == element
                    obj.Elements(i) = obj.Elements(obj.Length);
                    obj.Length = obj.Length - 1;
                    break;
                end
            end
        end
    end
end
