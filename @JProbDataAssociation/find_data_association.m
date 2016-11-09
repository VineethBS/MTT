function jpda_probability_matrix = find_data_association(o, observations, list_of_tracks, gate_membership_matrix)

num_observations = length(observations);
num_tracks = length(list_of_tracks);

% the JPDA probability matrix to be computed
jpda_probability_matrix = zeros(num_observations, num_tracks);

track_indices = 1:num_tracks;
if num_observations > 0
    % all_possible_valid_hypothesis - every column is a possible association hypothesis
    all_possible_valid_hypothesis = o.get_all_possible_valid_hypothesis(gate_membership_matrix); % generate the set of all possible valid hypothesis
    hypothesis_probability = o.get_hypothesis_probability(observations, list_of_tracks, all_possible_valid_hypothesis); % find out the probability of each hypothesis
    jpda_probability_matrix = o.get_jpda_probability_matrix(observations, list_of_tracks, hypothesis_probability,  all_possible_valid_hypothesis); % find out the track association probability for each observation
end