classdef MultiStepUpdateKalmanFilter
    % Implementation of a Kalman filter with update over multiple steps for track prediction
    %   Kalman filter equations. This filter is to be used for the situations where observations
    %   are only obtained at certain time instants.
    %   x_{k + 1} = A x_{k} + w_{k}; where x_{k} is the state
    %   y_{k} = C x_{k} + v_{k}; where y_{k} is the observation
    %   Both w_{k} and v_{k} are jointly Gaussian vectors with zero mean
    %   and covariance matrices Q and R. The dynamics and the noise covariances
    %   can change with time
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
        step_size; % the step size for time
        last_time; % the last time at which update happened
    end
    
    methods
        function o = MultiStepUpdateKalmanFilter(parameters, time, initial_observation)
            o.A = parameters.A;
            o.C = parameters.C;
            o.Q = parameters.Q;
            o.R = parameters.R;
            o.step_size = parameters.step_size;
            initial_state = [initial_observation', parameters.rest_of_initial_state']';
            o.state = initial_state;
            o.covariance = o.Q;
            o.last_time = time;
        end
        
        function o = predict(o)
            o.predicted_state = o.A * o.state;
            o.predicted_covariance = o.A * o.covariance * o.A' + o.Q;
        end
        
        % state update for a single observation - such as in the case of GNN
        function o = update(o, time, observation)
            time_difference = time - o.last_time;
            num_steps = time_difference / o.step_size;
            num_steps = num_steps - 1;
            for i = 1:num_steps
                o = o.update_internal(o.get_predicted_observation());
                o = o.predict();
            end
            
            o = o.update_internal(observation);
            o.last_time = time;
        end
        
        % internal function for updating the KF with the observation
        function o = update_internal(o, observation)
            o.kalman_gain = o.predicted_covariance * o.C' * inv(o.C * o.predicted_covariance * o.C' + o.R);
            o.state = o.predicted_state + o.kalman_gain * (observation - o.C * o.predicted_state);
            o.covariance = o.predicted_covariance - o.kalman_gain * o.C * o.predicted_covariance;
        end
        % state update for multiple observations; each observation is associated with a probability
        % observations is a cell array of the set of observations to be used to update the filter
        % observation probability is a vector of probabilities - with length = the number of observations. Entries give
        % the probability of an observation being associated with this track.
        % the probability that there is no observation associated with this track is in probability_no_assoc_observation
        % This update equation is from "Sonar Tracking of Multiple Targets using JPDA" - Fortmann et al.
        % Note that there is an error in eqs 2.12 (the transpose of the Wk term has to be taken)
        % Note that under JPDA the update in the posterior probability is only approximated by the state and covariance
        % updates.
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
            observation_covariance = o.C * o.predicted_covariance * o.C' + o.R;
            o.kalman_gain = o.predicted_covariance * o.C' * inv(observation_covariance);
            o.state = o.predicted_state + o.kalman_gain * combined_innovation;
            o.covariance = o.predicted_covariance - (1 - probability_no_assoc_observation) * o.kalman_gain * o.C * o.predicted_covariance + ...
                o.kalman_gain * innovation_sample_covariance * o.kalman_gain';
        end
            
        % return the observation corresponding to the current state of the filter
        function observation = get_observation(o)
            observation = o.C * o.state;
        end
        
        % return the predicted observation
        function predicted_observation = get_predicted_observation(o)
            predicted_observation = o.C * o.predicted_state;
        end 
        
        % return the innovation covariance for the observations
        function innovation_covariance = get_innovation_covariance(o)
            innovation_covariance = o.C * o.predicted_covariance * o.C' + o.R;
        end
    end
end