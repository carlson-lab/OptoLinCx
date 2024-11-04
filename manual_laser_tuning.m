function manual_laser_tuning()
    channel_out = 145; %153 is digital out 1, 145 is analog out 1
    stim_duration = 2; %2 seconds
    second_equivalent = 30000; %1 second in blackrock language
    volt_equivalent = 6553.4; %1 volt in blackrock language
    v_options = [3, 2.758, 2.676, 2.622]; %1mW, 0.75mW, 0.5mW, 0.25mW
    cbmex('open');
    pause(5);
    for i = 1 : length(v_options)
        disp(strcat('Stimulus', {' '}, string(v_options(i))));
        cbmex('analogout', channel_out, 'sequence', [stim_duration*second_equivalent, v_options(i)*volt_equivalent],'repeats',5);
        pause(10);
    end
end

    
   

    

        