classdef MTTSystem
    % MTT system - models the complete MTT system consisting of the main
    % MTT (tracker), the configuration (through a configuration file), and
    % the data (through a data file).
    
    properties
        configuration_file; % string
        data_file; % string
        MTT; % MTT 
        dimension_observations; % int
        num_of_observations; % int
    end
    
    methods
        function o = MTTSystem(configuration_file, data_file)
            o.configuration_file = configuration_file;
            o.data_file = data_file;
            
            run(o.configuration_file); % this will populate the local workspace with the configuration variables that we need
            
            o.MTT = MultiTargetTracker(filter_type, filter_parameters, gating_method_type, gating_method_parameters, ...
                                       data_association_type, data_association_parameters, track_maintenance_type, track_maintenance_parameters);
                                   
            o.dimension_observations = dimension_observations;
            o.num_of_observations = num_of_observations;
        end
        
        function o = run(o)
            fh = fopen(o.data_file);
            while 1
                line = fgetl(fh);
                if ~ischar(line)
                    break;
                end
                tokens = strsplit(line, ',');
                % convert all tokens to double
                numeric_tokens = zeros(1, length(tokens));
                for i = 1:length(tokens)
                    numeric_tokens(i) = str2double(tokens{i});
                end
                
                time = numeric_tokens(1);
                numeric_tokens = numeric_tokens(2:end);
                
                % If the number of tokens other than time is not a multiple of dimension_observations then continue on to the next line
                if mod(length(tokens) - 1, o.dimension_observations) ~= 0
                    continue;
                end
                
                num_observations = floor((length(tokens) - 1)/o.dimension_observations);
                observation_matrix = reshape(numeric_tokens, o.dimension_observations, num_observations);
                
                % the observations to be fed into MTT should be a
                % cell-array
                observations = {};
                for i = 1:num_observations
                    observations{i} = observation_matrix(:, i);
                end
                
                o.MTT = o.MTT.process_one_observation(time, observations);
            end
        end
    end
end

