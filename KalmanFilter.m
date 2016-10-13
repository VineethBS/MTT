classdef KalmanFilter
    % Implementation of a Kalman filter for track prediction
    %   Kalman filter equations
    %   x_{k + 1} = A x_{k} + w_{k}; where x_{k} is the state
    %   y_{k} = C x_{k} + v_{k}; where y_{k} is the observation
    %   Both w_{k} and v_{k} are jointly Gaussian vectors with zero mean
    %   and covariance matrices Q and Rs
    properties
        A;
        C;
        Q;
        R;
        state;
        covariance;
        predicted_state;
        predicted_covariance;
        kalman_gain;
    end
    
    methods
        function o = KalmanFilter(A, C, Q, R, initial_state)
            o.A = A;
            o.C = C;
            o.Q = Q;
            o.R = R;
            o.state = initial_state;
            o.covariance = Q;
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
    end
    
end

