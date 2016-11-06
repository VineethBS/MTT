function data_association_matrix = find_data_association(o, observations, list_of_tracks, gate_membership_matrix)
num_of_observations = length(observations);
num_of_tracks = length(list_of_tracks);

data_association_matrix = zeros(num_of_observations, num_of_tracks + 1);

if num_of_observations > 0
    cost_matrix = Inf * ones(num_of_observations, num_of_tracks);
    for i = 1:num_of_observations
        current_observation = observations{i};
        
        for j = 1:num_of_tracks
            current_track = list_of_tracks{j};
            if gate_membership_matrix(i, j) == 1
                cost_matrix(i, j) = distance(current_observation, current_track.get_predicted_observation());
            end
        end
    end
    [temp_data_association_matrix, ~] = o.hungarian_matching(cost_matrix);
    data_association_matrix = [temp_data_association_matrix, 1 - sum(temp_data_association_matrix, 2)];
end
    
end