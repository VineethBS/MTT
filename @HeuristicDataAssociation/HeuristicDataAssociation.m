classdef HeuristicDataAssociation
    % Implementation of a heuristic data association algorithm
    
    methods
        function o = HeuristicDataAssociation(~)
        end
        
        data_association_matrix = find_data_association(observations, o, list_of_tracks, gate_membership_matrix);
        
    end
    
end

