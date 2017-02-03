function o = process_one_observation(o, time, observations, additional_information)
% observations: list of observations at a particular time. Each
% observation could be a vector

o = o.predict_new_positions();
gate_membership_matrix = o.find_gate_membership(observations);
if strcmp(o.data_association_type, 'GNN')
    data_association_matrix = o.find_data_association(observations, gate_membership_matrix);
    o = o.update_and_make_newtracks(time, observations, gate_membership_matrix, data_association_matrix);
elseif strcmp(o.data_association_type, 'JPDA')
    % the JPDA probability matrix is number of observations x number of tracks
    % jpda_probability_matrix(j, t) is the probability of observation j being associated to track t
    jpda_probability_matrix = o.find_data_association(observations, gate_membership_matrix);
    o = o.jpda_update_and_make_newtracks(time, observations, gate_membership_matrix, jpda_probability_matrix);
elseif strcmp(o.data_association_type, 'Heuristic')
    data_association_matrix = o.find_data_association(observations, gate_membership_matrix);
    o = o.update_and_make_newtracks(time, observations, gate_membership_matrix, data_association_matrix);
end
o = o.maintain_tracks();

end