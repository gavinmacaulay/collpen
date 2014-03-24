function cp_ProcessArraydata(blockn,block,par)

% This is the block, subblock, treatment vector. If the vecotr is shorter,
%
% Parameters for picking the right data

% block(blockn).subblock(subblockn).treatment(treatmentn)
%
% %%%Note that this was changed  on 2 july to 118.816 Pa/V for block 10 and greater
% par.nexus1.cal=115.4 % Pa/volt
%
% % This is our calibration after changing the NExus
% %par.nexus2.cal= 118.816% 37.6% Pa/volt Note that this was changed  on 2 july to 118.816 Pa/V for block 10 and greater
%
% par.nexus2.cal= 37.6% 37.6% Pa/volt FOR BLOCK 9 AND LOWER , 118.816 for block 10 and higher

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
        disp(['Processing file: ' files(f).name ...
            ' (treatment is ' block(a(1)).subblock(a(2)).treatment(a(3)).t_treatmenttype ')'])
        
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
        
        for chan = 1:16
            par.Fs = data(data_i).sample_rate(chan);
            par.start_time = data(data_i).start_time(chan);
            par.avg_bin = floor(par.Fs*par.avgtime);  % average into 1/10 second  bins
            press(chan,:) = data(data_i).values(:,chan).*block(blockn).b_nexus1sens;  % XXXXXXXXXXX pressure in Pa

            % compute RMS pressure by averaging
            for i = 1:floor(length(press(chan,:))/par.avg_bin)-1
                ind_start(i)=((i-1)*(par.avg_bin))+1;
                ind_end(i)=((i)*(par.avg_bin));
                % compute rms via a homebrew function by taking rms of small section
                temp = press(chan,ind_start(i):ind_end(i)) - mean(press(chan,ind_start(i):ind_end(i))); %  % these are de-trended as per Nils Olav's suggestion
                press_rms_avg(chan, i)= (mean(temp.^2))^.5;
                time(i) = ((mean([ind_start(i) ind_end(i)])))./(par.Fs);
            end
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
        title([hdr,'_psd_chan' num2str(exChan)], 'Interpreter', 'none')
        colorbar
        xlabel('Time (s)')
        print('-dpng','-r200',fullfile(par.figdir,[hdr,'_psd_chan' num2str(exChan) '.png']))
        
        % plot of pressure as a function of time
        figure(2)
        plot((1:length(press(exChan,:)))./(par.Fs), press(exChan,:))
        xlabel('Time (s)')
        ylabel('Pressure (Pa)')
        title([hdr,'_chan' num2str(exChan) '_pressure'],'Interpreter','none')
        print('-dpng','-r200',fullfile(par.figdir,[hdr,'_chan' num2str(exChan) '_pressure.png']))
        
        % plot SPL
        figure(3)
        plot(time, 20*log10(press_rms_avg(exChan,:)./par.p_ref))

        xlabel('Time (s)')
        ylabel('SPL dB re 1 \mu Pa')
        title([hdr,'_SPL'],'Interpreter','none')
        print('-dpng','-r200',fullfile(par.figdir,[hdr,'_SPL.png']))
        
        % plot of SPL for all hydrophones in array, arranged to show
        % variation with depth
        
        
    end
end
