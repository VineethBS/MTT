function all_possible_valid_hypothesis = get_all_possible_valid_hypothesis(o, actual_gate_membership_matrix)
% computes the set of all possible valid hypothesis given a gate membership matrix

% the last column indicates whether the observation is outside the gate of any track and is therefore not used
gate_membership_matrix = actual_gate_membership_matrix(:, 1:(end - 1)); 
num_observations = size(gate_membership_matrix, 1);
num_tracks = size(gate_membership_matrix, 2);

% Step 1: Building of the set of all possible hypothesis
% the first observation is used to kick start the building up of the matrix of all possible hypotheses
% a column of all_possible_hypothesis is a possible association hypothesis of observations to tracks or FA
track_indices = 1:num_tracks;
set_of_tracks = track_indices(gate_membership_matrix(1, :) > 0);
set_of_tracks = [set_of_tracks, 0]; % zero indicates a FA
all_possible_hypothesis = set_of_tracks;
for i = 2:num_observations
    set_of_tracks = track_indices(gate_membership_matrix(i, :) > 0);
    set_of_tracks = [set_of_tracks, 0];
    all_possible_hypothesis = combvec(all_possible_hypothesis, set_of_tracks);
end

% Step 2: Removing those hypothesis which contain multiple assignments of a track to different observations
% we consider each column of all_possible_hypothesis and check if it is a valid hypothesis or not
all_possible_valid_hypothesis = [];
for i = 1:size(all_possible_hypothesis, 2)
    check_matrix = zeros(num_observations, num_tracks);
    current_hypothesis = all_possible_hypothesis(:, i);
    for j = 1:num_observations
        if current_hypothesis(j) > 0
            check_matrix(j, current_hypothesis(j)) = 1;
        end
    end
    num_associations_to_tracks = sum(check_matrix, 1);
    if find(num_associations_to_tracks > 1)
        continue;
    else
        all_possible_valid_hypothesis = [all_possible_valid_hypothesis, current_hypothesis];
    end
end