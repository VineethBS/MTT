classdef JProbDataAssociation
    % Joint probabilistic data association
    
    properties
        detection_probability;
        false_alarm_rate;
    end
    
    methods
        function o = JProbDataAssociation(parameters)
            o.detection_probability = parameters.detection_probability;
            o.false_alarm_rate = parameters.false_alarm_rate;
        end
        
        jpda_probability_matrix = find_data_association(o, observations, list_of_tracks, gate_membership_matrix);
        all_possible_valid_hypothesis = get_all_possible_valid_hypothesis(o, gate_membership_matrix);
        hypothesis_probability = get_hypothesis_probability(o, all_possible_valid_hypothesis);
        jpda_probability_matrix = get_jpda_probability_matrix(o, hypothesis_probability);
    end
    
end

