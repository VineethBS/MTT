classdef Metrics
    % Reporting - block for generating reports and saving information for further processing
    
    properties
        original_tracks_file;
        in_field_separator;
        dimension_observations;
        
        compute_ospa;
        compute_omat;
        compute_hausdorff;
        
        plot_metrics;
        
        ospa_parameters;
        omat_parameters;
        
        time_sequence;
        ospa_metric;
        omat_metric;
        hausdorff_metric;
        
        average_ospa_metric;
        average_omat_metric;
        average_hausdorff_metric;
    end
    
    methods
        function o = Metrics(parameters)
            o.original_tracks_file = parameters.original_tracks_file;
            o.in_field_separator = parameters.in_field_separator;
            o.dimension_observations = parameters.dimension_observations;
            
            o.compute_ospa = parameters.compute_ospa;
            o.compute_omat = parameters.compute_omat;
            o.compute_hausdorff = parameters.compute_hausdorff;
            
            o.plot_metrics = parameters.plot_metrics;
            
            o.ospa_parameters.c = parameters.ospa_parameters.c;
            o.ospa_parameters.p = parameters.ospa_parameters.p;
            o.omat_parameters.c = parameters.omat_parameters.c;
            
            o.time_sequence = [];
            o.ospa_metric = [];
            o.omat_metric = [];
            o.hausdorff_metric = [];
            
            o.average_ospa_metric = 0;
            o.average_omat_metric = 0;
            o.average_hausdorff_metric = 0;
        end
        
        o = compute_metrics(o, tracks);
        dist = find_ospa_metric(o, x, y, c, p);
        dist = find_omat_metric(o, x, y, c);
        dist = find_hausdorff_metric(o, x, y);
        [assignment, cost] = hungarian_algorithm(o, D);
    end
end
