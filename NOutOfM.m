classdef NOutOfM
    % Track maintenance using N out of M technique
    %   A track is declared to be active if it has at least N associations
    %   in the past M time instants
    
    properties
        N;
        M;
    end
    
    methods
        function o = NOutOfM(track_maintenance_parameters)
            o.N = track_maintenance_parameters.N;
            o.M = track_maintenance_parameters.M;
        end
        
        function [active_tracks, inactive_tracks] = get_active_inactive_tracks(o, list_of_tracks)
            active_tracks = {};
            inactive_tracks = {};
            num_of_tracks = length(list_of_tracks);
            for i = 1:num_of_tracks
                current_track = list_of_tracks{i};
                if length(current_track.sequence_times) <= o.M
                    active_tracks{end + 1} = current_track;
                    continue;
                end
                last_M_start_time = current_track.sequence_times(end - o.M);
                if sum(current_track.sequence_times_observations >= last_M_start_time) >= o.N
                    active_tracks{end + 1} = current_track;
                else
                    inactive_tracks{end + 1} = current_track;
                end
            end
        end
    end
end

