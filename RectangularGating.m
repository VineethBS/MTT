classdef RectangularGating
    % Implementation of rectangular gating
    
    properties
        gate_width;
    end
    
    methods
        function o = RectangularGating(parameters)
            o.gate_width = parameters.gate_width;
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
                        if prod(abs(current_observation - current_track.get_observation()) <= o.gate_width)
                            gate_membership_matrix(i, j) = 1;
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

