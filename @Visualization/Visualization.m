classdef Visualization
    % Visualization - block for visualization (and saving) experiment output
    
    properties
        visualization_parameters;
    end
    
    methods
        function o = Visualization(parameters)
            o.visualization_parameters = parameters;
        end
        
        plot_1D(o, tracks);
        plot_3D(o, tracks);
    end
    
end

