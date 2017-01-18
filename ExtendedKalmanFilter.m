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
        function o = ExtendedKalmanFilter(parameters, time, initial_observation)
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
        
        function o = update(o, time, observation)
            o.kalman_gain = o.predicted_covariance * o.H(o.predicted_state)' * inv(o.H(o.predicted_state) * o.predicted_covariance * o.H(o.predicted_state)' + o.R);
            o.state = o.predicted_state + o.kalman_gain * (observation - o.h(o.predicted_state));
            o.covariance = o.predicted_covariance - o.kalman_gain * o.H(o.predicted_state) * o.predicted_covariance;
        end
        
         function o = update_with_multiple_observations(o, time, observations, observation_probability, probability_no_assoc_observation)
            num_observations = length(observations);
            predicted_observation = o.get_predicted_observation();
            combined_innovation = zeros(length(predicted_observation), 1);
            innovation_sample_correlation = zeros(length(predicted_observation)); % matrix of size num of dimensions x num of dimensions
            for i = 1:num_observations
                current_observation = observations{i};
                current_innovation = current_observation - predicted_observation;
                combined_innovation = combined_innovation + observation_probability(i) * current_innovation;
                innovation_sample_correlation = innovation_sample_correlation + observation_probability(i) * (current_innovation * current_innovation');
            end
            innovation_sample_covariance = innovation_sample_correlation - (combined_innovation * combined_innovation');
            
            % updates using the combined innovation
            observation_covariance = o.H(o.predicted_state) * o.predicted_covariance * o.H(o.predicted_state)' + o.R;
            o.kalman_gain = o.predicted_covariance * o.H(o.predicted_state)' * inv(observation_covariance);
            o.state = o.predicted_state + o.kalman_gain * combined_innovation;
            o.covariance = o.predicted_covariance - (1 - probability_no_assoc_observation) * o.kalman_gain * o.H(o.predicted_state) * o.predicted_covariance + ...
                o.kalman_gain * innovation_sample_covariance * o.kalman_gain';
         end
        
        % return the observation corresponding to the current state of the filter
        function observation = get_observation(o)
            observation = o.h(o.state);            
        end
        
        % return the predicted observation
        function predicted_observation = get_predicted_observation(o)
            predicted_observation = o.h(o.predicted_state);
        end 
        
       % return the innovation covariance for the observations
        function innovation_covariance = get_innovation_covariance(o)
            innovation_covariance = o.H(o.predicted_state) * o.predicted_covariance * o.H(o.predicted_state)' + o.R;
        end
    end
end

