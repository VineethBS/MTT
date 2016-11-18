classdef StaticMultiModalFilter
    % Implementation of a Static Multi Modal filter for track prediction
    %   A static multi modal filter consists of a number of filters
    %   Each filter has an associated probability of being the correct filter
    %   A weighted combination of the constituent filters is used for state estimation and prediction
    properties
        filters; % cell array containing the filters making up the multi modal filter
        filter_posterior_probabilities;
        state; % this is a combined state - combined by using the posterior probabilities
        covariance; % this is a covariance obtained by a combination
    end
    
    methods
        function o = StaticMultiModalFilter(parameters, initial_observation)
            num_filters = length(parameters.filters);
            for i = 1:num_filters
                if strcmp(parameters.filters{i}, 'kalmanfilter')
                    p.A = parameters.filterparameters{i}.A;
                    p.C = parameters.filterparameters{i}.C;
                    p.Q = parameters.filterparameters{i}.Q;
                    p.R = parameters.filterparameters{i}.R;
                    p.rest_of_initial_state = parameters.filterparameters{i}.rest_of_initial_state;
                    o.filters{i} = KalmanFilter(p, initial_observation);
                end
            end
            o.filter_posterior_probabilities = parameters.filter_prior_probabilities; % the posterior probabilities are initialized with the prior
            o.state = initial_state;
            o.covariance = o.Q;
        end
        
        function o = predict(o)
            o.predicted_state = o.A * o.state;
            o.predicted_covariance = o.A * o.covariance * o.A' + o.Q;
        end
        
        % state update for a single observation - such as in the case of GNN
        function o = update(o, observation)
            o.kalman_gain = o.predicted_covariance * o.C' * inv(o.C * o.predicted_covariance * o.C' + o.R);
            o.state = o.predicted_state + o.kalman_gain * (observation - o.C * o.predicted_state);
            o.covariance = o.predicted_covariance - o.kalman_gain * o.C * o.predicted_covariance;
        end
        
        % return the observation corresponding for the multi modal filter.
        % the observations from all the filters are combined using the posterior probabilities
        function combined_observation = get_observation(o)
            num_filters = length(o.filters);
            for i = 1:num_filters
                observation = o.filters{i}.get_observation();
                combined_observation = combined_observation + o.filter_posterior_probabilities(i) * observation;
            end
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