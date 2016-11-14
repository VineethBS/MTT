classdef Reporting
    % Reporting - block for generating reports and saving information for further processing
    
    properties
        reporting_parameters;
    end
    
    methods
        function o = Reporting(parameters)
            o.reporting_parameters = parameters;
        end
        
        function save_tracks(o, tracks)
           save(o.reporting_parameters.savefilename, 'tracks'); 
        end
    end
    
end
