classdef AlphaBetaFilter
    % Implementation of a AlphaBeta filter for track prediction
    %   AlphaBeta filter equations
    %   x_{k + 1} = x_{k} + alpha * r_{k}; where x_{k} is the state
    
    %   y_{k} = x_{k}
    %   Both w_{k} and v_{k} are jointly Gaussian vectors with zero mean
    %   and covariance matrices Q and R
    properties
        A;
        C;
        alpha;
        beta;
        gain_observations;
        gain_velocity;
        state; % the current state
        predicted_state;
    end
    
    methods
        % gobs and gvel are vectors with all ones of each with the dimension of observations
        function o = AlphaBetaFilter(parameters, time, initial_observation)
            o.A = parameters.A;
            o.C = parameters.C;
            o.gain_observations = parameters.gain_observations;
            o.gain_velocity = parameters.gain_velocity;
            o.alpha = parameters.alpha;
            o.beta = parameters.beta;
            initial_state = [initial_observation', parameters.rest_of_initial_state']';
            o.state = initial_state;
        end
        
        function o = predict(o)
            o.predicted_state = o.A * o.state;
        end
        
        function o = update(o, time, observation)
            residual = observation - o.get_observation();
            residual = [residual;residual];
            gain = [o.alpha * o.gain_observations; o.beta * o.gain_velocity] .* residual;
            o.state = o.predicted_state + gain;          
        end
        
        % return the observation corresponding to the current state of the filter
        function observation = get_observation(o)
            observation = o.C * o.state;
        end
        
        function predicted_observation = get_predicted_observation(o)
            predicted_observation = o.C * o.predicted_state;
        end
    end
end

