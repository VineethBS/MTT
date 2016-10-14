classdef MultiTargetTracker
    %Multi target tracker with the multi target tracking algorithm
        
    properties
        filter_type;
        gating_method_type;
        data_association_type;
        
        gating;
        data_association;
        
        list_of_tracks;
        list_of_non_active_tracks;
    end
    
    methods
        function o = MultiTargetTracker(filter_type, gating_method_type, gating_method_parameters, data_association_type, data_association_parameters)
            o.filter_type = filter_type;
            o.gating_method_type = gating_method_type;
            o.data_association_type = data_association_type;
            
            o.list_of_tracks = [];
            o.list_of_non_active_tracks = [];
            
            if strcmp(o.data_association_type, 'GNN')
                o.data_association = GlobalNearestNeighbour(data_association_parameters);
            elseif strcmp(o.data_association_type, 'JPDA')
                o.data_association = JProbDataAssociation(data_association_parameters);
            elseif strcmp(o.data_association_type, 'Heuristic')
                o.data_association = HeuristicDataAssociation(data_association_parameters);
            end
            
            if strcmp(o.gating_method_type, 'Spherical')
                o.gating = SphericalGating(gating_method_parameters);
            elseif strcmp(o.gating_method_type, 'Rectangular')
                o.gating = RectangularGating(gating_method_parameters);
            end
        end
        
        o = predict_new_positions(o);
        gate_membership_matrix = find_gate_membership(o, observations);
        data_association_matrix = find_data_association(o, observations, gate_membership_matrix);
        o = update_and_make_newtracks(o);
        o = maintain_tracks(o);
        o = process_one_observation(o, observations);
        o = process_multiple_observations(o, list_of_observations);
    end
    
end

