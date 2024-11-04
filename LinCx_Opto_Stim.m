function LinCx_Opto_Stim(mouse_id, mode)
    %Two modes possible: 
    %   -- 0: using laser with pre-tuned power of 1mW, do 30 stimui at
    %   100% power, 30 at 75%, 30 at 50% and 30 at 25%
    %   -- 1: use NAc response magnitude to tune laser power to be within predefined window
    
    %directory to save random pulse pattern to
    mousestr = strcat('Mouse', mouse_id);
    datestr = string(datetime('now', 'Format', 'MMddyy'));
    experiment = 'OptoLinCx';
    absolute_path = 'C:\LinCx_Kirill\';
    dir_to_make = strcat(absolute_path, mousestr, '\', datestr);
    pathtosave = convertStringsToChars(strcat(dir_to_make, '\', mousestr, '_', datestr, '_', experiment));
    random_pauses_path = strcat(pathtosave, '.csv');
    mkdir(dir_to_make);
    
    %Use digital channel 1 on Blackrock for output 
    channel_out = 145; %153 is digital out 1, 145 is analog out 1
    min_interstim_pause = 10;
    max_interstim_pause = 24;
    
    second_equivalent = 30000; %1 second in blackrock language
    volt_equivalent = 6553.4; %1 volt in blackrock language
    stim_duration = 0.005; %5 ms
    
    cbmex('open');
    if mode == 0
        %Number of light pulses
        num_stim = 120;
        v_options = [3, 2.758, 2.676, 2.622]; %1mW, 0.75mW, 0.5mW, 0.25mW
        v_options_rep = repelem(v_options, num_stim/4);
        %Generate interpulse intervals of random duration
        rand_intervals = randi([min_interstim_pause, max_interstim_pause], [1,num_stim]);
        rand_stimuli = v_options_rep(randperm(length(v_options_rep)));
        writematrix([rand_intervals, rand_stimuli], random_pauses_path);

        cbmex('fileconfig', pathtosave, '', 1);
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
        disp('Finishing with 60 second baseline recording...');
        pause(60) %60-sec post-stim recording
        cbmex('fileconfig', pathtosave, '', 0);
        disp("That's all Folks!");
        
    else
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
            disp('Starting with 60 second baseline recording...');
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
    
   
    

        