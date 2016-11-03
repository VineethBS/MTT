function makeInputFile_AfterRemovalOfZeros(filename, output_filename, in_field_separator, out_field_separator, skip_lines, dimension_observations)
if exist(filename, 'file') == 2
    fh = fopen(filename);
else
    error('%s does not exist!', filename);
    return;
end

fho = fopen(output_filename, 'w');

line_number = 0;

while 1
    line = fgetl(fh);
    if ~ischar(line)
        break;
    end
    line_number = line_number + 1;
    if (line_number <= skip_lines)
        continue;
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
    
    fprintf(fho, '%.2f', time);
    num_observations = floor(length(numeric_tokens)/dimension_observations); % this should be an integer
    observation_matrix = reshape(numeric_tokens, dimension_observations, num_observations);
    for i = 1:num_observations
        observations = observation_matrix(:, i);
        if sum(observations.^2) > 0
            for j = 1:dimension_observations
                fprintf(fho,'%s%.3f',out_field_separator, observations(j));
            end
        end
    end
    fprintf(fho,'\n');
end

fclose(fh);
fclose(fho);
