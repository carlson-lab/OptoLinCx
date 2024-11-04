function min_vs = stim_at_v(curr_voltage, pathtosave, num_stim, rand_intervals) 
    tuningfile_path = convertStringsToChars(strcat(pathtosave, '_tuning_', string(curr_voltage), '_volts'));
    second_equivalent = 30000; %1 second in blackrock language
    volt_equivalent = 6553.4; %1 volt in blackrock language
    stim_duration = 0.01; %10 ms
    channel_out = 145; %Use analog channel 1 on Blackrock for output
    
    disp(strcat('Wait around 100 seconds, stimulating at ', {' '}, string(curr_voltage)));
    cbmex('fileconfig', tuningfile_path, '', 1);
    pause(1) %60-sec baseline recording
    for i = 1 : num_stim
        cbmex('analogout', channel_out, 'sequence', [stim_duration*second_equivalent, curr_voltage*volt_equivalent],'repeats',1);
        pause(rand_intervals(i)); % i-th randomized interstimulus pause
    end 
    pause(1) %60-sec post-stim recording
    cbmex('fileconfig', pathtosave, '', 0);
    min_vs = calc_max_resp(tuningfile_path);

end