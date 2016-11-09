function hypothesis_probability = get_hypothesis_probability(o, observations, list_of_tracks, all_possible_valid_hypothesis)
% compute the probability of each hypothesis
% all_possible_valid_hypothesis - every column is a valid hypothesis, with the entry 0 indicating false alarm

num_observations = size(all_possible_valid_hypothesis, 1);
num_hypothesis = size(all_possible_valid_hypothesis, 2);
num_tracks = length(list_of_tracks);

hypothesis_probability = zeros(1, num_hypothesis);
probability_of_obs_given_hypothesis = zeros(1, num_hypothesis);
probability_of_hypothesis_given_past = zeros(1, num_hypothesis);
for i = 1:num_hypothesis
    current_hypothesis = all_possible_valid_hypothesis(:, i);
    probability_of_obs_given_hypothesis(i) = 1;
    probability_of_hypothesis_given_past(i) = 1;
    for j = 1:num_observations
        current_observation = observations{j};
        if current_hypothesis(j) == 0
            probability_of_obs_given_hypothesis(i) = probability_of_obs_given_hypothesis(i) * 1/o.volume;
        else
            current_track = list_of_tracks{current_hypothesis(j)};
            probability_of_obs_given_hypothesis(i) = probability_of_obs_given_hypothesis(i) * ... 
                mvnpdf(current_observation, current_track.get_observation(), current_track.get_innovation_covariance);
        end
    end
end

