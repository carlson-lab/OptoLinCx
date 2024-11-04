function adjusted_ld = laser_durations(laser)
    laser(laser <= 500) = 0;
    laser(laser > 0) = 1;
    ld = {};
    prev_val = 0;
    start_stim = NaN;
    stop_stim = NaN;
    for i = 1 : length(laser)
        val = laser(i);
        if val == 1 && prev_val == 0
            start_stim = i;
            prev_val = 1;
        elseif val == 0 && prev_val == 1
            stop_stim = i;
            prev_val = 0;
            ld{end+1} = [start_stim, stop_stim];
        end
    end
    %Given the rising/falling edge of the step, threshold is generally 1 ms off, 
    % plus add 1 ms at the tail end for off-by-one indexing used next
    adjusted_ld = {};
    for j = 1 : length(ld)
        t = ld{j};
        adjusted_ld{j} = [t(1) - 1, t(2) + 2];
    end
end