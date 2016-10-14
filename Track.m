classdef Track
    % Implementation of a Track 
    %   A track is a sequence of observations and/or filtered states which
    %   corresponds to an object
    
    properties
        kalman_filter;
        sequence_associated_observations;
        sequence_states;
    end
    
    methods
        function o = Track(A, C, Q, R, initial_state)
            o.kalman_filter = KalmanFilter(A, C, Q, R, initial_state);
        end
        
        function o = predict(o)
            o.kalman_filter = o.kalman_filter.predict();
        end
        
        function o = update(o, observation)
            o.kalman_filter = o.kalman_filter.update(observation);
        end
        
        function predicted_observation = get_observation(o)
            predicted_observation = o.kalman_filter.get_observation();
        end
    end
end

