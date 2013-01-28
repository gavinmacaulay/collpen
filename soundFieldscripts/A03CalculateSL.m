function A03CalculateSL()
    
    %
    
    %
    
    dataDir = '..\..\callisto\AustevollExp\data\NTNUtrials\block1\hydrophones\converted_data_files';
    resultsDir = '..\..\results';
    
    p_ref = 1e-6; % [Pa]
    r_ref = 1; % [m]
    % array #1, 19.5 m from CARUSO. CARUSO is 3 m deep. Arrays start at 2 m
    % deep, with a hydrophone every 1 m.
    range = sqrt(19.5^2 + (-1:1:6).^2);
    % array #2, 75.95 m from CARUSO. CARUSO is 3 m deep. Arrays start at 2 m
    % deep, with a hydrophone every 1 m.
    range(9:16) = sqrt(75.95^2 + (-1:1:6).^2);
    % but channels 5 and 13 are not in the array (were the IMR hydrophones,
    % but their position changes with experiment, so we use an average here
    % for the moment). Also, the depth was not precisely measured, so
    % that's an estimate too.
    range(5) = sqrt(mean([82, 86.7])^2 + 4.^2);
    range(13) = range(5);
    
    % These need to go into the structure....
    calibration = ones(16,1) * 5; % NTNU hydrophones [Pa/V]
    calibration(5)  = 10.5504; % IMR hydrophones [Pa/V]
    calibration(13) = 11.346; % IMR hydrophones [Pa/V]
    
    % gives 'experiments'
    load(fullfile(resultsDir, 'A02PlotData_experiments'), 'experiments')
    
    for i = 1:length(experiments)
        
        if ~isempty(experiments(i).file)
            disp(['For ' experiments(i).file])

            % gives structure 'data'.
            load(fullfile(dataDir, experiments(i).file))

            % loop over tones
            for sig_i = [1 2 3 4 5 6 7 8 9 10]
                f_sig = experiments(i).signal(sig_i).freq; % transmitted signal freq [Hz]
                % choose the correct filter for the current frequency
                Hd = bandpass_filter(f_sig);


                for chan_i = 1:16
                    fs = data.sample_rate(chan_i); % sample freq [Hz]
                    % To make sure that our signal is 100% from
                    % the tone (and not background noise), trim the ends by 1 second.
                    data_start_i = floor((experiments(i).signal(sig_i).start_time+1) * fs);
                    data_stop_i = ceil((experiments(i).signal(sig_i).stop_time-1) * fs);

                    sig = data.values(data_start_i:data_stop_i, chan_i);
                    
                    % apply calibration. Converts from volts to Pascals
                    sig = sig * calibration(chan_i);
                    
                    % bandpass the data
                    y = filter(Hd.Numerator, 1, sig);
                    
                    % calculate SPL.
                    SPL = 20*log10(rms(y) / p_ref);
                    
                    % estimate transmission loss (assume spherical spreading and
                    % homogeneous medium). No absorption - not significant at
                    % the ranges and frequencies of interest
                    TL = 20*log10(range(chan_i)/r_ref);
                    
                    % estimate SL of sound source
                    SL = SPL + TL;
                    
                    experiments(i).signal(sig_i).SL(chan_i) = SL;
                    experiments(i).signal(sig_i).SPL(chan_i) = SPL;
                    disp(['  SL from channel ' num2str(chan_i) ' at ' ...
                        num2str(f_sig) ' Hz = ' ...
                        num2str(SL) ' dB re 1 m re 1uPa'])
                    
                    save(fullfile(resultsDir, 'A03CalculateSL_experiments'), 'experiments')
                end
            end
        end
    end
    
    
end
