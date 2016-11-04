function valid_tracks = find_tracks_velocity_threshold(o, tracks)
% returns a cell array of valid tracks - valid tracks are either active tracks or inactive tracks that have an estimated
% velocity either greater than or less than a threshold. The threshold is set by velocity_threshold which is a vector of
% dimensions the same as that of the observations. The threshold is separate for each dimension of the observations.
% Depending on direction, we check if the absolute value of the velocity along a co-ordinate is more or less than the
% threshold.

velocity_threshold = o.velocity_threshold_parameters.velocity_threshold;
direction = o.velocity_threshold_parameters.direction;
j = 1;
valid_tracks = [];
for i = 1:length(tracks)
    observed_state_sequence = cell2mat(tracks{i}.sequence_predicted_observations); % the observations are converted into a matrix
    time_sequence = tracks{i}.sequence_times;
    
    observed_state_delta = diff(observed_state_sequence, [], 2);
    time_delta = diff(time_sequence, [], 2);
    time_delta = repmat(time_delta, size(observed_state_delta, 1), 1);
    observed_velocity = observed_state_delta ./ time_delta;
    observed_velocity = mean(observed_velocity, 2); % find the average along the column for every dimension of the observed state
    observed_velocity = abs(observed_velocity);
    
    flag = 1; % flag = 1 means that the track is valid
    % iterate along all components of the observed velocity and depending on the specification in direction check if the
    % threshold is met or not
    for k = 1:length(observed_velocity)
        if strcmp(direction(k), 'less')
            if observed_velocity(k) > velocity_threshold(k)
                flag = 0;
                break;
            end
        else
            if observed_velocity(k) < velocity_threshold(k)
                flag = 0;
                break;
            end
        end
    end
    if flag == 1
        valid_tracks{j} = tracks{i};
        j = j + 1;
    end
end