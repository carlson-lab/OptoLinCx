function LinCx_Opto_Stim(meaID, mode)
    %Two modes possible: 
    %   -- 0: using laser with pre-tuned power of 1mW, do 30 stimui at
    %   100% power, 30 at 75%, 30 at 50% and 30 at 25% %% this refers to laser intensity 75% = 0.75 mW
    %   -- 1: use NAc response magnitude to tune laser power to be within predefined window 
    %%**q: how would I do this for this experiment the thing about the response magnitude?
    %% let's change mode 1 to wave generator test
    %%% = means I changed a variable names to be more reflective of my experiment
% every comment that has '%%' are comments I added and 'q:' are questions. **q: are questions to ask Kirill

    %directory to save random pulse pattern to
    meastr = strcat('MEA', meaID); %%% meaID corresponds to the 5 digit ID found on each MEA
    datestr = string(datetime('now', 'Format', 'MMddyy'));
    experiment = 'OptoCellStim'; %%%
    absolute_path = '/Users/morgangallimore/Desktop/mea stuff/OptoStimData'; %%%
    dir_to_make = strcat(absolute_path, meastr, '/', datestr); 
    pathtosave = convertStringsToChars(strcat(dir_to_make, '/', meastr, '_', datestr, '_', experiment)); %%%
    random_pauses_path = strcat(pathtosave, '.csv'); 
    waveform_settings_path = strcat(pathtosave, '.csv'); % i added this
    mkdir(dir_to_make); 
    
    %Use digital channel 1 on Blackrock for output 
    channel_out = 145; %153 is digital out 1, 145 is analog out 1 %% may need to change
    min_interstim_pause = 10; %%*q: how do we determine a number for this?
    max_interstim_pause = 24; %%*q: how do we determine a number for this?
    
    second_equivalent = 30000; %1 second in blackrock language %%q: is this because the sample frequency is 30 Hz?
    volt_equivalent = 6553.4; %1 volt in blackrock language %%q: what conversion is this?
    stim_duration = 0.005; %5 ms
    
    cbmex('open');
    if (mode == 0)
        %Number of light pulses
        num_stim = 120; %%q: how did you choose this number?
        v_options = [3, 2.758, 2.676, 2.622]; %1mW, 0.75mW, 0.5mW, 0.25mW %%q: what conversion is this?
        v_options_rep = repelem(v_options, num_stim/4);
        %Generate interpulse intervals of random duration
        rand_intervals = randi([min_interstim_pause, max_interstim_pause], [1,num_stim]); %%q: so are stimulation intervals random, why?
        rand_stimuli = v_options_rep(randperm(length(v_options_rep))); 
        writematrix([rand_intervals, rand_stimuli], random_pauses_path);

        cbmex('fileconfig', pathtosave, '', 1); %%q: what does this variable do?
        disp('Starting with 10 minute baseline recording...');
        pause(600) %10 minute baseline recording
        for i = 1 : num_stim
            if i == num_stim/2
                disp('We are at half-way! Take off optical fiber and put it back, then press Enter');
                pause;    
            end
            fprintf('\n');
            disp(strcat('Stimulus', {' '}, string(i)));
            cbmex('analogout', channel_out, 'sequence', [stim_duration*second_equivalent, rand_stimuli(i)*volt_equivalent],'repeats',1);
            disp(strcat('Pause for', {' '}, string(rand_intervals(i)), ' seconds'));
            pause(rand_intervals(i)); % i-th randomized interstimulus pause
        end 
        disp('Finishing with 60 second baseline recording...'); %%q: is the recording 2 mins in total?
        pause(60) %60-sec post-stim recording
        cbmex('fileconfig', pathtosave, '', 0);
        disp("That's all Folks!");
        
    else if (mode == 1)
        %Number of light pulses
        num_stim = 30;
        %Tune the laser power so that your optogenetic response is within
        %desired 
        optimal_v = tune_laser(pathtosave);
        if optimal_v ~= 0
            %Generate interpulse intervals of random duration
            rand_intervals = randi([min_interstim_pause, max_interstim_pause], [1,num_stim]);
            writematrix(rand_intervals, random_pauses_path);
            
            cbmex('fileconfig', pathtosave, '', 1);
            disp('Starting with 60 second baseline recording...'); %%q: why do we do baseline after and not before? see line 54 
            pause(60) %60-sec baseline recording
            for i = 1 : num_stim
                fprintf('\n');
                disp(strcat('Stimulus', {' '}, string(i)));
                cbmex('analogout', channel_out, 'sequence', [stim_duration*second_equivalent, optimal_v*volt_equivalent],'repeats',1);
                disp(strcat('Pause for', {' '}, string(rand_intervals(i)), ' seconds'));
                pause(rand_intervals(i)); % i-th randomized interstimulus pause
            end 
            disp('Finishing with 60 second baseline recording...');
            pause(60) %60-sec post-stim recording
            cbmex('fileconfig', pathtosave, '', 0);
            disp("That's all Folks!");
        else
            rmdir(dir_to_make, 's');
        end
    end

    else
        channel_out = 145; %this would be the output channel for the waveform generator, so adjust accordingly
        waveform_duration = 30; %check your units to get it to 30 seconds
        stim_duration = 0.005; %5 ms, adjust if you want a different duration
        % add shit about baseline recording 
        baseline_length = waveform_duration; % set's the length of the baseline recording to be the same length as signal recording
        % below will be about what we manually select on waveform generator
        chan = 'CH1';
        wavetype = 'pulse'; %this is button you select on the right that lights up 
        freq = 44. 4444444;
        freq_unit = 'Hz' ;
        Amp1 = 5.0;
        Amp1_unit = 'mV';
        width = 7.38888888;
        duty_percent = 32.8395062;
        delay = 0;
        delay_unit = 'ms';
        writematrix([chan, wavetype, freq,freq_unit,Amp1, Amp1_unit, width,duty_percent,delay,delay_unit], waveform_settings_path);

        cbmex('fileconfig', pathtosave, '', 1); %starts blackrock recording
        disp('Starting with ',  baseline_length, ' second baseline recording...');
        pause(baseline_length) %don't seem to need semicolon?
        disp('Starting waveform generator output...');
        cbmex('digitalout', channel_out, 'sequence', [stim_duration*second_equivalent, 1]); 
        pause(waveform_output_duration);
        cbmex('digitalout', channel_out, 'sequence', [stim_duration*second_equivalent, 0]); 
        cbmex('fileconfig', pathtosave, '', 0);
        disp("Waveform output complete, that's all folks");
    end
end
%     
%     cbmex('fileconfig', pathtosave, '', 1);
%     disp('Starting with 60 second baseline recording...');
%     pause(60) %60-sec baseline recording
%     for i = 1 : num_stim
%         fprintf('\n');
%         disp(strcat('Stimulus', {' '}, string(i)));
%         cbmex ('digitalout', channel_out, 1);
%         pause(0.01); %stimulate for 10 ms
%         disp(strcat('Pause for', {' '}, string(rand_intervals(i)), ' seconds'));
%         cbmex ('digitalout', channel_out, 0);
%         pause(rand_intervals(i)); % i-th randomized interstimulus pause
%     end 
%     pause(60) %60-sec post-stim recording
%     cbmex('fileconfig', pathtosave, '', 0);
%     disp("That's all Folks!");
    
   
    

        