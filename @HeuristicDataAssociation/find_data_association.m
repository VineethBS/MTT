function data_association_matrix = find_data_association(o, observations, list_of_tracks, gate_membership_matrix)

num_of_observations = length(observations);
num_of_tracks = length(list_of_tracks);
data_association_matrix = zeros(num_of_observations, num_of_tracks + 1);
if num_of_observations > 0
    score_matrix = zeros(num_of_observations, num_of_tracks + 1);
    
    for i = 1:num_of_observations
        current_observation = observations{i};
        if gate_membership_matrix(i, end) == 1
            score_matrix(i, end) = Inf;
            data_association_matrix(i, end) = 1;
            continue;
        end
        
        for j = 1:num_of_tracks
            current_track = list_of_tracks{j};
            if gate_membership_matrix(i, j) == 1
                score_matrix(i, j) = exp(-distance(current_observation, current_track.get_observation()) ^ 2);
            end
        end
        
        temp = score_matrix(i, 1:(end - 1));
        score_matrix(i, end) = min(temp(temp > 0)) - o.epsilon;
        [~, ind] = max(score_matrix(i, :));
        data_association_matrix(i, ind) = 1;
    end
    
    for j = 1:num_of_tracks
        if sum(data_association_matrix(:, j)) <= 1
            continue;
        end
        
        [~, max_ind] = max(score_matrix(:, j));
        for i = 1:num_of_observations
            if (data_association_matrix(i, j) == 1) && (i ~= max_ind)
                data_association_matrix(i, j) = 0;
                data_association_matrix(i, end) = 1;
            end
        end
    end
end
end