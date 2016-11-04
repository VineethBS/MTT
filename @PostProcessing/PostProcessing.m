classdef PostProcessing
    % PostProcessing - contains methods for post processing of the tracks to extract "useful" tracks
    %   We define useful tracks in two ways - either those tracks which have at least N associations or those tracks
    %   which have a velocity more than or less than a threshold.
    
    properties
        velocity_threshold_parameters;
        atleastN_parameters;
    end
    
    methods
        function o = PostProcessing(parameters)
            o.velocity_threshold_parameters = parameters.velocity_threshold_parameters;
            o.atleastN_parameters = parameters.atleastN_parameters;
        end
        
        valid_tracks = find_tracks_atleast_N_detections(o, tracks);
        valid_tracks = find_tracks_velocity_threshold(o, tracks);
    end
    
end

