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

data_association_type = 'Heuristic';
data_association_parameters.epsilon = 0.1;

track_maintenance_type = 'NOutOfM';
track_maintenance_parameters.N = 2;
track_maintenance_parameters.M = 5;
track_maintenance_parameters.confirm_threshold = 3;
track_maintenance_parameters.confirm_M = 3;
track_maintenance_parameters.confirm_N = 1;

postprocessing_parameters.velocity_threshold_parameters.velocity_threshold = 10;
postprocessing_parameters.velocity_threshold_parameters.direction = 'greater';
postprocessing_parameters.atleastN_parameters.N = 10;


