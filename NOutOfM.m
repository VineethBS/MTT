classdef NOutOfM
    % Track maintenance using N out of M technique
    %   A track is said to be new if the number of times it has been
    %   updated is less than confirm_threshold
    %   If the track is new and the number of associations it had in the
    %   last confirm_M times is less than confirm_N then the track is made
    %   inactive, else it is confirmed
    %   For a confirmed track, a track is declared to be active if it has 
    %   at least N associations in the past M time instants
    
    properties
        N;
        M;
        confirm_threshold;
        confirm_M;
        confirm_N;
    end
    
    methods
        function o = NOutOfM(track_maintenance_parameters)
            o.N = track_maintenance_parameters.N;
            o.M = track_maintenance_parameters.M;
            o.confirm_threshold = track_maintenance_parameters.confirm_threshold;
            o.confirm_N = track_maintenance_parameters.confirm_N;
            o.confirm_M = track_maintenance_parameters.confirm_M;
        end
        
        function [active_tracks, inactive_tracks] = get_active_inactive_tracks(o, list_of_tracks)
            active_tracks = {};
            inactive_tracks = {};
            num_of_tracks = length(list_of_tracks);
            for i = 1:num_of_tracks
                current_track = list_of_tracks{i};
                
                if length(current_track.sequence_times) <= o.confirm_threshold
                    if length(current_track.sequence_times) <= o.confirm_M
                        active_tracks{end + 1} = current_track;
                        continue;
                    end
                    last_M_start_time = current_track.sequence_times(end - o.confirm_M);
                    if sum(current_track.sequence_times_observations >= last_M_start_time) >= o.confirm_N
                        active_tracks{end + 1} = current_track;
                    end
                    % note that we will completely disregard this track
                    % here and it is not even added to inactive tracks
                else
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
end

