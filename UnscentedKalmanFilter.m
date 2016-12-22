classdef UnscentedKalmanFilter
    % Implementation of a Unscented Kalman filter for track prediction
    % The state and observation equations are
    %           x_k+1 = f(x_k) + w_k
    %           z_k   = h(x_k) + v_k
    %           w ~ N(0,Q) meaning w is gaussian noise with covariance Q
    %           v ~ N(0,R) meaning v is gaussian noise with covariance R
    % Inputs:   f: function handle for f(x)
    %           x: "a priori" state estimate
    %           P: "a priori" estimated state covariance
    %           h: function handle for h(x)
    %           z: current measurement
    %           Q: process noise covariance
    %           R: measurement noise covariance
    % Output:   x: "a posteriori" state estimate
    %           P: "a posteriori" state covariance
    
    properties
        f; % the state update function
        h; % the observation function
        Q; % process noise covariance
        R; % measurement noise covariance

        state; % the current state
        covariance;
        predicted_state;
        predicted_observation;
        predicted_covariance;
        
        kalman_gain;
        cross_covariance;
        observation_covariance;
        
        alpha;
        ki;
        beta;
        c;
        Wm;
        Wc;
    end
    
    methods
        function o = UnscentedKalmanFilter(parameters, time, initial_observation)
            o.f = parameters.f;
            o.h = parameters.h;
            o.Q = parameters.Q;
            o.R = parameters.R;
            
            o.alpha = parameters.alpha;
            o.ki = parameters.ki;
            o.beta = parameters.beta;
            
            initial_state = [initial_observation', parameters.rest_of_initial_state']';
            o.state = initial_state;
            o.covariance = o.Q;
            
            dimension_state = length(initial_state);
            lambda = o.alpha^2 * (dimension_state + o.ki) - dimension_state;
            o.c = dimension_state + lambda;
            
            o.Wm = [lambda/o.c, 0.5/o.c + zeros(1, 2 * dimension_state)];
            o.Wc = o.Wm;
            o.Wc(1) = o.Wc(1) + (1 - o.alpha^2 + o.beta);
            o.c = sqrt(o.c);
        end
        
        function [y, transformed_sigmapoints, P, transformed_deviations] = ut(o, f, sigma_points, Wm, Wc, R)
            % Unscented Transformation
            % Input:
            %            f: nonlinear map used for the transformation
            % sigma_points: sigma points used for the unscented transformation
            %       Wm: weights for mean
            %       Wc: weights for covariance
            %        R: additive covariance
            % Output:
            %        y: transformed mean
            % transformed_sigmapoints : transformed sampling points
            %        P: transformed covariance
            %       Y1: transformed deviations
            
            dimension_state = size(sigma_points, 1);
            number_sigmapoints = size(sigma_points, 2);
            y = f(zeros(dimension_state, 1)); % find what dimension the output would have
            dimension_output = length(y);
            y = zeros(dimension_output, 1);
            
            transformed_sigmapoints = zeros(dimension_output, number_sigmapoints);
            
            for k=1:number_sigmapoints
                transformed_sigmapoints(:,k) = f(sigma_points(:,k));
                y = y + Wm(k) * transformed_sigmapoints(:,k);
            end
            
            transformed_deviations = transformed_sigmapoints - y(:, ones(1, number_sigmapoints));
            P = transformed_deviations * diag(Wc) * transformed_deviations' + R;
        end
        
        function sigma_points = sigma_points(o, x, P, c)
            % Sigma points around reference point
            % Inputs:
            %       x: reference point
            %       P: covariance
            %       c: coefficient
            % Output:
            %       X: Sigma points
            
            A = c * chol(P)';
            Y = x(:, ones(1,numel(x)));
            sigma_points = [x, Y + A, Y - A];
        end
        
        function o = predict(o)
            sigma_points = o.sigma_points(o.state, o.covariance, o.c);
            [o.predicted_state, X1, o.predicted_covariance, X2] = o.ut(o.f, sigma_points, o.Wm, o.Wc, o.Q);
            [o.predicted_observation, ~, o.observation_covariance, Z2] = o.ut(o.h, X1, o.Wm, o.Wc, o.R);
            o.cross_covariance = X2 * diag(o.Wc) * Z2';
        end
        
        function o = update(o, time, observation)
            o.kalman_gain = o.cross_covariance * inv(o.observation_covariance);
            o.state = o.predicted_state + o.kalman_gain*(observation-o.predicted_observation); 
            o.covariance = o.predicted_covariance - o.kalman_gain * o.cross_covariance'; 
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

