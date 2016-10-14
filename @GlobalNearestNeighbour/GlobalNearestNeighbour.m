classdef GlobalNearestNeighbour
    % Global nearest neighbour method for data association
    
    properties
    end
    
    methods
        [matching_matrix, cost] = hungarian_matching(o, cost_matrix);
        data_association_matrix = find_data_association(o, observations, gate_membership_matrix);
    end
    
end

