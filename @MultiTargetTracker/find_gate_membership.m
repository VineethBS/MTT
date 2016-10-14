function gate_membership_matrix = find_gate_membership(o, observations)
gate_membership_matrix = o.gating.find_gate_membership(observations, o.list_of_tracks);
end
