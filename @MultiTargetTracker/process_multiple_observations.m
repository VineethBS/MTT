function o = process_multiple_observations(o, list_of_times, list_of_observations)
    num_list = length(list_of_observations);
    for i = 1:num_list
        o = o.process_one_observation(list_of_times(i), list_of_observations{i});
    end
end