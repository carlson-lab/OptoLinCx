function min_vs = calc_max_resp(tuningfile_path)
    lfp = openNSx('read', convertStringsToChars(strcat(tuningfile_path, '.ns2')), 'uv');
    pause(2);
    laser = lfp.Data(13, :);
    adjusted_ld = laser_durations(laser);
    stim_windows = {};
    %From experience, stim intervals turn out to be 13-14ms long, so making all stim windows =14ms; due to off-by-one, make it 15
    for i = 1 : length(adjusted_ld)
        interval = adjusted_ld{i};
        duration = interval(2) - interval(1);
        if duration > 9 && duration < 16
            stim_windows{end+1} = [interval(1), interval(2) + 15];
        end
    end
    %channels are il1, il2, il3, il4, il5, il6, il7, il8, nac1, nac2, nac3,
    %nac4, laser
    nac_minvals = [];
    pre_minvals = [];
    for i = 9 : 12
      rc = lfp.Data(i, :);
      stim_intervals = [];
      pre_intervals = [];
      for j = 1 : length(stim_windows)
          interval = stim_windows{j};
          norm_factor = mean(rc(interval(2) - 300 : interval(1)));
          %Use duration of the first stimulus as benchmark
          matlub_sucks = size(stim_intervals);
          if matlub_sucks(2) == 0
              endpos = interval(2);
          else % If interval(2) - interval(1) ~= matlub_sucks(2)
              endpos = interval(1) + matlub_sucks(2) - 1;
          end
          %+5 and -20 chosen from sample waveform, expecting good channels
          %to have this temporal dynamics of the response
          stim_intervals = cat(1, stim_intervals, rc(interval(1) : endpos) - norm_factor);
          pre_intervals = cat(1, pre_intervals, rc(interval(1) - 300 : interval(1)) - norm_factor);
          %minvals(end+1) = mean(rc(interval(1)+5 : interval(2) - 20) - norm_factor); %should use mean, not min, because in dead channels min could be very low but not meaningful
      end
      nac_minvals(end+1) = min(mean(stim_intervals, 1));
      pre_minvals(end+1) = min(mean(pre_intervals, 1));
    end
    for k = 1:4
        disp(pre_minvals(k));
        if pre_minvals(k) < -250 
            nac_minvals(k) = 0; %mute broken channels
        end
    end
    min_vs = nac_minvals;
end