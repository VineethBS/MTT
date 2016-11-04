function valid_tracks = find_tracks_atleast_N_detections(o, tracks)
% returns a cell array of valid tracks - each valid track is either an active track or an inactive track that contains
% at least N associations.
N = o.atleastN_parameters.N;
j = 1;
valid_tracks = [];
for i = 1:length(tracks)
    if length(tracks{i}.sequence_times_observations) >= N
        valid_tracks{j} = tracks{i};
        j = j + 1;
    end
end
