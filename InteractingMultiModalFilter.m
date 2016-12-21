classdef InteractingMultiModalFilter
    % Implementation of a Interacting Multi Modal filter for track prediction
    %   A interacting multi modal filter consists of a number of filters
    %   Each filter has an associated probability of being the correct filter
    %   A weighted combination of the constituent filters is used for state estimation and prediction
    %   The implementation follows the development of IMM in the book by Estimation with applications to tracking by
    %   Bar-Shalom.
    
    % TODO: Can only use rectangular or spherical gating with this implementation of IMM. Extend to use with JPDA
    
    properties
        filters; % cell array containing the filters making up the multi modal filter
        filter_posterior_probabilities;
        state_transition_probabilities;
        num_filters;
        mixed_filter_inputs_state;
        mixed_filter_inputs_covariance;
        normalization_cbar;
    end
    
    methods
        % currently the IMM filter can only use Kalman filters as the component filters
        % we have to make sure that the state dimension of the Kalman filters are all the same
        function o = InteractingMultiModalFilter(parameters, time, initial_observation)
            o.num_filters = length(parameters.filters);
            for i = 1:o.num_filters
                if strcmp(parameters.filters{i}, 'kalmanfilter')
                    p.A = parameters.filterparameters{i}.A;
                    p.C = parameters.filterparameters{i}.C;
                    p.Q = parameters.filterparameters{i}.Q;
                    p.R = parameters.filterparameters{i}.R;
                    p.rest_of_initial_state = parameters.filterparameters{i}.rest_of_initial_state;
                    o.filters{i} = KalmanFilter(p, time, initial_observation);
                end
            end
            o.filter_posterior_probabilities = parameters.filter_prior_probabilities; % the posterior probabilities are initialized with the prior
            o.state_transition_probabilities = parameters.state_transition_probabilities;
        end
        
        % before the prediction step, the interaction/mixing of the last states from the component KFs are used to
        % obtain new states and covariances
        function o = predict(o)
            o = o.mix_states();
            o = o.set_mixed_inputs();
            for i = 1:o.num_filters
                o.filters{i} = o.filters{i}.predict();
            end
        end
        
        % update for a single observation
        % the update step is split into two, each component filter has to be updated separately
        function o = update(o, time, observation)
            % Calculation of likelihoods and updation of posterior probability
            for i = 1:o.num_filters                
                % Step 1 - updation of posterior probability for the component filters
                predicted_observation = o.filters{i}.get_predicted_observation();
                innovation = observation - predicted_observation;
                innovation_covariance = o.filters{i}.get_innovation_covariance();
                likelihood = mvnpdf(innovation, zeros(o.num_filters, 1), innovation_covariance);
                o.filter_posterior_probabilities(i) = o.normalization_cbar(i) * likelihood;
                % Step 2 - updation of each filter
                o.filters{i} = o.filters{i}.update(time, observation);
            end
            o.filter_posterior_probabilities = o.filter_posterior_probabilities / sum(o.filter_posterior_probabilities);
        end
            
        % mixing or interaction of the states for the IMM filter
        function o = mix_states(o)
            o.normalization_cbar = o.state_transition_probabilities' * o.filter_posterior_probabilities;
            mu_ij = zeros(o.num_filters, o.num_filters);
            for i = 1:o.num_filters
                for j = 1:o.num_filters
                    mu_ij(i, j) = o.state_transition_probabilities(i, j) * o.filter_posterior_probabilities(j) / o.normalization_cbar(j);
                end
            end
            
            o.mixed_filter_inputs_state = [];
            o.mixed_filter_inputs_covariance = [];
            
            for i = 1:o.num_filters
                for j = 1:o.num_filters
                    filter_last_state = o.filters{i}.get_state();
                    if j == 1
                        o.mixed_filter_inputs_state{i} = mu_ij(j, i) * filter_last_state;
                    else
                        o.mixed_filter_inputs_state{i} = o.mixed_filter_inputs_state{i} + mu_ij(j, i) * filter_last_state;
                    end
                end
            end 
            
            for i = 1:o.num_filters
                for j = 1:o.num_filters
                    filter_last_state = o.filters{i}.get_state();
                    state_difference = filter_last_state - o.mixed_filter_inputs_state{i};
                    if j == 1
                        o.mixed_filter_inputs_covariance{i} = mu_ij(j, i) * (o.filters{i}.get_covariance() + state_difference * state_difference');
                    else
                        o.mixed_filter_inputs_covariance{i} = o.mixed_filter_inputs_covariance{i} + ...
                            mu_ij(j, i) * (o.filters{i}.get_covariance() + state_difference * state_difference');
                    end
                end
            end
        end

        % set the filter state and covariance to be the mixed state and covariance
        function o = set_mixed_inputs(o)
            for i = 1:o.num_filters
                o.filters{i} = o.filters{i}.set_state(o.mixed_filter_inputs_state{i});
                o.filters{i} = o.filters{i}.set_covariance(o.mixed_filter_inputs_covariance{i});
            end
        end
        
        % return the observation corresponding for the multi modal filter.
        % the observations from all the filters are combined using the posterior probabilities
        function combined_observation = get_observation(o)
            for i = 1:o.num_filters
                observation = o.filters{i}.get_observation();
                if i == 1
                    combined_observation = o.filter_posterior_probabilities(i) * observation;
                else
                    combined_observation = combined_observation + o.filter_posterior_probabilities(i) * observation;
                end
            end
        end
        
        % return the predicted observation
        % the predicted observations from all the filters are combined using the posterior probabilities
        % note that in order to get the "correct" predicted observations, this has to be called before the update
        % function is called
        function combined_predicted_observation = get_predicted_observation(o)
            for i = 1:o.num_filters
                predicted_observation = o.filters{i}.get_predicted_observation();
                if i == 1
                    combined_predicted_observation = o.filter_posterior_probabilities(i) * predicted_observation;
                else
                    combined_predicted_observation = combined_predicted_observation + o.filter_posterior_probabilities(i) * predicted_observation;
                end
            end
        end
        
        % return the innovation covariance for the observations
        function innovation_covariance = get_innovation_covariance(o)
            innovation_covariance = 0;
        end
    end
end