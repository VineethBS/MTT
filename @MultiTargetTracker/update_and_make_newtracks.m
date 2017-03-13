function o = update_and_make_newtracks(o, time, observations, gate_membership_matrix, data_association_matrix)

new_tracks = {};
num_of_observations = length(observations);
num_of_tracks = length(o.list_of_tracks);

for i = 1:num_of_observations
    current_observation = observations{i};
    % If the last column is 1 for an observation then a new target has to be made
    % If the new target is not within the gate of any existing tracks, then a new track is made with default initial
    % parameters. If the new target is within the gate of some existing tracks, then a new track is made by deriving the
    % track from the nearest track to the observation.
    
    if data_association_matrix(i, end) == 1
        if gate_membership_matrix(i, end) == 1
		if (o.additional_information.snr{i} >= o.observation_snr_limit) 
            t = Track(o.filter_type, o.filter_parameters, time, current_observation);
            t = t.record_first_observation(time);
            t = t.record_associated_observation(time, current_observation);
		new_tracks{end + 1} = t;
		end
        else
            cost_vector = Inf * ones(1, num_of_tracks);
            for j = 1:num_of_tracks
                current_track = o.list_of_tracks{j};
                if gate_membership_matrix(i, j) == 1
                    cost_vector(j) = distance(current_observation, current_track.get_predicted_observation());
                end
            end
            [~, track_from_which_split] = min(cost_vector);
            t = o.list_of_tracks{track_from_which_split}.split_track();
            t = t.record_predicted_observation(time);
            t = t.update(time, current_observation);
            t = t.record_associated_observation(time, current_observation);
            t = t.record_updated_state(time);
		new_tracks{end + 1} = t;
        end
    else
        for j = 1:num_of_tracks
            if data_association_matrix(i, j) == 1
                o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
                o.list_of_tracks{j} = o.list_of_tracks{j}.update(time, current_observation);
                o.list_of_tracks{j} = o.list_of_tracks{j}.record_associated_observation(time, current_observation);
                o.list_of_tracks{j} = o.list_of_tracks{j}.record_updated_state(time);
            end 
        end
    end
end

% For the tracks which do not have any associated observations the current time and observation is recorded
for j = 1:num_of_tracks
    if sum(data_association_matrix(:, j)) == 0
	% Option 1 and 2 are not mathematically correct
        % Option 1 : Use the observation corresponding to the state without prediction
        % o.list_of_tracks{j} = o.list_of_tracks{j}.update(time, o.list_of_tracks{j}.get_observation());
        % Option 2 : Use the observation corresponding to the predicted state
%         o.list_of_tracks{j} = o.list_of_tracks{j}.update(time, o.list_of_tracks{j}.get_predicted_observation());
         % Option 3 : Update current state with the predicted state
         interval_center = o.additional_information.pointing_information;
         interval_width = o.observation_pointing_limit;
         residue = interval_center' - o.list_of_tracks{j}.get_predicted_observation();
        if (prod(abs(residue) > interval_width/2))
            o.list_of_tracks{j} = o.list_of_tracks{j}.update_with_noobservation(time);         
            o.list_of_tracks{j} = o.list_of_tracks{j}.record_notobserved_times(time);
        else
            o.list_of_tracks{j} = o.list_of_tracks{j}.update_with_noobservation(time);         
            o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
            o.list_of_tracks{j} = o.list_of_tracks{j}.record_updated_state(time);
        end
    end
end

o.list_of_tracks = [o.list_of_tracks, new_tracks];
end
