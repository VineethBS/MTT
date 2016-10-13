classdef KalmanFilter
    % Implementation of a Kalman filter for track prediction
    %   Kalman filter equations
    %   x_{k + 1} = A x_{k} + w_{k}
    %   y_{k} = C x_{k} + v_{k}
    %   Both w_{k} and v_{k} are jointly Gaussian vectors with zero mean
    %   and covariance matrices Q and Rs
    properties
        A;
        C;
        Q;
        R;
    end
    
    methods
    end
    
end

