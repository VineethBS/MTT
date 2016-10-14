function o = process_one_observation(o, observations)
% observations: list of observations at a particular time. Each
% observation could be a vector

o = o.predict_new_positions();
gate_membership_matrix = o.find_gate_membership(observations);
data_association_matrix = o.find_data_association(observations, gate_membership_matrix);
o = o.update_and_make_newtracks(data_association_matrix);
o = o.maintain_tracks();

end