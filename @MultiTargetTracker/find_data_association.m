function data_association_matrix = find_data_association(o, observations, gate_membership_matrix)
data_association_matrix = o.data_association.find_data_association(observations, o.list_of_tracks, gate_membership_matrix);
end
