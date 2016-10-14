classdef MTTSystem
    % Implementation of the complete MTT System
        
    properties
        configuration_file;
        data_file;
        MTT;
        dimension_observations;
        num_of_observations;
    end
    
    methods
        function o = MTTSystem(configuration_file, data_file)
            o.configuration_file = configuration_file;
            o.data_file = data_file;
            
            run(o.configuration_file);
            
            o.MTT = MultiTargetTracker(filter_type, filter_parameters, gating_method_type, gating_method_parameters, ...
                                       data_association_type, data_association_parameters);
                                   
            o.dimension_observations = dimension_observations;
            o.num_of_observations = num_of_observations;
        end
        
        function run(start_time, end_time)
            fh = fopen(o.data_file);
            while 1
                line = fgetl(fh);
                if ~ischar(line)
                    break;
                end
                tokens = strsplit(line, ',');
                time = str2double(tokens{1});
                
                if (time < start_time) || (time > end_time)
                    continue;
                end
                
                % If the number of tokens other than time is not a multiple
                % of dimension_observations then continue on to the next
                % line
                if mod(length(tokens) - 1, o.dimension_observations) ~= 0
                    continue;
                end
                
                num_of_observations = floor((length(tokens) - 1)/o.dimension_observations);
                observations = {}
                for i = 1:num_observations
                    observation = zeros(o.dimension_observations, 1);
                    for j = 1:o.dimension_observations
                        observation(j) = str2double(tokens{(i - 1) * num_observations + j});
                    end
                    observations{i} = observation;
                end
                
                o.MTT.process_one_observation(observations);
            end
        end
    end
    
end

