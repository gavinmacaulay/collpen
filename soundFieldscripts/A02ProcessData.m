%%
% some globals. Run this cell before the ones below.
datadir = '..\..\callisto\AustevollExp\data\NTNUexp\block1\hydrophones';
resultsdir = '..\..\results';
% hydrophone number and depth below surface [m]
depths = [1 9; ...
          2 8; ...
          3 7; ...
          4 6; ...
          5 5; ...
          6 4; ...
          7 3; ...
          8 2; ...
          9 9; ...
          10 8; ...
          11 7; ...
          12 6; ...
          13 5; ...
          14 4; ...
          15 3; ...
          16 2; ...
          17 5; ...
          18 5];

path(path, '../matlabtoolbox')
      
%%
% cal_factor has units of Pa/V, converting from voltage [V] recorded
% by the system to pressure at the hydrophone [Pa].


preamp_sens_cal = [1.00e-3 3.16e-3]; % B&K pre-amp sensitivity [V/Pa], for hydrophone 1 and 2

% The calibrator SPL is 154.25 dB re 1uPa
expected_pressure_at_hydrophone = 1e-6 * 10^(154.25/20); % [Pa]
expected_voltage_from_hydrophone = expected_pressure_at_hydrophone * preamp_sens_cal; % [V]

% there is some unknown gain applied by the NTNU amplifier.
%expected_recorded_voltage = expected_voltage_from_hydrophone * 10^(??/20); % [V]

% Load in the data from the two channels with the IMR hydrophones
load(fullfile(datadir, 'cal01.mat'))
signal1 = data.values(:,17);
load(fullfile(datadir, 'cal02.mat'))
signal2 = data.values(:,18);
clear data

% pick out some data when the calibrator was running
signal(1) = rms(signal1(200000:end));
signal(2) = rms(signal2(600000:end));

cal_factor = expected_pressure_at_hydrophone*ones(size(signal)) ./ signal; % [Pa/V]
cal_factor

% so to get SPL, multiply the rms of the recorded signal by
% cal_factor * 1e6, take log10 and multiply by 20 to give dB re 1 uPa,
% thus: 20*log10(signal .* cal_factor * 1e6)

%%
% now process some data using the cal
load(fullfile(datadir, 'run15'))
sig = data.values(:,17:18);
clear data

d = [2094100 2097300; ...
    2110000 2147400; ...
    2182300 2197500; ...
    2211100 2245800; ...
    2285500 2295800; ...
    2335000 2344000; ...
    2384800 2394100; ...
    2439300 2446500; ...
    2462100 2498700; ...
    2543600 2545500; ...
    2591000 2597900];

nfft = 1024;
Fs = 10e3;
freq = [80 150 225 300 400 600 750 900 1000 1250 1500];
% make the bandpass filters
disp('Making filters')
for i = 1:length(freq)
    Hd(i) = cp_bandpass_filter(freq(i), Fs);
end
hydrophone = 1;
start_sample = [2058000 2918000 3778100 4638000 5498000 6358000];
results = [];
for st = 1:length(start_sample)
    for hydrophone = 1:2
        for i = 1:length(freq)
            start_i = start_sample(st) + 5000 + 50000*(i-1);
            stop_i = start_i + 30000;
            s = sig(start_i:stop_i, hydrophone);
            y = filter(Hd(i).Numerator, 1, s);
            spec = fft(y, nfft);
            f = Fs/2*linspace(0,1,nfft/2+1);
            
            subplot(2,1,1)
            plot(y)
            subplot(2,1,2)
            j = find(f <= 1600);
            %plot(f,abs(spec(1:nfft/2+1)))
            plot(f(j),abs(spec(j)))
            
            fj = f(j);
            specj = abs(spec(j));
            [~, ll] = max(specj);            
            spl = 20*log10(rms(y) * cal_factor(hydrophone) * 1e6);
            
            results = [results; freq(i) st hydrophone fj(ll) spl];
            disp([num2str(st) ' ' num2str(hydrophone) ' ' ...
                num2str(fj(ll)) ' ' num2str(spl)])
            %pause
        end
    end
end

R = 58.1; % [m]
TL = 20*log10(R);
clf
avg1 = [];
i = find(results(:,3) == 1);
plot(results(i,1), results(i,5) + TL,'b.')
for i = 1:length(freq)
    j = find(results(:,3) == 1 & results(:,1) == freq(i));
    avg1 = [avg1; freq(i) logmean(results(j,5))]; 
end
hold on
plot(avg1(:,1), avg1(:,2) + TL, 'b')
avg1
xlabel('Frequency (Hz)')
ylabel('SL (dB re 1\muPa at 1m)')

% the compensation filter for this response is:
compf = max(avg1(:,2)) - avg1(:,2); % [dB]
compf_limits = [min(freq) max(freq)];

% given an arbituary signal, do this to compensate
nfft = 4096;
Fs = 10e3;
y = fft(sig(:,1), nfft);
f = Fs/2*linspace(0,1,nfft/2+1);

%  interpolate the compensation function onto the fft freqs
comp = interp1(freq, compf, f, 'spline', 0);

clf
plot(f, comp(1:nfft/2+1))

i = find(results(:,3) == 2);
plot(results(i,1), results(i,5),'r.')
avg2 = [];
for i = 1:length(freq)
    j = find(results(:,3) == 2 & results(:,1) == freq(i));
    avg2 = [avg2; freq(i) logmean(results(j,5))]; 
end
hold on
plot(avg2(:,1), avg2(:,2), 'r')
avg2

%% Process and plot some of the array data

% run number and start sample number of the played sounds
% runs 1, 2, and 3 all had clipping on the inner array
% runs 
% 11 is a noise recording. The start sample number is hence arbituary.
% 12 to 14 were low freq trials with higher power
% 16 had feeding occuring (pellet noise)

run_info = [4 307105 % poor SNR at lowest freq
            5 369919 % poor SNR at lowest freq
            6 300040 % good SNR at lowest freq
            7 307111 % changed amp gain (and kept change for later runs)
            8 682716 
            9 322629
           10 425310 
           11 100000
           15 2058200]; % only 6 repeats, not 15 like the rest

% and reformat into something more useful
runs = run_info(:,1)';
start_sample = run_info(:,2);

Fs = 10e3;
nfft = 1024;
freq = [80 150 225 300 400 600 750 900 1000 1250 1500];
% calibration factors for each hydrophone (18 in total)
cal_factor = [115.3534*ones(1,8)/10 115.3534*ones(1,8)/10 115.3534 37.6232];
    
disp('Making filters')
clear Hd
for i = 1:length(freq)
    Hd(i) = cp_bandpass_filter(freq(i), Fs);
end

for run_i = 1:length(runs)

    run_name = ['run' num2str(runs(run_i), '%02d')];
    
    disp(['Processing ' run_name])
    
    load(fullfile(datadir, run_name))

    % extract data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this code only extracts one of the repeats. It should be changed to
    % extract all of them and take an average value. This will allow the
    % plotting of the variability (with a nice shaded region:))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    spl = [];
    for hydrophone = 1:18
        sig = data.values(:,hydrophone);
        for i = 1:length(freq)
            start_i = start_sample(run_i) + 5000 + 50000*(i-1);
            stop_i = start_i + 30000;
            s = sig(start_i:stop_i);
            % Filter for the frequency we are expected to see
            s = filter(Hd(i).Numerator, 1, s);

            %plot(s)
            %pause
            %spec = fft(s, nfft);
            %f = Fs/2*linspace(0,1,nfft/2+1);
            
            spl(i,hydrophone) = 20*log10(rms(s) * cal_factor(hydrophone) * 1e6);
        end
    end
    
    % plot of frequency verses SPL for each hydrophone
    clf
    symbol = {'k' 'k' 'k' 'k' 'k' 'k' 'k' 'k' ...
        'b' 'b' 'b' 'b' 'b' 'b' 'b' 'b' ...
        'r' 'g'};
    for hydrophone = 1:size(spl, 2)
        h = plot(freq, spl(:,hydrophone), symbol{hydrophone}, 'LineWidth', 2);
        if hydrophone == 1
            hh(1) = h;
        elseif hydrophone == 9
            hh(2) = h;
        elseif hydrophone == 17
            hh(3) = h;
        else
            hh(4) = h;
        end
        hold on
    end
    xlabel('Frequency (Hz)')
    ylabel('received SPL (dB re 1 \muPa)')
    if runs(run_i) ~= 11
        ylim([90 150])
    end
    hold off
    legend(hh, 'Channels 1-8', 'Channels 9-16', 'Channel 17', 'Channel 18')
    grid on
    
    print('-dpng', '-r300', fullfile(resultsdir, ['A02Processdata_f_v_SPL_' run_name]))
    
    % plot of depth verses SPL for each frequency
    clf
    colours = [166, 206, 227; 31, 120, 180; 178, 223, 138; 51, 160, 44; 251, 154, 153; 227, 26, 28; 253, 191, 111; 255, 127, 0; 202, 178, 214; 106, 61, 154; 255, 255, 153]/255;
    for f = 1:size(spl, 1) % loop over frequencies
        h(f) = plot(depths(1:8,2), spl(f,1:8), '-', 'color', colours(f,:), 'LineWidth', 2);
        hold on
        plot(depths(9:16,2), spl(f,9:16), '*-', 'color', colours(f,:), 'LineWidth', 2)
    end
    xlabel('Depth (m)')
    ylabel('received SPL (dB re 1 \muPa)')
    if runs(run_i) ~= 11
        ylim([90 150])
    end
    hold off
    
    for i = 1:size(spl, 1)
        legend_text{i} = [num2str(freq(i)) ' Hz'];
    end
    legend(h, legend_text)
    grid on
    
    print('-dpng', '-r300', fullfile(resultsdir, ['A02Processdata_d_v_SPL_' run_name]))

end




