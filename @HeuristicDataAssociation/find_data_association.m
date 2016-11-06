function data_association_matrix = find_data_association(~, observations, list_of_tracks, gate_membership_matrix)

num_of_observations = length(observations);
num_of_tracks = length(list_of_tracks);
data_association_matrix = zeros(num_of_observations, num_of_tracks + 1);
if num_of_observations > 0
    % the score matrix is proportional to finding the current observation within the gate of the current
    % track, conditioned on the event that the observation is within the gate.
    score_matrix = zeros(num_of_observations, num_of_tracks + 1);
    
    for i = 1:num_of_observations
        current_observation = observations{i};
        % if the observation does not fall within the gate of any track, then it is taken as a new track
        if gate_membership_matrix(i, end) == 1
            score_matrix(i, end) = Inf;
            data_association_matrix(i, end) = 1;
            continue;
        end
        
        % here if at least one track has this observation in its gate
        % for each observation, we iterate among all the tracks. If the observation is within the gate of a track then
        % the score is taken to be similar to the probability of having the observation under Gaussian noise.
        for j = 1:num_of_tracks
            current_track = list_of_tracks{j};
            if gate_membership_matrix(i, j) == 1
                score_matrix(i, j) = exp(-distance(current_observation, current_track.get_predicted_observation()) ^ 2);
            end
        end
        
        % Find that track which has the maximum score and assign this observation to that track        
        [~, ind] = max(score_matrix(i, 1:(end - 1)));
        data_association_matrix(i, ind) = 1;
    end
    
    % Iterate over tracks
    for j = 1:num_of_tracks
        % If only one observation has been assigned to a track then no conflict.
        if sum(data_association_matrix(:, j)) <= 1
            continue;
        end
        % Multiple observations have been assigned to this track, need to reassign some observations
        % All observations which have a score less than the maximum is just made into new tracks.
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