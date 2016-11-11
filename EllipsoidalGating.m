classdef EllipsoidalGating
    % Implementation of ellipsoidal gating
    
    properties
        threshold_type;
        gate_threshold;
    end
    
    methods
        function o = EllipsoidalGating(parameters)
            o.threshold_type = parameters.threshold_type;
            o.gate_threshold = parameters.gate_threshold;
        end
        
        function gate_membership_matrix = find_gate_membership(o, observations, list_of_tracks)
            gate_membership_matrix = zeros(length(observations), length(list_of_tracks) + 1);
            num_of_observations = length(observations);
            num_of_tracks = length(list_of_tracks);
            if num_of_observations > 0
                for i = 1:num_of_observations
                    current_observation = observations{i};
                    for j = 1:num_of_tracks
                        current_track = list_of_tracks{j};
                        covariance_matrix = current_track.get_innovation_covariance();
                        if strcmp(o.threshold_type, 'manual')
                            if statistical_distance(current_observation, current_track.get_predicted_observation(), covariance_matrix) <= o.gate_radius
                                gate_membership_matrix(i, j) = 1;
                            end
                        else
                            if statistical_distance(current_observation, current_track.get_predicted_observation(), covariance_matrix) <= o.gate_radius
                                gate_membership_matrix(i, j) = 1;
                            end
                        end
                    end
                    if sum(gate_membership_matrix(i, :)) == 0
                        gate_membership_matrix(i, end) = 1;
                    end
                end     
            end
        end
    end
    
end

