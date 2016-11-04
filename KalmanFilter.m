classdef KalmanFilter
    % Implementation of a Kalman filter for track prediction
    %   Kalman filter equations
    %   x_{k + 1} = A x_{k} + w_{k}; where x_{k} is the state
    %   y_{k} = C x_{k} + v_{k}; where y_{k} is the observation
    %   Both w_{k} and v_{k} are jointly Gaussian vectors with zero mean
    %   and covariance matrices Q and R
    properties
        A;
        C;
        Q;
        R;
        state; % the current state
        covariance;
        predicted_state;
        predicted_covariance;
        kalman_gain;
    end
    
    methods
        function o = KalmanFilter(parameters, initial_observation)
            o.A = parameters.A;
            o.C = parameters.C;
            o.Q = parameters.Q;
            o.R = parameters.R;
            initial_state = [initial_observation', parameters.rest_of_initial_state']';
            o.state = initial_state;
            o.covariance = o.Q;
        end
        
        function o = predict(o)
            o.predicted_state = o.A * o.state;
            o.predicted_covariance = o.A * o.covariance * o.A' + o.Q;
        end
        
        function o = update(o, observation)
            o.kalman_gain = o.predicted_covariance * o.C' * inv(o.C * o.predicted_covariance * o.C' + o.R);
            o.state = o.predicted_state + o.kalman_gain * (observation - o.C * o.predicted_state);
            o.covariance = o.predicted_covariance - o.kalman_gain * o.C * o.predicted_covariance;
        end
        
        % return the observation corresponding to the current state of the filter
        function predicted_observation = get_observation(o)
            predicted_observation = o.C * o.state;
        end
    end
    
end

