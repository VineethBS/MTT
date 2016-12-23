function plot_1D(o, tracks)

filename = o.visualization_parameters.filename;
plot_input = o.visualization_parameters.plot_input;
plot_tracks = o.visualization_parameters.plot_tracks;
in_field_separator = o.visualization_parameters.in_field_separator;
plottype_input = o.visualization_parameters.plottype_input;
plottype_track = o.visualization_parameters.plottype_track;

dimension_observations = 1;

if exist(filename, 'file') == 2
    fh = fopen(filename);
else
    error('%s does not exist!', filename);
    return;
end

figure(1);
hold on;

if plot_input == 1
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
        for i = 1:num_observations
            observations = observation_matrix(:, i);
            plot(time, observations, plottype_input);
        end
    end
    
    fclose(fh);
end

if plot_tracks == 1
    for i = 1:length(tracks)
        plot(tracks{i}.sequence_times, cell2mat(tracks{i}.sequence_predicted_observations), plottype_track);
    end
end

hold off;