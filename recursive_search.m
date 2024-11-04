function optimal_v = recursive_search(min_v, max_v, rand_intervals, pathtosave, num_stim, acceptable_mean_v, tolerance_v)
    %Generate interpulse intervals of random duration
    curr_voltage = (min_v + max_v) / 2;
    disp(strcat('Trying', {' '}, string(curr_voltage), {' '}, 'volts'));
    min_vs = stim_at_v(curr_voltage, pathtosave, num_stim, rand_intervals);
    most_min = min(min_vs);
    disp(strcat('Current response magnitude is ', {' '}, string(most_min), {' '}, 'uV'));
    if (most_min < acceptable_mean_v + tolerance_v && most_min > acceptable_mean_v - tolerance_v)
        disp('Found the good voltage!')
        optimal_v = curr_voltage;
    elseif most_min > acceptable_mean_v + tolerance_v
        disp(strcat(string(curr_voltage), {' '}, 'is too low, looking at higher voltages'));
        optimal_v = recursive_search(curr_voltage, max_v, rand_intervals, pathtosave, num_stim, acceptable_mean_v, tolerance_v);
    else 
        disp(strcat(string(curr_voltage), {' '}, 'is too high, looking at lower voltages'));
        optimal_v = recursive_search(min_v, curr_voltage, rand_intervals, pathtosave, num_stim, acceptable_mean_v, tolerance_v);
    end

end

