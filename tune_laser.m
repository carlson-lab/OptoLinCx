function optimal_v = tune_laser(pathtosave)
    max_voltage = 3; % max votage to feed into laser
    min_voltage = 2; % min voltage to feed into laser
    num_stim = 30; %Number of light pulses
    min_interstim_pause = 1;
    max_interstim_pause = 3;
    acceptable_mean_v = -400; %response magnitude in nV
    tolerance_v = 50;
    rand_intervals = randi([min_interstim_pause, max_interstim_pause], [1,num_stim]);
    cbmex('open');
    disp('Starting tuning...');
    
    %First, try the smallest possible voltage to make sure I don't need to
    %tune it lower manually:
    min_vs_at_max = stim_at_v(max_voltage, pathtosave, num_stim, rand_intervals);
    most_min_at_max = min(min_vs_at_max);
    disp(strcat(string(most_min_at_max), {' '}, 'is the response'));
    if isnan(most_min_at_max)
        disp('Something is terribly wrong, maybe min_voltage too low?')
    elseif (most_min_at_max < acceptable_mean_v + tolerance_v && most_min_at_max > acceptable_mean_v - tolerance_v)
        disp('Max voltage works great!')
        optimal_v = max_voltage;
    elseif most_min_at_max > acceptable_mean_v + tolerance_v
        disp('Even at highest voltage response is too weak, I recommend manually increasing laser power with a knob');
        optimal_v = 0;
    else % If we are in the condition where most_min_at_max < acceptable_mean_v - tolerance_v
        disp("Max voltage is too strong, let's try the lowest voltage now");
        min_vs_at_min = stim_at_v(min_voltage, pathtosave, num_stim, rand_intervals);
        for nac_chan = 1:4
            if min_vs_at_min(nac_chan) < min_vs_at_max(nac_chan) - 100
                min_vs_at_min(nac_chan) = 10000; %arbitrary large number to exclude noisy channel
            end
        end
        most_min_at_min = min(min_vs_at_min);
        disp(strcat(string(most_min_at_min), {' '}, 'is the response'));
        if (most_min_at_min < acceptable_mean_v + tolerance_v && most_min_at_min > acceptable_mean_v - tolerance_v)
            disp('Min voltage works great!')
            optimal_v = min_voltage;
        elseif most_min_at_min < acceptable_mean_v - tolerance_v
            disp('Even at lowest voltage response is too strong, I recommend manually decreasing laser power with a knob');
            optimal_v = 0;
        else % If we are in the condition where we know that the lowest voltage is too little and the highest voltage -- too high
            disp('Min voltage is too low, searching for optimal voltage recursively...')
            optimal_v = recursive_search(min_voltage, max_voltage, rand_intervals, pathtosave, num_stim, acceptable_mean_v, tolerance_v);
        end
    end
end




    

