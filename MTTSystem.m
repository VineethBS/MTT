classdef MTTSystem
    % MTT system - models the complete MTT system consisting of the main
    % MTT (tracker), the configuration (through a configuration file), and
    % the data (through a data file).
    
    properties
        inputfile_parameters; % contains information about the formatting of the input file
        configuration_file; % string
        data_file; % string
        MTT; % MTT 
        dimension_observations; % int
        post_MTT_run_sequence;
        post_MTT_run_parameters;
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
            o.inputfile_parameters = inputfile_parameters;
            o.post_MTT_run_sequence = post_MTT_run_sequence;
            o.post_MTT_run_parameters = post_MTT_run_parameters;
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
                tokens = strsplit(line, o.inputfile_parameters.field_separator);
                o = o.run_once(tokens);
            end
        end
        
        % run_once - for each line that is read in, converts the obtained tokens to time and numeric tokens, makes a cell array of
        % observations with each element of the cell being an observation and runs the MTT tracker with this observation object.
        function o = run_once(o, tokens)
            numeric_tokens = zeros(1, length(tokens));
            for i = 1:length(tokens)
                numeric_tokens(i) = str2double(tokens{i});
            end
            
            % ---- Find the time from the line
            time = numeric_tokens(o.inputfile_parameters.time_column);
            
            % ---- Find additional information which are independent of the number of observations
            additional_information = [];
            for i = 1:length(o.inputfile_parameters.additional_information_fixedcols)
                information_type = o.inputfile_parameters.additional_information_fixedcols{i};
                if strcmp(information_type, 'pointinginformation')
                    additional_information.pointing_information = numeric_tokens(o.inputfile_parameters.additional_information_fixedcols_columns{i});
                end
            end
            
            % ---- Find all the observations and additional information from the line and arrange in an array
            observation_and_info_numeric_tokens = numeric_tokens(o.inputfile_parameters.observation_column_start:end);
            
            % If the number of numeric tokens is not a multiple of dimension_observations and the number of variable columns per 
            % observation then continue on to the next line
            dimension_per_observation_and_info = o.dimension_observations + o.inputfile_parameters.additional_information_num_varcols_perobs;
            if mod(length(observation_and_info_numeric_tokens), dimension_per_observation_and_info) ~= 0
                return;
            end
            
            num_observations = floor(length(observation_and_info_numeric_tokens)/dimension_per_observation_and_info); % this should be an integer
            % For example, if the numeric tokens were 10,20,SNR1, 30,10, SNR2, 20,30, SNR3  the observation info matrix should be [10 10 SNR1; 20 20 SNR2; 30 30 SNR3]
            observation_info_matrix = reshape(observation_and_info_numeric_tokens, dimension_per_observation_and_info, num_observations);
            
            % the observations to be fed into MTT should be a cell-array
            % each observation is a column vector. In the example above, [[10, 10]], [[20, 20]] would be elements of the
            % observations cell array
            observations = {};
            for i = 1:num_observations
                observations{i} = observation_info_matrix(1:o.dimension_observations, i);
            end
            
            % ---- Find additional information dependent on number of observations to be passed
            for i = 1:length(o.inputfile_parameters.additional_information_varcols)
                information_type = o.inputfile_parameters.additional_information_varcols{i};
                if strcmp(information_type, 'snr')
                    for j = 1:num_observations
                        additional_information.snr{j} = observation_info_matrix(o.inputfile_parameters.additional_information_varcols_offsets{i}, j);
                    end
                end
            end
            
            % ---- Now call the MTT's process one observation
            o.MTT = o.MTT.process_one_observation(time, observations, additional_information);
        end
        
        % run post processing, visualization, and reporting tasks according to the instructions in post_MTT_run_sequence
        function o = post_MTT_run(o)
            tracks = [o.MTT.list_of_tracks, o.MTT.list_of_inactive_tracks];
            for i = 1:length(o.post_MTT_run_sequence)
                instruction = o.post_MTT_run_sequence{i};
                if strcmp(instruction, 'atleastN')
                    temp = PostProcessing(o.post_MTT_run_parameters{i});
                    tracks = temp.find_tracks_atleast_N_detections(tracks); % tracks change here
                elseif strcmp(instruction, 'velocitythreshold')
                    temp = PostProcessing(o.post_MTT_run_parameters{i});
                    tracks = temp.find_tracks_velocity_threshold(tracks); % tracks change here
                elseif strcmp(instruction, 'plot1D')
                    temp = Visualization(o.post_MTT_run_parameters{i});
                    temp.plot_1D(tracks);
                elseif strcmp(instruction, 'plot3D')
                    temp = Visualization(o.post_MTT_run_parameters{i});
                    temp.plot_3D(tracks);
                elseif strcmp(instruction, 'savetracks')
                    temp = Reporting(o.post_MTT_run_parameters{i});
                    temp.save_tracks(tracks);
                elseif strcmp(instruction, 'computemetrics')
                    temp = Metrics(o.post_MTT_run_parameters{i});
                    temp.compute_metrics(tracks);
                end
            end
        end
    end
end

