% A sample configuration file

dt = 0.05;

dimension_observations = 1;
num_of_observations = 100;
field_separator = ',';

filter_type = 'Kalman';

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

gating_method_type = 'Rectangular';
gating_method_parameters.gate_width = 1;

% parameters for heuristic data association
data_association_type = 'Heuristic';
data_association_parameters.epsilon = 0.1;

% parameters for JPDA 
data_association_type = 'JPDA';
data_association_parameters.detection_probability = 0.9;
data_association_parameters.false_alarm_rate = 0.05;

track_maintenance_type = 'NOutOfM';
track_maintenance_parameters.N = 2;
track_maintenance_parameters.M = 5;
track_maintenance_parameters.confirm_threshold = 3;
track_maintenance_parameters.confirm_M = 3;
track_maintenance_parameters.confirm_N = 1;

postprocessing_parameters.velocity_threshold_parameters.velocity_threshold = 10;
postprocessing_parameters.velocity_threshold_parameters.direction = 'greater';
postprocessing_parameters.atleastN_parameters.N = 10;

visualization1D_parameters.filename = 'example_data.csv';
visualization1D_parameters.plot_input = 1;
visualization1D_parameters.plot_tracks = 1;
visualization1D_parameters.in_field_separator = ',';
visualization1D_parameters.plottype_input = 'ro';
visualization1D_parameters.plottype_track = 'k';

post_MTT_run_sequence = {'atleastN','velocitythreshold','plot1D'};
post_MTT_run_parameters{1} = postprocessing_parameters;
post_MTT_run_parameters{2} = postprocessing_parameters;
post_MTT_run_parameters{3} = visualization1D_parameters;

