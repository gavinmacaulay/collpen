function A04ProfishAnalysis
    
    %
    
    %
    
        dataDir = 'q:\collpen\data\201112 Austevoll\Hydrophones\converted_data_files';
        load(fullfile(dataDir, 'T17.mat'))
    
        chan_i = 8;
        signal = data.values(:,chan_i); 
        [S, F, T, P] = spectrogram(double(signal), 1000, 100, 1024, 10000);
        
        imagesc(T,F/1000,10*log10(P))
        
        profish_on = mean(P(:,1:2000),2);
        profish_off = mean(P(:,2800:end), 2);
        
        clf
        subplot(2,1,1)
        plot(F/1000, 10*log10(profish_on), 'LineWidth', 2)
        hold on
        plot(F/1000, 10*log10(profish_off), 'r', 'LineWidth', 2)
        xlabel('Frequency (kHz)')
        ylabel('PSD (power spectral density)')
        legend('on', 'off')
        
        subplot(2,1,2)
        plot(F, 10*log10(profish_on), 'LineWidth', 2)
        hold on
        plot(F, 10*log10(profish_off), 'r', 'LineWidth', 2)
        xlim([0 500])
        xlabel('Frequency (Hz)')
        ylabel('PSD (power spectral density)')
        legend('on', 'off')
        
        print('-dpng', '-r300', '../results/A04ProfishAnalysis_on_off_comparison')
        
        % try for particle velocity
        sig1 = data.values(1:1900000, 5);
        sig2 = data.values(1:1900000, 13);
        % calibrate
        calibration(5)  = 10.5504; % IMR hydrophones [Pa/V]
        calibration(13) = 11.346; % IMR hydrophones [Pa/V]
        sig1 = sig1 * calibration(5);
        sig2 = sig2 * calibration(13);
        
        % filter for 10 Hz
        Hd = bandpass_filter_10Hz();
        sig1f = filter(Hd.Numerator, 1, sig1);
        sig2f = filter(Hd.Numerator, 1, sig2);
        
        % particle acc.
        separation = 1.02; % [m]
        density = sw_dens(32, 10, 1);
        pres_grad = (sig1f - sig2f) / separation;
        acc = rms(pres_grad / (-density));
        disp(['Particle velocity = ' num2str(acc) ' m/s^2'])
end

