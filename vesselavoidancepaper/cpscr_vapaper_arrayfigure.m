function cpscr_vapaper_arrayfigure
    
    %%
    % Data directory
    par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
    par.reposdir = '.\matlabtoolbox';
    
    % Parameters and metadata
    file = fullfile(par.datadir,'CollPenAustevollLog.xls');
    block = cp_GetExpPar(file);
    
    % Parameters for the spectrogram
    par.avgtime = 0.1;%s
    par.p_ref = 1e-6; % [Pa]
    
    par.export_plot = true;
    
    par.calibration = [ones(1,16)*11.53 1 1]; % [Pa/V]
    
    % Load array data, but only those files that start with the block number
    files = dir(fullfile(par.datadir, 'block28', 'hydrophones', '28_*.mat'));
    
    % There are two hydrophone arrays, each containing 8 hydrophones.
    % Array 1 has 8 hydrophones connected to channels 1 to 8 and array 2 has
    % hydrophones connected to channels 9 to 16. The hydrophones were spaced
    % every 1 m and the topmost was 2 m deep. Channels 17 and 18 recorded data
    % from the two IMR hydrophones.
    
    array = struct('channel', 1:16, ...
        'depth', [9 8 7 6 5 4 3 2 9 8 7 6 5 4 3 2], ... % [m]
        'array', [1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2], ...
        'loc', ['f'; 'f'; 'f'; 'f'; 'f'; 'f'; 'f'; 'f'; ...
        'n'; 'n'; 'n'; 'n'; 'n'; 'n'; 'n'; 'n' ]); % near or far
    
    %%
    figure(1)
    clf
    subplot(3,1,1)
    
    for f = 1:length(files)
        
        % What kind of subblock/treatment is this?
        [a,~] = sscanf(files(f).name(1:end-4),'%u_%u_%u');
        subblock  = a(2);
        
        % only interested in the three vessel treatments.
        if strcmp(block(a(1)).subblock(subblock).s_treatmenttype, 'vessel')
            
            treatment = block(a(1)).subblock(subblock).treatment(a(3)).t_treatmenttype;
            
            disp(['Processing file: ' files(f).name ...
                ' (treatment is ' treatment ')'])
            
            clear press press_rms_avg time ind_start ind_end pressLowBand pressHighBand
            clear rmsLowBand rmsHighBand

            hdr = ['array_',files(f).name(1:end-4)];
            
            load(fullfile(par.datadir, 'block28', 'hydrophones', files(f).name))
            
            press = zeros(16, size(data.values,1));
            
            % Sample rate can sometimes change between treatment blocks
            Fs    = data.sample_rate(1);
            Fpass = 1000;            % Passband Frequency
            Fstop = 1100;            % Stopband Frequency
            Dpass = 0.057501127785;  % Passband Ripple
            Dstop = 0.0001;          % Stopband Attenuation
            dens  = 20;              % Density Factor
    
            % Calculate the required filter order.
            [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
    
            % Calculate the filter coefficients
            b  = firpm(N, Fo, Ao, W, {dens});
            Hd = dfilt.dffir(b);
            
            % and two other bandpass filters
            lowBandLimits = [100 150];
            highBandLimits = [300 500];
            lowBand = designfilt('bandpassfir', 'FilterOrder', 200, ...
                'CutoffFrequency1', lowBandLimits(1), 'CutoffFrequency2', lowBandLimits(2), ...
                'SampleRate', Fs);
            highBand = designfilt('bandpassfir', 'FilterOrder', 200, ...
                'CutoffFrequency1', highBandLimits(1), 'CutoffFrequency2', highBandLimits(2), ...
                'SampleRate', Fs);

            for chan = 1:16
                par.Fs = data.sample_rate(chan);
                par.start_time = data.start_time(chan);
                par.avg_bin = floor(par.Fs*par.avgtime);  % average into 1/10 second  bins
                press(chan,:) = data.values(:,chan) .* par.calibration(chan);  % pressure in Pa
                % lowpass filter the data
                press(chan,:) = filter(Hd, press(chan,:));
                
                % compute RMS pressure by averaging of the hydrophone data
                for i = 1:floor(length(press(chan,:))/par.avg_bin)-1
                    ind_start(i) = ((i-1) * (par.avg_bin)) + 1;
                    ind_end(i)   = ((i)   * (par.avg_bin));
                    % compute rms via a homebrew function by taking rms of small section
                    temp = press(chan,ind_start(i):ind_end(i)) - mean(press(chan,ind_start(i):ind_end(i))); %  % these are de-trended as per Nils Olav's suggestion
                    press_rms_avg(chan, i)= (mean(temp.^2))^.5;
                    time(i) = ((mean([ind_start(i) ind_end(i)])))./(par.Fs);
                end
                
                % select the peak region of each signal to use in selecting
                % the part of the signal of most interest.
                t = (1:length(press(chan,:)))/par.Fs;
                if strcmp(treatment, 'GOS_upscaled')
                    peak = 42; % [s]
                    subplotPosition = 2;
                elseif strcmp(treatment, 'GOS_unfiltered')
                    peak = 25; % [s]
                    subplotPosition = 1;
                elseif strcmp(treatment, 'JH_unfiltered')
                    peak = 26; % [s]
                    subplotPosition = 3;
                else
                    error('Unknown treatment')
                end
                
                psd_i = t >= (peak-3) & t <= (peak+3); % 6 seconds around the peak
                %psd_i = t >= (peak-300) & t <= (peak+300);
                
                
                % want the SPL in two frequency bands: a low one and a
                % high one  
                pressLowBand(chan,:) = filter(lowBand, press(chan, psd_i));
                pressHighBand(chan,:) = filter(highBand, press(chan, psd_i));
                
                [psdLow(chan,:), psdLowf] = pwelch(pressLowBand(chan,:).*1e6, 3000, 1000, 3000, par.Fs);
                [psdHigh(chan,:), psdHighf] = pwelch(pressHighBand(chan,:).*1e6, 3000, 1000, 3000, par.Fs);
                [psdFull(chan,:), psdFullf] = pwelch(press(chan,psd_i).*1e6, 3000, 1000, 3000, par.Fs);
                
                psdLow(chan, psdLowf  < lowBandLimits(1)  | psdLowf  > lowBandLimits(2))  = NaN;
                psdHigh(chan,psdHighf < highBandLimits(1) | psdHighf > highBandLimits(2)) = NaN;
                psdFull(chan,psdFullf > Fpass) = NaN;
            end
            clear data
            
            % Plot of SPL binned by depth for both arrays
            subplot(3,1,subplotPosition)
            shallowNear = array.depth <= 3 & (array.loc == 'n')';
            %shallowFar  = array.depth <= 4 & (array.loc == 'f')';
            deepNear    = array.depth >= 8 & (array.loc == 'n')';
            %deepFar     = array.depth >= 7 & (array.loc == 'f')';
            
            t = psdFull(shallowNear,:);
            shallowNearFull = t(:);
            t = psdLow(shallowNear,:);
            shallowNearLow = t(:);
            t = psdHigh(shallowNear,:);
            shallowNearHigh = t(:);
            
            t = psdFull(deepNear,:);
            deepNearFull = t(:);
            t = psdLow(deepNear,:);
            deepNearLow = t(:);
            t = psdHigh(deepNear,:);
            deepNearHigh = t(:);
            
            x = nan(length(shallowNearFull),6); % 6 SPL's to show
            x(1:length(shallowNearLow),1) = shallowNearLow;
            x(1:length(deepNearLow),2) = deepNearLow;
            x(1:length(shallowNearHigh),3) = shallowNearHigh;
            x(1:length(deepNearHigh),4) = deepNearHigh;
            x(1:length(shallowNearFull),5) = shallowNearFull;
            x(1:length(deepNearFull),6) = deepNearFull;
            
            x = 10*log10(x);
            
            categories = {'<=3m, 100-150Hz' '>=8m, 100-150Hz' '<=3m, 300-500Hz' '>=8m, 300-500Hz' '<=3m <1kHz' '>=8m, <1kHz'};
            
            boxplot(x, categories)
            title(treatment, 'Interpreter','None')
            
            % for export later on to R
            DAT(subplotPosition).x = x;
            DAT(subplotPosition).treatment = treatment;
            DAT(subplotPosition).categories = categories;
        end
    end
    % export the data to R to plot the manuscript version of the
    % figure
    save Figure4 DAT

    if par.export_plot
        export_fig('-dpng', '-r200', 'Figure4.png')
    end

end
