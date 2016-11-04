classdef Visualization
    % Visualization - block for visualization (and saving) experiment output
    
    properties
        visualization_type;
        visualization_parameters;
    end
    
    methods
        function o = Visualization(type, parameters)
            o.visualization_type = type;
            o.visualization_parameters = parameters;
        end
        
        plot_1D(o, tracks);
    end
    
end

