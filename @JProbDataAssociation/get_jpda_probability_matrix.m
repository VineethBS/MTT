function jpda_probability_matrix = get_jpda_probability_matrix(o, observations, list_of_tracks, hypothesis_probability, all_possible_valid_hypothesis)
num_tracks = length(list_of_tracks);
num_observations = length(observations);
jpda_probability_matrix = zeros(num_observations, num_tracks);

all_hypothesis_indices = 1: size(all_possible_valid_hypothesis, 2);
for i = 1:num_observations
    for j = 1:num_tracks
        obs_to_track_association = all_possible_valid_hypothesis(i, :);
        hypothesis_indices_with_association = all_hypothesis_indices(obs_to_track_association == j);
        jpda_probability_matrix(i, j) = sum(hypothesis_probability( hypothesis_indices_with_association ));
    end
end
    