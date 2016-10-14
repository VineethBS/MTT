classdef Track
    % Implementation of a Track 
    %   A track is a sequence of observations and/or filtered states which
    %   corresponds to an object
    
    properties
        kalman_filter;
        gate_parameters;
        track_maintenance_parameters;
    end
    
    methods
        function o = Track(A, C, Q, R, initial_state, gate_parameters, track_maintenance_parameters)
            o.kalman_filter = KalmanFilter(A, C, Q, R, initial_state);
            o.gate_parameters = gate_parameters;
            o.track_maintenance_parameters = track_maintenance_parameters;
        end
        
        function o = predict(o)
            o.kalman_filter = o.kalman_filter.predict();
        end
        
        function o = update(o, observation)
            o.kalman_filter = o.kalman_filter.update(observation);
        end
    end
end

