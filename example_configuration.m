% A sample configuration file

dt = 0.1;

dimension_observations = 3;

% parameters to be used for processing the input file with additional information
% the additional information can be independent of the number of observations/detections, such as in the case of
% pointing information, or it could be dependent on the number of observations/detections, such as in the case of
% snr. If the additional information is independent then we give the fixed columns in which the information is given
% If the additional information is dependent on the number of observations we give the number of such variable columns
% per observation as well as the offsets within each such set of observations + additional information.
inputfile_parameters.field_separator = ' ';
inputfile_parameters.time_column = 1;
inputfile_parameters.observation_column_start = 5;
inputfile_parameters.additional_information_fixedcols = {'pointinginformation'};
inputfile_parameters.additional_information_fixedcols_columns = {2:4};
inputfile_parameters.additional_information_varcols = {'snr'};
inputfile_parameters.additional_information_num_varcols_perobs = 1;
inputfile_parameters.additional_information_varcols_offsets = {4};

% filter parameters for Kalman Filter
filter_type = 'kalmanfilter';

filter_parameters.A = [1 0 0 dt 0 0 0 0 0;
                       0 1 0 0 dt 0 0 0 0;
                       0 0 1 0 0 dt 0 0 0;
                       0 0 0 1 0 0 0 0 0;
                       0 0 0 0 1 0 0 0 0;
                       0 0 0 0 0 1 0 0 0;
                       0 0 0 0 0 0 1 0 0;
                       0 0 0 0 0 0 0 1 0;
                       0 0 0 0 0 0 0 0 1];
                   
filter_parameters.C = [1 0 0 0 0 0 0 0 0;0 1 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0];

filter_parameters.Q = 1.1*eye(9);%[1 0 0
		               %0 1 0
                       %0 0 1];
                   
filter_parameters.R = 0.000001*eye(3);

filter_parameters.rest_of_initial_state = [0.1*randn(1);
                                           0.1*randn(1);
                                           0.1*randn(1);
                                           0.1*randn(1);
                                           0.1*randn(1);
                                           0.1*randn(1)];

% parameters for the gating method
gating_method_type = 'Rectangular';
gating_method_parameters.gate_width =10;

% parameters for JPDA 
data_association_type = 'JPDA';
data_association_parameters.detection_probability = 0.95;
data_association_parameters.false_alarm_rate = 0.0000005;

track_maintenance_type = 'NOutOfM';
track_maintenance_parameters.N = 1;
track_maintenance_parameters.M = 21;
track_maintenance_parameters.confirm_threshold = 5;
track_maintenance_parameters.confirm_M = 5;
track_maintenance_parameters.confirm_N = 1;


postprocessing_parameters.velocity_threshold_parameters.velocity_threshold = [0.00; 0.0;0.00]; 
postprocessing_parameters.velocity_threshold_parameters.direction = 'greater';
postprocessing_parameters.atleastN_parameters.N = 100;

visualization3D_parameters.filename_actual = 'input.txt';
visualization3D_parameters.filename_true = 'input_true.txt';
visualization3D_parameters.plot_input_actual = 1;
visualization3D_parameters.plot_input_true = 1;
visualization3D_parameters.plot_tracks = 1;
visualization3D_parameters.in_field_separator = ' ';
visualization3D_parameters.plottype_input= 'r.';
visualization3D_parameters.plottype_input_actual = 'r.';
visualization3D_parameters.plottype_input_true = 'bo';
visualization3D_parameters.plottype_track = 'k';
visualization3D_parameters.plot_coordinates = 'xyz';

metrics_parameters.compute_ospa=1;
metrics_parameters.compute_omat=1;
metrics_parameters.compute_hausdorff=1;
metrics_parameters.plot_metrics=1;
metrics_parameters.ospa_parameters.c=1000;
metrics_parameters.ospa_parameters.p=2;
metrics_parameters.omat_parameters.c=1000;
metrics_parameters.original_tracks_file='input_true.txt';
metrics_parameters.in_field_separator = ' ';
metrics_parameters.dimension_observations = 3;


post_MTT_run_sequence = {'atleastN','velocitythreshold','plot3D','computemetrics'};

post_MTT_run_parameters{1} = postprocessing_parameters;
post_MTT_run_parameters{2} = postprocessing_parameters;
post_MTT_run_parameters{3} = visualization3D_parameters;
post_MTT_run_parameters{4} = metrics_parameters;

