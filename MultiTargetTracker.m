classdef MultiTargetTracker
    %Multi target tracker with the multi target tracking algorithm
        
    properties
        filter_type;
        gating_method_type;
        data_association_type;
        list_of_tracks = [];
        list_of_non_active_tracks = [];
    end
    
    methods
        function o = predict_new_positions(o)
            for i = 1:length(o.list_of_tracks)
                o.list_of_tracks(i) = o.list_of_tracks(i).predict();
            end
        end
        
        function gate_membership_matrix = find_gate_membership(o, observations)
            gate_membership_matrix = zeros(length(observations), length(o.list_of_tracks) + 1);
        end
        
        function data_association_matrix = find_data_association(o, observations, gate_membership_matrix)
            data_association_matrix = gate_membership_matrix;
        end
        
        function o = update_and_make_newtracks(o)
        end
        
        function o = maintain_tracks(o)
        end
        
        % observations: list of observations at a particular time. Each
        % observation could be a vector
        function o = process_one_observation(o, observations)
            o = o.predict_new_positions();
            gate_membership_matrix = o.find_gate_membership(observations);
            data_association_matrix = o.find_data_association(observations, gate_membership_matrix);
            o = o.update_and_make_newtracks();
            o = o.maintain_tracks();
        end
        
        % list_of_observations: list of observations across multiple times
        function o = process_multiple_observations(o, list_of_observations)
            
        end
    end
    
end

