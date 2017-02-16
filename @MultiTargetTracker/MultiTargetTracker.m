classdef MultiTargetTracker
    %Multi target tracker with the multi target tracking algorithm
        
    properties
        filter_type; % configuration parameters for the types of filter, gating method, data association, and track maintenance.
        gating_method_type;
        data_association_type; 
        track_maintenance_type;
        
        filter_parameters;
        track_maintenance_parameters;
        
        gating; % actual objects for gating, data association and track maintenance
        data_association;
        track_maintenance;
        
        list_of_tracks;
        list_of_inactive_tracks;
    end
    
    methods
        function o = MultiTargetTracker(filter_type, filter_parameters, gating_method_type, gating_method_parameters, ...
                                        data_association_type, data_association_parameters, track_maintenance_type, track_maintenance_parameters)
                                        
            o.filter_type = filter_type;
            o.gating_method_type = gating_method_type;
            o.data_association_type = data_association_type;
            o.track_maintenance_type = track_maintenance_type;
            
            o.filter_parameters = filter_parameters;
            o.track_maintenance_parameters = track_maintenance_parameters;
            
            o.list_of_tracks = [];
            o.list_of_inactive_tracks = [];
            
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
                
                 o.gating = RectangularGating(gating_method_parameters,o.filter_type);
                
            end
            
            if strcmp(o.track_maintenance_type, 'NOutOfM')
                o.track_maintenance = NOutOfM(track_maintenance_parameters);
            elseif strcmp(o.track_maintenance_type, 'NOutOfM_FixedNumber')
                o.track_maintenance = NOutOfM_FixedNumberActiveTracks(track_maintenance_parameters);
            end
        end
        
        o = predict_new_positions(o);
        gate_membership_matrix = find_gate_membership(o, observations);
        data_association_matrix = find_data_association(o, observations, gate_membership_matrix);
        o = update_and_make_newtracks(o, time, observations, gate_membership_matrix, data_association_matrix);
        o = jpda_update_and_make_newtracks(o, time, observations, gate_membership_matrix, jpda_probability_matrix);
        o = maintain_tracks(o);
        o = process_one_observation(o, time, observations, additional_information);
        o = process_multiple_observations(o, list_of_times, list_of_observations, list_of_additional_information);
    end
end