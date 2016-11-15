classdef ExtendedKalmanFilter
    % Implementation of a Extended Kalman filter for track prediction
    % Extended Kalman filter equations
    %   x_{k + 1} = f(x_{k}) + w_{k}; where x_{k} is the state
    %   y_{k} = h(x_{k}) + v_{k}; where y_{k} is the observation
    %   Both w_{k} and v_{k} are jointly Gaussian vectors with zero mean
    %   and covariance matrices Q and R
    
    properties
        f; % non-linear state transition function
        h; % non-linear measurement function
        F; % Jacobian of f
        H; % Jacobian of h
        Q;
        R;
        state; % the current state
        covariance;
        predicted_state;
        predicted_covariance;
        kalman_gain;
    end
    
    methods
        function o = ExtendedKalmanFilter(parameters, initial_observation)
            o.f = parameters.f;
            o.F = parameters.F;
            o.h = parameters.h;
            o.H = parameters.H;            
            o.Q = parameters.Q;
            o.R = parameters.R;
            initial_state = [initial_observation', parameters.rest_of_initial_state']';
            o.state = initial_state;
            o.covariance = o.Q;
        end
        
        function o = predict(o)
            o.predicted_state = o.f(o.state);
            o.predicted_covariance = o.F(o.state) * o.covariance * o.F(o.state)' + o.Q;
        end
        
        function o = update(o, observation)
            o.kalman_gain = o.predicted_covariance * o.H(o.predicted_state)' * inv(o.H(o.predicted_state) * o.predicted_covariance * o.H(o.predicted_state)' + o.R);
            o.state = o.predicted_state + o.kalman_gain * (observation - o.h(o.predicted_state));
            o.covariance = o.predicted_covariance - o.kalman_gain * o.H(o.predicted_state) * o.predicted_covariance;
        end
        
        % return the observation corresponding to the current state of the filter
        function observation = get_observation(o)
            observation = o.h(o.state);            
        end
        
        % return the predicted observation
        function predicted_observation = get_predicted_observation(o)
            predicted_observation = o.h(o.predicted_state);
        end 
    end
end

