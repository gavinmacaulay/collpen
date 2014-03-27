function cp_ProcessArraydata(blockn,block,par)

    % This is the block, subblock, treatment vector. If the vecotr is shorter,
    %
    % Parameters for picking the right data
    
    % block(blockn).subblock(subblockn).treatment(treatmentn)
    
    % Load array data, but only those files that start with the block number
    files = dir(fullfile(par.datadir,['block',num2str(blockn)],'hydrophones',[num2str(blockn) '_*.mat']));
    
    if isempty(files)
        error(['No Matlab format hydrophone files available for block ' num2str(blockn) '. Run preparation script.'])
    end
    
    % There are two hydrophone arrays, each containing 8 hydrophones.
    % Array 1 has 8 hydrophones connected to channels 1 to 8 and array 2 has
    % hydrophones connected to channels 9 to 16. The hydrophones were spaced
    % every 1 m and the topmost was 2 m deep. Channels 17 and 18 recorded data
    % from the two IMR hydrophones.
    
    array = struct('channel', 1:16, ...
        'depth', [9 8 7 6 5 4 3 2 9 8 7 6 5 4 3 2], ... % [m]
        'array', [1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2]);
    
    for f=1:length(files)
        
        file =  fullfile(par.datadir,['block',num2str(blockn)],'hydrophones',files(f).name);
        hdr = ['array_',files(f).name(1:end-4)];
        
        % What kind of subblock/treatment is this?
        [a,~] = sscanf(files(f).name(1:end-4),'%u_%u_%u');
        subblock  = a(2);
        treatment = a(3);
        
        % only interested in vessel treatments for now.
        if strcmp(block(a(1)).subblock(subblock).s_treatmenttype,'vessel')
            treatment = block(a(1)).subblock(a(2)).treatment(a(3)).t_treatmenttype;
            disp(['Processing file: ' files(f).name ...
                ' (treatment is ' treatment ')'])
            
            clear press press_rms_avg time ind_start ind_end
            
            load(file)
            
            % if data is a vector we need to choose one (or merge them). At the
            % moment we'll take the last one and display a note to this effect
            
            data_i = 1;
            if length(data) > 1
                data_i = length(data);
                disp(' The "data" structure has a length > 1. ')
                for i = 1:length(data)
                    disp(['  Row ' num2str(i) ' starts at ' ...
                        datestr(data(i).start_time(1)) ' and has ' ...
                        num2str(size(data(i).values,1)) ' samples (' ...
                        num2str(size(data(i).values,1) / data(i).sample_rate(1)) ') s.'])
                end
                disp(['   Using row ' num2str(data_i)])
            end
            
            press = zeros(16, size(data(data_i).values,1));
            
            % Sample rate can sometimes change between treatment blocks
            %data.sample_rate(1)
            Hd = makeFilter(data.sample_rate(1));
            
            for chan = 1:16
                par.Fs = data(data_i).sample_rate(chan);
                par.start_time = data(data_i).start_time(chan);
                par.avg_bin = floor(par.Fs*par.avgtime);  % average into 1/10 second  bins
                press(chan,:) = data(data_i).values(:,chan) .* par.calibration(chan);  % pressure in Pa
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
                
                % PSD
                [psd(chan).psd, psd(chan).f] = pwelch(press(chan,:).*1e6, 1000, 500, 1000, par.Fs);
            end
            clear data
            
            % Plot spectrogram
            par.figdir = fullfile(par.datadir,'figures', 'array');
            if ~exist(par.figdir, 'dir')
                mkdir(par.figdir)
                warning('figure directory not created - fixed')
            end
            
            % basic spectrogram of a representative channel
            exChan = 1;
            figure(1)
            spectrogram(double(press(exChan,:)).*1e6,par.Nwindow,par.Noverlap,par.Nfft,par.Fs,'yaxis');
            title([hdr,'_psd_chan' num2str(exChan) ': ' treatment], 'Interpreter', 'none')
            colorbar
            xlabel('Time (s)')
            if par.export_plot
                print('-dpng','-r200',fullfile(par.figdir,[hdr,'_psd_chan' num2str(exChan) '.png']))
            end
            
            % plot of pressure as a function of time
            figure(2)
            plot((1:length(press(exChan,:)))./(par.Fs), press(exChan,:))
            xlabel('Time (s)')
            ylabel('Pressure (Pa)')
            title([hdr,'_chan' num2str(exChan) '_pressure: ' treatment],'Interpreter','none')
            if par.export_plot
                print('-dpng','-r200',fullfile(par.figdir,[hdr,'_chan' num2str(exChan) '_pressure.png']))
            end
            
            % plot SPL
            figure(3)
            clf
            plot(time, 20*log10(press_rms_avg(exChan,:)./par.p_ref))
            
            xlabel('Time (s)')
            ylabel('SPL dB re 1 \mu Pa')
            title([hdr,'_SPL: ' treatment],'Interpreter','none')
            if par.export_plot
                print('-dpng','-r200',fullfile(par.figdir,[hdr,'_SPL.png']))
            end
            
            % plot of SPL for all hydrophones in array, arranged to show
            % variation with depth
            
            figure(4)
            %dd = [press_rms_avg(1:8,:) press_rms_avg(9:16,:)];
            spl = 20*log10(press_rms_avg/par.p_ref);
            dd = [press_rms_avg(1:8,:) press_rms_avg(9:16,:)];
            timeAxis = [time time(end)+time];
            
            colours = [215,48,39;244,109,67;253,174,97;254,224,139; ...
                217,239,139;166,217,106;102,189,99;26,152,80]/255;
            
            clf
            
            for i = 1:size(press_rms_avg, 1)
                if i < 9
                    plot(time, spl(i,:), 'color', colours(rem(i-1,8)+1,:))
                else
                    plot(time, spl(i,:), 'color', colours(rem(i-1,8)+1,:), 'LineWidth',2)
                end
                legend_label{i} = [num2str(array.depth(i)) ' m'];
                hold on
            end
            legend(legend_label{9:16})
            xlabel('Time (s)')
            ylabel('SPL (dB re 1 \mu Pa)')
            
            % channel 1's SPL is much lower than the rest (wasn't working
            % properly), so change the y axis to remove it
            y = ylim;
            y(1) = 100;
            set(gca,'YLim', y)
            
            %imagesc(timeAxis, array.depth(1:8), dd)
            %colorbar
            
            %waterfall(timeAxis, array.depth(1:8), dd)
            %zlabel('SPL dB re 1 \muPa')
            
            %xlabel('Time (s)')
            %ylabel('Depth (m)')
            
            title(treatment, 'Interpreter', 'none')
            if par.export_plot
                print('-dpng', '-r200', fullfile(par.figdir, [hdr, '_array.png']))
            end
            
            % PSD
            figure(5)
            clf
            legend_label = [];
            subplot1(2,1)
            for i = 1:8
                j = find(psd(i).f < 1.1e3);
                subplot1(1)
                plot(psd(i).f(j), 10*log10(psd(i).psd(j)), 'LineWidth', 2, 'color', colours(i,:))
                xlim([0 1000])
                ylim([70 115])
                legend_label{i} = [num2str(array.depth(i)) ' m'];
                hold on
                
                subplot1(2)
                j = find(psd(i).f < 1.1e3);
                plot(psd(i+8).f(j), 10*log10(psd(i+8).psd(j)), 'LineWidth', 2, 'color', colours(i,:))
                xlim([0 1000])
                ylim([70 115])
                hold on
            end
            subplot1(1)
            title(treatment, 'Interpreter', 'none')
            textLoc('Near', 'NorthWest');
            legend(legend_label)

            subplot1(2)
            textLoc('Far', 'NorthWest');
            
            if par.export_plot
                print('-dpng', '-r200', fullfile(par.figdir, [hdr, '_psd.png']))
            end            
            
        end
    end
end

function Hd = makeFilter(Fs)

    % The bandpass filter applied to the hydrophone data
    %Fs = 20000;  % Sampling Frequency
    
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
end
