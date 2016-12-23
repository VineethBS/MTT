% A sample configuration file

dt = 0.05;

dimension_observations = 1;
num_of_observations = 100;
field_separator = ',';

% filter parameters for Kalman Filter
filter_type = 'kalmanfilter';

filter_parameters.A = [1 dt dt^2
                       0 1 dt
                       0 0 1];
                   
filter_parameters.C = [1 0 0];

filter_parameters.Q = [1 0 0;
                       0 1 0;
                       0 0 1];
                   
filter_parameters.R = 1;

filter_parameters.rest_of_initial_state = [0
                                           0];
                                       
% filter parameters for Multi Step Kalman Filter
filter_type = 'multistepkalmanfilter';

filter_parameters.A = [1 dt dt^2
                       0 1 dt
                       0 0 1];
                   
filter_parameters.C = [1 0 0];

filter_parameters.Q = [1 0 0;
                       0 1 0;
                       0 0 1];
                   
filter_parameters.R = 1;

filter_parameters.rest_of_initial_state = [0
                                           0];
filter_parameters.step_size = 1;

% filter parameters for Extended Kalman Filter
filter_type = 'extendedkalmanfilter';
filter_parameters.f = @(x) x;
filter_parameters.F = @(x) x;
filter_parameters.h = @(x) x;
filter_parameters.H = @(x) x;
filter_parameters.rest_of_initial_state = [0
                                           0];

filter_parameters.Q = [1 0 0;
                       0 1 0;
                       0 0 1];
                   
filter_parameters.R = 1;

% filter parameters for the Static Multi Modal Filter
filter_type = 'staticmultimodal';
filter_parameters.filters{1} = 'kalmanfilter';
filter_parameters.filterparameters{1}.A = [1 dt dt^2
    0 1 dt
    0 0 1];
filter_parameters.filterparameters{1}.C = [1 0 0];

filter_parameters.filterparameters{1}.Q = [1 0 0;
    0 1 0;
    0 0 1];
                   
filter_parameters.filterparameters{1}.R = 1;

filter_parameters.filterparameters{1}.rest_of_initial_state = [0
    0];
filter_parameters.filter_prior_probabilities = [1];


% parameters for the gating method
gating_method_type = 'Rectangular';
gating_method_parameters.gate_width = 1;

% parameters for heuristic data association
data_association_type = 'Heuristic';
data_association_parameters.epsilon = 0.1;

% parameters for JPDA 
data_association_type = 'JPDA';
data_association_parameters.detection_probability = 0.9;
data_association_parameters.false_alarm_rate = 0.05;

% parameters for track maintenance
track_maintenance_type = 'NOutOfM';
track_maintenance_parameters.N = 2;
track_maintenance_parameters.M = 5;
track_maintenance_parameters.confirm_threshold = 3;
track_maintenance_parameters.confirm_M = 3;
track_maintenance_parameters.confirm_N = 1;

% parameters for post processing

% velocity based thresholding
postprocessing_parameters.velocity_threshold_parameters.velocity_threshold = 10;
postprocessing_parameters.velocity_threshold_parameters.direction = 'greater';
% remove tracks based on number of associations
postprocessing_parameters.atleastN_parameters.N = 10;

% parameters for visualization
visualization1D_parameters.filename = 'example_data.csv';
visualization1D_parameters.plot_input = 1;
visualization1D_parameters.plot_tracks = 1;
visualization1D_parameters.in_field_separator = ',';
visualization1D_parameters.plottype_input = 'ro';
visualization1D_parameters.plottype_track = 'k';

% parameters for computation of metrics
metriccomputation_parameters.original_tracks_file = 'actual_object_trajectories.csv';
metriccomputation_parameters.in_field_separator = ',';
metriccomputation_parameters.dimension_observations = 3;
metriccomputation_parameters.compute_ospa = 1;
metriccomputation_parameters.compute_omat = 1;
metriccomputation_parameters.compute_hausdorff = 1;
metriccomputation_parameters.plot_metrics = 1;
metriccomputation_parameters.ospa_parameters.c = 10;
metriccomputation_parameters.ospa_parameters.p = 0.5;
metriccomputation_parameters.omat_parameters.c = 10;

% how to run the post MTT processing sequence
post_MTT_run_sequence = {'atleastN','velocitythreshold','plot1D', 'computemetrics'};
post_MTT_run_parameters{1} = postprocessing_parameters;
post_MTT_run_parameters{2} = postprocessing_parameters;
post_MTT_run_parameters{3} = visualization1D_parameters;
post_MTT_run_parameters{4} = metriccomputation_parameters;

