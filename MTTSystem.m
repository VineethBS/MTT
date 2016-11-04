classdef MTTSystem
    % MTT system - models the complete MTT system consisting of the main
    % MTT (tracker), the configuration (through a configuration file), and
    % the data (through a data file).
    
    properties
        field_separator; % character
        configuration_file; % string
        data_file; % string
        MTT; % MTT 
        dimension_observations; % int
    end
    
    methods
        function o = MTTSystem(configuration_file, data_file)
            o.configuration_file = configuration_file;
            o.data_file = data_file;
            
            if exist(o.configuration_file, 'file') == 2
                run(o.configuration_file); % this will populate the local workspace with the configuration variables that we need
            else
                error('%s does not exist!', o.configuration_file);
                return;
            end
                
            % initialize the Multi Target Tracker object with the configuration parameters
            o.MTT = MultiTargetTracker(filter_type, filter_parameters, gating_method_type, gating_method_parameters, ...
                                       data_association_type, data_association_parameters, track_maintenance_type, track_maintenance_parameters);
                                   
            o.dimension_observations = dimension_observations;
            o.field_separator = field_separator;
        end
        
        % run - simulates the step by step running of the multi targets tracker. It reads the data file line by line. Each line is a
        % sequence of detections, each detection being again a sequence of co-ordinates. For example, 2 detections each with 3 co-ordinates
        % would look like 10,20,30,10,20,30 which correspond to (10,20,30) and (10,20,30).
        function o = run(o)
            if exist(o.data_file, 'file') == 2
                fh = fopen(o.data_file);
            else
                error('%s does not exist!', o.data_file);
                return
            end
            while 1
                line = fgetl(fh);
                if ~ischar(line)
                    break;
                end
                tokens = strsplit(line, o.field_separator);
                o = o.run_once(tokens);
            end
        end
        
        % run_once - for each line that is read in, converts the obtained tokens to time and numeric tokens, makes a cell array of
        % observations with each element of the cell being an observation and runs the MTT tracker with this observation object.
        function o = run_once(o, tokens)
            % convert all tokens to double
            numeric_tokens = zeros(1, length(tokens));
            for i = 1:length(tokens)
                numeric_tokens(i) = str2double(tokens{i});
            end
            
            time = numeric_tokens(1);
            numeric_tokens = numeric_tokens(2:end);
            
            % If the number of numeric tokens is not a multiple of dimension_observations then continue on to the next line
            if mod(length(numeric_tokens), o.dimension_observations) ~= 0
                return;
            end
            
            num_observations = floor(length(numeric_tokens)/o.dimension_observations); % this should be an integer
            % For example, if the numeric tokens were 10,20,30,10,20,30  the observation matrix should be [10 10; 20 20; 30 30]
            observation_matrix = reshape(numeric_tokens, o.dimension_observations, num_observations);
            
            % the observations to be fed into MTT should be a cell-array
            % each observation is a column vector
            observations = {};
            for i = 1:num_observations
                observations{i} = observation_matrix(:, i);
            end
            
            o.MTT = o.MTT.process_one_observation(time, observations);
        end
    end
end

