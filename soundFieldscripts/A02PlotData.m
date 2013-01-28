function A02PlotData()

    % A function to produce a broad overview plot of the hydrophone data

    dataDir = 'q:\collpen\data\201112 Austevoll\Hydrophones\converted_data_files';
    d = dir(fullfile(dataDir, '*.mat'));

    do_spectrogram_plots = false;
    
    for i = 1:length(d)
        disp(d(i).name)
        load(fullfile(dataDir, d(i).name))
        
        %         for j = 1:size(data.values, 2)
        %             subplot(2,8,j)
        %             time = (1:1:size(data.values,1)) / data.sample_rate(j) ;
        %             plot(time, data.values(:,j))
        %             title(['Channel ' num2str(j)])
        %         end
       
        
       if do_spectrogram_plots
           for j = 1:size(data.values, 2)
               label = [d(i).name(1:end-4) ' ch' num2str(j, '%0.2d')];
               plot_spectrogram(data.values(:,j), label)
               disp(['Doing: ' label])
               print('-dpng', '-r300', fullfile('..', 'results', ...
                   ['A02PlotData ' label]))
           end
       end
       
       odds = {'T07.mat' 'T15.mat' 'T16.mat' 'T17.mat' 'T18.mat' 'T19.mat' ...
           'T18failureLigthbulb.mat' 'T19failureLigthbulb.mat' 'T20failureLigthbulb.mat'};
       
       if strcmp(d(i).name, 'Calibration not white channel.mat')
           caldata = data.values(:,5);
           cal_factor = calc_cal_factor(caldata);
           disp(['Cal factor = ' num2str(cal_factor) ' Pa/V'])
       elseif strcmp(d(i).name, 'Calibration white channel.mat')
           caldata = data.values(:,13);
           cal_factor = calc_cal_factor(caldata);
           disp(['Cal factor = ' num2str(cal_factor) ' Pa/V'])
       elseif sum(strcmp(d(i).name, odds)) > 0
           %
       else
           label = [d(i).name(1:end-4) ' ch01'];
           plot_spectrogram(data.values(:,1), label)
           % User to choose the 200 Hz sound (bounds in time, [s])
           x = ginput(1);
           x = x(1);
           % estimate and draw the other sounds
           %  sounds are 9 seconds long and the gap is 6.1s
           gap = 6.2; % [s]
           duration = 9; % [s]
           clear signals
           signals(1) = struct('name', '20Hz', 'freq', 20, 'start_time', ...
               x-3*(gap+duration), 'stop_time', x-3*gap-2*duration);
           signals(2) = struct('name', '50Hz',  'freq', 50, 'start_time', ...
               x-2*(gap+duration), 'stop_time', x-2*gap-duration);
           signals(3) = struct('name', '100Hz',  'freq', 100, 'start_time', ...
               x-gap-duration, 'stop_time', x-gap);
           signals(4) = struct('name', '200Hz', 'freq', 200, 'start_time', x, ...
               'stop_time', x+duration);
           signals(5) = struct('name', '300Hz', 'freq', 300, ...
               'start_time', x+gap+duration, 'stop_time', x+gap+2*duration);
           signals(6) = struct('name', '500Hz', 'freq', 500, ...
               'start_time', x+2*(gap+duration), 'stop_time', x+2*(gap+duration)+9.6);
           signals(7) = struct('name', '700Hz', 'freq', 700, ...
               'start_time', signals(6).stop_time+gap+.6, 'stop_time', ...
               signals(6).stop_time+gap+0.6+duration);
           signals(8) = struct('name', '900Hz', 'freq', 891, ...
               'start_time', signals(7).stop_time+gap+0.6, 'stop_time', ...
               signals(7).stop_time+gap+duration+0.6);
           signals(9) = struct('name', '1000Hz', 'freq', 989, ...
               'start_time', signals(8).stop_time+gap, 'stop_time', ...
               signals(8).stop_time+gap+duration+0.6);
           signals(10) = struct('name', '4000Hz', 'freq', 3961, ...
               'start_time', signals(9).stop_time+gap, ...
               'stop_time', signals(9).stop_time+gap+duration);
           
           hold on
           for j = 1:length(signals)
               x = [signals(j).start_time signals(j).stop_time ...
                   signals(j).stop_time signals(j).start_time signals(j).start_time];
               y = [signals(j).freq-25 signals(j).freq-25 ...
                   signals(j).freq+25 signals(j).freq+25 signals(j).freq-25];
               plot(x,y/1000,'b')
           end
           pause(3)
           % store for later use
           experiments(i) = struct('file', d(i).name, 'signal', signals);
           save(fullfile('..', 'results', 'A02PlotData_experiments'), 'experiments')
       end
       
    end
end

function plot_spectrogram(signal, label)
    [S,F,T,P]=spectrogram(double(signal), 1000, 100, 1024, 10000);
    clf
    imagesc(T,F/1000,10*log10(P))
    set(gca, 'YDir','normal')
    %set(gca,'YLim', [0 1050])
    xlabel('Time (s)')
    ylabel('Frequency (kHz)')
    title(label)
end

function cal_factor = calc_cal_factor(signal)
    % cal_factor has units of Pa/V, converting from voltage [V] recorded
    % by the system to pressure at the hydrophone [Pa].
    
    
    preamp_sens_cal = 3.16e-3; % pre-amp sensitivity during calibration [V/Pa]
    preamp_sens_exp = 10.0e-3; % pre-amp sensitivity during experiments [V/Pa]
    % preamp was set to 3.16mV/Pa, + 26 dB (x 19.9526) of signal gain
    % The calibrator SPL is 154.25 dB re 1uPa
    expected_pressure_at_hydrophone = 1e-6 * 10^(154.25/20); % [Pa]
    expected_voltage_from_hydrophone = expected_pressure_at_hydrophone * preamp_sens_cal; % [V]
    expected_recorded_voltage = expected_voltage_from_hydrophone * 10^(26/20); % [V]
    
    recorded_voltage = rms(signal); % [V]
    cal_factor = expected_recorded_voltage / recorded_voltage / preamp_sens_cal / 10^(26/20); % [Pa/V]
    % But, during the experiments the preamp gain was 10mV/Pa, not the
    % 3.16mV/Pa used during the calibration, so adjust for that
    cal_factor = cal_factor * preamp_sens_cal/preamp_sens_exp;
    
    % so to get SPL, multiply the rms of the recorded signal by
    % cal_factor/1e-6, take log10 and multiply by 20 to give dB re 1 uPa
    
end