function o = maintain_tracks(o)
    [active_tracks, inactive_tracks] = o.track_maintenance.get_active_inactive_tracks(o.list_of_tracks);
    o.list_of_tracks = active_tracks;
    o.list_of_inactive_tracks = [o.list_of_inactive_tracks, inactive_tracks];
end
