function plot_3D(o,tracks)

filename_actual = o.visualization_parameters.filename_actual;
filename_true = o.visualization_parameters.filename_true;
plot_coordinates=o.visualization_parameters.plot_coordinates;
plot_input_actual = o.visualization_parameters.plot_input_actual;
plot_input_true = o.visualization_parameters.plot_input_true;
plot_tracks = o.visualization_parameters.plot_tracks;
plot_tracks_predicted = o.visualization_parameters.plot_tracks_predicted;
get_error_plot= o.visualization_parameters.get_error_plot;
in_field_separator = o.visualization_parameters.in_field_separator;
plottype_input = o.visualization_parameters.plottype_input; 
plottype_input_actual = o.visualization_parameters.plottype_input_actual; 
plottype_input_true = o.visualization_parameters.plottype_input_true;
plottype_track_filtered = o.visualization_parameters.plottype_track_filtered;
plottype_track_predicted = o.visualization_parameters.plottype_track_predicted;

dimension_observations = 3;

if exist(filename_actual, 'file') == 2
    fh = fopen(filename_actual);
else
    error('%s does not exist!', filename_actual);
    return;
end

figure(1);
subplot(3, 1, 1);
title('Range(Km)');
xlabel('Time(s)');
grid on;

hold on;
subplot(3, 1, 2);
title('Azimuth(rad)');
xlabel('Time(s)');
grid on;

hold on;
subplot(3, 1, 3);
title('Elevation(rad)');
xlabel('Time(s)');
grid on;

hold on;
h_display={}; %holds legends

h=[]; %holds plot color
input_actual_x=[];
input_actual_y=[];
input_actual_z=[];
if plot_input_actual == 1
    h_input_actual=[];
    h_display{end+1}='Noisy'; %legend value
    while 1
        line = fgetl(fh);
        if ~ischar(line)
            break;
        end
        
        tokens = strsplit(line, in_field_separator);
        % convert all tokens to double
        numeric_tokens = zeros(1, length(tokens));
        for i = 1:length(tokens)
            numeric_tokens(i) = str2double(tokens{i});
        end
        
        time = numeric_tokens(1);
        numeric_tokens = numeric_tokens(2:end);
        % If the number of numeric tokens is not a multiple of dimension_observations then continue on to the next line
        if mod(length(numeric_tokens), dimension_observations) ~= 0
            continue;
        end
        
        
        num_observations = floor(length(numeric_tokens)/dimension_observations); % this should be an integer
        observation_matrix = reshape(numeric_tokens, dimension_observations, num_observations);
        %%% raghava remove zero observation
        observation_matrix(:,~any(observation_matrix,1)) = []; %%%removes columns ie observations with zero
        [~,num_observations] = size(observation_matrix);
        if(num_observations ==1)
            observation_matrix(~any(observation_matrix,2),:) = []; %%%removes rows ie if all observations zero
            [~,num_observations] = size(observation_matrix);
        end

        %%%%
        
        for i = 1:num_observations
%             observations = observation_matrix(:, i);
            
           if strcmp(plot_coordinates,'xyz')
            [observations_rae(2,:),observations_rae(3,:),observations_rae(1,:)]=cart2sph(observation_matrix(1, i),observation_matrix(2, i),observation_matrix(3, i));
            input_actual_x(end+1,1)= observation_matrix(1, i);
            input_actual_y(end+1,1)= observation_matrix(2, i);
            input_actual_z(end+1,1)= observation_matrix(3, i);
           else
               [input_actual_x(end+1,1), input_actual_y(end+1,1),input_actual_z(end+1,1) ]=sph2cart(observation_matrix(2, i),observation_matrix(3, i),observation_matrix(1, i));
               observations_rae(1,:)=observation_matrix(1, i);
               observations_rae(2,:)=observation_matrix(2, i);
               observations_rae(3,:)=observation_matrix(3, i);
               
           end
           if prod(observations_rae > 0) %%% raghava
                for j = 1:dimension_observations
                    subplot(3, 1, j);
                    h_input_actual(end+1)=plot(time, observations_rae(j,:), plottype_input_actual);
                end
           end
        end
    end
    
    
    
    fclose(fh);
    h(end+1)=h_input_actual(1); %,since all plots has same color, the color of 1st plot taken
end

if exist(filename_true, 'file') == 2
    fh = fopen(filename_true);
else
    error('%s does not exist!', filename_true);
    return;
end

input_true_x=[];
input_true_y=[];
input_true_z=[];
if plot_input_true == 1
    h_input_true=[];
    h_display{end+1}='True'; %legend value
    while 1
        line = fgetl(fh);
        if ~ischar(line)
            break;
        end
        
        tokens = strsplit(line, in_field_separator);
        % convert all tokens to double
        numeric_tokens = zeros(1, length(tokens));
        for i = 1:length(tokens)
            numeric_tokens(i) = str2double(tokens{i});
        end
        
        time = numeric_tokens(1);
        numeric_tokens = numeric_tokens(2:end);
        % If the number of numeric tokens is not a multiple of dimension_observations then continue on to the next line
        if mod(length(numeric_tokens), dimension_observations) ~= 0
            continue;
        end
        
        
        num_observations = floor(length(numeric_tokens)/dimension_observations); % this should be an integer
        observation_matrix = reshape(numeric_tokens, dimension_observations, num_observations);
        %%% raghava remove zero observation
        observation_matrix(:,~any(observation_matrix,1)) = []; %%%removes columns ie observations with zero
        [~,num_observations] = size(observation_matrix);
        if(num_observations ==1)
            observation_matrix(~any(observation_matrix,2),:) = []; %%%removes rows ie if all observations zero
            [~,num_observations] = size(observation_matrix);
        end

        %%%%
        
        for i = 1:num_observations
           if strcmp(plot_coordinates,'xyz')
            [observations_rae(2,:),observations_rae(3,:),observations_rae(1,:)]=cart2sph(observation_matrix(1, i),observation_matrix(2, i),observation_matrix(3, i));
            input_true_x(end+1,1)= observation_matrix(1, i);
            input_true_y(end+1,1)= observation_matrix(2, i);
            input_true_z(end+1,1)= observation_matrix(3, i);
           else
               [input_true_x(end+1,1),input_true_y(end+1,1),input_true_z(end+1,1) ]=sph2cart(observation_matrix(2, i),observation_matrix(3, i),observation_matrix(1, i));
               observations_rae(1,:)=observation_matrix(1, i);
               observations_rae(2,:)=observation_matrix(2, i);
               observations_rae(3,:)=observation_matrix(3, i);
               
           end
           if prod(observations_rae > 0) %%% raghava
                for j = 1:dimension_observations
                    subplot(3, 1, j);
                    h_input_true(end+1)=plot(time, observations_rae(j,:), plottype_input_true);
                end
           end

        end
    end
    h(end+1)=h_input_true(1);
end

output_x=[];
output_y=[];
output_z=[];

output_pred_x=[];
output_pred_y=[];
output_pred_z=[];

if plot_tracks == 1
    h_tracks=[];
    
    for i = 1:length(tracks)
        temp = cell2mat(tracks{i}.sequence_updated_state);       
        if plot_coordinates=='xyz'
         [temp_rae(2,1:size(temp,2)),temp_rae(3,1:size(temp,2)),temp_rae(1,1:size(temp,2))]=cart2sph(temp(1,:),temp(2,:),temp(3,:));
         output_x(1:size(temp,2),i)=temp(1,1:size(temp,2))';
         output_y(1:size(temp,2),i)=temp(2,1:size(temp,2))';
         output_z(1:size(temp,2),i)=temp(3,1:size(temp,2))'; 
        else
            [x_out,y_out,z_out]=cart2sph(temp(2,:),temp(3,:),temp(1,:));
          
            output_x(1:size(temp,2),i)=x_out';
            output_y(1:size(temp,2),i)=y_out';
            output_z(1:size(temp,2),i)=z_out';
         temp_rae(1,1:size(temp,2))=temp(1,:);
         temp_rae(2,1:size(temp,2))=temp(2,:);
         temp_rae(3,1:size(temp,2))=temp(3,:);
        end
        for j = 1:dimension_observations
            subplot(3, 1, j);
            h_tracks(end+1)=plot(tracks{i}.sequence_times, temp_rae(j, 1:size(temp,2)),plottype_track_filtered);% 'color',rand(1,3));%
          
        end
    end
    if ~isempty(tracks)
        h_display{end+1}='Output'; %legend value
        h(end+1)=h_tracks(1);
    end
  
end

if plot_tracks_predicted == 1
    h_tracks_predicted=[];
   
    for i = 1:length(tracks)
        temp_pred=cell2mat(tracks{i}.sequence_predicted_observations);
        if plot_coordinates=='xyz'
      
         [temp_pred_rae(2,1:size(temp_pred,2)),temp_pred_rae(3,1:size(temp_pred,2)),temp_pred_rae(1,1:size(temp_pred,2))]=cart2sph(temp_pred(1,:),temp_pred(2,:),temp_pred(3,:));
         output_pred_x(1:size(temp_pred,2),i)=temp(1,1:size(temp_pred,2))';
         output_pred_y(1:size(temp_pred,2),i)=temp(2,1:size(temp_pred,2))';
         output_pred_z(1:size(temp_pred,2),i)=temp(3,1:size(temp_pred,2))'; 
        else
        
         [x_out,y_out,z_out]=cart2sph(temp_pred(2,:),temp_pred(3,:),temp_pred(1,:));
          
            output_pred_x(1:size(temp_pred,2),i)=x_out';
            output_pred_y(1:size(temp_pred,2),i)=y_out';
            output_pred_z(1:size(temp_pred,2),i)=z_out';
         temp_pred_rae(1,1:size(temp_pred,2))=temp_pred(1,:);
         temp_pred_rae(2,1:size(temp_pred,2))=temp_pred(2,:);
         temp_pred_rae(3,1:size(temp_pred,2))=temp_pred(3,:);
        end
        for j = 1:dimension_observations
            subplot(3, 1, j);
                h_tracks_predicted(end+1)=plot(tracks{i}.sequence_times, temp_pred_rae(j, 1:size(temp_pred,2)),plottype_track_predicted);% 'color',rand(1,3));%
           
        end
    end
    if ~isempty(tracks)
        h(end+1)=h_tracks_predicted(1);
        h_display{end+1}='Prediction';%legend value
    end
end
if ~isempty(tracks)
    legend(h,h_display);  %legend h-plot color of each type of plot ; h_display-corresponding plot legends
end

% plotting in xyz


figure
plot3(output_x,output_y,output_z,plottype_track);grid on;
if plot_input_actual==1
  plot3(input_actual_x,input_actual_y,input_actual_z,plottype_input_actual);grid on;
    hold on;
 
 
end

if plot_input_true==1
    hold on;
 plot3(input_true_x,input_true_y,input_true_z,plottype_input_true);grid on;
  
end

if plot_tracks_predicted==1
    hold on;
    plot3(output_pred_x,output_pred_y,output_pred_z,plottype_track_predicted);grid on;
    
end
if plot_tracks == 1
    output_x(output_x==0)=NaN;
    output_y(output_y==0)=NaN;
    output_z(output_z==0)=NaN;
    plot3(output_x,output_y,output_z,plottype_track_filtered);grid on;
    
end

title('Input vs  Output');
if ~isempty(tracks)
    legend(h_display);
end
xlabel('x(km)');
ylabel('y(km)');
zlabel('z(km)');
