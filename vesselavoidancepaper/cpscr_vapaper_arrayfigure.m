function cpscr_vapaper_arrayfigure
    
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
        'array', [1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2]);
    
    %%
    for f=1:length(files)
        
        file =  fullfile(par.datadir, 'block28', 'hydrophones', files(f).name);
        hdr = ['array_',files(f).name(1:end-4)];
        
        % What kind of subblock/treatment is this?
        [a,~] = sscanf(files(f).name(1:end-4),'%u_%u_%u');
        subblock  = a(2);
        treatment = a(3);
        
        % only interested in the three vessel treatments.
        if strcmp(block(a(1)).subblock(subblock).s_treatmenttype,'vessel')
            treatment = block(a(1)).subblock(a(2)).treatment(a(3)).t_treatmenttype;
            disp(['Processing file: ' files(f).name ...
                ' (treatment is ' treatment ')'])
            
            clear press press_rms_avg time ind_start ind_end
            
            load(file)
            
            press = zeros(16, size(data.values,1));
            
            % Sample rate can sometimes change between treatment blocks
            Fs    = data.sample_rate(1);
            Fpass = 1000;            % Passband Frequency
            Fstop = 1100;            % Stopband Frequency
            Dpass = 0.057501127785;  % Passband Ripple
            Dstop = 0.0001;          % Stopband Attenuation
            dens  = 20;              % Density Factor
    
            % Calculate the order from the parameters using FIRPMORD.
            [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
    
            % Calculate the coefficients using the FIRPM function.
            b  = firpm(N, Fo, Ao, W, {dens});
            Hd = dfilt.dffir(b);

            for chan = 1:16
                par.Fs = data.sample_rate(chan);
                par.start_time = data.start_time(chan);
                par.avg_bin = floor(par.Fs*par.avgtime);  % average into 1/10 second  bins
                press(chan,:) = data.values(:,chan) .* par.calibration(chan);  % pressure in Pa
                % lowpass filter the data
                press(chan,:) = filter(Hd, press(chan,:));
                
                % compute RMS pressure by averaging
                for i = 1:floor(length(press(chan,:))/par.avg_bin)-1
                    ind_start(i)=((i-1)*(par.avg_bin))+1;
                    ind_end(i)=((i)*(par.avg_bin));
                    % compute rms via a homebrew function by taking rms of small section
                    temp = press(chan,ind_start(i):ind_end(i)) - mean(press(chan,ind_start(i):ind_end(i))); %  % these are de-trended as per Nils Olav's suggestion
                    press_rms_avg(chan, i)= (mean(temp.^2))^.5;
                    time(i) = ((mean([ind_start(i) ind_end(i)])))./(par.Fs);
                end
                
                % select the peak region of each signal for use in the PSD
                t = (1:length(press(chan,:)))/par.Fs;
                if strcmp(treatment, 'GOS_upscaled')
                    psd_i = t>37 & t<=47;
                elseif strcmp(treatment, 'GOS_unfiltered')
                    psd_i = t>20 & t<=30;
                elseif strcmp(treatment, 'JH_unfiltered')
                    psd_i = t>21 & t<=31;
                else
                    error('Unknown treatment')
                end

                [psd(chan).psd, psd(chan).f] = pwelch(press(chan,psd_i).*1e6, 1000, 500, 1000, par.Fs);
            end
            clear data

            spl = 20*log10(press_rms_avg/par.p_ref);
            
            % Plot of SPL as a function of depth for both arrays
            figure(1)
            clf
            
            % should use an average around the max, not just the max
            peak_spl = max(spl, [], 2);
            plot(peak_spl(2:8), array.depth(2:8),'LineWidth', 2, 'color',[.6 .6 .6])
            hold on
            plot(peak_spl(9:16), array.depth(9:16),'LineWidth', 2, 'color', 'k')

            xlabel('SPL (dB re 1\muPa)')
            ylabel('Depth (m)')
            set(gca,'Ydir','reverse')
            legend('Far','Close')
            
            title(treatment, 'Interpreter', 'none')
            if par.export_plot
                print('-dpng', '-r200', [hdr, '_SPLwithDepth.png'])
            end
            
            % Plot of PSD at selected frequencies as a function of depth
            % for both arrays
            figure(2)
            clf

            % should use frequency bands, not selected freqs
            for j = 1:16
                [~, psd_i] = min(abs(psd(j).f - 150));
                psd_at_150(j) = psd(j).psd(psd_i);
                
                [~, psd_i] = min(abs(psd(j).f - 350));
                psd_at_350(j) = psd(j).psd(psd_i);

            end

            plot(10*log10(psd_at_150(2:8)), array.depth(2:8),   'LineStyle', '-', 'LineWidth', 2, 'color', [.6 .6 .6])
            hold on
            plot(10*log10(psd_at_150(9:16)), array.depth(9:16), 'LineStyle', '-', 'LineWidth', 2, 'color', 'k')
            plot(10*log10(psd_at_350(2:8)), array.depth(2:8),   'LineStyle', ':', 'LineWidth', 2, 'color', [.6 .6 .6])
            plot(10*log10(psd_at_350(9:16)), array.depth(9:16), 'LineStyle', ':', 'LineWidth', 2, 'color', 'k')
            
            xlabel('PSD (dB re 1\muPa^2Hz^{-1})')
            ylabel('Depth(m)')
            set(gca,'Ydir','reverse')
            legend('Far, 150Hz','Close, 150Hz', 'Far 350Hz','Close 350Hz')
            
            title(treatment, 'Interpreter', 'none')
            if par.export_plot
                print('-dpng', '-r200', [hdr, '_SPDwithDepth.png'])
            end
        end
    end
end
