function o = compute_metrics(o, tracks)

if exist(o.original_tracks_file, 'file') == 2
    fh = fopen(o.original_tracks_file);
else
    error('%s does not exist!', o.original_tracks_file);
    return;
end

% Accumulate the times and observations from all the tracks into a single data structure
times_from_tracks = [];
observations_from_tracks = [];

for i = 1:length(tracks)
    current_track = tracks{i};
%     for j = 1:length(current_track.sequence_times_observations)
     for j = 1:length(current_track.sequence_times)
        current_track_time = current_track.sequence_times(j);
        current_track_observations = current_track.sequence_updated_state{j};
        
        index = find(times_from_tracks == current_track_time, 1);
        if isempty(index)
            times_from_tracks(end + 1) = current_track_time;
            index = find(times_from_tracks == current_track_time, 1);
            observations_from_tracks{index}{1} = current_track_observations;
        else
            observations_from_tracks{index}{end + 1} = current_track_observations; % TODO: logic for handling the case where this is empty; shouldn't happen
        end
    end
end

while 1
    line = fgetl(fh);
    if ~ischar(line)
        break;
    end
    
    tokens = strsplit(line, o.in_field_separator);
    % convert all tokens to double
    numeric_tokens = zeros(1, length(tokens));
    for i = 1:length(tokens)
        numeric_tokens(i) = str2double(tokens{i});
    end
    
    time = numeric_tokens(1);
    numeric_tokens = numeric_tokens(2:end);
    % If the number of numeric tokens is not a multiple of dimension_observations then continue on to the next line
    if mod(length(numeric_tokens), o.dimension_observations) ~= 0
        continue;
    end
    
    % arrange the observations at the current time as a matrix
    num_observations = floor(length(numeric_tokens)/o.dimension_observations); % this should be an integer
    observations_matrix = reshape(numeric_tokens, o.dimension_observations, num_observations);
    %%% raghava remove zero observation
    observations_matrix(:,~any(observations_matrix,1)) = []; %%%removes columns ie observations with zero
    observations_matrix(~any(observations_matrix,2),:) = []; %%%removes rows ie if all observations zero
    %%%%
    index = find(times_from_tracks == time, 1);
    if isempty(index)
        track_observations_matrix = [];
    else
        track_observations_matrix = cell2mat(observations_from_tracks{index});
    end
    
    %%% raghava remove zero observation
    track_observations_matrix(:,~any(track_observations_matrix,1)) = []; %%%removes columns ie observations with zero
    track_observations_matrix(~any(track_observations_matrix,2),:) = []; %%%removes rows ie if all observations zero
    %%%%
    
    o.time_sequence(end + 1) = time;
    %%% raghava
    [~,o.n_intargets(end + 1)] = size(observations_matrix);
    [~,o.n_outtargets(end + 1)] = size(track_observations_matrix);
    
    %%% raghava for finding metric in xyz cordinates
    if o.dimension_observations ==3
         if o.convertcordinate == 1
             
             for i = 1:o.n_intargets(end)
                 %%%% [x,y,z] = sph2cart(a,e,r)
                 [observations_matrix(1,i),observations_matrix(2,i),observations_matrix(3,i)] = sph2cart(observations_matrix(2,i),observations_matrix(3,i),observations_matrix(1,i));
             end
             
             for i = 1:o.n_outtargets(end)
                 %%%% [x,y,z] = sph2cart(a,e,r)
                 [track_observations_matrix(1,i),track_observations_matrix(2,i),track_observations_matrix(3,i)] = sph2cart(track_observations_matrix(2,i),track_observations_matrix(3,i),track_observations_matrix(1,i));
             end
             
         end
    end
    
    %%% raghava for finding metric in rae cordinates
    if o.dimension_observations ==3
         if o.convertcordinate == 2
             
             for i = 1:o.n_intargets(end)
                 %%%%[a,e,r] = cart2sph(x,y,z);
                 [observations_matrix(2,i),observations_matrix(3,i),observations_matrix(1,i)] = sph2cart(observations_matrix(1,i),observations_matrix(2,i),observations_matrix(3,i));
                 %%%%%observations_matrix r a e
             end
             
             for i = 1:o.n_outtargets(end)
                 %%%%[a,e,r] = cart2sph(x,y,z);
                 [track_observations_matrix(2,i),track_observations_matrix(3,i),track_observations_matrix(1,i)] = sph2cart(track_observations_matrix(1,i),track_observations_matrix(2,i),track_observations_matrix(3,i));
             end
             
         end
    end
    if o.compute_ospa
       dist = o.find_ospa_metric(observations_matrix, track_observations_matrix, o.ospa_parameters.c, o.ospa_parameters.p);
       o.ospa_metric(end + 1) = dist;
    end
    
    if o.compute_omat
        dist = o.find_omat_metric(observations_matrix, track_observations_matrix, o.omat_parameters.c);
        o.omat_metric(end + 1) = dist;
    end
    
    if o.compute_hausdorff
        dist = o.find_hausdorff_metric(observations_matrix, track_observations_matrix);
        o.hausdorff_metric(end + 1) = dist;
    end
end

if o.compute_ospa
    o.average_ospa_metric = mean(o.ospa_metric);
end

if o.compute_omat
    o.average_omat_metric = mean(o.omat_metric);
end

if o.compute_hausdorff
    o.average_hausdorff_metric = mean(o.hausdorff_metric);
end

if o.plot_metrics
    figure;
    hold on;
    if o.compute_ospa
        plot(o.time_sequence, o.ospa_metric, 'r');
    end
    if o.compute_omat
        plot(o.time_sequence, o.omat_metric, 'b');
    end
    if o.compute_hausdorff
        plot(o.time_sequence, o.hausdorff_metric, 'k');
    end
    grid on;
    title('Metric Plot');
    xlabel('Time(sec)');
    ylabel('Metric value');
    legend(sprintf('OSPA %.4f', o.average_ospa_metric), sprintf('OMAT %.4f', o.average_omat_metric), sprintf('Hausdorff %.4f', o.average_hausdorff_metric));
    hold off;
end