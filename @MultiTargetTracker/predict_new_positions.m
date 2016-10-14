function o = predict_new_positions(o)
for i = 1:length(o.list_of_tracks)
    o.list_of_tracks{i} = o.list_of_tracks{i}.predict();
end
end