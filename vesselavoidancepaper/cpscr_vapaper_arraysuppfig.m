%% Process hydrophone array data and create the supplemental figure that 
% shows PSD as a function of depth and frequency

% Data directory
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = '.\matlabtoolbox';

% Parameters and metadata
file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

% Parameters for the spectrogram
par.avgtime = 0.1;%s
par.p_ref = 1e-6; % [Pa]
par.ws=10000*60*4;%4 min of 8khz sampling
par.Nwindow=256*4;
par.Nfft=256*8;
par.Noverlap=fix(par.Nwindow/2);

% Example data for vessel avoidance and killer whale play back (for
% plotting a nice conceptual figure for the papers)
par.exampleVA = [21,1];
par.exampleKW = [21,4];
par.CPA = 38;

par.calibration = [ones(1,16)*11.53 1 1]; % [Pa/V]

par.export_plot = true;
blockn = block(28).b_block;

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

%%
for f=1:length(files)
    
    file =  fullfile(par.datadir,['block',num2str(blockn)],'hydrophones',files(f).name);
    hdr = ['array_',files(f).name(1:end-4)];
    
    % What kind of subblock/treatment is this?
    [a,~] = sscanf(files(f).name(1:end-4),'%u_%u_%u');
    subblock  = a(2);
    
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

        % The bandpass filter applied to the hydrophone data
        %Fs = 20000;  % Sampling Frequency
        
        Fpass = 1000;            % Passband Frequency
        Fstop = 1100;            % Stopband Frequency
        Dpass = 0.057501127785;  % Passband Ripple
        Dstop = 0.0001;          % Stopband Attenuation
        dens  = 20;              % Density Factor
        
        % Calculate the order from the parameters using FIRPMORD.

        
        for chan = 1:16
            Fs = data(data_i).sample_rate(chan);

            [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
        
            % Calculate the coefficients using the FIRPM function.
            b  = firpm(N, Fo, Ao, W, {dens});
            Hd = dfilt.dffir(b);
            
            % and a notch filter to remove some mains hum
            notch = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1', 49, ...
                'HalfPowerFrequency2', 51, 'DesignMethod', 'butter', 'SampleRate', Fs);
            
            press(chan,:) = data(data_i).values(:,chan) .* par.calibration(chan);  % pressure in Pa
            % lowpass filter the data
            press(chan,:) = filter(Hd, press(chan,:));
            % apply the notch filter
            press(chan,:) = filter(notch, press(chan,:));
            
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

            t = (1:length(press(chan,:)))/Fs;
            psd_i = t >= (peak-3) & t <= (peak+3); % 6 seconds around the peak
            
            % PSD
            [psd(chan).psd, psd(chan).f] = pwelch(press(chan,psd_i).*1e6, 1000, 500, 1000, Fs);
            
            % For one of the treatments, extract noise data for a plot...
            if strcmp(treatment, 'JH_unfiltered')
                t = (1:length(press(chan,:)))/Fs;
                psd_i = t >= 36 & t <= 45; % after playback ends
            
                [noise(chan).psd, noise(chan).f] = pwelch(press(chan,psd_i).*1e6, 1000, 500, 1000, Fs);                
            end
        end
        clear data
        
       
        % PSD
        figure(1)
        clf
        legend_label = [];
        colours = [215,48,39;244,109,67;253,174,97;254,224,139; ...
            217,239,139;166,217,106;102,189,99;26,152,80]/255;

        subplot1(2,1)
        for i = 1:8
            j = find(psd(i).f < 1.1e3);
            subplot1(1)
            plot(psd(i).f(j), 10*log10(psd(i).psd(j)), 'LineWidth', 2, 'color', colours(i,:))
            xlim([0 1000])
            %ylim([65 120])
            legend_label{i} = [num2str(array.depth(i)) ' m'];
            hold on
            
            subplot1(2)
            j = find(psd(i).f < 1.1e3);
            plot(psd(i+8).f(j), 10*log10(psd(i+8).psd(j)), 'LineWidth', 2, 'color', colours(i,:))
            xlim([0 1000])
            %ylim([64 120])
            hold on
        end
        subplot1(1)
        title(treatment, 'Interpreter', 'none')
        textLoc('Near', 'NorthWest');
        legend(legend_label)
        ylabel('PSD (dB re 1\muPa^2Hz^{-1})')
        
        subplot1(2)
        textLoc('Far', 'NorthWest');
        xlabel('Frequency (kHz)')
        ylabel('PSD (dB re 1\muPa^2Hz^{-1})')
        
        % data to export to make figures in R
        DAT(subplotPosition).psd = psd.psd;
        DAT(subplotPosition).f = psd.f;
        DAT(subplotPosition).depths = array.depth;
        DAT(subplotPosition).array = array.array;
        DAT(subplotPosition).treatment = treatment;
        
        if par.export_plot
            print('-dpng', '-r200', [treatment, '_psd.png'])
        end
        
    end
    save SuppFigX DAT    
end

% plot the noise data
figure(1)
clf
legend_label = [];
subplot1(2,1)
for i = 1:8
    j = find(noise(i).f < 1.1e3);
    subplot1(1)
    plot(noise(i).f(j), 10*log10(noise(i).psd(j)), 'LineWidth', 2, 'color', colours(i,:))
    xlim([0 1000])
    %ylim([65 120])
    legend_label{i} = [num2str(array.depth(i)) ' m'];
    hold on
    
    subplot1(2)
    j = find(noise(i).f < 1.1e3);
    plot(noise(i+8).f(j), 10*log10(noise(i+8).psd(j)), 'LineWidth', 2, 'color', colours(i,:))
    xlim([0 1000])
    %ylim([64 120])
    hold on
end
subplot1(1)
title('Noise')
textLoc('Near', 'NorthWest');
legend(legend_label)
ylabel('PSD (dB re 1\muPa^2Hz^{-1})')

subplot1(2)
textLoc('Far', 'NorthWest');
xlabel('Frequency (kHz)')
ylabel('PSD (dB re 1\muPa^2Hz^{-1})')

if par.export_plot
    print('-dpng', '-r200', 'noise_psd.png')
end
        
% Add in the noise data
DAT(subplotPosition+1).psd = noise.psd;
DAT(subplotPosition+1).f = noise.f;
DAT(subplotPosition+1).depths = array.depth;
DAT(subplotPosition+1).array = array.array;
DAT(subplotPosition+1).treatment = 'noise';

save SuppFigX DAT