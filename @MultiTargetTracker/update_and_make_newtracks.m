function o = update_and_make_newtracks(o, time, observations, data_association_matrix)

new_tracks = {};
num_of_observations = length(observations);
num_of_tracks = length(o.list_of_tracks);

for i = 1:num_of_observations
    current_observation = observations{i};

    if data_association_matrix(i, end) == 1
        initial_state = [current_observation', o.filter_parameters.rest_of_initial_state']';
        t = Track(o.filter_parameters.A,  o.filter_parameters.C, o.filter_parameters.Q, o.filter_parameters.R, initial_state);
        t = t.record_predicted_observation(time);
        t = t.record_associated_observation(time, current_observation);
        new_tracks{end + 1} = t;
    else
        for j = 1:num_of_tracks
            if data_association_matrix(i, j) == 1
                o.list_of_tracks{j} = o.list_of_tracks{j}.update(current_observation);
                o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
                o.list_of_tracks{j} = o.list_of_tracks{j}.record_associated_observation(time, current_observation);
            end 
        end
    end
end

for j = 1:num_of_tracks
    if sum(data_association_matrix(:, j)) == 0
        o.list_of_tracks{j} = o.list_of_tracks{j}.record_predicted_observation(time);
    end
end

o.list_of_tracks = [o.list_of_tracks, new_tracks];
end