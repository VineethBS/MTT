function o = jpda_update_make_newtracks(o, time, observations, gate_membership_matrix, jpda_probability_matrix)
new_tracks = {};
num_of_observations = length(observations);
num_of_tracks = length(o.list_of_tracks);

for i = 1:num_of_observations
    current_observation = observations{i};

    % for JPDA a new track is started for an observation only if the observation falls outside the combined gates of all tracks
    if gate_membership_matrix(i, end) == 1 
        t = Track(o.filter_type, o.filter_parameters, current_observation);
        t = t.record_predicted_observation(time);
        t = t.record_associated_observation(time, current_observation);
    else
        
    end