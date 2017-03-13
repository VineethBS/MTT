classdef RectangularGating
    % Implementation of rectangular gating
    
    properties
        % gate width - parameter which is a vector. Each element of the vector gives the width of the rectangular gate. 
        % For example a gate width of [4,4] means that the gate is the box determined by [x - 2, x + 2] x [y - 2, y + 2] 
        % where x and y are the centers of the box.
        gate_width;
        filter_type;
        hinv;
    end
    
    methods
        function o = RectangularGating(parameters, filter_type)
            o.gate_width = parameters.gate_width;
            o.filter_type=filter_type;
           
        end
        
        
        function gate_membership_matrix = find_gate_membership(o, observations, list_of_tracks)
            gate_membership_matrix = zeros(length(observations), length(list_of_tracks) + 1);
            num_of_observations = length(observations);
            num_of_tracks = length(list_of_tracks);
            if num_of_observations > 0
                for i = 1:num_of_observations
                    current_observation = observations{i};
                    if prod(current_observation > 0) %%%% raghava added checks all are non zero 
                        for j = 1:num_of_tracks
                            current_track = list_of_tracks{j};
                            if strcmp(o.filter_type, 'extendedkalmanfilter')
                                obs=current_observation - current_track.get_predicted_observation();
                                r = obs(1);
                                a = obs(2);
                                e = obs(3);

                            [x, y, z] = sph2cart(a,e,r);
                            residue = [x, y, z]';

                            else
                                residue=current_observation - current_track.get_predicted_observation();
                            end
                            %%%% raghava
                            if current_track.state ==2 %%%% raghava
                                gatewidth = o.gate_width/10;
                            else
                                gatewidth = o.gate_width/2;
                            end
                                if prod(abs(residue) <= gatewidth)
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

