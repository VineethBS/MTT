function o = jpda_update_and_make_newtracks(o, time, observations, gate_membership_matrix, jpda_probability_matrix)
new_tracks = {};
num_of_observations = length(observations);
num_of_tracks = length(o.list_of_tracks);

for i = 1:num_of_observations
    current_observation = observations{i};
    % for JPDA a new track is started for an observation only if the observation falls outside the combined gates of all tracks
    if gate_membership_matrix(i, end) == 1 
        t = Track(o.filter_type, o.filter_parameters, time, current_observation);
        t = t.record_first_observation(time);
        t = t.record_associated_observation(time, current_observation);
        new_tracks{end + 1} = t;
    end
end

for j = 1:num_of_tracks
    % For the tracks which do not have any associated observations the current time and observation is recorded
    if sum(gate_membership_matrix(:, j)) == 0
        % Option 1 : Use the observation corresponding to the state without prediction
%         o.list_of_tracks{j} = o.list_of_tracks{j}.update(time, o.list_of_tracks{j}.get_observation());
        % Option 2 : Use the observation corresponding to the predicted state
        o.list_of_tracks{j} = o.list_of_tracks{j}.update(time, o.list_of_tracks{j}.get_predicted_observation());
        o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
         o.list_of_tracks{j} = o.list_of_tracks{j}.record_updated_state(time);
       
    else % for the tracks with some probability of association
        o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
        probability_no_assoc_observation = 1 - sum(jpda_probability_matrix(:,j));
        observation_probability = jpda_probability_matrix(:, j);
        o.list_of_tracks{j} = o.list_of_tracks{j}.update_with_multiple_observations(time, observations, observation_probability, probability_no_assoc_observation);
        % we record the observation corresponding to the updated state
        o.list_of_tracks{j} = o.list_of_tracks{j}.record_associated_observation(time, o.list_of_tracks{j}.get_observation()); 
        o.list_of_tracks{j} = o.list_of_tracks{j}.record_updated_state(time);
    end
end

o.list_of_tracks = [o.list_of_tracks, new_tracks];
end